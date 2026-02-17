//
//  FastYIN.swift
//  Tuna
//
//  Created by Alan Maizon on 19/11/2025.
//  Updated for higher accuracy on 21/11/2025.
//

import AVFoundation
import Accelerate

final class FastYIN {
    private let sr: Float
    private let maxTau: Int
    private var yin: [Float]
    private var window: [Float]
    
    /// Controls sensitivity for the absolute threshold step (typical 0.10-0.20).
    var threshold: Float = 0.15
    
    /// Lowest frequency we want to detect (Hz). Used to suggest a sensible maxTau when not provided.
    var minFreq: Float = 50.0
    
    /// How far to search around the candidate tau for a better local minimum (samples). Larger -> more robust, slower.
    var peakSearchRange: Int = 3
    
    init(sampleRate: Float, maxTau: Int? = nil) {
        self.sr = sampleRate
        // if user doesn’t provide a maxTau, pick one from minFreq (period = sr/minFreq)
        let defaultMaxTau = Int(round(sampleRate / minFreq))
        self.maxTau = maxTau ?? defaultMaxTau
        self.yin = Array(repeating: 0, count: self.maxTau)
        self.window = Array(repeating: 0, count: 0) // built on demand per buffer size
    }

    /// Compute difference function using squared distances via vDSP.
    /// data -> pointer to frame floats, n -> number of samples available in frame
    private func differenceFunction(_ data: UnsafePointer<Float>, n: Int, maxTau: Int, result: inout [Float]) {
        // Ensure result size
        if result.count < maxTau { result = Array(repeating: 0, count: maxTau) }

        // For tau = 0, sum of squared differences is 0 by definition.
        result[0] = 0

        // For each tau compute sum_{i=0..n-tau-1} (x[i] - x[i+tau])^2
        // vDSP_distancesq computes sum (x - y)^2 over a vector, so reuse it for each tau.
        for tau in 1..<maxTau {
            let length = n - tau
            if length <= 0 {
                result[tau] = 0
                continue
            }
            // vDSP_distancesq expects pointers; produce sum into a single Float
            var sum: Float = 0
            vDSP_distancesq(data, 1, data.advanced(by: tau), 1, &sum, vDSP_Length(length))
            result[tau] = sum
        }
    }
    
    /// Build a Hann window of size n (reuses allocated array)
    private func ensureWindow(size n: Int) {
        if window.count == n { return }
        window = Array(repeating: 0, count: n)
        // hann: w[n] = 0.5 * (1 - cos(2πn/(N-1)))
        let N_minus_1 = Float(n - 1)
        if N_minus_1 <= 0 { window = Array(repeating: 1, count: n); return }
        for i in 0..<n {
            let t = Float(i)
            window[i] = 0.5 * (1.0 - cosf(2.0 * .pi * t / N_minus_1))
        }
    }
    
    /// Estimate pitch (Hz) from buffer. Returns 0 if no reliable pitch found.
    func estimatePitch(buffer: AVAudioPCMBuffer) -> Float {
        guard let ptr = buffer.floatChannelData?.pointee else { return 0 }
        let n = Int(buffer.frameLength)
        if n <= 2 { return 0 }
        
        // Apply windowing to reduce leakage (copy into temp array to avoid modifying original)
        ensureWindow(size: n)
        var windowed = Array(repeating: Float(0), count: n)
        vDSP_vmul(ptr, 1, window, 1, &windowed, 1, vDSP_Length(n))
        
        // Compute difference function (yin)
        differenceFunction(windowed, n: n, maxTau: maxTau, result: &yin)
        
        // Cumulative mean normalized difference function (cmndf)
        // cmndf[0] = 1 by convention (or 0 but not used). We'll compute cmndf in-place in 'yin' to save memory.
        var runningSum: Float = 0
        // start from tau = 1
        for tau in 1..<maxTau {
            runningSum += yin[tau]
            // Avoid division by zero: if runningSum is extremely small, set cmndf to 1 (no periodicity)
            if runningSum <= Float.ulpOfOne {
                yin[tau] = 1.0
            } else {
                yin[tau] = yin[tau] * (Float(tau) / runningSum)
            }
        }
        // Ensure index 0 is set to 1.0 (unused)
        if yin.indices.contains(0) { yin[0] = 1.0 }
        
        // Absolute threshold: find first tau where cmndf < threshold and it's a local minimum
        var candidateTau: Int? = nil
        for tau in 1..<(maxTau - 1) {
            let val = yin[tau]
            if val < threshold {
                // check local minimum within a small neighborhood to avoid spurious dips
                var isLocalMin = true
                let start = max(1, tau - peakSearchRange)
                let end = min(maxTau - 1, tau + peakSearchRange)
                for k in start...end {
                    if yin[k] < val && k != tau {
                        isLocalMin = false
                        break
                    }
                }
                if isLocalMin {
                    candidateTau = tau
                    break
                }
            }
        }
        guard let tau = candidateTau else {
            // no candidate found
            return 0
        }
        
        // Parabolic interpolation (safe): fit a parabola through (tau-1, y0), (tau, y1), (tau+1, y2)
        let x0 = max(tau - 1, 0)
        let x2 = min(tau + 1, maxTau - 1)
        let y0 = yin[x0]
        let y1 = yin[tau]
        let y2 = yin[x2]
        // Denominator for quadratic interpolation (2*y1 - y0 - y2)
        let denom = (2.0 * y1 - y0 - y2)
        var betterTau = Float(tau)
        if abs(denom) > Float.ulpOfOne {
            // offset = (y2 - y0) / (2*denom)
            let offset = (y2 - y0) / (2.0 * denom)
            // Clamp offset to -0.5..+0.5 for safety (parabola should be within neighbors)
            let clamped = min(max(offset, -0.5), 0.5)
            betterTau += clamped
        }
        // Prevent non-positive tau
        if betterTau <= 0 { return 0 }
        
        // Convert to frequency
        let frequency = sr / betterTau
        // Basic sanity: reject unreasonable pitches
        if frequency.isFinite && frequency > 20 && frequency < (sr / 2) {
            return frequency
        } else {
            return 0
        }
    }
}
