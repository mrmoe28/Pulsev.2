import SwiftUI

struct AppLogoView: View {
    let size: LogoSize
    let showText: Bool
    
    enum LogoSize {
        case small, medium, large, icon
        
        var dimension: CGFloat {
            switch self {
            case .icon: return 32
            case .small: return 40
            case .medium: return 60
            case .large: return 80
            }
        }
        
        var textSize: CGFloat {
            switch self {
            case .icon: return 14
            case .small: return 16
            case .medium: return 24
            case .large: return 32
            }
        }
        
        var cornerRadius: CGFloat {
            return dimension * 0.25
        }
    }
    
    init(size: LogoSize = .medium, showText: Bool = true) {
        self.size = size
        self.showText = showText
    }
    
    var body: some View {
        HStack(spacing: size == .icon ? 6 : 12) {
            // Logo Icon
            ZStack {
                // Background gradient
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.orange,
                                Color.orange.opacity(0.8),
                                Color.red.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size.dimension, height: size.dimension)
                    .shadow(color: .orange.opacity(0.3), radius: size.dimension * 0.1, x: 0, y: size.dimension * 0.05)
                
                // Inner elements
                VStack(spacing: 2) {
                    // Top "P" letter
                    Text("P")
                        .font(.system(size: size.dimension * 0.5, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    // Bottom pulse line
                    if size != .icon {
                        HStack(spacing: 1) {
                            ForEach(0..<3, id: \.self) { index in
                                Rectangle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 2, height: size.dimension * 0.1)
                                    .animation(
                                        .easeInOut(duration: 0.6)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                        value: size.dimension
                                    )
                            }
                        }
                    }
                }
            }
            
            // App name text
            if showText && size != .icon {
                HStack(spacing: 0) {
                    Text("Pulse")
                        .font(.system(size: size.textSize, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("CRM")
                        .font(.system(size: size.textSize, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - Animated Logo for Splash Screen
struct AnimatedAppLogoView: View {
    @State private var isAnimating = false
    @State private var pulseScale = 1.0
    @State private var rotationAngle = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Pulse effect background
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseScale)
                    .opacity(2.0 - pulseScale)
                    .animation(
                        .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: false),
                        value: pulseScale
                    )
                
                // Main logo
                AppLogoView(size: .large, showText: false)
                    .rotationEffect(.degrees(rotationAngle))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            
            // Animated text
            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    Text("Pulse")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(x: isAnimating ? 0 : -100)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.5), value: isAnimating)
                    
                    Text("CRM")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .offset(x: isAnimating ? 0 : 100)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.7), value: isAnimating)
                }
                
                Text("Crew Management Dashboard")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .offset(y: isAnimating ? 0 : 50)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(1.0), value: isAnimating)
            }
        }
        .onAppear {
            isAnimating = true
            pulseScale = 1.5
            
            // Subtle rotation effect
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

// MARK: - Top Navigation Logo
struct NavigationLogoView: View {
    var body: some View {
        AppLogoView(size: .small, showText: true)
    }
}

// MARK: - Compact Header Logo
struct HeaderLogoView: View {
    var body: some View {
        HStack {
            Spacer()
            AppLogoView(size: .medium, showText: true)
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}