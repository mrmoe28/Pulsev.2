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
            Form {
                // Profile Image Section
                Section {
                    VStack(spacing: 16) {
                        // Profile Image
                        Button(action: { showingImagePicker = true }) {
                            ZStack {
                                if let imageData = profileImageData ?? contact.profileImage,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.orange, lineWidth: 3)
                                        )
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            VStack {
                                                Image(systemName: "camera.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.gray)
                                                Text("Add Photo")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        )
                                }
                                
                                // Camera overlay
                                Circle()
                                    .fill(Color.black.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "camera")
                                            .foregroundColor(.white)
                                            .font(.title3)
                                    )
                                    .opacity(profileImageData != nil || contact.profileImage != nil ? 0.8 : 0)
                            }
                        }
                        .photosPicker(isPresented: $showingImagePicker, selection: $selectedPhoto, matching: .images)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
                
                // Basic Information
                Section("Basic Information") {
                    TextField("First Name", text: $contact.firstName)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Last Name", text: $contact.lastName)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Email", text: $contact.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    
                    TextField("Phone", text: $contact.phone)
                        .keyboardType(.phonePad)
                }
                
                // Work Information
                Section("Work Information") {
                    TextField("Company", text: $contact.company)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Position", text: $contact.position)
                        .textInputAutocapitalization(.words)
                }
                
                // Address Information
                Section("Address") {
                    TextField("Street Address", text: $contact.address)
                        .textInputAutocapitalization(.words)
                    
                    HStack {
                        TextField("City", text: $contact.city)
                            .textInputAutocapitalization(.words)
                        
                        TextField("State", text: $contact.state)
                            .textInputAutocapitalization(.characters)
                            .frame(maxWidth: 80)
                        
                        TextField("ZIP", text: $contact.zipCode)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: 80)
                    }
                }
                
                // Notes
                Section("Notes") {
                    TextEditor(text: $contact.notes)
                        .frame(minHeight: 100)
                }
                
                // Delete Button (only for editing)
                if isEditing {
                    Section {
                        Button("Delete Contact") {
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Contact" : "New Contact")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveContact()
                    }
                    .fontWeight(.semibold)
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