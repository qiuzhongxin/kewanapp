import SwiftUI

struct Level1: View {
    @ObservedObject var gameVM: GameViewModel
    @StateObject private var audioVM = AudioViewModel()
    @Environment(\.dismiss) var dismiss
    @Binding var showGameView: Bool 
    @StateObject private var settings = AppSettings.shared
    
    // 保存初始选择的单词
    @State private var initialWords: [MyModel] = []
    
    // 气泡位置状态
    @State private var bubblePositions: [String: CGPoint] = [:]
    @State private var bubbleColors: [String: Color] = [:]
    @State private var bubbleSizes: [String: CGFloat] = [:]
    @State private var bubbleVelocities: [String: CGPoint] = [:]
    @State private var animationTimer: Timer?
    @State private var particles: [BurstParticle] = []
    
    //动画效果
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.0
    
    let colors: [Color] = [.blue.opacity(0.8), .green, .orange, .purple, .pink, .mint,.cyan,.red.opacity(0.4)]
    
    // 添加一个 StateObject 来管理数据
    @StateObject private var requestData = MyRequestData()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景色
                settings.color.opacity(settings.backgroundOpacity).ignoresSafeArea()
                
                // 顶部信息栏
                VStack {
                    HStack {
                        Button(action: {
                            cleanup()
                            dismiss()
                        }) {
                            //返回按钮
//                            Image(systemName: "chevron.left")
//                                .font(.title2)
                        }
                        Spacer()
//                        Text("Level: \(gameVM.currentLevel)")
//                            .font(.title2)
//                        Spacer()
                        Text("Score: \(String(format: "%.1f", gameVM.score))")
                            .font(.title2)
                    }
                    .padding()
                    
                    Spacer()
                }
                
                // 粒子效果
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .opacity(particle.opacity)
                        .scaleEffect(particle.scale)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(particle.position)
                }
                
                // 气泡
                ForEach(gameVM.currentWords) { word in
                    let enKey = word.id + "_en"
                    let cnKey = word.id + "_cn"
                    
                    // 英文气泡
                    if let position = bubblePositions[enKey] {
                        LevelBubbleView(
                            word: word.english,
                            color: bubbleColors[enKey] ?? colors.randomElement()!,
                            position: position,
                            bubbleId: enKey,
                            size: bubbleSizes[enKey] ?? 150,
                            gameVM: gameVM,
                            audioVM: audioVM
                        )
                    }

                    // 中文气泡
                    if let position = bubblePositions[cnKey] {
                        LevelBubbleView(
                            word: word.chinese,
                            color: bubbleColors[cnKey] ?? colors.randomElement()!,
                            position: position,
                            bubbleId: cnKey,
                            size: bubbleSizes[cnKey] ?? 150,
                            gameVM: gameVM,
                            audioVM: audioVM
                        )
                    }
                }
                
                // 添加完成动画层
                if gameVM.isShowingCompletionAnimation {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    VStack {
                        Spacer()
                        
                         .opacity(opacity)
                       
                        Spacer()
                        
                        if gameVM.showContinueOptions {
                            HStack {
                                Button(action: {
                                    cleanup()
                                    // 清除保存的单词
                                    initialWords.removeAll()
                                    dismiss()
                                }) {
                                    Text("返回主菜单")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(width: 160)
                                        .cornerRadius(10)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    if gameVM.isGameCompleted {
                                        print("点击重新游戏按钮")
                                        // 重置游戏状态
                                        stopAnimation()
                                        bubblePositions.removeAll()
                                        bubbleColors.removeAll()
                                        bubbleSizes.removeAll()
                                        bubbleVelocities.removeAll()
                                        particles.removeAll()
                                        
                                        // 重置游戏状态
                                        gameVM.currentLevel = 1
                                        gameVM.isGameCompleted = false
                                        gameVM.isListeningMode = false
                                        gameVM.isShowingCompletionAnimation = false
                                        gameVM.showContinueOptions = false
                                        
                                        // 使用保存的初始单词
                                        print("重新使用保存的单词：\(initialWords.map { $0.english }.joined(separator: ", "))")
                                        gameVM.currentWords = initialWords
                                        
                                        // 重新初始化游戏
                                        initializeBubbles()
                                        startAnimation()
                                    } else {
                                        print("点击继续游戏按钮")
                                        gameVM.continueToListeningMode()
                                    }
                                }) {
                                    Text(gameVM.isGameCompleted ? "重新游戏" : "继续游戏")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(width: 160)
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 50)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
        }
        
        .onChange(of: gameVM.matchedPair) { newValue in
            if let pair = newValue {
                handleMatchEffect(firstId: pair.firstId, secondId: pair.secondId)
            }
        }
        
        .onChange(of: gameVM.isShowingCompletionAnimation) { newValue in
            if newValue {
                playCompletionAnimation()
            }
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        cleanupAndDismiss()
                    }
                }
        )
        .onAppear {
            print("Level1 onAppear")
            if initialWords.isEmpty {
                // 首次加载游戏，保存初始单词
                print("Level1: 首次加载游戏数据")
                requestData.requestData()
                gameVM.currentLevel = 1
                gameVM.startNewGame(level: 1)
                initialWords = gameVM.currentWords
                print("首次保存初始单词：\(initialWords.map { $0.english }.joined(separator: ", "))")
            } else {
                // 已有保存的单词，直接使用
                print("Level1: 使用保存的初始单词")
                gameVM.currentLevel = 1
                gameVM.currentWords = initialWords
                print("使用保存的单词：\(initialWords.map { $0.english }.joined(separator: ", "))")
            }
            setupGame()
        }
        .onDisappear {
            cleanup()
        }
    }
    
    // 生成随机位置
    private func randomPosition(in geometry: GeometryProxy) -> CGPoint {
        CGPoint(
            x: CGFloat.random(in: 50...(geometry.size.width - 50)),
            y: CGFloat.random(in: 100...(geometry.size.height - 100))
        )
    }
    
    // 初始化气泡
    private func initializeBubbles() {
        bubblePositions.removeAll()
        bubbleColors.removeAll()
        bubbleSizes.removeAll()
        bubbleVelocities.removeAll()
        particles.removeAll()
        
        let screenBounds = UIScreen.main.bounds
        
        for word in gameVM.currentWords {
            let enKey = word.id + "_en"
            let cnKey = word.id + "_cn"
            
            // 设置随机颜色
            var availableColors = colors
            let englishColorIndex = Int.random(in: 0..<availableColors.count)
            let englishColor = availableColors.remove(at: englishColorIndex)
            bubbleColors[enKey] = englishColor
            
            let chineseColorIndex = Int.random(in: 0..<availableColors.count)
            let chineseColor = availableColors[chineseColorIndex]
            bubbleColors[cnKey] = chineseColor
            
            // 设置随机大小
            bubbleSizes[enKey] = CGFloat.random(in: 100...150)
            bubbleSizes[cnKey] = CGFloat.random(in: 100...150)
            
            // 设置初始位置
            bubblePositions[enKey] = CGPoint(
                x: CGFloat.random(in: 50...(screenBounds.width - 50)),
                y: CGFloat.random(in: 100...(screenBounds.height - 100))
            )
            bubblePositions[cnKey] = CGPoint(
                x: CGFloat.random(in: 50...(screenBounds.width - 50)),
                y: CGFloat.random(in: 100...(screenBounds.height - 100))
            )
            
            // 设置初始速度
            let randomAngle = Double.random(in: 0...2 * .pi)
            let speed = Double.random(in: 5...20)
            
            bubbleVelocities[enKey] = CGPoint(
                x: cos(randomAngle) * speed,
                y: sin(randomAngle) * speed
            )
            bubbleVelocities[cnKey] = CGPoint(
                x: cos(randomAngle) * speed,
                y: sin(randomAngle) * speed
            )
        }
    }
    
    // 创建破裂效果
    private func createBurstEffect(at position: CGPoint, color: Color) {
        // 主要粒子
        for _ in 0..<40 {
            let angle = Double.random(in: 0...2 * .pi)
            let speed = CGFloat.random(in: 3...10)
            let velocity = CGPoint(
                x: CGFloat(Darwin.cos(angle)) * speed,
                y: CGFloat(Darwin.sin(angle)) * speed
            )
            let particle = BurstParticle(
                position: position,
                velocity: velocity,
                color: color,
                size: CGFloat.random(in: 5...15),
                opacity: 1.0,
                scale: 1.0,
                rotation: Double.random(in: 0...360)
            )
            particles.append(particle)
        }
        
        // 添加小型点缀粒子
        for _ in 0..<30 {
            let angle = Double.random(in: 0...2 * .pi)
            let speed = CGFloat.random(in: 2...8)
            let velocity = CGPoint(
                x: CGFloat(Darwin.cos(angle)) * speed,
                y: CGFloat(Darwin.sin(angle)) * speed
            )
            let particle = BurstParticle(
                position: position,
                velocity: velocity,
                color: color.opacity(0.6),
                size: CGFloat.random(in: 2...8),
                opacity: 0.8,
                scale: 1.0,
                rotation: Double.random(in: 0...360)
            )
            particles.append(particle)
        }
    }
    
    // 更新粒子
    private func updateParticles() {
        for index in (0..<particles.count).reversed() {
            var particle = particles[index]
            
            // 更新位置
            particle.position.x += particle.velocity.x * 0.7
            particle.position.y += particle.velocity.y * 0.7
            
            // 添加重力效果
            particle.velocity.y += 0.1
            
            // 更新旋转
            particle.rotation += 3
            
            // 更新缩放和透明度 - 加快衰减速度
            particle.scale = max(0, particle.scale - 0.02)  // 从0.005改为0.02
            particle.opacity = max(0, particle.opacity - 0.02)  // 从0.005改为0.02
            
            if particle.opacity <= 0 {
                particles.remove(at: index)
            } else {
                particles[index] = particle
            }
        }
    }
    
    // 处理匹配效果
    private func handleMatchEffect(firstId: String, secondId: String) {
        if let firstPosition = bubblePositions[firstId],
           let secondPosition = bubblePositions[secondId],
           let firstColor = bubbleColors[firstId],
           let secondColor = bubbleColors[secondId] {
            
            createBurstEffect(at: firstPosition, color: firstColor)
            createBurstEffect(at: secondPosition, color: secondColor)
            
            // 使用配对成功音效
            audioVM.playMatchSound()
        }
    }
    
    // 开始动画
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            for word in gameVM.currentWords {
                let enKey = word.id + "_en"
                let cnKey = word.id + "_cn"
                
                updateBubble(key: enKey)
                updateBubble(key: cnKey)
            }
            updateParticles()
        }
    }
    
    // 更新单个气泡
    private func updateBubble(key: String) {
        guard var position = bubblePositions[key],
              var velocity = bubbleVelocities[key],
              !gameVM.isBubbleSelected(key) else { return }
        
        position.x += velocity.x * 0.016
        position.y += velocity.y * 0.016
        
        let screenBounds = UIScreen.main.bounds
        let margin: CGFloat = 50
        
        if position.x < margin {
            position.x = margin
            velocity.x = abs(velocity.x) * 0.8
        } else if position.x > screenBounds.width - margin {
            position.x = screenBounds.width - margin
            velocity.x = -abs(velocity.x) * 0.8
        }
        
        if position.y < margin {
            position.y = margin
            velocity.y = abs(velocity.y) * 0.8
        } else if position.y > screenBounds.height - margin {
            position.y = screenBounds.height - margin
            velocity.y = -abs(velocity.y) * 0.8
        }
        
        // 减小机扰动
        velocity.x += CGFloat.random(in: -1...1)  // 原来是 -10...10
        velocity.y += CGFloat.random(in: -1...1)  // 原来是 -10...10
        
        // 降低最大速度
        let maxSpeed: CGFloat = 90  // 原来是 200
        let currentSpeed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
        if currentSpeed > maxSpeed {
            velocity.x = velocity.x / currentSpeed * maxSpeed
            velocity.y = velocity.y / currentSpeed * maxSpeed
        }
        
        withAnimation(.linear(duration: 0.016)) {
            bubblePositions[key] = position
            bubbleVelocities[key] = velocity
        }
    }
    
    // 停止动画
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    // 设置游戏
    private func setupGame() {
        // 只初始化气泡和动画
        initializeBubbles()
        startAnimation()
    }
    
    // 清资源
    private func cleanup() {
        stopAnimation()
        bubblePositions.removeAll()
        bubbleColors.removeAll()
        bubbleSizes.removeAll()
        bubbleVelocities.removeAll()
        particles.removeAll()
        gameVM.cleanupAll()
    }
    
    // 清理并返回
    private func cleanupAndDismiss() {
        cleanup()
        dismiss()
    }
    
    // 添加播放完成动画的方法
    private func playCompletionAnimation() {
        audioVM.playGoodSound()
        
        // 创建多组烟花
        for _ in 0...8 {
            let screenBounds = UIScreen.main.bounds
            let position = CGPoint(
                x: CGFloat.random(in: screenBounds.width * 0.2...screenBounds.width * 0.8),
                y: CGFloat.random(in: screenBounds.height * 0.2...screenBounds.height * 0.8)
            )
            createBurstEffect(at: position, color: colors.randomElement()!)
        }
        
        withAnimation(.easeOut(duration: 1.5)) {
            opacity = 1
            scale = 1.5
        }
    }
    
    // 开始新游戏
    private func startNewGame() {
        // 清理所有粒子
        particles.removeAll()
        
        // 重置游戏状态
        gameVM.startNewGame(level: 1)
        initializeBubbles()
        startAnimation()
    }
    
}

#Preview {
    NavigationView {
        Level1(gameVM: {
            let vm = GameViewModel()
            vm.currentWords = LocalDataManager.shared.getRandomFiveWords()
            return vm
        }(),
                     showGameView: .constant(true))
    }
}
