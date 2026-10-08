import SwiftUI

// MARK: - Modelo

struct Level: Identifiable {
    let id: Int                 // 1...8
    var stars: Int              // 0...3 (solo para el contador del banner)
    var isLocked: Bool = false

    /// Nombre del asset del recuadro completo: imagen_nl1 ... imagen_nl8
    var imageName: String { "imagen_nl\(id)" }

    /// Datos de ejemplo (8 niveles, empezando con 0 estrellas)
    static let sample: [Level] = (1...8).map { Level(id: $0, stars: 0) }
}

// MARK: - Colores

extension Color {
    init(hex: String) {
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(
            red: Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8) & 0xFF) / 255,
            blue: Double(int & 0xFF) / 255
        )
    }
}

enum Theme {
    static let cardTop    = Color(hex: "4A2A85")
    static let cardBottom = Color(hex: "2E1660")
    static let border     = Color(hex: "D42F35")
    static let banner     = Color(hex: "D9302F")
    static let gold       = Color(hex: "F5C531")
}

// MARK: - Recuadro de nivel
// Muestra la imagen "imagen_nlX" completa (ya trae número, íconos y estrellas).
// Si todavía no existe en Assets, dibuja un placeholder con el nombre que debes usar.

struct LevelCardView: View {
    let level: Level

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)

            ZStack {
                if UIImage(named: level.imageName) != nil {
                    Image(level.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: s, height: s)
                        .clipped()
                } else {
                    // Placeholder
                    RoundedRectangle(cornerRadius: s * 0.16)
                        .fill(LinearGradient(colors: [Theme.cardTop, Theme.cardBottom],
                                             startPoint: .top, endPoint: .bottom))
                    RoundedRectangle(cornerRadius: s * 0.16)
                        .strokeBorder(Theme.border, lineWidth: s * 0.035)
                    VStack(spacing: s * 0.04) {
                        Text("\(level.id)")
                            .font(.system(size: s * 0.4, weight: .black, design: .rounded))
                            .italic()
                            .foregroundColor(.white)
                        Text(level.imageName)
                            .font(.system(size: s * 0.09, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                }

                if level.isLocked {
                    RoundedRectangle(cornerRadius: s * 0.16)
                        .fill(Color.black.opacity(0.55))
                    Image(systemName: "lock.fill")
                        .font(.system(size: s * 0.3))
                        .foregroundColor(.white)
                }
            }
            .frame(width: s, height: s)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
            .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 3)
        }
    }
}

// MARK: - Botón de retroceso
// Asset: "icon_back" (la imagen completa del botón). Si no existe, dibuja uno de ejemplo.

struct BackButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            if UIImage(named: "icon_back") != nil {
                Image("icon_back")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 2)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 14).fill(Theme.cardTop)
                    RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.border, lineWidth: 3)
                    Image(systemName: "arrowshape.left.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Theme.border)
                }
                .frame(width: 56, height: 56)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Pantalla de niveles (horizontal)

struct LevelSelectView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var levels: [Level]
    let onSelect: (Level) -> Void

    init(levels: [Level] = Level.sample,
         onSelect: @escaping (Level) -> Void = { _ in }) {
        self._levels = State(initialValue: levels)
        self.onSelect = onSelect
    }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            GeometryReader { geo in
                content(in: geo.size)
            }
        }
        .statusBar(hidden: true)
    }

    // MARK: Contenido

    private func content(in size: CGSize) -> some View {
        let spacing: CGFloat = 12
        let backBarHeight: CGFloat = 56
        let padding: CGFloat = 12
        let columnsCount = 4
        let rowCount = max(1, Int(ceil(Double(levels.count) / Double(columnsCount))))

        let availableHeight = size.height - backBarHeight - padding * 3
        let availableWidth  = size.width * 0.90
        let cardByWidth  = (availableWidth  - spacing * CGFloat(columnsCount - 1)) / CGFloat(columnsCount)
        let cardByHeight = (availableHeight - spacing * CGFloat(rowCount    - 1)) / CGFloat(rowCount)
        let cardSize = max(60, min(cardByWidth, cardByHeight))

        let rows: [[Level]] = stride(from: 0, to: levels.count, by: columnsCount).map {
            Array(levels[$0..<min($0 + columnsCount, levels.count)])
        }

        return VStack(spacing: 0) {
            // ── Barra de retroceso (solo el botón back, sin banner) ──────
            HStack {
                BackButton { dismiss() }
                Spacer()
            }
            .frame(height: backBarHeight)

            Spacer(minLength: 0)

            // ── Cuadrícula de niveles ────────────────────────────────────
            VStack(spacing: spacing) {
                ForEach(rows.indices, id: \.self) { r in
                    HStack(spacing: spacing) {
                        ForEach(rows[r]) { level in
                            Button {
                                if !level.isLocked {
                                    AudioManager.shared.playSound(named: "tap")
                                    onSelect(level)
                                }
                            } label: {
                                LevelCardView(level: level)
                                    .frame(width: cardSize, height: cardSize)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(padding)
        .frame(width: size.width, height: size.height)
    }

    // MARK: Fondo (asset opcional: "bg_zona_vial")

    private var background: some View {
        ZStack {
            if UIImage(named: "bg_zona_vial") != nil {
                Image("bg_zona_vial")
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [Color(hex: "4B2A7B"), Color(hex: "8A3F7A"), Color(hex: "E0524F")],
                    startPoint: .top, endPoint: .bottom)
            }
        }
        .clipped()
    }
}

// MARK: - Bloqueo de orientación: solo horizontal

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .landscape
    }
}

// MARK: - Preview (horizontal)

struct LevelSelectView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LevelSelectView()
                .previewLayout(.fixed(width: 844, height: 390))
                .previewDisplayName("iPhone horizontal")

            LevelSelectView()
                .previewLayout(.fixed(width: 1194, height: 834))
                .previewDisplayName("iPad horizontal")
        }
    }
}
