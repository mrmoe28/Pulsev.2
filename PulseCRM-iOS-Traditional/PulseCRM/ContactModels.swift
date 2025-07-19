import SwiftUI
import Foundation

// MARK: - Contact Data Models
struct Contact: Identifiable, Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var company: String
    var position: String
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var notes: String
    var profileImage: Data?
    var createdDate: Date
    var customFields: [String: String]
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    init(id: UUID = UUID(), firstName: String = "", lastName: String = "", email: String = "", phone: String = "", company: String = "", position: String = "", address: String = "", city: String = "", state: String = "", zipCode: String = "", notes: String = "", profileImage: Data? = nil, createdDate: Date = Date(), customFields: [String: String] = [:]) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.company = company
        self.position = position
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.notes = notes
        self.profileImage = profileImage
        self.createdDate = createdDate
        self.customFields = customFields
    }
}

// MARK: - Column Configuration
struct ContactColumn: Identifiable, Codable {
    let id: UUID
    var title: String
    var key: String
    var width: CGFloat
    var isVisible: Bool
    var isEditable: Bool
    var fieldType: FieldType
    
    enum FieldType: String, CaseIterable, Codable {
        case text = "Text"
        case email = "Email"
        case phone = "Phone"
        case image = "Image"
        case date = "Date"
        case notes = "Notes"
        
        var systemImage: String {
            switch self {
            case .text: return "textformat"
            case .email: return "envelope"
            case .phone: return "phone"
            case .image: return "photo"
            case .date: return "calendar"
            case .notes: return "note.text"
            }
        }
    }
    
    init(id: UUID = UUID(), title: String, key: String, width: CGFloat, isVisible: Bool, isEditable: Bool, fieldType: FieldType) {
        self.id = id
        self.title = title
        self.key = key
        self.width = width
        self.isVisible = isVisible
        self.isEditable = isEditable
        self.fieldType = fieldType
    }
}

// MARK: - View Types
enum ContactViewType: String, CaseIterable {
    case table = "Table"
    case cards = "Cards"
    
    var systemImage: String {
        switch self {
        case .table: return "tablecells"
        case .cards: return "rectangle.grid.2x2"
        }
    }
}

// MARK: - Filter and Sort Options
enum ContactFilterType: String, CaseIterable {
    case all = "All"
    case favorites = "Favorites"
    case recent = "Recent"
    case company = "By Company"
}

enum ContactGroupBy: String, CaseIterable {
    case none = "None"
    case company = "Company"
    case position = "Position"
    case location = "Location"
}

// MARK: - Contact Manager
class ContactManager: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var columns: [ContactColumn] = []
    @Published var currentViewType: ContactViewType = .table
    @Published var searchText: String = ""
    @Published var selectedContact: Contact?
    @Published var sortField: String = "name"
    @Published var filterType: ContactFilterType = .all
    @Published var groupBy: ContactGroupBy = .none
    @Published var showingImport: Bool = false
    
    init() {
        setupDefaultColumns()
        loadContacts()
    }
    
    private func setupDefaultColumns() {
        loadColumns()
        
        // Only set up default columns if none exist
        if columns.isEmpty {
            columns = [
                ContactColumn(title: "Photo", key: "profileImage", width: 80, isVisible: true, isEditable: false, fieldType: .image),
                ContactColumn(title: "First Name", key: "firstName", width: 120, isVisible: true, isEditable: true, fieldType: .text),
                ContactColumn(title: "Last Name", key: "lastName", width: 120, isVisible: true, isEditable: true, fieldType: .text),
                ContactColumn(title: "Email", key: "email", width: 200, isVisible: true, isEditable: true, fieldType: .email),
                ContactColumn(title: "Phone", key: "phone", width: 140, isVisible: true, isEditable: true, fieldType: .phone),
                ContactColumn(title: "Company", key: "company", width: 150, isVisible: true, isEditable: true, fieldType: .text),
                ContactColumn(title: "Position", key: "position", width: 130, isVisible: true, isEditable: true, fieldType: .text),
                ContactColumn(title: "City", key: "city", width: 100, isVisible: false, isEditable: true, fieldType: .text),
                ContactColumn(title: "State", key: "state", width: 80, isVisible: false, isEditable: true, fieldType: .text),
                ContactColumn(title: "Created", key: "createdDate", width: 100, isVisible: false, isEditable: false, fieldType: .date)
            ]
            saveColumns()
        }
    }
    
    private func loadContacts() {
        print("Debug: loadContacts() called - starting contact loading process")
        
        // Check all UserDefaults keys first
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        print("Debug: Total UserDefaults keys: \(allKeys.count)")
        let pulseKeys = allKeys.filter { $0.contains("pulse") }
        print("Debug: Pulse-related keys: \(pulseKeys)")
        
        if let data = UserDefaults.standard.data(forKey: "pulse_contacts") {
            print("Debug: Found pulse_contacts data - size: \(data.count) bytes")
            
            do {
                let decoded = try JSONDecoder().decode([Contact].self, from: data)
                contacts = decoded
                print("Debug: Successfully decoded \(contacts.count) contacts")
                for (index, contact) in contacts.enumerated() {
                    print("Debug: Contact \(index + 1): \(contact.fullName) (\(contact.email))")
                }
            } catch {
                print("Debug: ERROR - Failed to decode contacts: \(error)")
                contacts = []
            }
        } else {
            print("Debug: No pulse_contacts data found in UserDefaults")
            contacts = [] // Start with empty contacts list
            print("Debug: Starting with empty contact list")
        }
        
        print("Debug: loadContacts() completed - final contact count: \(contacts.count)")
    }
    
    private func saveContacts() {
        // Compress profile images before saving to prevent size issues
        let contactsToSave = contacts.map { contact in
            var compressedContact = contact
            if let imageData = contact.profileImage {
                compressedContact.profileImage = compressImageData(imageData)
            }
            return compressedContact
        }
        
        do {
            let encoded = try JSONEncoder().encode(contactsToSave)
            
            // Check if the encoded data is too large (UserDefaults limit is around 4MB)
            let sizeInMB = Double(encoded.count) / 1024.0 / 1024.0
            if sizeInMB > 3.0 {
                print("Debug: WARNING - Contacts data size is \(String(format: "%.2f", sizeInMB))MB, which may cause issues")
                // Still attempt to save but warn about potential issues
            }
            
            UserDefaults.standard.set(encoded, forKey: "pulse_contacts")
            UserDefaults.standard.synchronize() // Force immediate save
            print("Debug: Contacts successfully encoded and saved. Count: \(contacts.count), Size: \(String(format: "%.2f", sizeInMB))MB")
        } catch {
            print("Debug: ERROR - Failed to encode contacts for saving: \(error.localizedDescription)")
            // In a real app, we would show this error to the user
            showSaveError(error)
        }
    }
    
    private func compressImageData(_ imageData: Data) -> Data? {
        guard let image = UIImage(data: imageData) else { return imageData }
        
        // Resize image if it's too large (max 300x300)
        let maxSize: CGFloat = 300
        let size = image.size
        
        if size.width > maxSize || size.height > maxSize {
            let ratio = min(maxSize / size.width, maxSize / size.height)
            let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // Compress to JPEG with 70% quality
            return resizedImage?.jpegData(compressionQuality: 0.7) ?? imageData
        }
        
        // Just compress existing image
        return image.jpegData(compressionQuality: 0.7) ?? imageData
    }
    
    private func showSaveError(_ error: Error) {
        // For now just print, but in a real app we'd show an alert to the user
        print("Debug: Contact save failed - this should be shown to user: \(error.localizedDescription)")
        
        // Post a notification that the UI can listen to for showing alerts
        NotificationCenter.default.post(
            name: NSNotification.Name("ContactSaveError"),
            object: nil,
            userInfo: ["error": error.localizedDescription]
        )
    }
    
    private func saveColumns() {
        if let encoded = try? JSONEncoder().encode(columns) {
            UserDefaults.standard.set(encoded, forKey: "pulse_contact_columns")
        }
    }
    
    private func loadColumns() {
        if let data = UserDefaults.standard.data(forKey: "pulse_contact_columns"),
           let decoded = try? JSONDecoder().decode([ContactColumn].self, from: data) {
            columns = decoded
        }
    }
    
    var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter { contact in
                contact.fullName.localizedCaseInsensitiveContains(searchText) ||
                contact.email.localizedCaseInsensitiveContains(searchText) ||
                contact.company.localizedCaseInsensitiveContains(searchText) ||
                contact.position.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var visibleColumns: [ContactColumn] {
        columns.filter { $0.isVisible }
    }
    
    func addContact(_ contact: Contact) {
        contacts.append(contact)
        print("Debug: Adding contact - \(contact.fullName), Total contacts: \(contacts.count)")
        saveContacts()
        print("Debug: Contact saved to UserDefaults")
    }
    
    func updateContact(_ contact: Contact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index] = contact
            saveContacts()
        }
    }
    
    func deleteContact(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
        saveContacts()
    }
    
    func addCustomColumn(title: String, fieldType: ContactColumn.FieldType) {
        let newColumn = ContactColumn(
            title: title,
            key: "custom_\(UUID().uuidString.prefix(8))",
            width: 120,
            isVisible: true,
            isEditable: true,
            fieldType: fieldType
        )
        columns.append(newColumn)
        saveColumns()
    }
    
    func updateColumnWidth(columnId: UUID, width: CGFloat) {
        if let index = columns.firstIndex(where: { $0.id == columnId }) {
            columns[index].width = max(80, width) // Minimum width of 80
            saveColumns()
        }
    }
    
    func toggleColumnVisibility(columnId: UUID) {
        if let index = columns.firstIndex(where: { $0.id == columnId }) {
            columns[index].isVisible.toggle()
            saveColumns()
        }
    }
    
    // MARK: - Export and Import Functions
    func exportToCSV() {
        // Implementation for CSV export
        print("Exporting contacts to CSV...")
    }
    
    func exportToVCard() {
        // Implementation for vCard export
        print("Exporting contacts to vCard...")
    }
    
    func shareSelected() {
        // Implementation for sharing selected contacts
        print("Sharing selected contacts...")
    }
}