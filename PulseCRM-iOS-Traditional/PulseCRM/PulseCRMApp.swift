import SwiftUI

@main
struct PulseCRMApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .environmentObject(navigationManager)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        // SwiftData ModelContainer - temporarily disabled for development
        // TODO: Re-enable once all models are properly implemented
        /*
        .modelContainer(for: [
            ContactData.self,
            JobData.self,
            DocumentData.self
        ]) { result in
            switch result {
            case .success(let container):
                print("SwiftData: ModelContainer initialized successfully")
                container.mainContext.autosaveEnabled = true
            case .failure(let error):
                print("SwiftData Error: Failed to initialize ModelContainer - \(error)")
                fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
            }
        }
        */
    }
}

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        // Check if user is logged in from UserDefaults
        if let userData = UserDefaults.standard.data(forKey: "pulse_user"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    @MainActor
    func login(email: String, password: String) async -> Bool {
        // Simulate API login
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        // For demo purposes, accept any email/password
        let user = User(id: UUID().uuidString, email: email, name: email.components(separatedBy: "@").first ?? "User")
        
        currentUser = user
        isAuthenticated = true
        
        // Save to UserDefaults
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "pulse_user")
        }
        
        return true
    }
    
    @MainActor
    func logout() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "pulse_user")
    }
}

struct User: Codable {
    let id: String        // Keep ID immutable for data integrity
    var email: String     // Make email mutable for profile updates
    var name: String      // Make name mutable for profile updates
}

// MARK: - Validation Utilities

struct ValidationUtils {
    
    // MARK: - Email Validation
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Phone Number Validation
    static func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^[\\+]?[1-9]?[0-9]{7,12}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
    
    // MARK: - Password Validation
    static func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters, one uppercase, one lowercase, one number, one special character
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    // MARK: - Name Validation
    static func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 2 && trimmed.count <= 50
    }
    
    // MARK: - Required Field Validation
    static func isRequiredFieldValid(_ field: String) -> Bool {
        return !field.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Zip Code Validation
    static func isValidZipCode(_ zipCode: String) -> Bool {
        let zipRegex = "^[0-9]{5}(-[0-9]{4})?$"
        let zipPredicate = NSPredicate(format: "SELF MATCHES %@", zipRegex)
        return zipPredicate.evaluate(with: zipCode)
    }
}

// MARK: - Validation Result

struct ValidationResult {
    let isValid: Bool
    let errorMessage: String?
    
    init(isValid: Bool, errorMessage: String? = nil) {
        self.isValid = isValid
        self.errorMessage = errorMessage
    }
    
    static let valid = ValidationResult(isValid: true)
    
    static func invalid(_ message: String) -> ValidationResult {
        return ValidationResult(isValid: false, errorMessage: message)
    }
}

// MARK: - Form Validator

class FormValidator: ObservableObject {
    @Published var errors: [String: String] = [:]
    
    func validate(field: String, value: String, validationType: ValidationType) -> ValidationResult {
        let result = performValidation(value: value, type: validationType)
        
        if result.isValid {
            errors.removeValue(forKey: field)
        } else {
            errors[field] = result.errorMessage
        }
        
        return result
    }
    
    func validateRequired(field: String, value: String, fieldName: String) -> ValidationResult {
        if ValidationUtils.isRequiredFieldValid(value) {
            errors.removeValue(forKey: field)
            return .valid
        } else {
            let message = "\(fieldName) is required"
            errors[field] = message
            return .invalid(message)
        }
    }
    
    func clearErrors() {
        errors.removeAll()
    }
    
    func clearError(for field: String) {
        errors.removeValue(forKey: field)
    }
    
    var isValid: Bool {
        return errors.isEmpty
    }
    
    private func performValidation(value: String, type: ValidationType) -> ValidationResult {
        switch type {
        case .email:
            return ValidationUtils.isValidEmail(value) ? .valid : .invalid("Please enter a valid email address")
        case .phone:
            return ValidationUtils.isValidPhoneNumber(value) ? .valid : .invalid("Please enter a valid phone number")
        case .password:
            return ValidationUtils.isValidPassword(value) ? .valid : .invalid("Password must be at least 8 characters with uppercase, lowercase, number, and special character")
        case .name:
            return ValidationUtils.isValidName(value) ? .valid : .invalid("Name must be between 2 and 50 characters")
        case .zipCode:
            return ValidationUtils.isValidZipCode(value) ? .valid : .invalid("Please enter a valid zip code")
        case .required:
            return ValidationUtils.isRequiredFieldValid(value) ? .valid : .invalid("This field is required")
        }
    }
}

enum ValidationType {
    case email
    case phone
    case password
    case name
    case zipCode
    case required
}

// MARK: - SwiftUI Extensions

extension View {
    func validationError(_ error: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            self
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - Validated Text Field

struct ValidatedTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let validationType: ValidationType
    @ObservedObject var validator: FormValidator
    let fieldKey: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(validator.errors[fieldKey] != nil ? Color.red : Color.clear, lineWidth: 1)
                )
                .onChange(of: text) { newValue in
                    let _ = validator.validate(field: fieldKey, value: newValue, validationType: validationType)
                }
            
            if let error = validator.errors[fieldKey] {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - Validated Secure Field

struct ValidatedSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let validationType: ValidationType
    @ObservedObject var validator: FormValidator
    let fieldKey: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            SecureField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(validator.errors[fieldKey] != nil ? Color.red : Color.clear, lineWidth: 1)
                )
                .onChange(of: text) { newValue in
                    let _ = validator.validate(field: fieldKey, value: newValue, validationType: validationType)
                }
            
            if let error = validator.errors[fieldKey] {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }
        }
    }
}