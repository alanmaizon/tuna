//
//  MercuryBead.swift
//  Tuna
//
//  Created by Alan Maizon on 21/11/2025.
//

import SwiftUI
struct MercuryBar: View {
    var progress: CGFloat   // -1 ... 0 ... +1

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let beadX = (width / 2) + (progress * (width / 2 - 18))

            ZStack {
                // Smoked-glass LED housing
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.45),
                                Color.black.opacity(0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // subtle reflective edge
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.25),
                                        Color.white.opacity(0.02)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .overlay(
                        // faint internal gloss band
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.10),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                            .padding(.horizontal, 4)
                            .padding(.vertical, 5)
                            .blendMode(.screen)
                    )
                    .shadow(color: .black.opacity(0.8), radius: 10, y: 4)
                    .frame(height: 42)

                // LED bead
                Circle()
                    .fill(abs(progress) <= 0.3 ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                    .shadow(
                        color: abs(progress) <= 0.05
                            ? Color.green.opacity(0.9)
                            : Color.red.opacity(0.9),
                        radius: 6
                    )
                    .offset(x: beadX - width / 2)
                    .animation(.easeOut(duration: 0.22), value: progress)
            }
        }
        .frame(height: 42)
        .padding(.horizontal, 40)
    }
}
