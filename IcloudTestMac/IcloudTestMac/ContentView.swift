import SwiftUI
import NoteKit

struct ContentView: View {
    @StateObject private var cloudKit = CloudKitManager.shared
    @State private var notes: [Note] = []
    @State private var selectedNote: Note?
    @State private var isCreatingNewNote = false
    
    var body: some View {
        NavigationSplitView {
            List(notes, selection: $selectedNote) { note in
                VStack(alignment: .leading) {
                    Text(note.title)
                        .font(.headline)
                    Text(note.date.formatted())
                        .font(.caption)
                }
            }
            .navigationTitle("记事本")
            .toolbar {
                Button(action: {
                    isCreatingNewNote = true
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        } detail: {
            if let note = selectedNote {
                NoteDetailView(note: note)
            } else {
                Text("选择或创建一个笔记")
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $isCreatingNewNote) {
            NewNoteView { note in
                notes.append(note)
                selectedNote = note
            }
        }
        .onAppear {
            loadNotes()
        }
    }
    
    private func loadNotes() {
        cloudKit.fetchNotes { fetchedNotes in
            notes = fetchedNotes
        }
    }
} 