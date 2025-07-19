import SwiftUI
import PhotosUI
import Foundation

struct JobFormView: View {
    @ObservedObject var jobManager: JobManager
    @Environment(\.dismiss) private var dismiss
    @State private var job: Job
    @State private var customFieldValues: [String: String] = [:]
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showingPhotoPicker = false
    @State private var newNote = ""
    @State private var selectedNoteType: NoteType = .general
    @State private var showingDeleteAlert = false
    @State private var showingCustomFieldManager = false
    @StateObject private var validator = FormValidator()
    
    private let isEditing: Bool
    
    init(jobManager: JobManager, job: Job? = nil) {
        self.jobManager = jobManager
        self.isEditing = job != nil
        self._job = State(initialValue: job ?? Job())
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information
                Section("Job Information") {
                    ValidatedTextField(
                        title: "Job Title",
                        placeholder: "Enter job title",
                        text: $job.title,
                        validationType: .required,
                        validator: validator,
                        fieldKey: "title"
                    )
                    
                    ValidatedTextField(
                        title: "Client",
                        placeholder: "Enter client name",
                        text: $job.client,
                        validationType: .required,
                        validator: validator,
                        fieldKey: "client"
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Enter job description", text: $job.description, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Enter job location", text: $job.location)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                // Status and Priority
                Section("Job Status") {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("Status", selection: $job.status) {
                                ForEach(JobStatus.allCases, id: \.self) { status in
                                    HStack {
                                        Image(systemName: status.systemImage)
                                            .foregroundColor(status.color)
                                        Text(status.rawValue)
                                    }
                                    .tag(status)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("Priority", selection: $job.priority) {
                                ForEach(JobPriority.allCases, id: \.self) { priority in
                                    HStack {
                                        Image(systemName: priority.systemImage)
                                            .foregroundColor(priority.color)
                                        Text(priority.rawValue)
                                    }
                                    .tag(priority)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                }
                
                // Dates
                Section("Schedule") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start Date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        DatePicker("Start Date", selection: $job.startDate, displayedComponents: [.date])
                            .datePickerStyle(CompactDatePickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("End Date (Optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            if let endDate = job.endDate {
                                DatePicker("End Date", selection: Binding(
                                    get: { endDate },
                                    set: { job.endDate = $0 }
                                ), displayedComponents: [.date])
                                .datePickerStyle(CompactDatePickerStyle())
                                
                                Button("Remove") {
                                    job.endDate = nil
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            } else {
                                Button("Add End Date") {
                                    job.endDate = Calendar.current.date(byAdding: .day, value: 7, to: job.startDate) ?? Date()
                                }
                                .foregroundColor(.orange)
                            }
                        }
                    }
                }
                
                // Custom Fields
                if !jobManager.customFields.isEmpty {
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
                        ForEach(jobManager.customFields) { field in
                            CustomFieldView(field: field, value: Binding(
                                get: { customFieldValues[field.id.uuidString] ?? "" },
                                set: { customFieldValues[field.id.uuidString] = $0 }
                            ))
                        }
                    }
                }
                
                // Photos
                Section(header: 
                    HStack {
                        Text("Photos")
                        Spacer()
                        PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 10, matching: .images) {
                            HStack {
                                Image(systemName: "photo.badge.plus")
                                Text("Add Photos")
                            }
                            .foregroundColor(.orange)
                            .font(.caption)
                        }
                    }
                ) {
                    if job.photos.isEmpty {
                        Text("No photos added yet")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(job.photos) { photo in
                                    PhotoThumbnailView(photo: photo) {
                                        if let index = job.photos.firstIndex(where: { $0.id == photo.id }) {
                                            job.photos.remove(at: index)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Notes
                Section("Notes & Timeline") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            TextField("Add a note...", text: $newNote)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Picker("Type", selection: $selectedNoteType) {
                                ForEach(NoteType.allCases, id: \.self) { type in
                                    HStack {
                                        Image(systemName: type.systemImage)
                                        Text(type.rawValue)
                                    }
                                    .tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 100)
                            
                            Button("Add") {
                                if !newNote.isEmpty {
                                    let note = JobNote(content: newNote, type: selectedNoteType)
                                    job.notes.append(note)
                                    newNote = ""
                                }
                            }
                            .foregroundColor(.orange)
                        }
                        
                        if !job.notes.isEmpty {
                            ForEach(job.notes.sorted { $0.timestamp > $1.timestamp }) { note in
                                JobNoteView(note: note) {
                                    if let index = job.notes.firstIndex(where: { $0.id == note.id }) {
                                        job.notes.remove(at: index)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Delete Section (only for editing)
                if isEditing {
                    Section {
                        Button("Delete Job") {
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Job" : "New Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveJob()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid())
                }
            }
        }
        .onAppear {
            loadCustomFieldValues()
        }
        .onChange(of: selectedPhotos) { _ in
            loadPhotos()
        }
        .alert("Delete Job", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                jobManager.deleteJob(job)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this job? This action cannot be undone.")
        }
        .sheet(isPresented: $showingCustomFieldManager) {
            CustomFieldManagerView(jobManager: jobManager)
        }
    }
    
    private func loadCustomFieldValues() {
        customFieldValues = job.customFields
    }
    
    private func isFormValid() -> Bool {
        let hasRequiredFields = !job.title.isEmpty && !job.client.isEmpty
        let hasValidValidation = validator.isValid
        
        // Check if end date is after start date
        if let endDate = job.endDate {
            let isValidDateRange = endDate >= job.startDate
            if !isValidDateRange {
                validator.errors["endDate"] = "End date must be after start date"
                return false
            } else {
                validator.errors.removeValue(forKey: "endDate")
            }
        }
        
        return hasRequiredFields && hasValidValidation
    }
    
    private func saveJob() {
        // Validate form before saving
        guard isFormValid() else {
            return
        }
        
        job.customFields = customFieldValues
        
        if isEditing {
            jobManager.updateJob(job)
        } else {
            jobManager.addJob(job)
        }
        
        dismiss()
    }
    
    private func loadPhotos() {
        Task {
            var newPhotos: [JobPhoto] = []
            
            for item in selectedPhotos {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    let photo = JobPhoto(imageData: data)
                    newPhotos.append(photo)
                }
            }
            
            await MainActor.run {
                job.photos.append(contentsOf: newPhotos)
                selectedPhotos.removeAll()
            }
        }
    }
}

// MARK: - Custom Field View

struct CustomFieldView: View {
    let field: JobCustomField
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
            }
        }
    }
}

// MARK: - Photo Thumbnail View

struct PhotoThumbnailView: View {
    let photo: JobPhoto
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                if let uiImage = UIImage(data: photo.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .offset(x: 8, y: -8)
            }
            
            Text(photo.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Job Note View

struct JobNoteView: View {
    let note: JobNote
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: note.type.systemImage)
                        .foregroundColor(note.type.color)
                        .font(.caption)
                    Text(note.type.rawValue)
                        .font(.caption)
                        .foregroundColor(note.type.color)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Text(note.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Text(note.content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Custom Field Manager View

struct CustomFieldManagerView: View {
    @ObservedObject var jobManager: JobManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddField = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(jobManager.customFields) { field in
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
            AddCustomFieldView(jobManager: jobManager)
        }
    }
    
    private func deleteFields(offsets: IndexSet) {
        for index in offsets {
            jobManager.deleteCustomField(jobManager.customFields[index])
        }
    }
}

// MARK: - Add Custom Field View

struct AddCustomFieldView: View {
    @ObservedObject var jobManager: JobManager
    @Environment(\.dismiss) private var dismiss
    @State private var fieldName = ""
    @State private var fieldType: CustomFieldType = .text
    @State private var isRequired = false
    @State private var options: [String] = [""]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Field Information") {
                    TextField("Field Name", text: $fieldName)
                    
                    Picker("Field Type", selection: $fieldType) {
                        ForEach(CustomFieldType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.systemImage)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Toggle("Required Field", isOn: $isRequired)
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
                        let field = JobCustomField(
                            name: fieldName,
                            type: fieldType,
                            isRequired: isRequired,
                            options: fieldType == .dropdown ? options.filter { !$0.isEmpty } : []
                        )
                        jobManager.addCustomField(field)
                        dismiss()
                    }
                    .disabled(fieldName.isEmpty)
                }
            }
        }
    }
}