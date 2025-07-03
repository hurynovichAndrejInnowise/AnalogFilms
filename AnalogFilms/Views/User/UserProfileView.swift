import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject private var containerWrapper: ContainerWrapper
    @State private var authService: AuthenticationServiceLogic?
    @State private var showLogoutConfirmation = false
    @State private var animateProfile = false
    @State private var isLoggingOut = false
    
    let onLogout: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                backgroundGradient
                
                // Main Content
                ScrollView {
                    VStack(spacing: 32) {
                        // Profile Header
                        profileHeaderSection
                        
                        // Profile Info
                        profileInfoSection
                        
                        // Statistics Section (placeholder)
                        statisticsSection
                        
                        // Actions Section
                        actionsSection
                        
                        // Logout Section
                        logoutSection
                        
                        // App Info
                        appInfoSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog(
                "Sign Out",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) {
                    Task {
                        await handleLogout()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
        .onAppear {
            setupAuthService()
            startAnimations()
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.98, blue: 1.0),
                Color(red: 0.95, green: 0.96, blue: 0.98),
                Color(red: 0.92, green: 0.94, blue: 0.97)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Profile Header Section
    
    private var profileHeaderSection: some View {
        VStack(spacing: 20) {
            // Profile Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignTokens.Colors.primaryAccent.opacity(0.2),
                                DesignTokens.Colors.secondaryAccent.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateProfile ? 1.0 : 0.8)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateProfile)
                
                // User Icon or Guest Icon
                Image(systemName: currentUser?.isGuest == true ? "person.circle" : "person.crop.circle.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                DesignTokens.Colors.primaryAccent,
                                DesignTokens.Colors.secondaryAccent
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(animateProfile ? 1.0 : 0.8)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1), value: animateProfile)
                
                // Guest or User Badge
                if let user = currentUser {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            modernBadge(
                                text: user.isGuest ? "Guest" : "Member",
                                color: user.isGuest ? DesignTokens.Colors.secondaryAccent : DesignTokens.Colors.successGreen
                            )
                            .offset(x: 10, y: 10)
                        }
                    }
                    .frame(width: 120, height: 120)
                }
            }
            
            // User Info
            VStack(spacing: 8) {
                Text(currentUser?.name ?? "Unknown User")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .opacity(animateProfile ? 1.0 : 0)
                    .offset(y: animateProfile ? 0 : 20)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: animateProfile)
                
                Text(currentUser?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(DesignTokens.Colors.textSecondary)
                    .opacity(animateProfile ? 1.0 : 0)
                    .offset(y: animateProfile ? 0 : 20)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: animateProfile)
            }
        }
    }
    
    // MARK: - Profile Info Section
    
    private var profileInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Information")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(DesignTokens.Colors.textPrimary)
            
            VStack(spacing: 12) {
                profileInfoRow(
                    icon: "envelope.fill",
                    title: "Email",
                    value: currentUser?.email ?? "",
                    color: DesignTokens.Colors.primaryAccent
                )
                
                profileInfoRow(
                    icon: "person.fill",
                    title: "Account Type",
                    value: currentUser?.isGuest == true ? "Guest User" : "Registered User",
                    color: DesignTokens.Colors.secondaryAccent
                )
                
                profileInfoRow(
                    icon: "key.fill",
                    title: "User ID",
                    value: currentUser?.id ?? "",
                    color: DesignTokens.Colors.textSecondary
                )
            }
        }
        .padding(24)
        .modernCard()
        .opacity(animateProfile ? 1.0 : 0)
        .offset(x: animateProfile ? 0 : -50)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: animateProfile)
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Activity")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(DesignTokens.Colors.textPrimary)
            
            HStack(spacing: 16) {
                statisticCard(
                    icon: "heart.fill",
                    title: "Favorites",
                    value: "0", // Placeholder - could be connected to actual data
                    color: DesignTokens.Colors.favoriteRed
                )
                
                statisticCard(
                    icon: "eye.fill",
                    title: "Films Viewed",
                    value: "0", // Placeholder
                    color: DesignTokens.Colors.primaryAccent
                )
                
                statisticCard(
                    icon: "clock.fill",
                    title: "Time Active",
                    value: "Today", // Placeholder
                    color: DesignTokens.Colors.successGreen
                )
            }
        }
        .padding(24)
        .modernCard()
        .opacity(animateProfile ? 1.0 : 0)
        .offset(x: animateProfile ? 0 : 50)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: animateProfile)
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(DesignTokens.Colors.textPrimary)
            
            VStack(spacing: 12) {
                actionButton(
                    icon: "heart.fill",
                    title: "View Favorites",
                    subtitle: "See your pinned films",
                    color: DesignTokens.Colors.favoriteRed
                ) {
                    // Action to view favorites
                }
                
                actionButton(
                    icon: "gear",
                    title: "App Settings",
                    subtitle: "Customize your experience",
                    color: DesignTokens.Colors.textSecondary
                ) {
                    // Action for settings
                }
            }
        }
        .padding(24)
        .modernCard()
        .opacity(animateProfile ? 1.0 : 0)
        .offset(y: animateProfile ? 0 : 30)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: animateProfile)
    }
    
    // MARK: - Logout Section
    
    private var logoutSection: some View {
        Button {
            showLogoutConfirmation = true
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(DesignTokens.Colors.secondaryAccent.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: isLoggingOut ? "arrow.counterclockwise" : "rectangle.portrait.and.arrow.right")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(DesignTokens.Colors.secondaryAccent)
                        .rotationEffect(.degrees(isLoggingOut ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isLoggingOut)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(isLoggingOut ? "Signing Out..." : "Sign Out")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignTokens.Colors.secondaryAccent)
                    
                    Text("Return to login screen")
                        .font(.caption)
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(DesignTokens.Colors.secondaryAccent.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(DesignTokens.Colors.secondaryAccent.opacity(0.2), lineWidth: 1.5)
                    )
            )
        }
        .disabled(isLoggingOut)
        .opacity(animateProfile ? 1.0 : 0)
        .offset(y: animateProfile ? 0 : 30)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.7), value: animateProfile)
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        VStack(spacing: 12) {
            Text("Analog Films")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(DesignTokens.Colors.textPrimary)
            
            Text("Version 1.0.0")
                .font(.caption)
                .foregroundColor(DesignTokens.Colors.textTertiary)
            
            Text("Discover the magic of film photography")
                .font(.caption)
                .foregroundColor(DesignTokens.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .opacity(animateProfile ? 1.0 : 0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: animateProfile)
    }
    
    // MARK: - Helper Views
    
    private func modernBadge(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color)
                    .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: 1)
            )
    }
    
    private func profileInfoRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DesignTokens.Colors.textSecondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
    }
    
    private func statisticCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(DesignTokens.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.05))
        )
    }
    
    private func actionButton(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignTokens.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DesignTokens.Colors.textTertiary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var currentUser: User? {
        authService?.currentUser
    }
    
    // MARK: - Methods
    
    private func setupAuthService() {
        authService = containerWrapper.container.resolve(AuthenticationServiceLogic.self)
    }
    
    private func startAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animateProfile = true
        }
    }
    
    private func handleLogout() async {
        guard let authService = authService else { return }
        
        isLoggingOut = true
        
        await authService.logout()
        
        await MainActor.run {
            isLoggingOut = false
            onLogout()
        }
    }
}

// MARK: - Preview

#Preview {
    UserProfileView {
        print("Logout")
    }
    .environmentObject(ContainerWrapper(container: ContainerFactory.createContainer()))
}