import SwiftUI
import UIKit
import UniformTypeIdentifiers

// MARK: - Document Models

enum DocumentError: Error {
    case saveFailed(String)
    case documentNotFound
    case fileSaveFailed(String)
    
    var localizedDescription: String {
        switch self {
        case .saveFailed(let message):
            return "Failed to save document: \(message)"
        case .documentNotFound:
            return "Document not found"
        case .fileSaveFailed(let message):
            return "Failed to save file: \(message)"
        }
    }
}

struct Document: Identifiable, Codable {
    var id = UUID()
    var name: String
    var originalFileName: String
    var description: String
    var category: DocumentCategory
    var tags: [String]
    var fileData: Data
    var fileSize: Int64
    var mimeType: String
    var fileExtension: String
    var uploadDate: Date
    var modifiedDate: Date
    var version: String
    var isArchived: Bool
    var associatedJobId: String?
    var associatedContactId: String?
    var customFields: [String: String]
    var accessLevel: AccessLevel
    var uploadedBy: String
    var checksumMD5: String
    var pageCount: Int?
    var thumbnailData: Data?
    var filePath: String
    
    init(name: String = "", originalFileName: String = "", description: String = "", category: DocumentCategory = .general, tags: [String] = [], fileData: Data = Data(), fileSize: Int64 = 0, mimeType: String = "", fileExtension: String = "", version: String = "1.0", isArchived: Bool = false, associatedJobId: String? = nil, associatedContactId: String? = nil, customFields: [String: String] = [:], accessLevel: AccessLevel = .standard, uploadedBy: String = "User", checksumMD5: String = "", pageCount: Int? = nil, thumbnailData: Data? = nil, filePath: String = "") {
        self.name = name
        self.originalFileName = originalFileName
        self.description = description
        self.category = category
        self.tags = tags
        self.fileData = fileData
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.fileExtension = fileExtension
        self.uploadDate = Date()
        self.modifiedDate = Date()
        self.version = version
        self.isArchived = isArchived
        self.associatedJobId = associatedJobId
        self.associatedContactId = associatedContactId
        self.customFields = customFields
        self.accessLevel = accessLevel
        self.uploadedBy = uploadedBy
        self.checksumMD5 = checksumMD5
        self.pageCount = pageCount
        self.thumbnailData = thumbnailData
        self.filePath = filePath
    }
}

enum DocumentCategory: String, CaseIterable, Codable {
    case general = "General"
    case contracts = "Contracts"
    case invoices = "Invoices"
    case reports = "Reports"
    case specifications = "Specifications"
    case drawings = "Drawings"
    case permits = "Permits"
    case safety = "Safety"
    case photos = "Photos"
    case correspondence = "Correspondence"
    case legal = "Legal"
    case financial = "Financial"
    
    var color: Color {
        switch self {
        case .general:
            return .blue
        case .contracts:
            return .green
        case .invoices:
            return .orange
        case .reports:
            return .purple
        case .specifications:
            return .indigo
        case .drawings:
            return .cyan
        case .permits:
            return .yellow
        case .safety:
            return .red
        case .photos:
            return .pink
        case .correspondence:
            return .teal
        case .legal:
            return .brown
        case .financial:
            return .mint
        }
    }
    
    var systemImage: String {
        switch self {
        case .general:
            return "doc.text"
        case .contracts:
            return "doc.text.fill"
        case .invoices:
            return "dollarsign.circle"
        case .reports:
            return "chart.bar.doc.horizontal"
        case .specifications:
            return "doc.plaintext"
        case .drawings:
            return "scribble.variable"
        case .permits:
            return "checkmark.seal"
        case .safety:
            return "shield.checkerboard"
        case .photos:
            return "photo.stack"
        case .correspondence:
            return "envelope.fill"
        case .legal:
            return "scale.3d"
        case .financial:
            return "banknote"
        }
    }
}

enum AccessLevel: String, CaseIterable, Codable {
    case publicAccess = "Public"
    case standard = "Standard"
    case confidential = "Confidential"
    case restricted = "Restricted"
    
    var color: Color {
        switch self {
        case .publicAccess:
            return .green
        case .standard:
            return .blue
        case .confidential:
            return .orange
        case .restricted:
            return .red
        }
    }
    
    var systemImage: String {
        switch self {
        case .publicAccess:
            return "eye"
        case .standard:
            return "lock.open"
        case .confidential:
            return "lock"
        case .restricted:
            return "lock.fill"
        }
    }
}

struct DocumentCustomField: Identifiable, Codable {
    var id = UUID()
    var name: String
    var type: DocumentFieldType
    var isRequired: Bool
    var options: [String]
    var defaultValue: String
    
    init(name: String, type: DocumentFieldType = .text, isRequired: Bool = false, options: [String] = [], defaultValue: String = "") {
        self.name = name
        self.type = type
        self.isRequired = isRequired
        self.options = options
        self.defaultValue = defaultValue
    }
}

enum DocumentFieldType: String, CaseIterable, Codable {
    case text = "Text"
    case number = "Number"
    case date = "Date"
    case dropdown = "Dropdown"
    case multiline = "Multiline"
    case checkbox = "Checkbox"
    case url = "URL"
    case email = "Email"
    
    var systemImage: String {
        switch self {
        case .text:
            return "textformat"
        case .number:
            return "number"
        case .date:
            return "calendar"
        case .dropdown:
            return "chevron.down.circle"
        case .multiline:
            return "text.alignleft"
        case .checkbox:
            return "checkmark.square"
        case .url:
            return "link"
        case .email:
            return "envelope"
        }
    }
}

enum DocumentViewType: String, CaseIterable {
    case cards = "Cards"
    case list = "List"
    case grid = "Grid"
    
    var systemImage: String {
        switch self {
        case .cards:
            return "rectangle.grid.2x2"
        case .list:
            return "list.bullet"
        case .grid:
            return "square.grid.3x3"
        }
    }
}

enum DocumentQuickFilter: String, CaseIterable {
    case images = "Images"
    case pdfs = "PDFs"
    case recent = "Recent"
}

enum DocumentSortOption: String, CaseIterable {
    case name = "Name"
    case date = "Date"
    case size = "Size"
    case category = "Category"
    case type = "Type"
    
    var systemImage: String {
        switch self {
        case .name:
            return "textformat.abc"
        case .date:
            return "calendar"
        case .size:
            return "arrow.up.arrow.down"
        case .category:
            return "folder"
        case .type:
            return "doc"
        }
    }
}

// MARK: - Document Manager

class DocumentManager: ObservableObject {
    @Published var documents: [Document] = []
    @Published var customFields: [DocumentCustomField] = []
    @Published var searchText = ""
    @Published var filterCategory: DocumentCategory?
    @Published var filterAccessLevel: AccessLevel?
    @Published var currentViewType: DocumentViewType = .cards
    @Published var sortOption: DocumentSortOption = .date
    @Published var sortAscending = false
    @Published var showArchivedDocuments = false
    @Published var quickFilter: DocumentQuickFilter? = nil
    @Published var showingBulkActions = false
    @Published var selectedDocuments: Set<UUID> = []
    @Published var fileTypeFilter: String? = nil
    
    init() {
        loadDocuments()
        setupDefaultCustomFields()
        setupSampleDocuments()
    }
    
    var filteredDocuments: [Document] {
        var result = documents
        
        // Archive filter
        if !showArchivedDocuments {
            result = result.filter { !$0.isArchived }
        }
        
        // Search filter
        if !searchText.isEmpty {
            result = result.filter { document in
                document.name.localizedCaseInsensitiveContains(searchText) ||
                document.description.localizedCaseInsensitiveContains(searchText) ||
                document.originalFileName.localizedCaseInsensitiveContains(searchText) ||
                document.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Category filter
        if let category = filterCategory {
            result = result.filter { $0.category == category }
        }
        
        // Access level filter
        if let accessLevel = filterAccessLevel {
            result = result.filter { $0.accessLevel == accessLevel }
        }
        
        // File type filter
        if let fileType = fileTypeFilter {
            result = result.filter { $0.fileExtension.lowercased() == fileType.lowercased() }
        }
        
        // Quick filter
        if let quickFilter = quickFilter {
            switch quickFilter {
            case .images:
                result = result.filter { $0.isImage() }
            case .pdfs:
                result = result.filter { $0.fileExtension.lowercased() == "pdf" }
            case .recent:
                let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                result = result.filter { $0.uploadDate >= sevenDaysAgo }
            }
        }
        
        // Sort
        result.sort { doc1, doc2 in
            let comparison: Bool
            switch sortOption {
            case .name:
                comparison = doc1.name.localizedCompare(doc2.name) == .orderedAscending
            case .date:
                comparison = doc1.uploadDate < doc2.uploadDate
            case .size:
                comparison = doc1.fileSize < doc2.fileSize
            case .category:
                comparison = doc1.category.rawValue.localizedCompare(doc2.category.rawValue) == .orderedAscending
            case .type:
                comparison = doc1.fileExtension.localizedCompare(doc2.fileExtension) == .orderedAscending
            }
            return sortAscending ? comparison : !comparison
        }
        
        return result
    }
    
    var recentDocuments: [Document] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return documents.filter { document in
            document.uploadDate >= sevenDaysAgo
        }.sorted { $0.uploadDate > $1.uploadDate }
    }
    
    var pdfCount: Int {
        documents.filter { $0.fileExtension.lowercased() == "pdf" }.count
    }
    
    var imageCount: Int {
        documents.filter { $0.isImage() }.count
    }
    
    var wordDocCount: Int {
        documents.filter { doc in
            let ext = doc.fileExtension.lowercased()
            return ext == "doc" || ext == "docx"
        }.count
    }
    
    var excelCount: Int {
        documents.filter { doc in
            let ext = doc.fileExtension.lowercased()
            return ext == "xls" || ext == "xlsx"
        }.count
    }
    
    var powerPointCount: Int {
        documents.filter { doc in
            let ext = doc.fileExtension.lowercased()
            return ext == "ppt" || ext == "pptx"
        }.count
    }
    
    var totalStorageUsed: Int64 {
        documents.reduce(0) { $0 + $1.fileSize }
    }
    
    var largestDocument: Document? {
        documents.max(by: { $0.fileSize < $1.fileSize })
    }
    
    var smallestDocument: Document? {
        documents.min(by: { $0.fileSize < $1.fileSize })
    }
    
    var averageFileSize: Int64 {
        guard !documents.isEmpty else { return 0 }
        return totalStorageUsed / Int64(documents.count)
    }
    
    func documentsOverSize(_ sizeInBytes: Int64) -> [Document] {
        documents.filter { $0.fileSize > sizeInBytes }
    }
    
    var largeDocuments: [Document] {
        documentsOverSize(10 * 1024 * 1024) // Over 10MB
    }
    
    func getStorageByCategory() -> [(category: DocumentCategory, size: Int64)] {
        let grouped = Dictionary(grouping: documents) { $0.category }
        return grouped.map { (category, docs) in
            let totalSize = docs.reduce(0) { $0 + $1.fileSize }
            return (category: category, size: totalSize)
        }.sorted { $0.size > $1.size }
    }
    
    func addDocument(_ document: Document) -> Result<Void, DocumentError> {
        do {
            documents.append(document)
            try saveDocumentsWithResult()
            // Reload documents to ensure thumbnails are regenerated if needed
            loadDocuments()
            return .success(())
        } catch {
            return .failure(.saveFailed(error.localizedDescription))
        }
    }
    
    func updateDocument(_ document: Document) -> Result<Void, DocumentError> {
        do {
            var updatedDocument = document
            updatedDocument.modifiedDate = Date()
            
            if let index = documents.firstIndex(where: { $0.id == document.id }) {
                documents[index] = updatedDocument
                try saveDocumentsWithResult()
                // Reload documents to ensure thumbnails are regenerated if needed
                loadDocuments()
                return .success(())
            } else {
                return .failure(.documentNotFound)
            }
        } catch {
            return .failure(.saveFailed(error.localizedDescription))
        }
    }
    
    func deleteDocument(_ document: Document) {
        documents.removeAll { $0.id == document.id }
        saveDocuments()
    }
    
    func archiveDocument(_ document: Document) {
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            documents[index].isArchived = true
            documents[index].modifiedDate = Date()
            saveDocuments()
        }
    }
    
    func unarchiveDocument(_ document: Document) {
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            documents[index].isArchived = false
            documents[index].modifiedDate = Date()
            saveDocuments()
        }
    }
    
    func addCustomField(_ field: DocumentCustomField) {
        customFields.append(field)
        saveCustomFields()
    }
    
    func updateCustomField(_ field: DocumentCustomField) {
        if let index = customFields.firstIndex(where: { $0.id == field.id }) {
            customFields[index] = field
            saveCustomFields()
        }
    }
    
    func deleteCustomField(_ field: DocumentCustomField) {
        customFields.removeAll { $0.id == field.id }
        saveCustomFields()
    }
    
    func getDocumentsByCategory(_ category: DocumentCategory) -> [Document] {
        return filteredDocuments.filter { $0.category == category }
    }
    
    func getDocumentsByJob(_ jobId: String) -> [Document] {
        return filteredDocuments.filter { $0.associatedJobId == jobId }
    }
    
    func getDocumentsByContact(_ contactId: String) -> [Document] {
        return filteredDocuments.filter { $0.associatedContactId == contactId }
    }
    
    func getTotalFileSize() -> Int64 {
        return documents.reduce(0) { $0 + $1.fileSize }
    }
    
    func getDocumentCount(for category: DocumentCategory) -> Int {
        return filteredDocuments.filter { $0.category == category }.count
    }
    
    private func setupSampleDocuments() {
        // Only add sample documents if no documents exist
        guard documents.isEmpty else { return }
        
        // Create sample thumbnail data (small colored rectangles)
        let sampleThumbnails = createSampleThumbnails()
        
        let sampleDocs = [
            Document(
                name: "Site Safety Plan",
                originalFileName: "safety_plan_2024.pdf",
                description: "Comprehensive safety plan for construction site operations",
                category: .safety,
                tags: ["safety", "construction", "2024"],
                fileData: "Sample PDF content".data(using: .utf8) ?? Data(),
                fileSize: 2048000, // 2MB
                mimeType: "application/pdf",
                fileExtension: "pdf",
                version: "2.1",
                accessLevel: .standard,
                uploadedBy: "Safety Manager",
                checksumMD5: "abc123",
                pageCount: 15,
                thumbnailData: sampleThumbnails[0]
            ),
            Document(
                name: "Foundation Blueprint",
                originalFileName: "foundation_blueprint_v3.jpg",
                description: "Architectural blueprint for building foundation",
                category: .drawings,
                tags: ["blueprint", "foundation", "architecture"],
                fileData: "Sample image content".data(using: .utf8) ?? Data(),
                fileSize: 5120000, // 5MB
                mimeType: "image/jpeg",
                fileExtension: "jpg",
                version: "3.0",
                accessLevel: .standard,
                uploadedBy: "Project Architect",
                checksumMD5: "def456",
                thumbnailData: sampleThumbnails[1]
            ),
            Document(
                name: "Equipment Invoice",
                originalFileName: "equipment_invoice_march.pdf",
                description: "Monthly equipment rental invoice",
                category: .invoices,
                tags: ["invoice", "equipment", "march", "2024"],
                fileData: "Sample invoice content".data(using: .utf8) ?? Data(),
                fileSize: 512000, // 512KB
                mimeType: "application/pdf",
                fileExtension: "pdf",
                version: "1.0",
                accessLevel: .confidential,
                uploadedBy: "Finance Team",
                checksumMD5: "ghi789",
                pageCount: 3,
                thumbnailData: sampleThumbnails[2]
            ),
            Document(
                name: "Progress Photo - Week 12",
                originalFileName: "progress_week12_photo1.png",
                description: "Construction progress documentation photo",
                category: .photos,
                tags: ["progress", "week12", "construction", "photo"],
                fileData: "Sample photo content".data(using: .utf8) ?? Data(),
                fileSize: 3072000, // 3MB
                mimeType: "image/png",
                fileExtension: "png",
                version: "1.0",
                accessLevel: .standard,
                uploadedBy: "Site Supervisor",
                checksumMD5: "jkl012",
                thumbnailData: sampleThumbnails[3]
            ),
            Document(
                name: "Building Permit",
                originalFileName: "building_permit_2024.pdf",
                description: "Official building permit documentation",
                category: .permits,
                tags: ["permit", "building", "official", "2024"],
                fileData: "Sample permit content".data(using: .utf8) ?? Data(),
                fileSize: 1024000, // 1MB
                mimeType: "application/pdf",
                fileExtension: "pdf",
                version: "1.0",
                accessLevel: .restricted,
                uploadedBy: "Legal Department",
                checksumMD5: "mno345",
                pageCount: 8,
                thumbnailData: sampleThumbnails[4]
            ),
            Document(
                name: "Material Specifications",
                originalFileName: "material_specs_concrete.docx",
                description: "Detailed specifications for concrete materials",
                category: .specifications,
                tags: ["specifications", "concrete", "materials"],
                fileData: "Sample spec content".data(using: .utf8) ?? Data(),
                fileSize: 768000, // 768KB
                mimeType: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                fileExtension: "docx",
                version: "1.2",
                accessLevel: .standard,
                uploadedBy: "Materials Engineer",
                checksumMD5: "pqr678"
            )
        ]
        
        documents = sampleDocs
        saveDocuments()
    }
    
    private func createSampleThumbnails() -> [Data] {
        var thumbnails: [Data] = []
        let colors: [UIColor] = [.systemOrange, .systemBlue, .systemGreen, .systemPurple, .systemRed, .systemTeal]
        
        for (index, color) in colors.enumerated() {
            let size = CGSize(width: 200, height: 200)
            let renderer = UIGraphicsImageRenderer(size: size)
            
            let image = renderer.image { context in
                // Fill background
                color.setFill()
                context.fill(CGRect(origin: .zero, size: size))
                
                // Add some visual elements to make it look like a document thumbnail
                UIColor.white.withAlphaComponent(0.3).setFill()
                
                // Add some rectangles to simulate document content
                let rect1 = CGRect(x: 20, y: 30, width: 160, height: 15)
                let rect2 = CGRect(x: 20, y: 55, width: 120, height: 10)
                let rect3 = CGRect(x: 20, y: 75, width: 140, height: 10)
                
                context.fill(rect1)
                context.fill(rect2)
                context.fill(rect3)
                
                // Add a document icon overlay
                let iconSize: CGFloat = 40
                let iconRect = CGRect(
                    x: (size.width - iconSize) / 2,
                    y: (size.height - iconSize) / 2 + 20,
                    width: iconSize,
                    height: iconSize
                )
                
                UIColor.white.withAlphaComponent(0.8).setFill()
                context.fill(iconRect)
                
                // Add page number indicator
                let pageText = "\(index + 1)"
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                    .foregroundColor: UIColor.white
                ]
                
                let textSize = pageText.size(withAttributes: attributes)
                let textRect = CGRect(
                    x: (size.width - textSize.width) / 2,
                    y: size.height - 40,
                    width: textSize.width,
                    height: textSize.height
                )
                
                pageText.draw(in: textRect, withAttributes: attributes)
            }
            
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                thumbnails.append(imageData)
            }
        }
        
        return thumbnails
    }
    
    private func setupDefaultCustomFields() {
        if customFields.isEmpty {
            customFields = [
                DocumentCustomField(name: "Project Code", type: .text, isRequired: false),
                DocumentCustomField(name: "Approval Status", type: .dropdown, isRequired: false, options: ["Pending", "Approved", "Rejected", "Under Review"]),
                DocumentCustomField(name: "Expiry Date", type: .date, isRequired: false),
                DocumentCustomField(name: "Document Owner", type: .text, isRequired: false),
                DocumentCustomField(name: "Revision Number", type: .number, isRequired: false),
                DocumentCustomField(name: "External Reference", type: .url, isRequired: false),
                DocumentCustomField(name: "Requires Signature", type: .checkbox, isRequired: false),
                DocumentCustomField(name: "Notes", type: .multiline, isRequired: false)
            ]
            saveCustomFields()
        }
    }
    
    private func saveDocuments() {
        // Save document metadata to UserDefaults and file data to Documents directory
        let documentsToSave = documents.map { doc in
            var docCopy = doc
            
            // Save file data to Documents directory if it exists
            if !doc.fileData.isEmpty {
                if let documentURL = saveFileToDocuments(fileData: doc.fileData, filename: doc.id.uuidString + "." + doc.fileExtension) {
                    docCopy.filePath = documentURL.path
                }
            }
            
            // Clear file data from UserDefaults to save space
            docCopy.fileData = Data()
            return docCopy
        }
        
        do {
            let encoded = try JSONEncoder().encode(documentsToSave)
            UserDefaults.standard.set(encoded, forKey: "pulse_documents")
        } catch {
            print("Error saving documents: \(error)")
        }
    }
    
    private func saveDocumentsWithResult() throws {
        // Save document metadata to UserDefaults and file data to Documents directory
        var documentsToSave: [Document] = []
        
        for doc in documents {
            var docCopy = doc
            
            // Save file data to Documents directory if it exists
            if !doc.fileData.isEmpty {
                do {
                    if let documentURL = try saveFileToDocumentsWithResult(fileData: doc.fileData, filename: doc.id.uuidString + "." + doc.fileExtension) {
                        docCopy.filePath = documentURL.path
                    }
                } catch {
                    throw DocumentError.fileSaveFailed(error.localizedDescription)
                }
            }
            
            // Clear file data from UserDefaults to save space
            docCopy.fileData = Data()
            documentsToSave.append(docCopy)
        }
        
        do {
            let encoded = try JSONEncoder().encode(documentsToSave)
            UserDefaults.standard.set(encoded, forKey: "pulse_documents")
        } catch {
            throw DocumentError.saveFailed(error.localizedDescription)
        }
    }
    
    private func saveFileToDocuments(fileData: Data, filename: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not access Documents directory")
            return nil
        }
        
        let pulseCRMDirectory = documentsDirectory.appendingPathComponent("PulseCRM")
        
        // Create PulseCRM directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: pulseCRMDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: pulseCRMDirectory, withIntermediateDirectories: true)
            } catch {
                print("Error creating PulseCRM directory: \(error)")
                return nil
            }
        }
        
        let fileURL = pulseCRMDirectory.appendingPathComponent(filename)
        
        do {
            try fileData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving file to documents: \(error)")
            return nil
        }
    }
    
    private func saveFileToDocumentsWithResult(fileData: Data, filename: String) throws -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw DocumentError.fileSaveFailed("Could not access Documents directory")
        }
        
        let pulseCRMDirectory = documentsDirectory.appendingPathComponent("PulseCRM")
        
        // Create PulseCRM directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: pulseCRMDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: pulseCRMDirectory, withIntermediateDirectories: true)
            } catch {
                throw DocumentError.fileSaveFailed("Could not create PulseCRM directory: \(error.localizedDescription)")
            }
        }
        
        let fileURL = pulseCRMDirectory.appendingPathComponent(filename)
        
        do {
            try fileData.write(to: fileURL)
            return fileURL
        } catch {
            throw DocumentError.fileSaveFailed("Could not write file: \(error.localizedDescription)")
        }
    }
    
    private func loadDocuments() {
        if let data = UserDefaults.standard.data(forKey: "pulse_documents"),
           let decoded = try? JSONDecoder().decode([Document].self, from: data) {
            // Load documents and restore file data from Documents directory
            let loadedDocuments = decoded.map { doc in
                var loadedDoc = doc
                
                // Load file data from Documents directory if path exists
                if !doc.filePath.isEmpty {
                    if let fileData = loadFileFromDocuments(filePath: doc.filePath) {
                        loadedDoc.fileData = fileData
                        
                        // Generate thumbnail if missing and document is an image
                        if loadedDoc.thumbnailData == nil && loadedDoc.isImage() {
                            loadedDoc.thumbnailData = generateThumbnail(from: fileData)
                        }
                    }
                }
                
                return loadedDoc
            }
            
            // Update documents directly
            documents = loadedDocuments
        }
    }
    
    private func loadFileFromDocuments(filePath: String) -> Data? {
        let fileURL = URL(fileURLWithPath: filePath)
        
        // Start security-scoped access if needed
        let hasAccess = fileURL.startAccessingSecurityScopedResource()
        
        defer {
            if hasAccess {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let fileData = try Data(contentsOf: fileURL)
            return fileData
        } catch {
            print("Error loading file from documents: \(error)")
            // Check if it's a permission error and provide helpful message
            if let nsError = error as NSError?,
               nsError.domain == NSCocoaErrorDomain && nsError.code == 257 {
                print("File permission error - this may occur with files from document picker")
            }
            return nil
        }
    }
    
    private func generateThumbnail(from data: Data) -> Data? {
        guard let originalImage = UIImage(data: data) else { return nil }
        
        // Define thumbnail size (width: 200, height: proportional)
        let thumbnailSize = CGSize(width: 200, height: 200)
        
        // Calculate the scale factor to maintain aspect ratio
        let widthScale = thumbnailSize.width / originalImage.size.width
        let heightScale = thumbnailSize.height / originalImage.size.height
        let scale = min(widthScale, heightScale)
        
        // Calculate the new size
        let newSize = CGSize(
            width: originalImage.size.width * scale,
            height: originalImage.size.height * scale
        )
        
        // Create the thumbnail
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let thumbnail = renderer.image { context in
            originalImage.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        // Convert to JPEG data with 70% quality for smaller file size
        return thumbnail.jpegData(compressionQuality: 0.7)
    }
    
    private func saveCustomFields() {
        if let encoded = try? JSONEncoder().encode(customFields) {
            UserDefaults.standard.set(encoded, forKey: "pulse_document_custom_fields")
        }
    }
    
    // MARK: - Bulk Actions
    func toggleDocumentSelection(_ documentId: UUID) {
        if selectedDocuments.contains(documentId) {
            selectedDocuments.remove(documentId)
        } else {
            selectedDocuments.insert(documentId)
        }
    }
    
    func selectAllDocuments() {
        selectedDocuments = Set(filteredDocuments.map { $0.id })
    }
    
    func deselectAllDocuments() {
        selectedDocuments.removeAll()
    }
    
    func bulkArchiveSelected() {
        for documentId in selectedDocuments {
            if let index = documents.firstIndex(where: { $0.id == documentId }) {
                documents[index].isArchived = true
                documents[index].modifiedDate = Date()
            }
        }
        saveDocuments()
        selectedDocuments.removeAll()
    }
    
    func bulkDeleteSelected() {
        documents.removeAll { selectedDocuments.contains($0.id) }
        saveDocuments()
        selectedDocuments.removeAll()
    }
    
    func bulkUpdateCategory(_ category: DocumentCategory) {
        for documentId in selectedDocuments {
            if let index = documents.firstIndex(where: { $0.id == documentId }) {
                documents[index].category = category
                documents[index].modifiedDate = Date()
            }
        }
        saveDocuments()
        selectedDocuments.removeAll()
    }
    
    // MARK: - Search and Filter Helpers
    func filterByFileType(_ fileType: String) {
        fileTypeFilter = fileType
        quickFilter = nil
    }
    
    func clearAllFilters() {
        fileTypeFilter = nil
        quickFilter = nil
        filterCategory = nil
        filterAccessLevel = nil
        searchText = ""
    }
    
    var availableFileTypes: [String] {
        let extensions = documents.map { $0.fileExtension.lowercased() }
        return Array(Set(extensions)).sorted()
    }
    
    private func loadCustomFields() {
        if let data = UserDefaults.standard.data(forKey: "pulse_document_custom_fields"),
           let decoded = try? JSONDecoder().decode([DocumentCustomField].self, from: data) {
            customFields = decoded
        }
    }
}

// MARK: - Document Utilities

extension Document {
    func formattedFileSize() -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    func isPDF() -> Bool {
        return mimeType == "application/pdf" || fileExtension.lowercased() == "pdf"
    }
    
    func isImage() -> Bool {
        return mimeType.hasPrefix("image/")
    }
    
    func isOfficeDocument() -> Bool {
        let officeTypes = [
            "application/vnd.ms-word",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "application/vnd.ms-excel",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "application/vnd.ms-powerpoint",
            "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        ]
        return officeTypes.contains(mimeType)
    }
    
    func getFileTypeIcon() -> String {
        if isPDF() {
            return "doc.richtext"
        } else if isImage() {
            return "photo"
        } else if isOfficeDocument() {
            return "doc.text"
        } else {
            switch fileExtension.lowercased() {
            case "txt":
                return "doc.plaintext"
            case "zip", "rar", "7z":
                return "archivebox"
            case "mp4", "mov", "avi":
                return "play.rectangle"
            case "mp3", "wav", "aac":
                return "waveform"
            default:
                return "doc"
            }
        }
    }
}

// MARK: - File Type Utilities

struct FileTypeUtilities {
    static func getMimeType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "pdf":
            return "application/pdf"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "doc":
            return "application/vnd.ms-word"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls":
            return "application/vnd.ms-excel"
        case "xlsx":
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "ppt":
            return "application/vnd.ms-powerpoint"
        case "pptx":
            return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "txt":
            return "text/plain"
        case "zip":
            return "application/zip"
        case "mp4":
            return "video/mp4"
        case "mp3":
            return "audio/mpeg"
        default:
            return "application/octet-stream"
        }
    }
    
    static func getFileExtension(from filename: String) -> String {
        return (filename as NSString).pathExtension
    }
    
    static func generateMD5(from data: Data) -> String {
        // Simple checksum implementation
        return String(data.hashValue)
    }
}

// MARK: - Supported File Types

struct SupportedFileTypes {
    static let documents = [
        UTType.pdf,
        UTType.text,
        UTType.rtf,
        UTType.plainText
    ]
    
    static let images = [
        UTType.jpeg,
        UTType.png,
        UTType.gif,
        UTType.bmp,
        UTType.tiff
    ]
    
    static let office = [
        UTType(filenameExtension: "doc"),
        UTType(filenameExtension: "docx"),
        UTType(filenameExtension: "xls"),
        UTType(filenameExtension: "xlsx"),
        UTType(filenameExtension: "ppt"),
        UTType(filenameExtension: "pptx")
    ].compactMap { $0 }
    
    static let all = documents + images + office
}