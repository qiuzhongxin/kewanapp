//import SwiftUI
//import CoreData
//
//struct WordDetailView: View {
//    let word: String
//    @Environment(\.managedObjectContext) private var viewContext
//    @State private var learnedWord: LearnedWord?
//    
//    var body: some View {
//        List {
//            if let learnedWord = learnedWord {
//                Section(header: Text("基本信息")) {
//                    HStack {
//                        Text("英文")
//                        Spacer()
//                        Text(learnedWord.english)
//                            .foregroundColor(.blue)
//                    }
//                    
//                    HStack {
//                        Text("中文")
//                        Spacer()
//                        Text(learnedWord.chinese)
//                            .foregroundColor(.blue)
//                    }
//                    
//                    HStack {
//                        Text("学习日期")
//                        Spacer()
//                        Text(formatDate(learnedWord.learningDate))
//                            .foregroundColor(.gray)
//                    }
//                    
//                    HStack {
//                        Text("复习次数")
//                        Spacer()
//                        Text("\(learnedWord.reviewCount)")
//                            .foregroundColor(.orange)
//                    }
//                }
//            } else {
//                Text("未找到单词详情")
//                    .foregroundColor(.gray)
//            }
//        }
//        .onAppear {
//            loadWordDetails()
//        }
//    }
//    
//    private func loadWordDetails() {
//        let request: NSFetchRequest<LearnedWord> = LearnedWord.fetchRequest()
//        request.predicate = NSPredicate(format: "english == %@", word)
//        request.fetchLimit = 1
//        
//        do {
//            let results = try viewContext.fetch(request)
//            self.learnedWord = results.first
//        } catch {
//            print("Error fetching word details: \(error)")
//        }
//    }
//    
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "zh_CN")
//        formatter.dateFormat = "yyyy年M月d日 HH:mm"
//        return formatter.string(from: date)
//    }
//}
//
//#Preview {
//    let context = CoreDataManager.shared.viewContext
//    return WordDetailView(word: "example")
//        .environment(\.managedObjectContext, context)
//} 
