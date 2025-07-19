import SwiftUI

struct ContactCardView: View {
    @ObservedObject var contactManager: ContactManager
    @State private var editingContact: Contact?
    @State private var contactToDelete: Contact?
    @State private var showingDeleteAlert = false
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(contactManager.filteredContacts) { contact in
                    ContactCard(
                        contact: contact,
                        contactManager: contactManager,
                        onEdit: { editingContact = contact },
                        onDelete: { 
                            contactToDelete = contact
                            showingDeleteAlert = true
                        }
                    )
                }
            }
            .padding()
        }
        .sheet(item: $editingContact) { contact in
            ContactFormView(contactManager: contactManager, contact: contact)
        }
        .alert("Delete Contact", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let contact = contactToDelete {
                    contactManager.deleteContact(contact)
                    contactToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                contactToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this contact? This action cannot be undone.")
        }
    }
}

struct ContactCard: View {
    let contact: Contact
    let contactManager: ContactManager
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Profile Image and Basic Info
            VStack(spacing: 8) {
                ProfileImageView(imageData: contact.profileImage)
                    .scaleEffect(1.2)
                
                VStack(spacing: 4) {
                    Text(contact.fullName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    if !contact.position.isEmpty {
                        Text(contact.position)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    if !contact.company.isEmpty {
                        Text(contact.company)
                            .font(.caption)
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            Divider()
            
            // Enhanced Contact Information
            VStack(spacing: 6) {
                if !contact.email.isEmpty {
                    ContactInfoRow(icon: "envelope.fill", text: contact.email, color: .blue)
                }
                
                if !contact.phone.isEmpty {
                    ContactInfoRow(icon: "phone.fill", text: formatPhoneNumber(contact.phone), color: .green)
                }
                
                if !contact.address.isEmpty {
                    ContactInfoRow(icon: "house.fill", text: contact.address, color: .purple)
                }
                
                if !contact.city.isEmpty || !contact.state.isEmpty || !contact.zipCode.isEmpty {
                    let location = [contact.city, contact.state, contact.zipCode].filter { !$0.isEmpty }.joined(separator: ", ")
                    ContactInfoRow(icon: "location.fill", text: location, color: .red)
                }
                
                // Additional info badges
                HStack(spacing: 6) {
                    if !contact.notes.isEmpty {
                        InfoBadge(icon: "note.text", color: .orange)
                    }
                    
                    if contact.profileImage != nil {
                        InfoBadge(icon: "photo", color: .blue)
                    }
                    
                    InfoBadge(icon: "calendar.badge.plus", color: .green, text: formatCreatedDate(contact.createdDate))
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 8) {
                if !contact.phone.isEmpty {
                    ActionButton(icon: "phone.fill", color: .green) {
                        if let url = URL(string: "tel:\(contact.phone)") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                
                if !contact.email.isEmpty {
                    ActionButton(icon: "envelope.fill", color: .blue) {
                        if let url = URL(string: "mailto:\(contact.email)") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                
                ActionButton(icon: "pencil", color: .orange) {
                    onEdit()
                }
                
                ActionButton(icon: "square.and.arrow.up", color: .purple) {
                    shareContact()
                }
                
                ActionButton(icon: "trash", color: .red) {
                    onDelete()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onTapGesture {
            onEdit()
        }
    }
    
    private func shareContact() {
        let contactText = """
        \(contact.fullName)
        \(contact.position.isEmpty ? "" : contact.position + "\n")\(contact.company.isEmpty ? "" : contact.company + "\n")
        Email: \(contact.email)
        Phone: \(contact.phone)
        \(contact.address.isEmpty ? "" : contact.address + "\n")\(contact.city.isEmpty ? "" : contact.city + ", ")\(contact.state) \(contact.zipCode)
        """
        
        let activityViewController = UIActivityViewController(activityItems: [contactText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func formatPhoneNumber(_ phoneNumber: String) -> String {
        let cleaned = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if cleaned.count == 10 {
            let areaCode = String(cleaned.prefix(3))
            let firstThree = String(cleaned.dropFirst(3).prefix(3))
            let lastFour = String(cleaned.suffix(4))
            return "(\(areaCode)) \(firstThree)-\(lastFour)"
        } else if cleaned.count == 11 && cleaned.hasPrefix("1") {
            let areaCode = String(cleaned.dropFirst().prefix(3))
            let firstThree = String(cleaned.dropFirst(4).prefix(3))
            let lastFour = String(cleaned.suffix(4))
            return "+1 (\(areaCode)) \(firstThree)-\(lastFour)"
        }
        
        return phoneNumber
    }
    
    private func formatCreatedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct ContactInfoRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Spacer()
        }
    }
}

struct ActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(color)
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InfoBadge: View {
    let icon: String
    let color: Color
    let text: String?
    
    init(icon: String, color: Color, text: String? = nil) {
        self.icon = icon
        self.color = color
        self.text = text
    }
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8))
                .foregroundColor(color)
            
            if let text = text {
                Text(text)
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Column Customizer
struct ColumnCustomizerView: View {
    @ObservedObject var contactManager: ContactManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddColumn = false
    @State private var newColumnTitle = ""
    @State private var newColumnType: ContactColumn.FieldType = .text
    
    var body: some View {
        NavigationView {
            List {
                Section("Visible Columns") {
                    ForEach(contactManager.columns) { column in
                        HStack {
                            Image(systemName: column.fieldType.systemImage)
                                .foregroundColor(.orange)
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(column.title)
                                    .font(.body)
                                Text(column.fieldType.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(Int(column.width))px")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Toggle("", isOn: Binding(
                                get: { column.isVisible },
                                set: { _ in contactManager.toggleColumnVisibility(columnId: column.id) }
                            ))
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section {
                    Button("Add Custom Column") {
                        showingAddColumn = true
                    }
                    .foregroundColor(.orange)
                }
            }
            .navigationTitle("Customize Columns")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAddColumn) {
                AddColumnView(
                    title: $newColumnTitle,
                    fieldType: $newColumnType,
                    onAdd: {
                        contactManager.addCustomColumn(title: newColumnTitle, fieldType: newColumnType)
                        newColumnTitle = ""
                        newColumnType = .text
                        showingAddColumn = false
                    },
                    onCancel: {
                        newColumnTitle = ""
                        showingAddColumn = false
                    }
                )
            }
        }
    }
}

struct AddColumnView: View {
    @Binding var title: String
    @Binding var fieldType: ContactColumn.FieldType
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Column Details") {
                    TextField("Column Title", text: $title)
                    
                    Picker("Field Type", selection: $fieldType) {
                        ForEach(ContactColumn.FieldType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.systemImage)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                }
            }
            .navigationTitle("Add Column")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onAdd()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}