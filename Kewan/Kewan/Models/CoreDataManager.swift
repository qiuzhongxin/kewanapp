import CoreData
import CloudKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "GameData")
        
        // 配置 CloudKit 同步
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.qiuzx.Kewan"
        )
        
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // 启用自动同步
        do {
            try container.initializeCloudKitSchema()
        } catch {
            print("Failed to initialize CloudKit schema: \(error)")
        }
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    // MARK: - Game Score Methods
    
    func saveGameScore(score: Int16, level: Int16, totalTime: TimeInterval, userId: String?) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 查找今天是否已有记录
        let request: NSFetchRequest<GameScore> = GameScore.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@ AND userId == %@ AND level == %d",
                                      today as NSDate,
                                      calendar.date(byAdding: .day, value: 1, to: today)! as NSDate,
                                      userId ?? "",
                                      level)
        
        do {
            let existingScores = try viewContext.fetch(request)
            if let existingScore = existingScores.first {
                // 如果今天已有记录，更新分数
                existingScore.score += score
                existingScore.totalTime += totalTime
            } else {
                // 如果今天没有记录，创建新记录
                let newScore = GameScore(context: viewContext)
                newScore.id = UUID()
                newScore.score = score
                newScore.level = level
                newScore.totalTime = totalTime
                newScore.date = Date()
                newScore.userId = userId
            }
            
            try viewContext.save()
        } catch {
            print("Error saving game score: \(error)")
        }
    }
    
    func fetchGameScores(userId: String?) -> [GameScore] {
        let request: NSFetchRequest<GameScore> = GameScore.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GameScore.date, ascending: false)]
        
        if let userId = userId {
            request.predicate = NSPredicate(format: "userId == %@", userId)
        }
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching game scores: \(error)")
            return []
        }
    }
    
    // MARK: - Learned Word Methods
    
    func saveLearnedWord(english: String, chinese: String, phonetic: String? = nil, userId: String?) {
        let newWord = LearnedWord(context: viewContext)
        newWord.id = UUID()
        newWord.english = english
        newWord.chinese = chinese
        newWord.phonetic = phonetic
        newWord.learningDate = Date()
        newWord.reviewCount = 1
        newWord.userId = userId
        
        do {
            try viewContext.save()
            // 如果没有音标，异步获取
            if phonetic == nil {
                // 在进入异步上下文前捕获必要的值
                let wordToFetch = english
                let context = viewContext
                
                Task {
                    if let phoneticText = try? await DictionaryService.shared.fetchWordPhonetic(word: wordToFetch) {
                        await MainActor.run {
                            let request: NSFetchRequest<LearnedWord> = LearnedWord.fetchRequest()
                            request.predicate = NSPredicate(format: "english == %@ AND userId == %@", wordToFetch, userId ?? "")
                            if let existingWord = try? context.fetch(request).first {
                                existingWord.phonetic = phoneticText
                                try? context.save()
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error saving learned word: \(error)")
        }
    }
    
    func fetchLearnedWords(userId: String?) -> [LearnedWord] {
        let request: NSFetchRequest<LearnedWord> = LearnedWord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LearnedWord.learningDate, ascending: false)]
        
        if let userId = userId {
            request.predicate = NSPredicate(format: "userId == %@", userId)
        }
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching learned words: \(error)")
            return []
        }
    }
    
    func updateWordReviewCount(_ word: LearnedWord) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 查找今天是否已有这个单词的记录
        let request: NSFetchRequest<LearnedWord> = LearnedWord.fetchRequest()
        request.predicate = NSPredicate(
            format: "english == %@ AND userId == %@ AND learningDate >= %@ AND learningDate < %@",
            word.english,
            word.userId ?? "",
            today as NSDate,
            calendar.date(byAdding: .day, value: 1, to: today)! as NSDate
        )
        
        do {
            let todayWords = try viewContext.fetch(request)
            
            if let existingWord = todayWords.first {
                // 如果今天已有记录，增加复习次数
                existingWord.reviewCount += 1
                print("Updated review count for today's word: \(word.english)")
            } else {
                // 如果今天没有记录，创建新记录
                let newWord = LearnedWord(context: viewContext)
                newWord.id = UUID()
                newWord.english = word.english
                newWord.chinese = word.chinese
                newWord.phonetic = word.phonetic
                newWord.learningDate = Date()
                newWord.reviewCount = 1
                newWord.userId = word.userId
                print("Created new word record for: \(word.english)")
            }
            
            try viewContext.save()
        } catch {
            print("Error updating word record: \(error)")
        }
    }
}
