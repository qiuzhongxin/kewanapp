import AVFoundation

class AudioViewModel: ObservableObject {
    private var popPlayer: AVAudioPlayer?    // 气泡破裂音效
    private var guguPlayer: AVAudioPlayer?   // 配对成功音效
    private var goodPlayer: AVAudioPlayer?   // 完成音效
    private let synthesizer = AVSpeechSynthesizer()
    private let audioSession = AVAudioSession.sharedInstance()
    
    init() {
        setupAudio()
        // 只设置混音类别，不激活会话，不降低其他音频音量
        do {
            try audioSession.setCategory(.playback, mode: .default, options: .mixWithOthers)
        } catch {
            print("Error setting audio session category: \(error.localizedDescription)")
        }
    }
    
    // 初始化音频
    private func setupAudio() {
        // 设置点击音效
        if let popURL = Bundle.main.url(forResource: "gugu", withExtension: "mp3") {
            do {
                popPlayer = try AVAudioPlayer(contentsOf: popURL)
                popPlayer?.prepareToPlay()
            } catch {
                print("Error loading pop sound: \(error.localizedDescription)")
            }
        }
        
        // 设置配对成功音效
        if let guguURL = Bundle.main.url(forResource: "gugugu", withExtension: "mp3") {
            do {
                guguPlayer = try AVAudioPlayer(contentsOf: guguURL)
                guguPlayer?.prepareToPlay()
            } catch {
                print("Error loading gugu sound: \(error.localizedDescription)")
            }
        }
        
        // 设置完成音效
        if let goodURL = Bundle.main.url(forResource: "good", withExtension: "mp3") {
            do {
                goodPlayer = try AVAudioPlayer(contentsOf: goodURL)
                goodPlayer?.prepareToPlay()
            } catch {
                print("Error loading good sound: \(error.localizedDescription)")
            }
        }
    }
    
    // 播放英语单词
    func playEnglishWord(_ word: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4  // 降低语速
        utterance.volume = 1.0  // 保持正常音量
        utterance.pitchMultiplier = 1.2 // 调整音高
        
        synthesizer.speak(utterance)
    }
    
    // 播放点击音效
    func playPopSound() {
        popPlayer?.volume = 1.0
        popPlayer?.currentTime = 0
        popPlayer?.play()
    }
    
    // 播放配对成功音效
    func playMatchSound() {
        guguPlayer?.volume = 1.0
        guguPlayer?.currentTime = 0
        guguPlayer?.play()
    }
    
    // 播放完成音效
    func playGoodSound() {
        goodPlayer?.volume = 1.0  // 保持正常音量
        goodPlayer?.currentTime = 0
        goodPlayer?.play()
    }
    
    // 清理音频会话
    func cleanup() {
        synthesizer.stopSpeaking(at: .immediate)
        popPlayer?.stop()
        guguPlayer?.stop()
        goodPlayer?.stop()
    }
    
    deinit {
        cleanup()
    }
}
