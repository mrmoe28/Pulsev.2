import SwiftUI

enum ThemeMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    var systemImage: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: ThemeMode = .system
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selected_theme"
    
    init() {
        loadTheme()
    }
    
    func setTheme(_ theme: ThemeMode) {
        currentTheme = theme
        saveTheme()
    }
    
    private func saveTheme() {
        userDefaults.set(currentTheme.rawValue, forKey: themeKey)
    }
    
    private func loadTheme() {
        if let themeString = userDefaults.string(forKey: themeKey),
           let theme = ThemeMode(rawValue: themeString) {
            currentTheme = theme
        }
    }
}

struct ThemeToggleView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: themeManager.currentTheme.systemImage)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 24)
            
            Text("Appearance")
                .fontWeight(.medium)
            
            Spacer()
            
            Picker("Theme", selection: $themeManager.currentTheme) {
                ForEach(ThemeMode.allCases, id: \.self) { theme in
                    HStack {
                        Image(systemName: theme.systemImage)
                        Text(theme.rawValue)
                    }
                    .tag(theme)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 120)
        }
        .padding(.vertical, 2)
    }
}

struct QuickThemeToggle: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: {
            let nextTheme: ThemeMode
            switch themeManager.currentTheme {
            case .system:
                nextTheme = .light
            case .light:
                nextTheme = .dark
            case .dark:
                nextTheme = .system
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                themeManager.setTheme(nextTheme)
            }
        }) {
            Image(systemName: themeManager.currentTheme.systemImage)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 32, height: 32)
                .background(Color(.systemGray6))
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}