import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    var audioPlayer: AVAudioPlayer?
    var bgMusicPlayer: AVAudioPlayer?

    func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            print("Sound file \(soundName).wav not found.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func playBackgroundMusic(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            print("Background music file \(soundName).wav not found.")
            return
        }
        
        do {
            if bgMusicPlayer == nil || bgMusicPlayer?.url != url {
                bgMusicPlayer = try AVAudioPlayer(contentsOf: url)
                bgMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
                bgMusicPlayer?.play()
            }
        } catch {
            print("Error playing background music: \(error.localizedDescription)")
        }
    }
    
    func stopBackgroundMusic() {
        bgMusicPlayer?.stop()
    }

    func isBackgroundMusicPlaying() -> Bool {
        return bgMusicPlayer?.isPlaying ?? false
    }
}






