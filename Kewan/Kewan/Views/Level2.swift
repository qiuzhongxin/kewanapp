//
//  LevelOneView.swift
//  Kewan
//
//  Created by Zhongxin qiu on 2024/11/30.
//

import SwiftUI

struct Level2: View {
    @ObservedObject var gameVM: GameViewModel
    @StateObject private var audioVM = AudioViewModel()
    @Environment(\.dismiss) var dismiss
    @Binding var showGameView: Bool 
    
    // 气泡位置状态
    @State private var bubblePositions: [String: CGPoint] = [:]
    @State private var bubbleColors: [String: Color] = [:]
    @State private var bubbleSizes: [String: CGFloat] = [:]
    @State private var bubbleVelocities: [String: CGPoint] = [:]
    @State private var animationTimer: Timer?
    @State private var particles: [BurstParticle] = []
    
    // 动画效果
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.0
    
    let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red]
    
    // 使用 Level2 的 URL 初始化 requestData
    @StateObject private var requestData = MyRequestData(url: "https://www.myjsons.com/v/820e3619")
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Color.purple.opacity(0.5).ignoresSafeArea()
                
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
                        Text("❤️‍🔥: \(String(format: "%.1f", gameVM.score))")
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
                        BubbleView(
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
                        BubbleView(
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
                
                // 完成动画层
                if gameVM.isShowingCompletionAnimation {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    VStack {
                                            
                        Spacer()
                        
                        if gameVM.showContinueOptions {
                            HStack {
                                Button(action: {
                                    cleanup()
                                    dismiss()
                                }) {
                                    Text("返回主菜单")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(width: 160)
//                                        .background(Color.gray)
                                        .cornerRadius(10)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    if gameVM.isGameCompleted {
                                        print("点击重新开始按钮")
                                        // 先重置游戏状态
                                        stopAnimation()
                                        bubblePositions.removeAll()
                                        bubbleColors.removeAll()
                                        bubbleSizes.removeAll()
                                        bubbleVelocities.removeAll()
                                        particles.removeAll()
                                        
                                        // 重新请求数据
                                        requestData.requestData()
                                        print("重新请求 CET4 数据...")
                                        
                                        // 等待新数据加载完成
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {  // 减少等待时间
                                            if !requestData.funEnglishModeList.isEmpty {
                                                print("CET4 数据重新加载完成，单词数量：\(requestData.funEnglishModeList.count)")
                                                let randomWords = requestData.getRandomFiveWords()
                                                print("CET4 选择新的单词：\(randomWords.map { $0.english })")
                                                
                                                // 在主线程更新 UI
                                                DispatchQueue.main.async {
                                                    // 设置新数据并重新开始游戏
                                                    gameVM.currentWords = randomWords
                                                    gameVM.isGameCompleted = false
                                                    gameVM.isListeningMode = false
                                                    gameVM.isShowingCompletionAnimation = false
                                                    gameVM.showContinueOptions = false
                                                    
                                                    print("准备重新初始化游戏")
                                                    setupGame()
                                                    print("游戏重新初始化完成")
                                                }
                                            }
                                        }
                                    } else {
                                        print("点击继续游戏按钮")
                                        gameVM.continueToListeningMode()
                                    }
                                }) {
                                    Text(gameVM.isGameCompleted ? "重新开始" : "继续游戏")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(width: 160)
//                                        .background(Color.blue)
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
        .onChange(of: gameVM.matchedPair) { oldValue, newValue in
            if let pair = newValue {
                handleMatchEffect(firstId: pair.firstId, secondId: pair.secondId)
            }
        }
        .onChange(of: gameVM.isShowingCompletionAnimation) { oldValue, newValue in
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
            // 直接使用 ContentView 传入的数据开始游戏
            print("Level2 开始游戏，使用单词：\(gameVM.currentWords.map { $0.english })")
            setupGame()
        }
        .onDisappear {
            cleanup()
        }
    }
}

#Preview {
    NavigationView {
        Level2(gameVM: {
            let vm = GameViewModel()
            vm.currentWords = [
                MyModel(english: "Hello", chinese: "你好"),
                MyModel(english: "World", chinese: "世界"),
                MyModel(english: "Apple", chinese: "苹果"),
                MyModel(english: "Book", chinese: "书"),
                MyModel(english: "Cat", chinese: "猫")
            ]
            return vm
        }(),
        showGameView: .constant(true))
    }
}

// 添加所有必要的方法
extension Level2 {
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
            bubbleSizes[enKey] = CGFloat.random(in: 100...200)
            bubbleSizes[cnKey] = CGFloat.random(in: 100...200)
            
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
        for _ in 0..<30 {
            let angle = Double.random(in: 0...2 * .pi)
            let speed = Double.random(in: 100...300)
            let size = CGFloat.random(in: 3...8)
            
            let particle = BurstParticle(
                position: position,
                velocity: CGPoint(
                    x: cos(angle) * speed,
                    y: sin(angle) * speed
                ),
                color: color,
                createdAt: Date(),
                size: size,
                opacity: 1.0,
                scale: 1.0,
                rotation: Double.random(in: 0...360)
            )
            particles.append(particle)
        }
    }
    
    // 更新粒子
    private func updateParticles() {
        for index in particles.indices {
            particles[index].position.x += particles[index].velocity.x * 0.016
            particles[index].position.y += particles[index].velocity.y * 0.016
            particles[index].velocity.y += 200 * 0.016
            particles[index].rotation += 180 * 0.016
            
            let age = Date().timeIntervalSince(particles[index].createdAt)
            particles[index].opacity = max(0, 1 - age * 0.4)
            particles[index].scale = max(0, 1 - age * 0.25)
        }
        
        particles.removeAll { Date().timeIntervalSince($0.createdAt) > 2.5 }
    }
    
    // 处理匹配效果
    private func handleMatchEffect(firstId: String, secondId: String) {
        if let firstPosition = bubblePositions[firstId],
           let secondPosition = bubblePositions[secondId],
           let firstColor = bubbleColors[firstId],
           let secondColor = bubbleColors[secondId] {
            
            createBurstEffect(at: firstPosition, color: firstColor)
            createBurstEffect(at: secondPosition, color: secondColor)
            
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
        
        velocity.x += CGFloat.random(in: -5...5)
        velocity.y += CGFloat.random(in: -5...5)
        
        let maxSpeed: CGFloat = 100
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
        gameVM.startNewGame(level: 1)
        initializeBubbles()
        startAnimation()
    }
    
    // 清理资源
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
    
    // 播放完成动画
    private func playCompletionAnimation() {
        audioVM.playGoodSound()
        
        let center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            if !gameVM.isShowingCompletionAnimation {
                timer.invalidate()
                return
            }
            let offsetX = CGFloat.random(in: -100...100)
            let offsetY = CGFloat.random(in: -100...100)
            let position = CGPoint(x: center.x + offsetX, y: center.y + offsetY)
            createBurstEffect(at: position, color: colors.randomElement()!)
        }
        
        withAnimation(.easeOut(duration: 1.5)) {
            opacity = 1
            scale = 1.5
        }
    }
}
