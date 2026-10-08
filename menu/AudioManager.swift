import AVFoundation
import Combine
import SwiftUI

// MARK: - Gestor de audio global

@MainActor
final class AudioManager: ObservableObject {

    static let shared = AudioManager()

    // MARK: Estado publicado

    @Published var isMusicEnabled: Bool = true {
        didSet { isMusicEnabled ? resumeMusic() : pauseMusic() }
    }

    @Published var isSoundEnabled: Bool = true

    @Published var musicVolume: Float = 0.7 {
        didSet { musicPlayer?.volume = isMusicEnabled ? musicVolume : 0 }
    }

    @Published var soundVolume: Float = 1.0

    // MARK: Privado

    private var musicPlayer: AVAudioPlayer?

    private init() {
        configureSession()
        prepareMusic()
    }

    // MARK: Sesión de audio

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .ambient, mode: .default, options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioManager: error configurando sesión – \(error)")
        }
    }

    // MARK: Música de fondo
    // Coloca tu archivo de música en el bundle con el nombre "bg_music.mp3"
    // (o cambia la extensión a .wav / .m4a según corresponda).

    private func prepareMusic() {
        guard let url = Bundle.main.url(forResource: "bg_music", withExtension: "mp3") else { return }
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1   // loop infinito
            musicPlayer?.volume = musicVolume
            musicPlayer?.prepareToPlay()
            if isMusicEnabled { musicPlayer?.play() }
        } catch {
            print("AudioManager: no se pudo cargar bg_music – \(error)")
        }
    }

    func resumeMusic() {
        musicPlayer?.volume = musicVolume
        musicPlayer?.play()
    }

    func pauseMusic() {
        musicPlayer?.pause()
    }

    // MARK: Efectos de sonido
    // Llama a esto desde cualquier parte: AudioManager.shared.playSound("tap")

    func playSound(named name: String, extension ext: String = "mp3") {
        guard isSoundEnabled else { return }
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = soundVolume
            player.play()
            // AVAudioPlayer se libera al terminar porque no guardamos referencia;
            // para sonidos cortos esto es suficiente.
        } catch {
            print("AudioManager: no se pudo reproducir \(name) – \(error)")
        }
    }
}
