import SwiftUI
import PDFKit
import QuickLook

struct DocumentCardView: View {
    @ObservedObject var documentManager: DocumentManager
    @Binding var selectedDocument: Document?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(documentManager.filteredDocuments) { document in
                    DocumentCard(document: document) {
                        selectedDocument = document
                    }
                }
            }
            .padding()
        }
    }
}

struct DocumentCard: View {
    let document: Document
    let onTap: () -> Void
    @State private var showingDocumentViewer = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with file icon and actions
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: document.getFileTypeIcon())
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(document.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .lineLimit(2)
                            
                            Text(document.originalFileName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    // Category Badge
                    HStack(spacing: 4) {
                        Image(systemName: document.category.systemImage)
                            .font(.caption)
                        Text(document.category.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(document.category.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(document.category.color.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Access Level Badge
                    HStack(spacing: 4) {
                        Image(systemName: document.accessLevel.systemImage)
                            .font(.caption)
                        Text(document.accessLevel.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(document.accessLevel.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(document.accessLevel.color.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // Description
            if !document.description.isEmpty {
                Text(document.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // File details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label {
                        Text(document.formattedFileSize())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "externaldrive")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    if let pageCount = document.pageCount {
                        Label {
                            Text("\(pageCount) pages")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: "doc.text")
                                .foregroundColor(.green)
                        }
                    }
                }
                
                HStack {
                    Label {
                        Text(document.uploadDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    Label {
                        Text(document.uploadedBy)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "person")
                            .foregroundColor(.purple)
                    }
                }
            }
            
            // Tags
            if !document.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(document.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(.systemGray6))
                                .cornerRadius(4)
                        }
                        
                        if document.tags.count > 3 {
                            Text("+\(document.tags.count - 3)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(.systemGray5))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            // Thumbnail preview (for images)
            if let thumbnailData = document.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 100)
                    .clipped()
                    .cornerRadius(8)
            } else if document.isImage() {
                // Show placeholder for images without thumbnails
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 100)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundColor(.gray)
                            Text("Loading...")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
            
            // Version and associations
            HStack {
                if !document.version.isEmpty {
                    Label {
                        Text("v\(document.version)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "number")
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                if document.isArchived {
                    Label {
                        Text("Archived")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "archivebox")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Associated items
            if document.associatedJobId != nil || document.associatedContactId != nil {
                HStack(spacing: 12) {
                    if document.associatedJobId != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "hammer.circle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("Job")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if document.associatedContactId != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text("Contact")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            if document.isPDF() || !document.filePath.isEmpty {
                showingDocumentViewer = true
            } else {
                onTap()
            }
        }
        .fullScreenCover(isPresented: $showingDocumentViewer) {
            SimpleDocumentViewer(document: document)
        }
    }
}

struct DocumentListHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            // Name
            Text("Document Name")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Category
            Text("Category")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            // Size
            Text("Size")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .center)
            
            // Upload Date
            Text("Upload Date")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .center)
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

struct DocumentGridItem: View {
    let document: Document
    let onTap: () -> Void
    @State private var showingDocumentViewer = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Thumbnail or file icon
            if let thumbnailData = document.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else if document.isImage() {
                // Show placeholder for images without thumbnails
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("...")
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                        }
                    )
            } else {
                VStack(spacing: 4) {
                    Image(systemName: document.getFileTypeIcon())
                        .font(.system(size: 32))
                        .foregroundColor(.orange)
                    
                    Text(document.fileExtension.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
                .frame(height: 60)
            }
            
            // Document name
            Text(document.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            // Size
            Text(document.formattedFileSize())
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Category indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(document.category.color)
                .frame(height: 3)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        .onTapGesture {
            if document.isPDF() || !document.filePath.isEmpty {
                showingDocumentViewer = true
            } else {
                onTap()
            }
        }
        .fullScreenCover(isPresented: $showingDocumentViewer) {
            SimpleDocumentViewer(document: document)
        }
    }
}
// MARK: - Simple Document Viewer

struct SimpleDocumentViewer: View {
    let document: Document
    @Environment(\.dismiss) private var dismiss
    @State private var showingQuickLook = false
    @State private var documentURL: URL?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Group {
                if document.isPDF() && !document.fileData.isEmpty {
                    // Use PDFKit for PDF files
                    SimplePDFViewer(data: document.fileData)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !document.filePath.isEmpty {
                    // Use QuickLook for other file types
                    if let documentURL = documentURL {
                        SimpleQuickLookView(url: documentURL)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ProgressView("Loading document...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    // Fallback content
                    VStack(spacing: 20) {
                        Image(systemName: document.getFileTypeIcon())
                            .font(.system(size: 80))
                            .foregroundColor(.orange)
                        
                        Text(document.name)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        Text("File Type: \(document.fileExtension.uppercased())")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if !document.description.isEmpty {
                            Text(document.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Size: \(document.formattedFileSize())", systemImage: "externaldrive")
                            Label("Modified: \(document.modifiedDate.formatted(date: .abbreviated, time: .shortened))", systemImage: "calendar")
                            Label("Category: \(document.category.rawValue)", systemImage: document.category.systemImage)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray6).opacity(0.3))
                }
            }
            .navigationTitle(document.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingQuickLook = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .onAppear {
            prepareDocumentForViewing()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingQuickLook) {
            if let url = documentURL {
                SimpleShareSheet(items: [url])
            }
        }
    }
    
    private func prepareDocumentForViewing() {
        if !document.fileData.isEmpty && document.filePath.isEmpty {
            createTemporaryFile()
        } else if !document.filePath.isEmpty {
            documentURL = URL(fileURLWithPath: document.filePath)
        } else {
            errorMessage = "Document data is not available for viewing"
            showingError = true
        }
    }
    
    private func createTemporaryFile() {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileName = "\(document.id.uuidString).\(document.fileExtension)"
        let tempFileURL = tempDirectory.appendingPathComponent(tempFileName)
        
        do {
            try document.fileData.write(to: tempFileURL)
            documentURL = tempFileURL
        } catch {
            errorMessage = "Failed to create temporary file: \(error.localizedDescription)"
            showingError = true
        }
    }
}

// MARK: - Simple PDF Viewer

struct SimplePDFViewer: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor.systemBackground
        
        if let document = PDFDocument(data: data) {
            pdfView.document = document
        }
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // No updates needed
    }
}

// MARK: - Simple QuickLook View

struct SimpleQuickLookView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        var parent: SimpleQuickLookView
        
        init(_ parent: SimpleQuickLookView) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.url as QLPreviewItem
        }
    }
}

// MARK: - Simple Share Sheet

struct SimpleShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}