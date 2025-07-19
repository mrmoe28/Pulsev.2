import SwiftUI

// MARK: - Settings Views

struct ProfileSettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var displayName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var organization = ""
    @State private var position = ""
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingPasswordChange = false
    
    var body: some View {
        List {
            // Enhanced Profile Card Section
            Section {
                VStack(spacing: 16) {
                    // Profile Image with Enhanced Design
                    VStack(spacing: 12) {
                        ZStack {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.orange, .red]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 3
                                            )
                                    )
                                    .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                            } else {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(.systemGray5), Color(.systemGray4)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 40))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color.orange.opacity(0.5), lineWidth: 2)
                                    )
                            }
                            
                            // Camera icon overlay
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: { showingImagePicker = true }) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                            .frame(width: 28, height: 28)
                                            .background(Color.orange)
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                                    }
                                    .offset(x: -8, y: -8)
                                }
                            }
                        }
                        
                        // Profile Name Display
                        VStack(spacing: 4) {
                            Text(displayName.isEmpty ? "Your Name" : displayName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            if !position.isEmpty || !organization.isEmpty {
                                Text("\(position)\(!position.isEmpty && !organization.isEmpty ? " at " : "")\(organization)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if !email.isEmpty {
                                Text(email)
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            .listRowBackground(Color(.systemBackground))
            
            Section("Personal Information") {
                
                ProfileField(
                    title: "Display Name",
                    icon: "person.circle",
                    text: $displayName,
                    placeholder: "Enter your full name"
                )
                
                ProfileField(
                    title: "Email Address",
                    icon: "envelope.circle",
                    text: $email,
                    placeholder: "Enter your email address",
                    keyboardType: .emailAddress
                )
                
                ProfileField(
                    title: "Phone Number",
                    icon: "phone.circle",
                    text: $phone,
                    placeholder: "Enter your phone number",
                    keyboardType: .phonePad
                )
                
                ProfileField(
                    title: "Organization",
                    icon: "building.2.circle",
                    text: $organization,
                    placeholder: "Enter your company or organization"
                )
                
                ProfileField(
                    title: "Position",
                    icon: "briefcase.circle",
                    text: $position,
                    placeholder: "Enter your job title or role"
                )
            }
            
            Section("Security") {
                Button("Change Password") {
                    showingPasswordChange = true
                }
                .foregroundColor(.orange)
            }
            
            Section("Actions") {
                HStack {
                    Spacer()
                    Button(action: {
                        saveProfile()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                            Text("Save Profile")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                        .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Profile Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadProfile()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $profileImage)
        }
        .sheet(isPresented: $showingPasswordChange) {
            PasswordChangeView()
        }
    }
    
    private func loadProfile() {
        // Load from UserDefaults if available, otherwise use AuthManager data
        displayName = UserDefaults.standard.string(forKey: "pulse_user_display_name") 
                     ?? authManager.currentUser?.name ?? ""
        email = UserDefaults.standard.string(forKey: "pulse_user_email") 
               ?? authManager.currentUser?.email ?? ""
        phone = UserDefaults.standard.string(forKey: "pulse_user_phone") ?? ""
        organization = UserDefaults.standard.string(forKey: "pulse_user_organization") ?? ""
        position = UserDefaults.standard.string(forKey: "pulse_user_position") ?? ""
        
        // Load profile image if available
        if let imageData = UserDefaults.standard.data(forKey: "pulse_user_profile_image") {
            profileImage = UIImage(data: imageData)
        }
    }
    
    private func saveProfile() {
        // Save profile data to UserDefaults
        UserDefaults.standard.set(displayName, forKey: "pulse_user_display_name")
        UserDefaults.standard.set(email, forKey: "pulse_user_email")
        UserDefaults.standard.set(phone, forKey: "pulse_user_phone")
        UserDefaults.standard.set(organization, forKey: "pulse_user_organization")
        UserDefaults.standard.set(position, forKey: "pulse_user_position")
        
        // Save profile image if available
        if let imageData = profileImage?.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "pulse_user_profile_image")
        }
        
        // Update AuthManager with new profile data
        if var currentUser = authManager.currentUser {
            currentUser.name = displayName
            currentUser.email = email
            authManager.currentUser = currentUser
        }
        
        print("Profile saved successfully")
    }
}

struct NotificationSettingsView: View {
    @State private var pushNotifications = true
    @State private var emailNotifications = true
    @State private var jobUpdates = true
    @State private var documentUpdates = true
    @State private var contactUpdates = false
    @State private var weeklyReports = true
    @State private var soundEnabled = true
    @State private var badgeEnabled = true
    @State private var alertStyle = 0
    @State private var quietHoursEnabled = false
    @State private var quietHoursStart = Date()
    @State private var quietHoursEnd = Date()
    @State private var showingQuietHoursStart = false
    @State private var showingQuietHoursEnd = false
    
    var body: some View {
        List {
            Section("General") {
                Toggle("Push Notifications", isOn: $pushNotifications)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                
                Toggle("Email Notifications", isOn: $emailNotifications)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                
                if pushNotifications {
                    Toggle("Sound", isOn: $soundEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                    
                    Toggle("Badge", isOn: $badgeEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Alert Style")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Picker("Alert Style", selection: $alertStyle) {
                            Text("None").tag(0)
                            Text("Banners").tag(1)
                            Text("Alerts").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
            }
            
            Section("Content Updates") {
                Toggle("Job Updates", isOn: $jobUpdates)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                
                Toggle("Document Updates", isOn: $documentUpdates)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                
                Toggle("Contact Updates", isOn: $contactUpdates)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                
                Toggle("Weekly Reports", isOn: $weeklyReports)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
            }
            
            Section("Quiet Hours") {
                Toggle("Enable Quiet Hours", isOn: $quietHoursEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                
                if quietHoursEnabled {
                    // Start Time
                    HStack {
                        Image(systemName: "moon.circle.fill")
                            .foregroundColor(.indigo)
                            .font(.system(size: 20))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Start Time")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(quietHoursStart, formatter: timeFormatter)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Change") {
                            showingQuietHoursStart = true
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingQuietHoursStart = true
                    }
                    
                    // End Time
                    HStack {
                        Image(systemName: "sun.max.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 20))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("End Time")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(quietHoursEnd, formatter: timeFormatter)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Change") {
                            showingQuietHoursEnd = true
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingQuietHoursEnd = true
                    }
                    
                    // Quiet Hours Summary
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("Summary")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        Text("Notifications will be silenced from \(quietHoursStart, formatter: timeFormatter) to \(quietHoursEnd, formatter: timeFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 16)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    Text("Configure quiet hours to pause notifications during specific times")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingQuietHoursStart) {
            TimePickerSheet(
                title: "Quiet Hours Start Time",
                selectedTime: $quietHoursStart,
                isPresented: $showingQuietHoursStart
            )
        }
        .sheet(isPresented: $showingQuietHoursEnd) {
            TimePickerSheet(
                title: "Quiet Hours End Time",
                selectedTime: $quietHoursEnd,
                isPresented: $showingQuietHoursEnd
            )
        }
        .onAppear {
            loadNotificationSettings()
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    private func loadNotificationSettings() {
        // Load saved notification preferences
        pushNotifications = UserDefaults.standard.bool(forKey: "pulse_push_notifications")
        emailNotifications = UserDefaults.standard.bool(forKey: "pulse_email_notifications")
        jobUpdates = UserDefaults.standard.bool(forKey: "pulse_job_updates")
        documentUpdates = UserDefaults.standard.bool(forKey: "pulse_document_updates")
        contactUpdates = UserDefaults.standard.bool(forKey: "pulse_contact_updates")
        weeklyReports = UserDefaults.standard.bool(forKey: "pulse_weekly_reports")
        soundEnabled = UserDefaults.standard.bool(forKey: "pulse_sound_enabled")
        badgeEnabled = UserDefaults.standard.bool(forKey: "pulse_badge_enabled")
        alertStyle = UserDefaults.standard.integer(forKey: "pulse_alert_style")
        quietHoursEnabled = UserDefaults.standard.bool(forKey: "pulse_quiet_hours_enabled")
        
        // Load quiet hours times
        if let startTimeData = UserDefaults.standard.data(forKey: "pulse_quiet_hours_start") {
            quietHoursStart = (try? JSONDecoder().decode(Date.self, from: startTimeData)) ?? Date()
        }
        if let endTimeData = UserDefaults.standard.data(forKey: "pulse_quiet_hours_end") {
            quietHoursEnd = (try? JSONDecoder().decode(Date.self, from: endTimeData)) ?? Date()
        }
        
        // Save settings when values change
        saveNotificationSettings()
    }
    
    private func saveNotificationSettings() {
        // Save all notification preferences
        UserDefaults.standard.set(pushNotifications, forKey: "pulse_push_notifications")
        UserDefaults.standard.set(emailNotifications, forKey: "pulse_email_notifications")
        UserDefaults.standard.set(jobUpdates, forKey: "pulse_job_updates")
        UserDefaults.standard.set(documentUpdates, forKey: "pulse_document_updates")
        UserDefaults.standard.set(contactUpdates, forKey: "pulse_contact_updates")
        UserDefaults.standard.set(weeklyReports, forKey: "pulse_weekly_reports")
        UserDefaults.standard.set(soundEnabled, forKey: "pulse_sound_enabled")
        UserDefaults.standard.set(badgeEnabled, forKey: "pulse_badge_enabled")
        UserDefaults.standard.set(alertStyle, forKey: "pulse_alert_style")
        UserDefaults.standard.set(quietHoursEnabled, forKey: "pulse_quiet_hours_enabled")
        
        // Save quiet hours times
        if let startTimeData = try? JSONEncoder().encode(quietHoursStart) {
            UserDefaults.standard.set(startTimeData, forKey: "pulse_quiet_hours_start")
        }
        if let endTimeData = try? JSONEncoder().encode(quietHoursEnd) {
            UserDefaults.standard.set(endTimeData, forKey: "pulse_quiet_hours_end")
        }
    }
}

struct PrivacySettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var locationServices = false
    @State private var analytics = true
    @State private var crashReporting = true
    @State private var dataSyncEnabled = true
    @State private var biometricAuth = false
    @State private var autoLock = 1
    @State private var shareUsageData = false
    
    var body: some View {
        List {
            Section("Data & Privacy") {
                Toggle("Location Services", isOn: $locationServices)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                
                Toggle("Analytics", isOn: $analytics)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                
                Toggle("Crash Reporting", isOn: $crashReporting)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                
                Toggle("Share Usage Data", isOn: $shareUsageData)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
            }
            
            Section("Security") {
                Toggle("Biometric Authentication", isOn: $biometricAuth)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Auto-Lock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("Auto-Lock", selection: $autoLock) {
                        Text("Immediately").tag(0)
                        Text("1 minute").tag(1)
                        Text("5 minutes").tag(2)
                        Text("15 minutes").tag(3)
                        Text("Never").tag(4)
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Toggle("Data Sync", isOn: $dataSyncEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
            }
            
            Section("Data Management") {
                Button("Export Data") {
                    exportData()
                }
                .foregroundColor(.orange)
                
                Button("Clear Cache") {
                    clearCache()
                }
                .foregroundColor(.orange)
                
                Button("Delete All Data") {
                    deleteAllData()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Privacy & Security")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func exportData() {
        // Create export data structure
        let exportData: [String: Any] = [
            "user_profile": [
                "name": authManager.currentUser?.name ?? "",
                "email": authManager.currentUser?.email ?? "",
                "export_date": Date().ISO8601Format()
            ],
            "contacts": UserDefaults.standard.data(forKey: "pulse_contacts") != nil,
            "jobs": UserDefaults.standard.data(forKey: "pulse_jobs") != nil,
            "documents": UserDefaults.standard.data(forKey: "pulse_documents") != nil,
            "settings": [
                "theme": UserDefaults.standard.string(forKey: "selected_theme") ?? "system",
                "navigation_style": UserDefaults.standard.string(forKey: "navigation_style") ?? "fullPage"
            ]
        ]
        
        // Convert to JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            
            // Create shareable content
            let activityController = UIActivityViewController(
                activityItems: [jsonString],
                applicationActivities: nil
            )
            
            // Present activity controller
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(activityController, animated: true)
            }
        } catch {
            print("Error exporting data: \(error)")
        }
    }
    
    private func clearCache() {
        // Clear image cache
        URLCache.shared.removeAllCachedResponses()
        
        // Clear temporary files
        let tempDirectory = FileManager.default.temporaryDirectory
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
            for file in tempFiles {
                try? FileManager.default.removeItem(at: file)
            }
        } catch {
            print("Error clearing temp files: \(error)")
        }
        
        // Clear any cached document thumbnails
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("PulseCRM")
            .appendingPathComponent("Cache")
        
        if let cachePath = documentsPath, FileManager.default.fileExists(atPath: cachePath.path) {
            try? FileManager.default.removeItem(at: cachePath)
        }
    }
    
    private func deleteAllData() {
        // Remove all UserDefaults data
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "pulse_user")
        defaults.removeObject(forKey: "pulse_user_profile")
        defaults.removeObject(forKey: "pulse_user_profile_image")
        defaults.removeObject(forKey: "pulse_contacts")
        defaults.removeObject(forKey: "pulse_jobs")
        defaults.removeObject(forKey: "pulse_job_custom_fields")
        defaults.removeObject(forKey: "pulse_documents")
        defaults.removeObject(forKey: "pulse_document_custom_fields")
        defaults.removeObject(forKey: "selected_theme")
        defaults.removeObject(forKey: "navigation_style")
        defaults.removeObject(forKey: "current_page")
        
        // Remove all files from Documents directory
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("PulseCRM") {
            try? FileManager.default.removeItem(at: documentsPath)
        }
        
        // Clear cache
        clearCache()
        
        // Log out user
        authManager.logout()
    }
}

struct PasswordChangeView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Current Password") {
                    SecureField("Enter current password", text: $currentPassword)
                }
                
                Section("New Password") {
                    SecureField("Enter new password", text: $newPassword)
                    SecureField("Confirm new password", text: $confirmPassword)
                }
                
                Section {
                    Button("Change Password") {
                        changePassword()
                    }
                    .foregroundColor(.orange)
                    .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Password Change", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func changePassword() {
        // Validate passwords
        guard !currentPassword.isEmpty else {
            errorMessage = "Please enter your current password"
            showingError = true
            return
        }
        
        guard !newPassword.isEmpty else {
            errorMessage = "Please enter a new password"
            showingError = true
            return
        }
        
        guard newPassword.count >= 8 else {
            errorMessage = "Password must be at least 8 characters long"
            showingError = true
            return
        }
        
        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match"
            showingError = true
            return
        }
        
        // Validate password complexity
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        
        if !passwordTest.evaluate(with: newPassword) {
            errorMessage = "Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character"
            showingError = true
            return
        }
        
        // For demo purposes, we'll simulate password change
        // In a real app, this would involve API calls
        
        // Save new password hash (in a real app, this would be done on the server)
        let passwordHash = newPassword.hash
        UserDefaults.standard.set(passwordHash, forKey: "pulse_password_hash")
        
        // Clear form
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
        
        // Show success and dismiss
        dismiss()
    }
}

// MARK: - Profile Field Component

struct ProfileField: View {
    let title: String
    let icon: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
                    .frame(width: 20)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(text.isEmpty ? Color.clear : Color.orange.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Simplified Health Support View

struct HealthSupportView: View {
    @State private var healthKitEnabled = false
    @State private var stepsTracking = false
    @State private var showingPermissionAlert = false
    
    var body: some View {
        List {
            Section("Health & Wellness") {
                Toggle("Enable Health Tracking", isOn: $healthKitEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                
                Toggle("Daily Steps", isOn: $stepsTracking)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                    .disabled(!healthKitEnabled)
            }
            
            Section("Features") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Health tracking helps maintain wellness during construction work")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "heart.circle.fill")
                            .foregroundColor(.red)
                        Text("Heart Rate Monitoring")
                    }
                    
                    HStack {
                        Image(systemName: "figure.walk.circle.fill")
                            .foregroundColor(.green)
                        Text("Activity Tracking")
                    }
                    
                    HStack {
                        Image(systemName: "moon.zzz.circle.fill")
                            .foregroundColor(.indigo)
                        Text("Sleep Quality")
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Health & Wellness")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - About View

struct AboutView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingAccountSettings = false
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text("P")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    VStack(spacing: 4) {
                        Text("PulseCRM")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Construction Management Platform")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            .listRowBackground(Color.clear)
            
            Section("Account") {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Account Details")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("Manage your account information")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("App Information") {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Features: Contact Management, Job Tracking, Document Storage")
                        .font(.caption)
                }
                
                HStack {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.green)
                    Text("Built for teams of 1-100+ members")
                        .font(.caption)
                }
                
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.orange)
                    Text("End-to-end encryption & privacy")
                        .font(.caption)
                }
            }
            
            Section("Support") {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.blue)
                    Text("Contact Support")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Rate the App")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Time Picker Sheet

struct TimePickerSheet: View {
    let title: String
    @Binding var selectedTime: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select the time for \(title.lowercased())")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                DatePicker(
                    "Time",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}