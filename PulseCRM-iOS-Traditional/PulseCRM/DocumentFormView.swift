import SwiftUI
import UniformTypeIdentifiers

struct DocumentFormView: View {
    @ObservedObject var documentManager: DocumentManager
    @Environment(\.dismiss) private var dismiss
    @State private var document: Document
    @State private var customFieldValues: [String: String] = [:]
    @State private var selectedTags: Set<String> = []
    @State private var newTag = ""
    @State private var showingFilePicker = false
    @State private var showingDeleteAlert = false
    @State private var showingCustomFieldManager = false
    @State private var isUploading = false
    @State private var uploadProgress: Double = 0.0
    @State private var uploadTimer: Timer?
    @State private var availableJobs: [String] = []
    @State private var availableContacts: [String] = []
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    private let isEditing: Bool
    private let commonTags = ["Important", "Draft", "Final", "Review", "Approved", "Confidential", "Public", "Archive"]
    
    init(documentManager: DocumentManager, document: Document? = nil) {
        self.documentManager = documentManager
        self.isEditing = document != nil
        self._document = State(initialValue: document ?? Document())
    }
    
    var body: some View {
        NavigationView {
            Form {
                // File Upload Section
                if !isEditing {
                    Section("File Upload") {
                        VStack(spacing: 16) {
                            // File picker button
                            Button(action: {
                                showingFilePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.orange)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Choose File")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("PDF, Images, Office Documents")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Selected file info
                            if !document.originalFileName.isEmpty {
                                HStack {
                                    Image(systemName: document.getFileTypeIcon())
                                        .foregroundColor(.orange)
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading) {
                                        Text(document.originalFileName)
                                            .font(.body)
                                            .fontWeight(.medium)
                                        
                                        HStack {
                                            Text(document.formattedFileSize())
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            Text("•")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            Text(document.fileExtension.uppercased())
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Button("Remove") {
                                        document.originalFileName = ""
                                        document.fileData = Data()
                                        document.fileSize = 0
                                        document.mimeType = ""
                                        document.fileExtension = ""
                                    }
                                    .foregroundColor(.red)
                                    .font(.caption)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.orange, lineWidth: 1)
                                )
                            }
                            
                            // Upload progress
                            if isUploading {
                                VStack(spacing: 8) {
                                    ProgressView(value: uploadProgress)
                                        .progressViewStyle(LinearProgressViewStyle())
                                    
                                    Text("Uploading... \(Int(uploadProgress * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                // Document Information
                Section("Document Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Document Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Enter document name", text: $document.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Enter description", text: $document.description, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Version")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g., 1.0, 2.1, Draft", text: $document.version)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                // Classification
                Section("Classification") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Picker("Category", selection: $document.category) {
                            ForEach(DocumentCategory.allCases, id: \.self) { category in
                                HStack {
                                    Image(systemName: category.systemImage)
                                        .foregroundColor(category.color)
                                    Text(category.rawValue)
                                }
                                .tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Access Level")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Picker("Access Level", selection: $document.accessLevel) {
                            ForEach(AccessLevel.allCases, id: \.self) { level in
                                HStack {
                                    Image(systemName: level.systemImage)
                                        .foregroundColor(level.color)
                                    Text(level.rawValue)
                                }
                                .tag(level)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Tags
                Section("Tags") {
                    VStack(alignment: .leading, spacing: 12) {
                        // Add new tag
                        HStack {
                            TextField("Add tag", text: $newTag)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Add") {
                                if !newTag.isEmpty && !selectedTags.contains(newTag) {
                                    selectedTags.insert(newTag)
                                    newTag = ""
                                }
                            }
                            .foregroundColor(.orange)
                            .disabled(newTag.isEmpty)
                        }
                        
                        // Common tags
                        Text("Common Tags:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        FlexibleTagView(tags: commonTags, selectedTags: $selectedTags)
                        
                        // Selected tags
                        if !selectedTags.isEmpty {
                            Text("Selected Tags:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            FlexibleTagView(tags: Array(selectedTags), selectedTags: $selectedTags, isRemovable: true)
                        }
                    }
                }
                
                // Associations
                Section("Associations") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Associated Job (Optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Select Job", selection: $document.associatedJobId) {
                            Text("None").tag(nil as String?)
                            ForEach(availableJobs, id: \.self) { job in
                                Text(job).tag(job as String?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Associated Contact (Optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Select Contact", selection: $document.associatedContactId) {
                            Text("None").tag(nil as String?)
                            ForEach(availableContacts, id: \.self) { contact in
                                Text(contact).tag(contact as String?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Custom Fields
                if !documentManager.customFields.isEmpty {
                    Section(header: 
                        HStack {
                            Text("Custom Fields")
                            Spacer()
                            Button("Manage Fields") {
                                showingCustomFieldManager = true
                            }
                            .foregroundColor(.orange)
                            .font(.caption)
                        }
                    ) {
                        ForEach(documentManager.customFields) { field in
                            DocumentCustomFieldView(field: field, value: Binding(
                                get: { customFieldValues[field.id.uuidString] ?? field.defaultValue },
                                set: { customFieldValues[field.id.uuidString] = $0 }
                            ))
                        }
                    }
                }
                
                // Archive Section (only for editing)
                if isEditing {
                    Section("Document Status") {
                        Toggle("Archive Document", isOn: $document.isArchived)
                            .toggleStyle(SwitchToggleStyle(tint: .orange))
                        
                        if document.isArchived {
                            Text("Archived documents are hidden from the main view but can still be accessed.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Document Info (editing only)
                if isEditing {
                    Section("Document Info") {
                        InfoRow(label: "Original File", value: document.originalFileName)
                        InfoRow(label: "File Size", value: document.formattedFileSize())
                        InfoRow(label: "File Type", value: document.fileExtension.uppercased())
                        InfoRow(label: "Uploaded", value: document.uploadDate.formatted(date: .abbreviated, time: .shortened))
                        InfoRow(label: "Modified", value: document.modifiedDate.formatted(date: .abbreviated, time: .shortened))
                        InfoRow(label: "Uploaded By", value: document.uploadedBy)
                        
                        if let pageCount = document.pageCount {
                            InfoRow(label: "Pages", value: "\(pageCount)")
                        }
                    }
                }
                
                // Delete Section (only for editing)
                if isEditing {
                    Section {
                        Button("Delete Document") {
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Document" : "Upload Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveDocument()
                    }
                    .fontWeight(.semibold)
                    .disabled(document.name.isEmpty || (!isEditing && document.fileData.isEmpty))
                }
            }
        }
        .onAppear {
            loadCustomFieldValues()
            loadAvailableAssociations()
            if isEditing {
                selectedTags = Set(document.tags)
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: SupportedFileTypes.all,
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
        .alert("Delete Document", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                documentManager.deleteDocument(document)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this document? This action cannot be undone.")
        }
        .alert("Unable to Save Document", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingCustomFieldManager) {
            DocumentCustomFieldManagerView(documentManager: documentManager)
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Start security-scoped access for the file
            let hasAccess = url.startAccessingSecurityScopedResource()
            
            defer {
                if hasAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            // Load file data first
            do {
                let fileData = try Data(contentsOf: url)
                let fileName = url.lastPathComponent
                let fileExtension = FileTypeUtilities.getFileExtension(from: fileName)
                let mimeType = FileTypeUtilities.getMimeType(for: fileExtension)
                
                // Update document on main thread
                DispatchQueue.main.async {
                    document.originalFileName = fileName
                    document.fileData = fileData
                    document.fileSize = Int64(fileData.count)
                    document.mimeType = mimeType
                    document.fileExtension = fileExtension
                    document.checksumMD5 = FileTypeUtilities.generateMD5(from: fileData)
                    
                    // Set default name if empty
                    if document.name.isEmpty {
                        document.name = (fileName as NSString).deletingPathExtension
                    }
                    
                    // Extract page count for PDFs (simplified implementation)
                    if document.isPDF() {
                        document.pageCount = extractPDFPageCount(from: fileData)
                    }
                    
                    // Generate thumbnail for images
                    if document.isImage() {
                        document.thumbnailData = generateThumbnail(from: fileData)
                    }
                }
                
                // Start upload progress animation
                isUploading = true
                uploadProgress = 0.0
                
                // Simulate upload progress
                uploadTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    DispatchQueue.main.async {
                        uploadProgress += 0.1
                        if uploadProgress >= 1.0 {
                            uploadTimer?.invalidate()
                            uploadTimer = nil
                            isUploading = false
                        }
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    print("Error loading file: \(error)")
                    errorMessage = "Failed to load file: \(error.localizedDescription)"
                    showingErrorAlert = true
                }
            }
            
        case .failure(let error):
            DispatchQueue.main.async {
                print("File selection error: \(error)")
                errorMessage = "File selection failed: \(error.localizedDescription)"
                showingErrorAlert = true
            }
        }
    }
    
    private func extractPDFPageCount(from data: Data) -> Int? {
        // Simplified PDF page count extraction
        // In a real implementation, you'd use PDFKit or similar
        let dataString = String(data: data, encoding: .utf8) ?? ""
        let pageMatches = dataString.matches(of: /\/Count\s+(\d+)/)
        return pageMatches.first.flatMap { match in
            Int(String(match.output.1))
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
    
    private func loadCustomFieldValues() {
        customFieldValues = document.customFields
    }
    
    private func loadAvailableAssociations() {
        // Load available jobs and contacts
        // In a real implementation, you'd fetch from managers
        availableJobs = ["Project Alpha", "Project Beta", "Project Gamma"]
        availableContacts = ["John Smith", "Jane Doe", "Mike Johnson"]
    }
    
    private func saveDocument() {
        document.customFields = customFieldValues
        document.tags = Array(selectedTags)
        
        let result: Result<Void, DocumentError>
        if isEditing {
            result = documentManager.updateDocument(document)
        } else {
            result = documentManager.addDocument(document)
        }
        
        switch result {
        case .success:
            dismiss()
        case .failure(let error):
            errorMessage = error.localizedDescription
            showingErrorAlert = true
        }
    }
}

// MARK: - Document Custom Field View

struct DocumentCustomFieldView: View {
    let field: DocumentCustomField
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: field.type.systemImage)
                    .foregroundColor(.orange)
                    .font(.caption)
                Text(field.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if field.isRequired {
                    Text("*")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            switch field.type {
            case .text:
                TextField("Enter \(field.name.lowercased())", text: $value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
            case .number:
                TextField("Enter \(field.name.lowercased())", text: $value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
            case .multiline:
                TextField("Enter \(field.name.lowercased())", text: $value, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(2...4)
                
            case .dropdown:
                Picker("Select \(field.name.lowercased())", selection: $value) {
                    Text("Select...").tag("")
                    ForEach(field.options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
            case .date:
                if let date = DateFormatter().date(from: value) {
                    DatePicker("Select date", selection: Binding(
                        get: { date },
                        set: { value = DateFormatter().string(from: $0) }
                    ), displayedComponents: [.date])
                    .datePickerStyle(CompactDatePickerStyle())
                } else {
                    Button("Select Date") {
                        value = DateFormatter().string(from: Date())
                    }
                    .foregroundColor(.orange)
                }
                
            case .checkbox:
                Toggle(isOn: Binding(
                    get: { value == "true" },
                    set: { value = $0 ? "true" : "false" }
                )) {
                    Text("Enable \(field.name)")
                }
                
            case .url:
                TextField("Enter URL", text: $value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                
            case .email:
                TextField("Enter email", text: $value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
        }
    }
}

// MARK: - Flexible Tag View

struct FlexibleTagView: View {
    let tags: [String]
    @Binding var selectedTags: Set<String>
    var isRemovable: Bool = false
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                TagView(
                    tag: tag,
                    isSelected: selectedTags.contains(tag),
                    isRemovable: isRemovable
                ) {
                    if selectedTags.contains(tag) {
                        selectedTags.remove(tag)
                    } else {
                        selectedTags.insert(tag)
                    }
                }
            }
        }
    }
}

struct TagView: View {
    let tag: String
    let isSelected: Bool
    let isRemovable: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                if isRemovable {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Text(tag)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.orange : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Document Custom Field Manager

struct DocumentCustomFieldManagerView: View {
    @ObservedObject var documentManager: DocumentManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddField = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(documentManager.customFields) { field in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: field.type.systemImage)
                                .foregroundColor(.orange)
                            Text(field.name)
                                .fontWeight(.medium)
                            if field.isRequired {
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            Spacer()
                            Text(field.type.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if !field.options.isEmpty {
                            Text("Options: \(field.options.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if !field.defaultValue.isEmpty {
                            Text("Default: \(field.defaultValue)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteFields)
            }
            .navigationTitle("Custom Fields")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Field") {
                        showingAddField = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddField) {
            AddDocumentCustomFieldView(documentManager: documentManager)
        }
    }
    
    private func deleteFields(offsets: IndexSet) {
        for index in offsets {
            documentManager.deleteCustomField(documentManager.customFields[index])
        }
    }
}

// MARK: - Add Document Custom Field View

struct AddDocumentCustomFieldView: View {
    @ObservedObject var documentManager: DocumentManager
    @Environment(\.dismiss) private var dismiss
    @State private var fieldName = ""
    @State private var fieldType: DocumentFieldType = .text
    @State private var isRequired = false
    @State private var defaultValue = ""
    @State private var options: [String] = [""]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Field Information") {
                    TextField("Field Name", text: $fieldName)
                    
                    Picker("Field Type", selection: $fieldType) {
                        ForEach(DocumentFieldType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.systemImage)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Toggle("Required Field", isOn: $isRequired)
                    
                    TextField("Default Value (Optional)", text: $defaultValue)
                }
                
                if fieldType == .dropdown {
                    Section("Options") {
                        ForEach(options.indices, id: \.self) { index in
                            HStack {
                                TextField("Option \(index + 1)", text: $options[index])
                                Button("Remove") {
                                    options.remove(at: index)
                                }
                                .foregroundColor(.red)
                                .opacity(options.count > 1 ? 1 : 0)
                            }
                        }
                        
                        Button("Add Option") {
                            options.append("")
                        }
                        .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Add Custom Field")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let field = DocumentCustomField(
                            name: fieldName,
                            type: fieldType,
                            isRequired: isRequired,
                            options: fieldType == .dropdown ? options.filter { !$0.isEmpty } : [],
                            defaultValue: defaultValue
                        )
                        documentManager.addCustomField(field)
                        dismiss()
                    }
                    .disabled(fieldName.isEmpty)
                }
            }
        }
    }
}

// MARK: - String Extension for Regex

extension String {
    func matches(of regex: Regex<(Substring, Substring)>) -> [Regex<(Substring, Substring)>.Match] {
        return []  // Simplified for this implementation
    }
}