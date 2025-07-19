import SwiftUI
import PhotosUI
import Foundation

struct ContactFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var contactManager: ContactManager
    @State private var contact: Contact
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImageData: Data?
    @State private var showingImagePicker = false
    @State private var showingDeleteAlert = false
    
    let isEditing: Bool
    
    init(contactManager: ContactManager, contact: Contact? = nil) {
        self.contactManager = contactManager
        self.isEditing = contact != nil
        self._contact = State(initialValue: contact ?? Contact())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Image Section
                    VStack(spacing: 16) {
                        Button(action: { showingImagePicker = true }) {
                            ZStack {
                                if let imageData = profileImageData ?? contact.profileImage,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.orange, lineWidth: 3)
                                        )
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            VStack(spacing: 8) {
                                                Image(systemName: "camera.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.gray)
                                                Text("Add Photo")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        )
                                }
                                
                                // Camera overlay for existing images
                                if profileImageData != nil || contact.profileImage != nil {
                                    Circle()
                                        .fill(Color.black.opacity(0.4))
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            Image(systemName: "camera")
                                                .foregroundColor(.white)
                                                .font(.title2)
                                        )
                                }
                            }
                        }
                        .photosPicker(isPresented: $showingImagePicker, selection: $selectedPhoto, matching: .images)
                    }
                    .padding(.top, 20)
                    
                    // Basic Information Section
                    FormSectionView(title: "Basic Information") {
                        VStack(spacing: 16) {
                            CustomTextField("First Name", text: $contact.firstName)
                                .textInputAutocapitalization(.words)
                            
                            CustomTextField("Last Name", text: $contact.lastName)
                                .textInputAutocapitalization(.words)
                            
                            CustomTextField("Email", text: $contact.email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                            
                            CustomTextField("Phone", text: $contact.phone)
                                .keyboardType(.phonePad)
                        }
                    }
                    
                    // Work Information Section
                    FormSectionView(title: "Work Information") {
                        VStack(spacing: 16) {
                            CustomTextField("Company", text: $contact.company)
                                .textInputAutocapitalization(.words)
                            
                            CustomTextField("Position", text: $contact.position)
                                .textInputAutocapitalization(.words)
                        }
                    }
                    
                    // Address Information Section
                    FormSectionView(title: "Address") {
                        VStack(spacing: 16) {
                            CustomTextField("Street Address", text: $contact.address)
                                .textInputAutocapitalization(.words)
                            
                            HStack(spacing: 12) {
                                CustomTextField("City", text: $contact.city)
                                    .textInputAutocapitalization(.words)
                                
                                CustomTextField("State", text: $contact.state)
                                    .textInputAutocapitalization(.characters)
                                    .frame(maxWidth: 100)
                                
                                CustomTextField("ZIP", text: $contact.zipCode)
                                    .keyboardType(.numberPad)
                                    .frame(maxWidth: 100)
                            }
                        }
                    }
                    
                    // Notes Section
                    FormSectionView(title: "Notes") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Additional Notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $contact.notes)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                    }
                    
                    // Delete Button (only for editing)
                    if isEditing {
                        Button("Delete Contact") {
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.top, 20)
                    }
                    
                    // Bottom spacing for keyboard
                    Spacer()
                        .frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle(isEditing ? "Edit Contact" : "New Contact")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveContact()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                    .disabled(contact.firstName.isEmpty && contact.lastName.isEmpty)
                }
            }
            .alert("Delete Contact", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    contactManager.deleteContact(contact)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this contact? This action cannot be undone.")
            }
            .onChange(of: selectedPhoto) { newValue in
                Task {
                    if let photo = newValue,
                       let data = try? await photo.loadTransferable(type: Data.self) {
                        profileImageData = data
                    }
                }
            }
        }
    }
    
    private func saveContact() {
        print("Debug: saveContact() called - isEditing: \(isEditing)")
        print("Debug: Contact details - Name: \(contact.fullName), Email: \(contact.email)")
        
        // Validate contact data before saving
        guard !contact.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
              !contact.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Debug: ERROR - Contact name is required")
            showErrorAlert("Contact name is required. Please enter at least a first or last name.")
            return
        }
        
        // Update contact with selected image (only if a new image was selected)
        if let imageData = profileImageData {
            contact.profileImage = imageData
            print("Debug: New profile image added to contact")
        }
        // Note: If no new image is selected during editing, we preserve the existing contact.profileImage
        
        if isEditing {
            print("Debug: Updating existing contact")
            contactManager.updateContact(contact)
        } else {
            print("Debug: Adding new contact")
            contactManager.addContact(contact)
        }
        
        print("Debug: Save operation completed successfully")
        dismiss()
    }
    
    private func showErrorAlert(_ message: String) {
        // This should show an alert to the user - for now we'll use print
        // In a real implementation, you'd use an @State variable to show an alert
        print("Debug: USER ERROR ALERT - \(message)")
        
        // Post notification for error handling
        NotificationCenter.default.post(
            name: NSNotification.Name("ContactFormError"),
            object: nil,
            userInfo: ["message": message]
        )
    }
}

// MARK: - Supporting Views

struct FormSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.leading, 4)
            
            VStack(spacing: 16) {
                content
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(placeholder)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            TextField(placeholder, text: $text)
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}