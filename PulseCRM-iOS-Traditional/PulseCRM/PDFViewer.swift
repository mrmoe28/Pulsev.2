import SwiftUI
import PDFKit
import QuickLook

// MARK: - PDF Viewer using PDFKit

struct PDFViewer: UIViewRepresentable {
    let pdfData: Data?
    let pdfURL: URL?
    @Binding var currentPage: Int?
    @Binding var totalPages: Int?
    
    init(data: Data, currentPage: Binding<Int?> = .constant(nil), totalPages: Binding<Int?> = .constant(nil)) {
        self.pdfData = data
        self.pdfURL = nil
        self._currentPage = currentPage
        self._totalPages = totalPages
    }
    
    init(url: URL, currentPage: Binding<Int?> = .constant(nil), totalPages: Binding<Int?> = .constant(nil)) {
        self.pdfData = nil
        self.pdfURL = url
        self._currentPage = currentPage
        self._totalPages = totalPages
    }
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        // Configure PDF view properties
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true, withViewOptions: nil)
        pdfView.backgroundColor = UIColor.systemBackground
        
        // Enable text selection and search
        pdfView.canBecomeFirstResponder = true
        
        // Load PDF document
        loadPDFDocument(into: pdfView)
        
        // Set up notification observer for page changes
        NotificationCenter.default.addObserver(
            forName: .PDFViewPageChanged,
            object: pdfView,
            queue: .main
        ) { _ in
            updatePageInfo(from: pdfView)
        }
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // Update page if needed
        if let currentPage = currentPage,
           let document = pdfView.document,
           currentPage < document.pageCount {
            let page = document.page(at: currentPage)
            pdfView.go(to: page!)
        }
    }
    
    private func loadPDFDocument(into pdfView: PDFView) {
        var document: PDFDocument?
        
        if let pdfData = pdfData {
            document = PDFDocument(data: pdfData)
        } else if let pdfURL = pdfURL {
            document = PDFDocument(url: pdfURL)
        }
        
        pdfView.document = document
        
        // Update total pages count
        if let document = document {
            totalPages = document.pageCount
        }
    }
    
    private func updatePageInfo(from pdfView: PDFView) {
        guard let currentPageObj = pdfView.currentPage,
              let document = pdfView.document else { return }
        
        let pageIndex = document.index(for: currentPageObj)
        currentPage = pageIndex
    }
}

// MARK: - Document Viewer with Multiple Format Support

struct DocumentViewer: View {
    let document: Document
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage: Int? = 0
    @State private var totalPages: Int? = 0
    @State private var showingQuickLook = false
    @State private var documentURL: URL?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var zoomScale: CGFloat = 1.0
    @State private var showingShare = false
    
    var body: some View {
        NavigationView {
            Group {
                if document.isPDF() && !document.fileData.isEmpty {
                    // Use PDFKit for PDF files
                    pdfViewerContent
                } else if !document.filePath.isEmpty {
                    // Use QuickLook for other file types
                    quickLookContent
                } else {
                    // Fallback content
                    fallbackContent
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
                    HStack(spacing: 15) {
                        if document.isPDF() {
                            pdfToolbarItems
                        }
                        
                        Button(action: { showingShare = true }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.orange)
                        }
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
        .sheet(isPresented: $showingShare) {
            if let url = documentURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    @ViewBuilder
    private var pdfViewerContent: some View {
        VStack(spacing: 0) {
            // PDF Page Info Header
            if let currentPage = currentPage, let totalPages = totalPages {
                HStack {
                    Text("Page \(currentPage + 1) of \(totalPages)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // Zoom controls
                    HStack(spacing: 10) {
                        Button(action: { zoomScale = max(0.5, zoomScale - 0.25) }) {
                            Image(systemName: "minus.magnifyingglass")
                                .font(.caption)
                        }
                        .disabled(zoomScale <= 0.5)
                        
                        Text("\(Int(zoomScale * 100))%")
                            .font(.caption)
                            .frame(width: 50)
                        
                        Button(action: { zoomScale = min(3.0, zoomScale + 0.25) }) {
                            Image(systemName: "plus.magnifyingglass")
                                .font(.caption)
                        }
                        .disabled(zoomScale >= 3.0)
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
            }
            
            // PDF Viewer
            PDFViewer(
                data: document.fileData,
                currentPage: $currentPage,
                totalPages: $totalPages
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private var quickLookContent: some View {
        VStack {
            if let documentURL = documentURL {
                QuickLookView(url: documentURL)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView("Loading document...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    @ViewBuilder
    private var fallbackContent: some View {
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
            
            if !document.filePath.isEmpty {
                Button("Open with External App") {
                    showingQuickLook = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6).opacity(0.3))
        .sheet(isPresented: $showingQuickLook) {
            if let url = documentURL {
                QuickLookView(url: url)
            }
        }
    }
    
    @ViewBuilder
    private var pdfToolbarItems: some View {
        HStack(spacing: 10) {
            // Page navigation for PDFs
            if let currentPage = currentPage, let totalPages = totalPages {
                Button(action: previousPage) {
                    Image(systemName: "chevron.left")
                        .font(.caption)
                }
                .disabled(currentPage <= 0)
                
                Button(action: nextPage) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .disabled(currentPage >= totalPages - 1)
            }
        }
        .foregroundColor(.orange)
    }
    
    private func prepareDocumentForViewing() {
        // If we have file data but no file path, create a temporary file
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
    
    private func previousPage() {
        if let current = currentPage, current > 0 {
            currentPage = current - 1
        }
    }
    
    private func nextPage() {
        if let current = currentPage, let total = totalPages, current < total - 1 {
            currentPage = current + 1
        }
    }
}

// MARK: - QuickLook Viewer

struct QuickLookView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        // Update if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        var parent: QuickLookView
        
        init(_ parent: QuickLookView) {
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

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

// MARK: - Document Preview Card with PDF Support

struct DocumentPreviewCard: View {
    let document: Document
    @State private var showingViewer = false
    
    var body: some View {
        Button(action: { showingViewer = true }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: document.getFileTypeIcon())
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(document.name)
                            .font(.headline)
                            .lineLimit(1)
                            .foregroundColor(.primary)
                        
                        Text(document.formattedFileSize())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if document.isPDF() {
                        Image(systemName: "eye")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                if !document.description.isEmpty {
                    Text(document.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(document.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(document.category.color.opacity(0.2))
                        .foregroundColor(document.category.color)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text(document.uploadDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showingViewer) {
            DocumentViewer(document: document)
        }
    }
}