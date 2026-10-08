import SwiftUI

// MARK: - Pantalla de inicio

struct MainMenuView: View {

    @State private var showLevels   = false
    @State private var showOptions  = false

    var body: some View {
        NavigationStack {
            ZStack {
                // ── Fondo ────────────────────────────────────────────────
                menuBackground.ignoresSafeArea()

                // ── Contenido centrado ───────────────────────────────────
                VStack(spacing: 18) {
                    Spacer()

                    // Botón JUGAR
                    JugarButton {
                        AudioManager.shared.playSound(named: "tap")
                        showLevels = true
                    }

                    // Botón OPCIONES
                    OpcionesButton {
                        AudioManager.shared.playSound(named: "tap")
                        showOptions = true
                    }

                    Spacer()
                }
            }
            .statusBar(hidden: true)
            // ── Navegar a niveles ────────────────────────────────────────
            .navigationDestination(isPresented: $showLevels) {
                LevelSelectView()
                    .navigationBarBackButtonHidden(true)
            }
            // ── Hoja de opciones ─────────────────────────────────────────
            .sheet(isPresented: $showOptions) {
                OptionsView()
            }
        }
    }

    // MARK: Fondo

    private var menuBackground: some View {
        ZStack {
            if UIImage(named: "bg_zona_vial") != nil {
                Image("bg_zona_vial")
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [Color(hex: "4B2A7B"), Color(hex: "8A3F7A"), Color(hex: "E0524F")],
                    startPoint: .top, endPoint: .bottom
                )
            }
        }
        .clipped()
    }
}

// MARK: - Botón JUGAR

private struct JugarButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if UIImage(named: "btn_jugar") != nil {
                // Si tienes el asset completo del botón úsalo directamente
                Image("btn_jugar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 4)
            } else {
                // Placeholder que imita la imagen que compartiste
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "5C3499"), Color(hex: "3B1F6A")],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(Color(hex: "D42F35"), lineWidth: 4)

                    VStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)

                        Text("JUGAR")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .italic()
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 2)
                    }
                }
                .frame(width: 180, height: 180)
                .shadow(color: .black.opacity(0.45), radius: 8, x: 0, y: 5)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Botón OPCIONES

private struct OpcionesButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if UIImage(named: "btn_opciones") != nil {
                Image("btn_opciones")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 56)
                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 3)
            } else {
                // Placeholder cápsula roja con engranaje
                HStack(spacing: 10) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20, weight: .bold))
                    Text("OPCIONES")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "D9302F"), Color(hex: "9B1F1F")],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .overlay(Capsule().strokeBorder(Color(hex: "FF6860"), lineWidth: 2))
                )
                .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 3)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Estilo de botón con efecto de escala al pulsar

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    MainMenuView()
        .previewLayout(.fixed(width: 844, height: 390))
}
