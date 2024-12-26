import SwiftUI
import Foundation

class MyRequestData: ObservableObject {
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
            
            print("📦 接收到网络数据: \(data.count) bytes")
            
            do {
                let decodedData = try JSONDecoder().decode([MyModel].self, from: data)
                DispatchQueue.main.async {
                    print("✅ 成功加载 \(decodedData.count) 个单词")
                    self?.funEnglishModeList = decodedData
                    self?.isUsingLocalData = false
                }
            } catch {
                print("❌ 解码错误: \(error.localizedDescription)")
                self?.useLocalData()
            }
        }.resume()
    }
    
    func getRandomFiveWords() -> [MyModel] {
        print("当前单词列表数量: \(funEnglishModeList.count)")
        let words = Array(funEnglishModeList.shuffled().prefix(5))
        print("已选择 5 个随机单词")
        return words
    }
    
    private func useLocalData() {
        print("⚠️ 使用本地数据")
        DispatchQueue.main.async {
            self.funEnglishModeList = LocalDataManager.shared.getRandomFiveWords()
            self.isUsingLocalData = true
        }
    }
}
