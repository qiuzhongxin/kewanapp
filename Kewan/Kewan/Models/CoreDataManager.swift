import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GameData")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    // MARK: - Game Score Methods
    
    func saveGameScore(score: Int16, level: Int16, totalTime: TimeInterval) {
        let newScore = GameScore(context: viewContext)
        newScore.id = UUID()
        newScore.score = score
        newScore.level = level
        newScore.totalTime = totalTime
        newScore.date = Date()
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving game score: \(error)")
        }
    }
    
    func fetchGameScores() -> [GameScore] {
        let request: NSFetchRequest<GameScore> = GameScore.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GameScore.date, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching game scores: \(error)")
            return []
        }
    }
    
    // MARK: - Learned Word Methods
    
    func saveLearnedWord(english: String, chinese: String) {
        let newWord = LearnedWord(context: viewContext)
        newWord.id = UUID()
        newWord.english = english
        newWord.chinese = chinese
        newWord.learningDate = Date()
        newWord.reviewCount = 1
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving learned word: \(error)")
        }
    }
    
    func fetchLearnedWords() -> [LearnedWord] {
        let request: NSFetchRequest<LearnedWord> = LearnedWord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LearnedWord.learningDate, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching learned words: \(error)")
            return []
        }
    }
    
    func updateWordReviewCount(_ word: LearnedWord) {
        word.reviewCount += 1
        
        do {
            try viewContext.save()
        } catch {
            print("Error updating review count: \(error)")
        }
    }
}
