//
//  TunerModel.swift
//

import Foundation
import AVFoundation
import Accelerate
import Combine
final class TunerModel: ObservableObject {
    @Published var note: String = "—"
    @Published var cents: Double = 0
    @Published var frequency: Double = 0
    @Published var showPermissionAlert = false
    @Published private var smoothedCents: Double = 0.0
    private let smoothingFactor: Double = 0.5 // Adjust this value as needed
    private var engine: AVAudioEngine?
    private var link: CADisplayLink?

    init() {
        requestMic()
        start()
    }

    deinit {
        stop()
    }

    func requestMic() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    self?.showPermissionAlert = !granted
                    if granted {
                        self?.start()
                    }
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    self?.showPermissionAlert = !granted
                    if granted {
                        self?.start()
                    }
                }
            }
        }
    }

    private func start() {
        guard engine == nil else { return }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setPreferredIOBufferDuration(0.005)              // 5 ms hardware buffer
            try session.setCategory(.playAndRecord, mode: .measurement, options: [])
            try session.setActive(true)
        } catch { print("session \(error)"); return }

        let eng = AVAudioEngine()
        let node = eng.inputNode
        let hwFormat = node.outputFormat(forBus: 0)                      // 48 kHz / 1 ch
        let wantedBuf = AVAudioFrameCount(hwFormat.sampleRate / 18.75)   // 256 samples @48 kHz
        let tuner = FastYIN(sampleRate: Float(hwFormat.sampleRate))

        node.installTap(onBus: 0, bufferSize: wantedBuf, format: hwFormat) { buffer, _ in
            let freq = tuner.estimatePitch(buffer: buffer)
            if freq.isFinite && freq > 20 && freq < 5_000 {
                DispatchQueue.main.async {
                    self.updateUI(freq: Double(freq))
                }
            }
        }

        do {
            try eng.start()
        } catch { print("engine \(error)") }

        engine = eng

        let desiredInterval = 0.1 // Adjust this value as needed
        link = CADisplayLink(target: self, selector: #selector(dummySelector))
        link?.preferredFrameRateRange = CAFrameRateRange(minimum: Float(1 / desiredInterval), maximum: Float(1 / desiredInterval), preferred: Float(1 / desiredInterval))
        link?.add(to: .main, forMode: .default)
    }

    @objc private func dummySelector() {
        // No-op, only needed to keep the CADisplayLink alive
    }

    private func stop() {
        link?.invalidate(); link = nil
        engine?.stop()
        engine?.inputNode.removeTap(onBus: 0)
        engine = nil

        DispatchQueue.main.async {
            self.note = "—"; self.cents = 0; self.frequency = 0
        }
    }

    private func updateUI(freq: Double) {
        let c0 = 16.3515978312874
        let halfSteps = 12 * log2(freq / c0)
        let rounded = halfSteps.rounded()
        let centsOff = (halfSteps - rounded) * 100

        smoothedCents += (centsOff - smoothedCents) * smoothingFactor
        frequency = freq
        cents = smoothedCents
        note = noteName(pitchClass: Int(rounded) % 12)
    }

    private func noteName(pitchClass: Int) -> String {
        ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"][pitchClass]
    }
}

infix operator %%
private extension Int {
    static func %% (_ lhs: Int, _ rhs: Int) -> Int {
        (lhs % rhs + rhs) % rhs
    }
}

