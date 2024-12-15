import SwiftUI

struct NoteDetailView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(note.title)
                .font(.title)
            Text(note.content)
                .font(.body)
            Text(note.date.formatted())
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
} 