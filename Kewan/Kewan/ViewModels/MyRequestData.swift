import SwiftUI
import Foundation

class MyRequestData: ObservableObject {
//    let jsonURL = "https://www.myjsons.com/v/895d3638"
    @Published var funEnglishModeList: [MyModel] = []
    @Published var isUsingLocalData = false
    private let jsonURL: String
    
    init(url: String? = nil) {
            self.jsonURL = url ?? "https://www.myjsons.com/v/895d3638"
        }
    
    func requestData() {
        print("开始请求网络数据...")
                guard let url = URL(string: jsonURL) else {
                    print("❌ URL无效")
                    useLocalData()
                    return
                }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ 网络错误: \(error.localizedDescription)")
                self?.useLocalData()
                return
            }
            
            guard let data = data else {
                print("❌ 没有接收到数据")
                self?.useLocalData()
                return
            }
            
            // 打印接收到的 JSON 数据
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 接收到的JSON数据: \(jsonString)")
            }
            
            do {
                let decodedData = try JSONDecoder().decode([MyModel].self, from: data)
                DispatchQueue.main.async {
                    print("✅ 成功加载 \(decodedData.count) 个单词")
                    self?.funEnglishModeList = decodedData
                    self?.isUsingLocalData = false
                }
            } catch {
                print("❌ 解码错误: \(error)")
                self?.useLocalData()
            }
        }.resume()
    }
    
    func getRandomFiveWords() -> [MyModel] {
        print("当前单词列表数量: \(funEnglishModeList.count)")  // 添加调试输出
        let words = Array(funEnglishModeList.shuffled().prefix(5))
        print("随机选择的5个单词: \(words.map { $0.english })")  // 添加调试输出
        return words
    }
    
    private func useLocalData() {
        print("⚠️ 使用本地数据")  // 添加调试输出
        DispatchQueue.main.async {
            self.funEnglishModeList = [
                MyModel(id: "1", english: "Hello", chinese: "你好"),
                MyModel(id: "2", english: "World", chinese: "世界"),
                MyModel(id: "3", english: "Apple", chinese: "苹果"),
                MyModel(id: "4", english: "Book", chinese: "书"),
                MyModel(id: "5", english: "Cat", chinese: "猫")
            ]
            self.isUsingLocalData = true
        }
    }
}
