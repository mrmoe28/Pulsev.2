import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSignUp = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.9), Color.gray.opacity(0.8), Color.gray.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo and Title
                VStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Text("P")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 10) {
                        HStack(spacing: 0) {
                            Text("Pulse")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                            Text("CRM")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.orange)
                        }
                        
                        Text(isSignUp ? "Create your account" : "Welcome back")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                // Auth Form
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .font(.body)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        handleAuth()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                            }
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSignUp.toggle()
                        }
                    }) {
                        HStack {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .foregroundColor(.white.opacity(0.7))
                            Text(isSignUp ? "Sign In" : "Sign Up")
                                .foregroundColor(.orange)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                    }
                }
                
                Spacer()
                
                // Footer
                Text("Secure authentication powered by PulseCRM")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 20)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleAuth() {
        isLoading = true
        
        Task {
            let success = await authManager.login(email: email, password: password)
            
            await MainActor.run {
                isLoading = false
                
                if !success {
                    errorMessage = "Invalid credentials. Please try again."
                    showError = true
                }
            }
        }
    }
}