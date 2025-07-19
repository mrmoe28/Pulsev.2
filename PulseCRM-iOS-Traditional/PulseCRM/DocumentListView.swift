import SwiftUI

struct DocumentListView: View {
    @ObservedObject var documentManager: DocumentManager
    @Binding var selectedDocument: Document?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(documentManager.filteredDocuments) { document in
                    DocumentListRow(document: document)
                        .onTapGesture {
                            selectedDocument = document
                        }
                }
            }
            .padding()
        }
    }
}

struct DocumentListRow: View {
    let document: Document
    
    var body: some View {
        HStack(spacing: 12) {
            // File type icon
            Image(systemName: document.getFileTypeIcon())
                .font(.title2)
                .foregroundColor(document.category.color)
                .frame(width: 32, height: 32)
            
            // Document info
            VStack(alignment: .leading, spacing: 4) {
                Text(document.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(document.originalFileName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Text(document.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(document.category.color.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text(document.formattedFileSize())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(document.uploadDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Access level indicator
            Image(systemName: document.accessLevel.systemImage)
                .font(.caption)
                .foregroundColor(document.accessLevel.color)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}