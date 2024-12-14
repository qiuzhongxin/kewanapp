import CloudKit
import SwiftUI

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    private let container = CKContainer.default()
    private let database: CKDatabase
    
    @Published var isICloudAvailable = false
    
    private init() {
        self.database = container.privateCloudDatabase
        checkICloudStatus()
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
    
    func saveNote(_ note: Note) {
        let record = CKRecord(recordType: "Note")
        record.setValue(note.title, forKey: "title")
        record.setValue(note.content, forKey: "content")
        record.setValue(note.date, forKey: "date")
        
        database.save(record) { record, error in
            if let error = error {
                print("Error saving note: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchNotes(completion: @escaping ([Note]) -> Void) {
        let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        database.fetch(withQuery: query,
                      inZoneWith: nil,
                      desiredKeys: ["title", "content", "date"],
                      resultsLimit: 50) { result in
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
                    completion(notes)
                }
            case .failure(let error):
                print("Error fetching notes: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteNote(withTitle title: String) {
        let predicate = NSPredicate(format: "title == %@", title)
        let query = CKQuery(recordType: "Note", predicate: predicate)
        
        database.fetch(withQuery: query,
                      inZoneWith: nil,
                      desiredKeys: nil,
                      resultsLimit: 1) { result in
            switch result {
            case .success(let (matchResults, _)):
                guard let (_, matchResult) = matchResults.first,
                      case .success(let record) = matchResult else {
                    return
                }
                
                self.database.delete(withRecordID: record.recordID) { recordID, error in
                    if let error = error {
                        print("Error deleting note: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error finding note to delete: \(error.localizedDescription)")
            }
        }
    }
} 