import SwiftUI
import PhotosUI

// MARK: - Job Models

struct Job: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var client: String
    var status: JobStatus
    var priority: JobPriority
    var startDate: Date
    var endDate: Date?
    var location: String
    var customFields: [String: String]
    var photos: [JobPhoto]
    var notes: [JobNote]
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String = "", description: String = "", client: String = "", status: JobStatus = .planning, priority: JobPriority = .medium, startDate: Date = Date(), endDate: Date? = nil, location: String = "", customFields: [String: String] = [:], photos: [JobPhoto] = [], notes: [JobNote] = []) {
        self.title = title
        self.description = description
        self.client = client
        self.status = status
        self.priority = priority
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.customFields = customFields
        self.photos = photos
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum JobStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case planning = "Planning"
    case inProgress = "In Progress"
    case onHold = "On Hold"
    case completed = "Completed"
    case cancelled = "Cancelled"
    
    var color: Color {
        switch self {
        case .pending:
            return .gray
        case .planning:
            return .blue
        case .inProgress:
            return .orange
        case .onHold:
            return .yellow
        case .completed:
            return .green
        case .cancelled:
            return .red
        }
    }
    
    var systemImage: String {
        switch self {
        case .pending:
            return "clock.circle.fill"
        case .planning:
            return "calendar.badge.plus"
        case .inProgress:
            return "hammer.fill"
        case .onHold:
            return "pause.circle.fill"
        case .completed:
            return "checkmark.circle.fill"
        case .cancelled:
            return "xmark.circle.fill"
        }
    }
}

enum JobPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .blue
        case .high:
            return .orange
        case .urgent:
            return .red
        }
    }
    
    var systemImage: String {
        switch self {
        case .low:
            return "chevron.down"
        case .medium:
            return "minus"
        case .high:
            return "chevron.up"
        case .urgent:
            return "exclamationmark.triangle.fill"
        }
    }
}

struct JobPhoto: Identifiable, Codable {
    var id = UUID()
    var imageData: Data
    var caption: String
    var timestamp: Date
    var location: String?
    
    init(imageData: Data, caption: String = "", timestamp: Date = Date(), location: String? = nil) {
        self.imageData = imageData
        self.caption = caption
        self.timestamp = timestamp
        self.location = location
    }
}

struct JobNote: Identifiable, Codable {
    var id = UUID()
    var content: String
    var timestamp: Date
    var author: String
    var type: NoteType
    
    init(content: String, timestamp: Date = Date(), author: String = "User", type: NoteType = .general) {
        self.content = content
        self.timestamp = timestamp
        self.author = author
        self.type = type
    }
}

enum NoteType: String, CaseIterable, Codable {
    case general = "General"
    case progress = "Progress"
    case issue = "Issue"
    case milestone = "Milestone"
    
    var color: Color {
        switch self {
        case .general:
            return .blue
        case .progress:
            return .green
        case .issue:
            return .red
        case .milestone:
            return .purple
        }
    }
    
    var systemImage: String {
        switch self {
        case .general:
            return "note.text"
        case .progress:
            return "chart.line.uptrend.xyaxis"
        case .issue:
            return "exclamationmark.triangle"
        case .milestone:
            return "flag.fill"
        }
    }
}

struct JobCustomField: Identifiable, Codable {
    var id = UUID()
    var name: String
    var type: CustomFieldType
    var isRequired: Bool
    var options: [String]
    
    init(name: String, type: CustomFieldType = .text, isRequired: Bool = false, options: [String] = []) {
        self.name = name
        self.type = type
        self.isRequired = isRequired
        self.options = options
    }
}

enum CustomFieldType: String, CaseIterable, Codable {
    case text = "Text"
    case number = "Number"
    case date = "Date"
    case dropdown = "Dropdown"
    case multiline = "Multiline"
    case checkbox = "Checkbox"
    
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
        }
    }
}

// MARK: - Job Manager

enum DateFilterType {
    case today
    case thisWeek
    case overdue
}

class JobManager: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var customFields: [JobCustomField] = []
    @Published var searchText = ""
    @Published var filterStatus: JobStatus?
    @Published var filterPriority: JobPriority?
    @Published var currentViewType: JobViewType = .cards
    @Published var filterByDate: DateFilterType?
    
    init() {
        loadJobs()
        setupDefaultCustomFields()
    }
    
    var filteredJobs: [Job] {
        var result = jobs
        
        // Search filter
        if !searchText.isEmpty {
            result = result.filter { job in
                job.title.localizedCaseInsensitiveContains(searchText) ||
                job.client.localizedCaseInsensitiveContains(searchText) ||
                job.description.localizedCaseInsensitiveContains(searchText) ||
                job.location.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Status filter
        if let status = filterStatus {
            result = result.filter { $0.status == status }
        }
        
        // Priority filter
        if let priority = filterPriority {
            result = result.filter { $0.priority == priority }
        }
        
        return result.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    var todaysJobs: [Job] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return jobs.filter { job in
            let startOfJobDay = Calendar.current.startOfDay(for: job.startDate)
            return startOfJobDay >= today && startOfJobDay < tomorrow
        }
    }
    
    var thisWeeksJobs: [Job] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return [] }
        
        return jobs.filter { job in
            weekInterval.contains(job.startDate)
        }
    }
    
    var overdueJobs: [Job] {
        let now = Date()
        return jobs.filter { job in
            if let endDate = job.endDate {
                return endDate < now && job.status != .completed && job.status != .cancelled
            }
            return false
        }
    }
    
    func addJob(_ job: Job) {
        jobs.append(job)
        saveJobs()
    }
    
    func updateJob(_ job: Job) {
        var updatedJob = job
        updatedJob.updatedAt = Date()
        
        if let index = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[index] = updatedJob
            saveJobs()
        }
    }
    
    func deleteJob(_ job: Job) {
        jobs.removeAll { $0.id == job.id }
        saveJobs()
    }
    
    func addCustomField(_ field: JobCustomField) {
        customFields.append(field)
        saveCustomFields()
    }
    
    func updateCustomField(_ field: JobCustomField) {
        if let index = customFields.firstIndex(where: { $0.id == field.id }) {
            customFields[index] = field
            saveCustomFields()
        }
    }
    
    func deleteCustomField(_ field: JobCustomField) {
        customFields.removeAll { $0.id == field.id }
        saveCustomFields()
    }
    
    private func setupDefaultCustomFields() {
        if customFields.isEmpty {
            customFields = [
                JobCustomField(name: "Budget", type: .number, isRequired: false),
                JobCustomField(name: "Team Lead", type: .text, isRequired: false),
                JobCustomField(name: "Equipment Needed", type: .multiline, isRequired: false),
                JobCustomField(name: "Safety Requirements", type: .dropdown, isRequired: false, options: ["Standard", "High Risk", "Confined Space", "Height Work"]),
                JobCustomField(name: "Permit Required", type: .checkbox, isRequired: false)
            ]
            saveCustomFields()
        }
    }
    
    private func saveJobs() {
        if let encoded = try? JSONEncoder().encode(jobs) {
            UserDefaults.standard.set(encoded, forKey: "pulse_jobs")
        }
    }
    
    private func loadJobs() {
        if let data = UserDefaults.standard.data(forKey: "pulse_jobs"),
           let decoded = try? JSONDecoder().decode([Job].self, from: data) {
            jobs = decoded
        }
    }
    
    private func saveCustomFields() {
        if let encoded = try? JSONEncoder().encode(customFields) {
            UserDefaults.standard.set(encoded, forKey: "pulse_job_custom_fields")
        }
    }
    
    private func loadCustomFields() {
        if let data = UserDefaults.standard.data(forKey: "pulse_job_custom_fields"),
           let decoded = try? JSONDecoder().decode([JobCustomField].self, from: data) {
            customFields = decoded
        }
    }
}

enum JobViewType: String, CaseIterable {
    case cards = "Cards"
    case table = "Table"
    case timeline = "Timeline"
    case calendar = "Calendar"
    
    var systemImage: String {
        switch self {
        case .cards:
            return "rectangle.grid.2x2"
        case .table:
            return "list.bullet"
        case .timeline:
            return "timeline.selection"
        case .calendar:
            return "calendar"
        }
    }
}