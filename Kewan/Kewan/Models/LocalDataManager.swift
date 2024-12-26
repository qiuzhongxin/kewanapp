import Foundation

class LocalDataManager {
    static let shared = LocalDataManager()
    private var localWords: [MyModel] = []
    
    private init() {
        loadLocalData()
    }
    
    private func loadLocalData() {
        if let url = Bundle.main.url(forResource: "MyJsons", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            do {
                localWords = try JSONDecoder().decode([MyModel].self, from: data)
            } catch {
                print("Error decoding local data: \(error)")
            }
        }

    }
    
    func getRandomFiveWords() -> [MyModel] {
        guard !localWords.isEmpty else { return [] }
        
        var words = localWords
        var result: [MyModel] = []
        
        for _ in 0..<min(5, words.count) {
            let randomIndex = Int.random(in: 0..<words.count)
            result.append(words.remove(at: randomIndex))
        }
        
        return result
    }
} 