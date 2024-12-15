import SwiftUI

struct NewNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    let onSave: (Note) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("标题", text: $title)
                TextEditor(text: $content)
                    .frame(height: 200)
            }
            .padding()
            .frame(width: 400, height: 300)
            .navigationTitle("新建记事")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let note = Note(title: title, content: content, date: Date())
                        onSave(note)
                        dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
} 