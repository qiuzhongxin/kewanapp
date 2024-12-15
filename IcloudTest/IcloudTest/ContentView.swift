//
//  ContentView.swift
//  IcloudTest
//
//  Created by Zhongxin qiu on 2024/12/15.
//

import SwiftUI
import CloudKit

struct Note: Identifiable, Codable {
    var id: UUID
    var title: String
    var content: String
    var date: Date
    
    init(id: UUID = UUID(), title: String, content: String, date: Date) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
    }
}

struct ContentView: View {
    @StateObject private var cloudKit = CloudKitManager.shared
    @State private var notes: [Note] = []
    @State private var showingAddNote = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack {
            Group {
                if cloudKit.isICloudAvailable {
                    List {
                        ForEach(notes) { note in
                            VStack(alignment: .leading) {
                                Text(note.title)
                                    .font(.headline)
                                Text(note.content)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(note.date.formatted())
                                    .font(.caption)
                            }
                        }
                        .onDelete(perform: deleteNote)
                    }
                    .refreshable {
                        await refreshNotes()
                    }
                } else {
                    VStack {
                        Image(systemName: "icloud.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("iCloud 未连接")
                            .font(.headline)
                        Text("请检查：")
                            .padding(.top)
                        Text("1. 是否登录 iCloud 账号")
                        Text("2. 是否启用 iCloud Drive")
                        Text("3. 是否有网络连接")
                    }
                }
            }
            .navigationTitle("我的记事本")
            .toolbar {
                if cloudKit.isICloudAvailable {
                    Button(action: {
                        showingAddNote = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(notes: $notes)
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear {
            checkICloudConnection()
        }
    }
    
    private func checkICloudConnection() {
        if cloudKit.isICloudAvailable {
            cloudKit.fetchNotes { fetchedNotes in
                notes = fetchedNotes
            }
        }
    }
    
    private func deleteNote(at offsets: IndexSet) {
        if let index = offsets.first {
            let note = notes[index]
            cloudKit.deleteNote(withTitle: note.title)
        }
        notes.remove(atOffsets: offsets)
    }
    
    private func refreshNotes() async {
        await withCheckedContinuation { continuation in
            cloudKit.fetchNotes { fetchedNotes in
                notes = fetchedNotes
                continuation.resume()
            }
        }
    }
}

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var notes: [Note]
    @State private var title = ""
    @State private var content = ""
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("标题", text: $title)
                TextEditor(text: $content)
                    .frame(height: 200)
            }
            .navigationTitle("新建记事")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveNote()
                    }
                    .disabled(title.isEmpty || content.isEmpty || isSaving)
                }
            }
            .overlay {
                if isSaving {
                    ProgressView("保存中...")
                }
            }
            .alert("错误", isPresented: $showError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveNote() {
        guard !title.isEmpty && !content.isEmpty else { return }
        
        print("开始保存笔记...")
        isSaving = true
        let note = Note(title: title, content: content, date: Date())
        
        // 先更新本地UI
        notes.append(note)
        
        // 保存到 iCloud
        CloudKitManager.shared.saveNote(note) { error in
            print("保存完成回调")
            isSaving = false
            
            if let error = error {
                print("保存失败: \(error.localizedDescription)")
                if let ckError = error as? CKError {
                    print("CloudKit错误代码: \(ckError.code)")
                    switch ckError.code {
                    case .badContainer:
                        errorMessage = "iCloud容器配置错误"
                    case .permissionFailure:
                        errorMessage = "iCloud权限错误，请检查设置"
                    case .notAuthenticated:
                        errorMessage = "iCloud未登录，请在设置中登录iCloud账号"
                    case .quotaExceeded:
                        errorMessage = "iCloud存储空间不足"
                    case .networkUnavailable:
                        errorMessage = "网络不可用"
                    case .networkFailure:
                        errorMessage = "网络连接失败"
                    case .serverResponseLost:
                        errorMessage = "服务器响应丢失，请检查网络连接"
                    case .serviceUnavailable:
                        errorMessage = "iCloud服务不可用"
                    case .zoneBusy:
                        errorMessage = "服务器繁忙，请稍后重试"
                    default:
                        errorMessage = error.localizedDescription
                    }
                    print("详细错误信息: \(ckError.localizedDescription)")
                } else {
                    errorMessage = error.localizedDescription
                }
                showError = true
                
                // 如果保存失败，从本地列表中移除
                if let index = notes.firstIndex(where: { $0.id == note.id }) {
                    notes.remove(at: index)
                }
            } else {
                print("保存成功")
                dismiss()
            }
        }
    }
}

#Preview {
    ContentView()
}
