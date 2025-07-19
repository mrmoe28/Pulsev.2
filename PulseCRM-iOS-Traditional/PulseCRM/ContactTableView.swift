import SwiftUI

struct ContactTableView: View {
    @ObservedObject var contactManager: ContactManager
    @State private var showingColumnCustomizer = false
    @State private var editingContact: Contact?
    @State private var sortColumn: String = "firstName"
    @State private var sortAscending: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Enhanced Table Header with sorting
            VStack(spacing: 0) {
                // Column headers
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(contactManager.visibleColumns) { column in
                            Button(action: {
                                if sortColumn == column.key {
                                    sortAscending.toggle()
                                } else {
                                    sortColumn = column.key
                                    sortAscending = true
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: column.fieldType.systemImage)
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    
                                    Text(column.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    if sortColumn == column.key {
                                        Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
                                            .font(.caption2)
                                            .foregroundColor(.orange)
                                    }
                                    
                                    Spacer()
                                }
                                .frame(width: column.width, height: 50)
                                .padding(.horizontal, 8)
                                .background(Color(.systemGray6))
                                .overlay(
                                    Rectangle()
                                        .fill(Color.orange.opacity(0.1))
                                        .frame(height: sortColumn == column.key ? 50 : 0)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Actions column header
                        HStack(spacing: 8) {
                            Image(systemName: "gearshape")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text("Actions")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .frame(width: 120, height: 50)
                        .padding(.horizontal, 8)
                        .background(Color(.systemGray6))
                    }
                }
                
                // Header bottom border
                Rectangle()
                    .fill(Color.orange)
                    .frame(height: 2)
            }
            
            // Enhanced Table Content with better styling
            ScrollView(.horizontal, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    // Empty state
                    if sortedContacts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("No Contacts Found")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Text(contactManager.searchText.isEmpty ? 
                                "Add your first contact to get started" : 
                                "No contacts match your search criteria")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            if contactManager.searchText.isEmpty {
                                Button("Add Contact") {
                                    editingContact = Contact()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.orange)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        ForEach(Array(sortedContacts.enumerated()), id: \.element.id) { index, contact in
                            ContactRowView(
                                contact: contact,
                                columns: contactManager.visibleColumns,
                                contactManager: contactManager,
                                rowIndex: index,
                                onEdit: { editingContact = contact },
                                onUpdate: { updatedContact in
                                    contactManager.updateContact(updatedContact)
                                }
                            )
                            .background(index % 2 == 0 ? Color(.systemBackground) : Color(.systemGray6).opacity(0.3))
                            
                            if index < sortedContacts.count - 1 {
                                Divider()
                                    .background(Color(.systemGray4))
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .sheet(item: $editingContact) { contact in
            ContactFormView(contactManager: contactManager, contact: contact)
        }
        .sheet(isPresented: $showingColumnCustomizer) {
            ColumnCustomizerView(contactManager: contactManager)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Columns") {
                    showingColumnCustomizer = true
                }
                .font(.subheadline)
                .foregroundColor(.orange)
                
                Button("Add Contact") {
                    editingContact = Contact()
                }
                .font(.subheadline)
                .foregroundColor(.orange)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var sortedContacts: [Contact] {
        let contacts = contactManager.filteredContacts
        return contacts.sorted { contact1, contact2 in
            let comparison: ComparisonResult
            
            switch sortColumn {
            case "firstName":
                comparison = contact1.firstName.localizedCompare(contact2.firstName)
            case "lastName":
                comparison = contact1.lastName.localizedCompare(contact2.lastName)
            case "email":
                comparison = contact1.email.localizedCompare(contact2.email)
            case "phone":
                comparison = contact1.phone.localizedCompare(contact2.phone)
            case "company":
                comparison = contact1.company.localizedCompare(contact2.company)
            case "position":
                comparison = contact1.position.localizedCompare(contact2.position)
            case "city":
                comparison = contact1.city.localizedCompare(contact2.city)
            case "state":
                comparison = contact1.state.localizedCompare(contact2.state)
            case "zipCode":
                comparison = contact1.zipCode.localizedCompare(contact2.zipCode)
            case "createdDate":
                comparison = contact1.createdDate < contact2.createdDate ? .orderedAscending : 
                           contact1.createdDate > contact2.createdDate ? .orderedDescending : .orderedSame
            default:
                comparison = contact1.firstName.localizedCompare(contact2.firstName)
            }
            
            return sortAscending ? comparison == .orderedAscending : comparison == .orderedDescending
        }
    }
}

struct ContactRowView: View {
    let contact: Contact
    let columns: [ContactColumn]
    let contactManager: ContactManager
    let rowIndex: Int
    let onEdit: () -> Void
    let onUpdate: (Contact) -> Void
    
    @State private var editingField: String?
    @State private var editValue: String = ""
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Row number indicator
            Text("\(rowIndex + 1)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30, height: 65)
                .background(Color(.systemGray5))
            
            ForEach(columns) { column in
                HStack(spacing: 8) {
                    // Cell content
                    ContactCellView(
                        contact: contact,
                        column: column,
                        isEditing: editingField == column.key,
                        editValue: $editValue,
                        onStartEdit: {
                            editingField = column.key
                            editValue = getFieldValue(for: column.key)
                        },
                        onEndEdit: {
                            updateContactField(key: column.key, value: editValue)
                            editingField = nil
                        }
                    )
                    
                    Spacer()
                    
                    // Quick edit button for editable fields
                    if column.isEditable && editingField != column.key && !getFieldValue(for: column.key).isEmpty {
                        Button(action: {
                            editingField = column.key
                            editValue = getFieldValue(for: column.key)
                        }) {
                            Image(systemName: "pencil.circle")
                                .font(.caption)
                                .foregroundColor(.orange.opacity(0.6))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .opacity(0.8)
                    }
                }
                .frame(width: column.width, height: 65)
                .padding(.horizontal, 8)
                .background(
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture(count: 2) {
                            if column.isEditable {
                                editingField = column.key
                                editValue = getFieldValue(for: column.key)
                            }
                        }
                )
            }
            
            // Action buttons at the end of each row
            HStack(spacing: 8) {
                // Edit button
                Button(action: { onEdit() }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                
                // Share button
                Button(action: { shareContact() }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.purple)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                
                // Delete button
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 120)
            .padding(.horizontal, 8)
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            onEdit()
        }
        .alert("Delete Contact", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                contactManager.deleteContact(contact)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this contact? This action cannot be undone.")
        }
    }
    
    private func getFieldValue(for key: String) -> String {
        switch key {
        case "firstName": return contact.firstName
        case "lastName": return contact.lastName
        case "email": return contact.email
        case "phone": return contact.phone
        case "company": return contact.company
        case "position": return contact.position
        case "address": return contact.address
        case "city": return contact.city
        case "state": return contact.state
        case "zipCode": return contact.zipCode
        case "notes": return contact.notes
        default:
            if key.hasPrefix("custom_") {
                return contact.customFields[key] ?? ""
            }
            return ""
        }
    }
    
    private func updateContactField(key: String, value: String) {
        var updatedContact = contact
        
        switch key {
        case "firstName": updatedContact.firstName = value
        case "lastName": updatedContact.lastName = value
        case "email": updatedContact.email = value
        case "phone": updatedContact.phone = value
        case "company": updatedContact.company = value
        case "position": updatedContact.position = value
        case "address": updatedContact.address = value
        case "city": updatedContact.city = value
        case "state": updatedContact.state = value
        case "zipCode": updatedContact.zipCode = value
        case "notes": updatedContact.notes = value
        default:
            if key.hasPrefix("custom_") {
                updatedContact.customFields[key] = value
            }
        }
        
        onUpdate(updatedContact)
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
}

struct ContactCellView: View {
    let contact: Contact
    let column: ContactColumn
    let isEditing: Bool
    @Binding var editValue: String
    let onStartEdit: () -> Void
    let onEndEdit: () -> Void
    
    var body: some View {
        Group {
            if isEditing {
                TextField("Enter value", text: $editValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
                    .onSubmit {
                        onEndEdit()
                    }
            } else {
                switch column.fieldType {
                case .image:
                    ProfileImageView(imageData: contact.profileImage)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                case .text, .notes:
                    VStack(alignment: .leading, spacing: 2) {
                        Text(getDisplayValue())
                            .font(.body)
                            .fontWeight(column.key == "firstName" || column.key == "lastName" ? .medium : .regular)
                            .foregroundColor(getDisplayValue().isEmpty ? .secondary : .primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        if getDisplayValue().isEmpty {
                            Text("—")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                case .email:
                    VStack(alignment: .leading, spacing: 2) {
                        if !getDisplayValue().isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "envelope.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                Text(getDisplayValue())
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "envelope")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("No email")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                case .phone:
                    VStack(alignment: .leading, spacing: 2) {
                        if !getDisplayValue().isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "phone.fill")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                                Text(formatPhoneNumber(getDisplayValue()))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "phone")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("No phone")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                case .date:
                    VStack(alignment: .leading, spacing: 2) {
                        if column.key == "createdDate" {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(contact.createdDate, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                    Text(contact.createdDate, style: .time)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else {
                            Text(getDisplayValue())
                                .font(.body)
                                .foregroundColor(getDisplayValue().isEmpty ? .secondary : .primary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    private func getDisplayValue() -> String {
        switch column.key {
        case "firstName": return contact.firstName
        case "lastName": return contact.lastName
        case "email": return contact.email
        case "phone": return contact.phone
        case "company": return contact.company
        case "position": return contact.position
        case "address": return contact.address
        case "city": return contact.city
        case "state": return contact.state
        case "zipCode": return contact.zipCode
        case "notes": return contact.notes
        default:
            if column.key.hasPrefix("custom_") {
                return contact.customFields[column.key] ?? ""
            }
            return ""
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
}

struct ProfileImageView: View {
    let imageData: Data?
    
    var body: some View {
        Group {
            if let imageData = imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.orange, lineWidth: 1)
                    )
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    )
            }
        }
    }
}