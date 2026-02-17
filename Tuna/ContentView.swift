import SwiftUI

struct ContentView: View {
    @StateObject private var model = TunerModel()

    var body: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()

            VStack(spacing: 40) {
                HStack {
                    Spacer()
                    

                }
                .padding(.horizontal, 30)
                .padding(.top, 20)

                VStack(spacing: 12) {
                    TuningRuler()
                    MercuryBar(progress: CGFloat(max(-1, min(1, model.cents / 100))))
                }
                .padding(.top, 20)

                Text(model.note)
                    .font(.system(size: 96, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .shadow(color: .white.opacity(0.2), radius: 12)

                Text(String(format: "%.1f Hz", model.frequency))
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 18))
            }
            .padding(.bottom, 60)
        }
    }
}

struct TuningRuler: View {
    let marks = Array(stride(from: -50, through: 50, by: 10))

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width

            ZStack {
                ForEach(marks, id: \.self) { value in
                    let x = width * CGFloat(value + 50) / 100

                    Rectangle()
                        .fill(Color.white.opacity(value == 0 ? 0.9 : 0.6))
                        .frame(width: 2,
                               height: value == 0 ? 22 : 14)
                        .position(x: x, y: geo.size.height / 2)
                }
            }
        }
        .frame(height: 26)
        .padding(.horizontal, 30)
    }
}
