import SwiftUI

struct DocumentGridView: View {
    @ObservedObject var documentManager: DocumentManager
    @Binding var selectedDocument: Document?
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(documentManager.filteredDocuments) { document in
                    DocumentGridItem(document: document) {
                        selectedDocument = document
                    }
                }
            }
            .padding()
        }
    }
}