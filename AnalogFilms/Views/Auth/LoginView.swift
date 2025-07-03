import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isPasswordVisible = false
    @State private var animateFields = false
    @State private var backgroundOffset: CGFloat = 0
    
    @EnvironmentObject private var containerWrapper: ContainerWrapper
    @State private var authService: AuthenticationServiceLogic?
    
    let onLoginSuccess: () -> Void
    
    var body: some View {
        ZStack {
            // Animated Background
            animatedBackground
            
            // Main Content
            ScrollView {
                VStack(spacing: 0) {
                    // Logo and Welcome Section
                    welcomeSection
                        .padding(.top, 60)
                    
                    // Login Form
                    loginFormSection
                        .padding(.top, 40)
                    
                    // Guest Access
                    guestAccessSection
                        .padding(.top, 30)
                    
                    // Test Users Info
                    testUsersSection
                        .padding(.top, 40)
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            setupAuthService()
            startAnimations()
        }
    }
    
    // MARK: - Background
    
    private var animatedBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.88, green: 0.92, blue: 0.98),
                    Color(red: 0.82, green: 0.88, blue: 0.96)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating shapes
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignTokens.Colors.primaryAccent.opacity(0.1),
                                DesignTokens.Colors.secondaryAccent.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat(60 + index * 20), height: CGFloat(60 + index * 20))
                    .offset(
                        x: CGFloat(index * 80 - 160) + backgroundOffset,
                        y: CGFloat(index * 120 - 240) - backgroundOffset * 0.5
                    )
                    .rotationEffect(.degrees(backgroundOffset * 0.1))
                    .animation(
                        .linear(duration: 20 + Double(index * 2))
                        .repeatForever(autoreverses: true),
                        value: backgroundOffset
                    )
            }
        }
    }
    
    // MARK: - Welcome Section
    
    private var welcomeSection: some View {
        VStack(spacing: 20) {
            // Logo
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
                    .frame(width: 100, height: 100)
                    .scaleEffect(animateFields ? 1.0 : 0.8)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateFields)
                
                Image(systemName: "camera.vintage")
                    .font(.system(size: 40, weight: .medium))
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
                    .scaleEffect(animateFields ? 1.0 : 0.8)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1), value: animateFields)
            }
            
            // Welcome Text
            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .opacity(animateFields ? 1.0 : 0)
                    .offset(y: animateFields ? 0 : 20)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: animateFields)
                
                Text("Sign in to continue your analog journey")
                    .font(.subheadline)
                    .foregroundColor(DesignTokens.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(animateFields ? 1.0 : 0)
                    .offset(y: animateFields ? 0 : 20)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: animateFields)
            }
        }
    }
    
    // MARK: - Login Form Section
    
    private var loginFormSection: some View {
        VStack(spacing: 24) {
            // Email Field
            modernTextField(
                title: "Email",
                text: $email,
                icon: "envelope.fill",
                keyboardType: .emailAddress,
                isSecure: false
            )
            .opacity(animateFields ? 1.0 : 0)
            .offset(x: animateFields ? 0 : -50)
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: animateFields)
            
            // Password Field
            modernTextField(
                title: "Password",
                text: $password,
                icon: "lock.fill",
                keyboardType: .default,
                isSecure: !isPasswordVisible,
                trailingButton: {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPasswordVisible.toggle()
                        }
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .font(.subheadline)
                            .foregroundColor(DesignTokens.Colors.textSecondary)
                    }
                }
            )
            .opacity(animateFields ? 1.0 : 0)
            .offset(x: animateFields ? 0 : -50)
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: animateFields)
            
            // Login Button
            modernLoginButton
                .opacity(animateFields ? 1.0 : 0)
                .offset(y: animateFields ? 0 : 30)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: animateFields)
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Guest Access Section
    
    private var guestAccessSection: some View {
        VStack(spacing: 16) {
            // Divider
            HStack {
                Rectangle()
                    .fill(DesignTokens.Colors.textTertiary.opacity(0.3))
                    .frame(height: 1)
                
                Text("OR")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DesignTokens.Colors.textTertiary)
                    .padding(.horizontal, 16)
                
                Rectangle()
                    .fill(DesignTokens.Colors.textTertiary.opacity(0.3))
                    .frame(height: 1)
            }
            .opacity(animateFields ? 1.0 : 0)
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.7), value: animateFields)
            
            // Guest Button
            modernGuestButton
                .opacity(animateFields ? 1.0 : 0)
                .offset(y: animateFields ? 0 : 30)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: animateFields)
        }
    }
    
    // MARK: - Test Users Section
    
    private var testUsersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Test Accounts")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(DesignTokens.Colors.textPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(User.localPasswords.keys.sorted()), id: \.self) { email in
                    if let password = User.localPasswords[email] {
                        testUserRow(email: email, password: password)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DesignTokens.Colors.primaryAccent.opacity(0.2), lineWidth: 1)
                )
        )
        .opacity(animateFields ? 1.0 : 0)
        .offset(y: animateFields ? 0 : 30)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.9), value: animateFields)
    }
    
    // MARK: - Helper Views
    
    private func modernTextField<TrailingContent: View>(
        title: String,
        text: Binding<String>,
        icon: String,
        keyboardType: UIKeyboardType,
        isSecure: Bool,
        @ViewBuilder trailingButton: () -> TrailingContent = { EmptyView() }
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(DesignTokens.Colors.textSecondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(DesignTokens.Colors.primaryAccent)
                    .frame(width: 20)
                
                Group {
                    if isSecure {
                        SecureField("Enter \(title.lowercased())", text: text)
                    } else {
                        TextField("Enter \(title.lowercased())", text: text)
                            .keyboardType(keyboardType)
                            .textInputAutocapitalization(.never)
                    }
                }
                .font(.body)
                .foregroundColor(DesignTokens.Colors.textPrimary)
                
                trailingButton()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                text.wrappedValue.isEmpty
                                ? DesignTokens.Colors.textTertiary.opacity(0.3)
                                : DesignTokens.Colors.primaryAccent.opacity(0.5),
                                lineWidth: 1.5
                            )
                    )
            )
        }
    }
    
    private var modernLoginButton: some View {
        Button {
            Task {
                await handleLogin()
            }
        } label: {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                }
                
                Text(isLoading ? "Signing In..." : "Sign In")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignTokens.Colors.primaryAccent,
                                DesignTokens.Colors.primaryAccent.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: DesignTokens.Colors.primaryAccent.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
        .disabled(isLoading || email.isEmpty || password.isEmpty)
        .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: email.isEmpty || password.isEmpty)
    }
    
    private var modernGuestButton: some View {
        Button {
            Task {
                await handleGuestLogin()
            }
        } label: {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: DesignTokens.Colors.primaryAccent))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "person.circle")
                        .font(.title3)
                }
                
                Text(isLoading ? "Entering as Guest..." : "Continue as Guest")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(DesignTokens.Colors.primaryAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(DesignTokens.Colors.primaryAccent.opacity(0.5), lineWidth: 2)
                    )
            )
        }
        .disabled(isLoading)
    }
    
    private func testUserRow(email: String, password: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.email = email
                self.password = password
            }
        } label: {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(email)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(DesignTokens.Colors.textPrimary)
                    
                    Text("Password: \(password)")
                        .font(.caption2)
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.left.circle.fill")
                    .font(.caption)
                    .foregroundColor(DesignTokens.Colors.primaryAccent)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(DesignTokens.Colors.primaryAccent.opacity(0.05))
            )
        }
    }
    
    // MARK: - Methods
    
    private func setupAuthService() {
        authService = containerWrapper.container.resolve(AuthenticationServiceLogic.self)
    }
    
    private func startAnimations() {
        // Start background animation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
            backgroundOffset = 100
        }
        
        // Start field animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animateFields = true
        }
    }
    
    private func handleLogin() async {
        guard let authService = authService else { return }
        
        isLoading = true
        
        do {
            _ = try await authService.login(email: email, password: password)
            
            await MainActor.run {
                isLoading = false
                onLoginSuccess()
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func handleGuestLogin() async {
        guard let authService = authService else { return }
        
        isLoading = true
        
        _ = await authService.loginAsGuest()
        
        await MainActor.run {
            isLoading = false
            onLoginSuccess()
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView {
        print("Login success")
    }
    .environmentObject(ContainerWrapper(container: ContainerFactory.createContainer()))
}