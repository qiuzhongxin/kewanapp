import CloudKit
import SwiftUI

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    private let container = CKContainer(identifier: "iCloud.com.qiuqiu.IcloudTest")
    private let database: CKDatabase
    
    @Published var isICloudAvailable = false
    
    private let fileManager = FileManager.default
    private var localStorageURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("notes.json")
    }
    
    private init() {
        self.database = container.privateCloudDatabase
        checkICloudStatus()
        
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("iCloud账号状态错误: \(error.localizedDescription)")
                    return
                }
                
                print("iCloud账号状态: \(status.rawValue)")
                switch status {
                case .available:
                    print("iCloud 可用")
                    self?.isICloudAvailable = true
                    self?.testDatabaseAccess()
                case .noAccount:
                    print("未登录 iCloud 账号")
                    self?.isICloudAvailable = false
                case .restricted:
                    print("iCloud 访问受限")
                    self?.isICloudAvailable = false
                case .couldNotDetermine:
                    print("无法确定 iCloud 状态")
                    self?.isICloudAvailable = false
                case .temporarilyUnavailable:
                    print("iCloud 暂时不可用")
                    self?.isICloudAvailable = false
                @unknown default:
                    print("未知 iCloud 状态")
                    self?.isICloudAvailable = false
                }
            }
        }
    }
    
    private func testDatabaseAccess() {
        let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
        database.fetch(withQuery: query,
                      inZoneWith: nil,
                      desiredKeys: ["title"],
                      resultsLimit: 1) { result in
            switch result {
            case .success:
                print("成功访问 CloudKit 数据库")
            case .failure(let error):
                print("访问 CloudKit 数据库失败: \(error.localizedDescription)")
                if let ckError = error as? CKError {
                    print("CloudKit错误代码: \(ckError.code)")
                }
            }
        }
    }
    
    private func checkICloudStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.isICloudAvailable = true
                default:
                    self?.isICloudAvailable = false
                }
            }
        }
    }
    
    private func saveLocally(_ notes: [Note]) {
        guard let url = localStorageURL else { return }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(notes)
            try data.write(to: url)
            print("笔记已保存到本地")
        } catch {
            print("本地保存失败: \(error.localizedDescription)")
        }
    }
    
    private func loadLocally() -> [Note]? {
        guard let url = localStorageURL else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let notes = try decoder.decode([Note].self, from: data)
            print("从本地加载了 \(notes.count) 条笔记")
            return notes
        } catch {
            print("本地加载失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveNote(_ note: Note, completion: @escaping (Error?) -> Void) {
        let record = CKRecord(recordType: "Note")
        record.setValue(note.title, forKey: "title")
        record.setValue(note.content, forKey: "content")
        record.setValue(note.date, forKey: "date")
        
        database.save(record) { [weak self] _, error in
            DispatchQueue.main.async {
                if error == nil {
                    if let notes = self?.loadLocally() {
                        var updatedNotes = notes
                        updatedNotes.append(note)
                        self?.saveLocally(updatedNotes)
                    } else {
                        self?.saveLocally([note])
                    }
                }
                completion(error)
            }
        }
    }
    
    func fetchNotes(completion: @escaping ([Note]) -> Void) {
        let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        if let localNotes = loadLocally() {
            completion(localNotes)
        }
        
        database.fetch(withQuery: query,
                      inZoneWith: nil,
                      desiredKeys: ["title", "content", "date"],
                      resultsLimit: 50) { [weak self] result in
            switch result {
            case .success(let (matchResults, _)):
                let notes = matchResults.compactMap { _, result -> Note? in
                    guard case .success(let record) = result,
                          let title = record["title"] as? String,
                          let content = record["content"] as? String,
                          let date = record["date"] as? Date else {
                        return nil
                    }
                    return Note(title: title, content: content, date: date)
                }
                DispatchQueue.main.async {
                    self?.saveLocally(notes)
                    completion(notes)
                }
            case .failure(let error):
                print("从 iCloud 获取笔记失败: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteNote(withTitle title: String) {
        let predicate = NSPredicate(format: "title == %@", title)
        let query = CKQuery(recordType: "Note", predicate: predicate)
        
        if var localNotes = loadLocally() {
            localNotes.removeAll { $0.title == title }
            saveLocally(localNotes)
        }
        
        database.fetch(withQuery: query,
                      inZoneWith: nil,
                      desiredKeys: nil,
                      resultsLimit: 1) { [weak self] result in
            switch result {
            case .success(let (matchResults, _)):
                guard let (_, matchResult) = matchResults.first,
                      case .success(let record) = matchResult else {
                    return
                }
                
                self?.database.delete(withRecordID: record.recordID) { recordID, error in
                    if let error = error {
                        print("从 iCloud 删除笔记失败: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("查找要删除的笔记失败: \(error.localizedDescription)")
            }
        }
    }
} 
