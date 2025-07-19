import SwiftUI

enum AppPage: String, CaseIterable {
    case dashboard = "Dashboard"
    case contacts = "Contacts"
    case jobs = "Jobs"
    case documents = "Documents"
    case settings = "Settings"
    
    var systemImage: String {
        switch self {
        case .dashboard:
            return "house.fill"
        case .contacts:
            return "person.3.fill"
        case .jobs:
            return "hammer.fill"
        case .documents:
            return "doc.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
    
    var description: String {
        switch self {
        case .dashboard:
            return "Overview and quick stats"
        case .contacts:
            return "Manage your contacts"
        case .jobs:
            return "Track active projects"
        case .documents:
            return "Manage project documents"
        case .settings:
            return "App preferences"
        }
    }
}

enum NavigationStyle: String, CaseIterable {
    case tabs = "Tabs"
    case fullPage = "Full Page"
    
    var systemImage: String {
        switch self {
        case .tabs:
            return "rectangle.split.3x1.fill"
        case .fullPage:
            return "rectangle.fill"
        }
    }
}

class NavigationManager: ObservableObject {
    @Published var currentPage: AppPage = .dashboard
    @Published var navigationStyle: NavigationStyle = .fullPage
    
    private let userDefaults = UserDefaults.standard
    private let navigationStyleKey = "navigation_style"
    private let currentPageKey = "current_page"
    
    init() {
        loadSettings()
    }
    
    func setNavigationStyle(_ style: NavigationStyle) {
        navigationStyle = style
        saveSettings()
    }
    
    func setCurrentPage(_ page: AppPage) {
        currentPage = page
        saveSettings()
    }
    
    private func saveSettings() {
        userDefaults.set(navigationStyle.rawValue, forKey: navigationStyleKey)
        userDefaults.set(currentPage.rawValue, forKey: currentPageKey)
    }
    
    private func loadSettings() {
        if let styleString = userDefaults.string(forKey: navigationStyleKey),
           let style = NavigationStyle(rawValue: styleString) {
            navigationStyle = style
        }
        
        if let pageString = userDefaults.string(forKey: currentPageKey),
           let page = AppPage(rawValue: pageString) {
            currentPage = page
        }
    }
}

struct NavigationStyleToggleView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        HStack {
            Image(systemName: navigationManager.navigationStyle.systemImage)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 24)
            
            Text("Navigation Style")
                .fontWeight(.medium)
            
            Spacer()
            
            Picker("Navigation Style", selection: $navigationManager.navigationStyle) {
                ForEach(NavigationStyle.allCases, id: \.self) { style in
                    HStack {
                        Image(systemName: style.systemImage)
                        Text(style.rawValue)
                    }
                    .tag(style)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 120)
        }
        .padding(.vertical, 2)
    }
}