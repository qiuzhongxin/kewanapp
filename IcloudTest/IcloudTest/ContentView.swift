//
//  ContentView.swift
//  IcloudTest
//
//  Created by Zhongxin qiu on 2024/12/15.
//

import SwiftUI
import CloudKit

struct Note: Identifiable {
    let id = UUID()
    var title: String
    var content: String
    var date: Date
}

struct ContentView: View {
    @State private var notes: [Note] = []
    @State private var showingAddNote = false
    
    var body: some View {
        NavigationStack {
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
            .navigationTitle("我的记事本")
            .toolbar {
                Button(action: {
                    showingAddNote = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(notes: $notes)
            }
        }
    }
    
    private func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        // TODO: 同步删除到 iCloud
    }
}

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var notes: [Note]
    @State private var title = ""
    @State private var content = ""
    
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
                        let note = Note(title: title, content: content, date: Date())
                        notes.append(note)
                        // TODO: 保存到 iCloud
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
