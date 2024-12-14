import SwiftUI
import AVFoundation

// 单词按钮
struct WordButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 18))
                .foregroundColor(.black)
                .frame(width: 170, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white)
                        .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                )
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
    }
}

// Next 气泡按钮
struct NextBubbleButton: View {
    let action: () -> Void
    @State private var offset = CGSize.zero
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                isPressed = true
            }
            action()
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .blue.opacity(0.3), radius: 5)
                
                Text("Next")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            .offset(offset)
            .opacity(isPressed ? 0 : 1)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
                ) {
                    offset = CGSize(width: 0, height: -10)
                }
            }
        }
    }
}

// 主视图
struct WordLearningView: View {
    let words: [MyModel]
    @StateObject private var audioVM = AudioViewModel()
    @Binding var showGameView: Bool
    @Binding var showLearningView: Bool
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedWord: String? = nil
    @State private var nextButtonOffset = CGSize.zero
    @State private var showBurstEffect = false
    @State private var burstPosition = CGPoint.zero
    @State private var particles: [BurstParticle] = []
    @State private var burstPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            // 背景
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("请记住这些单词吧")
                    .font(.system(size: 24))
                    .padding(.top, 50)
                
                // 单词对
                ForEach(words) { word in
                    HStack(spacing: 20) {
                        // 英文按钮
                        WordButton(
                            text: word.english,
                            isSelected: selectedWord == word.english
                        ) {
                            audioVM.playEnglishWord(word.english)
                            withAnimation {
                                selectedWord = word.english
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    selectedWord = nil
                                }
                            }
                        }
                        
                        // 中文按钮
                        WordButton(
                            text: word.chinese,
                            isSelected: selectedWord == word.chinese
                        ) {
                            audioVM.playEnglishWord(word.english)
                            withAnimation {
                                selectedWord = word.chinese
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    selectedWord = nil
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Next 气泡按钮
                GeometryReader { geometry in
                                NextBubbleButton {
                                    let centerPosition = CGPoint(
                                        x: geometry.frame(in: .global).midX,
                                        y: geometry.frame(in: .global).midY
                                    )
                                    createBurstEffect(at: centerPosition)
                                    playBurstSound()
                                    
                                    // 修改这里的导航逻辑
                                    withAnimation {
                                        showGameView = true
                                        // 不要在这里设置 showLearningView = false
                                    }
                                }
                                .position(x: geometry.size.width/2, y: geometry.size.height/2)
                            }
                        }
                        .onChange(of: showGameView) { oldValue, newValue in
                            if newValue {
                                // 当游戏视图显示后，再关闭学习视图
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showLearningView = false
                                }
                            }
            }
            
            // 爆破粒子效果层
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
                    .position(particle.position)
            }
        }
        .onAppear {
            setupAudioPlayer()
        }
    }
    
    private func setupAudioPlayer() {
        if let url = Bundle.main.url(forResource: "gugugu", withExtension: "mp3") {
            do {
                burstPlayer = try AVAudioPlayer(contentsOf: url)
                burstPlayer?.prepareToPlay()
            } catch {
                print("Error loading burst sound: \(error)")
            }
        }
    }
    
    private func playBurstSound() {
        burstPlayer?.currentTime = 0
        burstPlayer?.play()
    }
    
    private func createBurstEffect(at position: CGPoint) {
        particles.removeAll()
        
        for _ in 0..<30 {
            let angle = Double.random(in: 0...2 * .pi)
            let speed = Double.random(in: 100...300)
            let particle = BurstParticle(
                position: position,
                velocity: CGPoint(
                    x: cos(angle) * speed,
                    y: sin(angle) * speed
                ),
                color: .cyan,
                createdAt: Date(),
                size: CGFloat.random(in: 3...8),
                opacity: 1.0,
                scale: 1.0,
                rotation: Double.random(in: 0...360)
            )
            particles.append(particle)
        }
        
        // 更新粒子动画
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            updateParticles()
            if particles.isEmpty {
                timer.invalidate()
            }
        }
    }
    
    private func updateParticles() {
        var updatedParticles: [BurstParticle] = []
        
        for particle in particles {
            let age = Date().timeIntervalSince(particle.createdAt)
            if age > 0.8 { continue }
            
            var updatedParticle = particle
            updatedParticle.position.x += particle.velocity.x * 0.016
            updatedParticle.position.y += particle.velocity.y * 0.016
            updatedParticle.opacity = max(0, 1 - age * 1.25)
            updatedParticle.scale = max(0, 1 - age * 0.8)
            updatedParticle.rotation += 8
            updatedParticle.velocity.y += 0.2
            
            updatedParticles.append(updatedParticle)
        }
        
        particles = updatedParticles
    }
}

#Preview {
    WordLearningView(
        words: [
            MyModel(id: "1", english: "Apple", chinese: "苹果"),
            MyModel(id: "2", english: "Banana", chinese: "香蕉"),
            MyModel(id: "3", english: "Orange", chinese: "橙子"),
            MyModel(id: "4", english: "Pear", chinese: "梨子"),
            MyModel(id: "5", english: "Grape", chinese: "葡萄")
        ],
        showGameView: .constant(false),
        showLearningView: .constant(true)
    )
}
