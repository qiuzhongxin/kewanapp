//
//  ScoreView.swift
//  Kewan
//
//  Created by Zhongxin qiu on 2024/11/30.
//

import SwiftUI
import CoreData

struct ScoreView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // 获取所有游戏分数
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GameScore.date, ascending: false)],
        animation: .default)
    private var gameScores: FetchedResults<GameScore>
    
    // 获取所有学习的单词
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LearnedWord.learningDate, ascending: false)],
        animation: .default)
    private var learnedWords: FetchedResults<LearnedWord>
    
    // 分组展示的学习记录
    private var groupedWords: [(date: Date, words: [LearnedWord], isExpanded: Bool)] {
        let grouped = Dictionary(grouping: Array(learnedWords)) { word in
            Calendar.current.startOfDay(for: word.learningDate)
        }
        return grouped.map { (date: $0.key, words: $0.value, isExpanded: false) }
            .sorted { $0.date > $1.date }
    }
    
    @State private var expandedDates: Set<Date> = []
    
    var body: some View {
        NavigationView {
            List {
                // 总分数统计
                Section(header: Text("游戏分数统计")) {
                    let totalScore = Double(gameScores.reduce(0) { $0 + Int($1.score) }) / 10.0
                    let easyScores = gameScores.filter { $0.level == 0 }
                    let hardScores = gameScores.filter { $0.level == 1 }
                    
                    HStack {
                        Text("总分")
                        Spacer()
                        Text(String(format: "%.1f", totalScore))
                            .foregroundColor(.orange)
                            .bold()
                    }
                    
                    HStack {
                        Text("我很简单")
                        Spacer()
                        Text(String(format: "%.1f", Double(easyScores.reduce(0) { $0 + Int($1.score) }) / 10.0))
                            .foregroundColor(.blue)
                            .bold()
                    }
                    
                    HStack {
                        Text("我超难的")
                        Spacer()
                        Text(String(format: "%.1f", Double(hardScores.reduce(0) { $0 + Int($1.score) }) / 10.0))
                            .foregroundColor(.purple)
                            .bold()
                    }
                }
                
                // 单词学习统计
                Section(header: Text("单词学习统计")) {
                    let totalWords = learnedWords.count
                    let totalReviews = learnedWords.reduce(0) { $0 + Int($1.reviewCount) }
                    let avgReviews = totalWords > 0 ? Double(totalReviews) / Double(totalWords) : 0
                    
                    HStack {
                        Text("已学单词")
                        Spacer()
                        Text("\(totalWords)")
                            .foregroundColor(.green)
                            .bold()
                    }
                    
                    HStack {
                        Text("复习次数")
                        Spacer()
                        Text("\(totalReviews)")
                            .foregroundColor(.blue)
                            .bold()
                    }
                    
                    HStack {
                        Text("平均复习")
                        Spacer()
                        Text(String(format: "%.1f", avgReviews))
                            .foregroundColor(.orange)
                            .bold()
                    }
                }
                
                // 按日期分组显示学习记录
                Section(header: Text("学习记录")) {
                    ForEach(groupedWords, id: \.date) { group in
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: { expandedDates.contains(group.date) },
                                set: { isExpanded in
                                    if isExpanded {
                                        expandedDates.insert(group.date)
                                    } else {
                                        expandedDates.remove(group.date)
                                    }
                                }
                            )
                        ) {
                            // 单词列表
                            ForEach(group.words, id: \.id) { word in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(word.english)
                                            .font(.system(size: 16, weight: .medium))
                                        Spacer()
                                        Text("复习: \(word.reviewCount)")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    Text(word.chinese)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                        } label: {
                            HStack {
                                Text(formatDate(group.date))
                                    .font(.headline)
                                Spacer()
                                Text("\(group.words.count) 个单词")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("学习记录")
            .listStyle(InsetGroupedListStyle())
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        
        if Calendar.current.isDateInToday(date) {
            return "今天"
        } else if Calendar.current.isDateInYesterday(date) {
            return "昨天"
        } else {
            formatter.dateFormat = "M月d日"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    let context = CoreDataManager.shared.viewContext
    return ScoreView()
        .environment(\.managedObjectContext, context)
}
