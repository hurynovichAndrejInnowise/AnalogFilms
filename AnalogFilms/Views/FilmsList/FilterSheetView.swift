import SwiftUI

struct FilterSheetView: View {
    @Binding var filter: FilmFilter
    let brands: [String]
    let clearAction: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedBrandIndex: Int = 0
    @State private var selectedSortIndex: Int = 0
    
    let onSortChanged: (() -> Void)?
    let onBrandChanged: (() -> Void)?
    
    init(
        filter: Binding<FilmFilter>,
        brands: [String],
        clearAction: @escaping () -> Void,
        onSortChanged: (() -> Void)? = nil,
        onBrandChanged: (() -> Void)? = nil
    ) {
        self._filter = filter
        self.brands = brands
        self.clearAction = clearAction
        self.onSortChanged = onSortChanged
        self.onBrandChanged = onBrandChanged
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                backgroundGradient
                
                // Content
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.xl) {
                        // Header
                        headerSection
                        
                        // Brand Filter Section
                        brandFilterSection
                        
                        // Sort Filter Section
                        sortFilterSection
                        
                        // Bottom Spacing
                        Spacer(minLength: DesignTokens.Spacing.xxxl)
                    }
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            clearAction()
                            selectedBrandIndex = 0
                            selectedSortIndex = FilmSortOption.allOptions.firstIndex(of: .popularityDesc) ?? 0
                        }
                    }
                    .foregroundColor(DesignTokens.Colors.secondaryAccent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignTokens.Colors.primaryAccent)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            setupInitialValues()
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.98, blue: 1.0),
                Color(red: 0.95, green: 0.96, blue: 0.98)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.title2)
                    .foregroundColor(DesignTokens.Colors.primaryAccent)
                
                Text("Filter & Sort Films")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Spacer()
            }
            
            Text("Customize your film discovery experience")
                .font(.subheadline)
                .foregroundColor(DesignTokens.Colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, DesignTokens.Spacing.md)
    }
    
    // MARK: - Brand Filter Section
    
    private var brandFilterSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            // Section Header
            HStack {
                Image(systemName: "building.2.fill")
                    .font(.headline)
                    .foregroundColor(DesignTokens.Colors.primaryAccent)
                
                Text("Brand")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Spacer()
                
                if filter.selectedBrand != nil {
                    Button("Clear") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            filter.selectedBrand = nil
                            selectedBrandIndex = 0
                            onBrandChanged?()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(DesignTokens.Colors.secondaryAccent)
                }
            }
            
            // Brand Picker
            VStack(spacing: DesignTokens.Spacing.sm) {
                modernSegmentedPicker(
                    selection: $selectedBrandIndex,
                    options: ["All"] + brands,
                    maxDisplayed: 3
                ) { index in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        let oldBrand = filter.selectedBrand
                        
                        if index == 0 {
                            filter.selectedBrand = nil
                        } else {
                            filter.selectedBrand = brands[index - 1]
                        }
                        
                        // Call immediate brand change if brand actually changed
                        if oldBrand != filter.selectedBrand {
                            print("🔄 Brand changed to: \(filter.selectedBrand ?? "All")")
                            onBrandChanged?()
                        }
                    }
                }
            }
        }
        .padding(DesignTokens.Spacing.xl)
        .modernCard()
    }
    
    // MARK: - Sort Filter Section
    
    private var sortFilterSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            // Section Header
            HStack {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.headline)
                    .foregroundColor(DesignTokens.Colors.primaryAccent)
                
                Text("Sort By")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Spacer()
            }
            
            // Sort Options
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignTokens.Spacing.md) {
                ForEach(Array(FilmSortOption.allOptions.enumerated()), id: \.offset) { index, option in
                    modernSortOption(
                        option: option,
                        isSelected: filter.sortOption == option
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            let oldSortOption = filter.sortOption
                            filter.sortOption = option
                            
                            // Call immediate sort change if sort option actually changed
                            if oldSortOption != option {
                                print("Sort changed to: \(option.apiValue)")
                                onSortChanged?()
                            }
                        }
                    }
                }
            }
        }
        .padding(DesignTokens.Spacing.xl)
        .modernCard()
    }
    
    
    // MARK: - Helper Views

    private func modernSegmentedPicker(
        selection: Binding<Int>,
        options: [String],
        maxDisplayed: Int,
        onSelection: @escaping (Int) -> Void
    ) -> some View {
        let chunkedOptions = options.chunked(into: maxDisplayed)
        
        return VStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(Array(chunkedOptions.enumerated()), id: \.offset) { chunkIndex, chunk in
                HStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(Array(chunk.enumerated()), id: \.offset) { itemIndex, option in
                        let globalIndex = chunkIndex * maxDisplayed + itemIndex
                        
                        Button {
                            selection.wrappedValue = globalIndex
                            onSelection(globalIndex)
                        } label: {
                            Text(option)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(
                                    selection.wrappedValue == globalIndex
                                    ? .white
                                    : DesignTokens.Colors.textPrimary
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DesignTokens.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                                        .fill(
                                            selection.wrappedValue == globalIndex
                                            ? DesignTokens.Colors.primaryAccent
                                            : DesignTokens.Colors.secondaryBackground
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    private func modernSortOption(
        option: FilmSortOption,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button {
            onTap()
        } label: {
            VStack(spacing: DesignTokens.Spacing.sm) {
                // Icon
                Image(systemName: sortIconFor(option.field))
                    .font(.title3)
                    .foregroundColor(
                        isSelected
                        ? DesignTokens.Colors.primaryAccent
                        : DesignTokens.Colors.textSecondary
                    )
                
                // Text
                VStack(spacing: 2) {
                    Text(option.field.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(option.order == .forward ? "Ascending" : "Descending")
                        .font(.caption2)
                        .opacity(0.8)
                }
                .foregroundColor(
                    isSelected
                    ? DesignTokens.Colors.primaryAccent
                    : DesignTokens.Colors.textPrimary
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .fill(
                        isSelected
                        ? DesignTokens.Colors.primaryAccent.opacity(0.1)
                        : DesignTokens.Colors.secondaryBackground
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                            .stroke(
                                isSelected
                                ? DesignTokens.Colors.primaryAccent.opacity(0.3)
                                : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Methods
    
    private func setupInitialValues() {
        // Set initial brand selection
        if let selectedBrand = filter.selectedBrand,
           let index = brands.firstIndex(of: selectedBrand) {
            selectedBrandIndex = index + 1 // +1 because "All" is at index 0
        } else {
            selectedBrandIndex = 0
        }
        
        // Set initial sort selection
        if let index = FilmSortOption.allOptions.firstIndex(of: filter.sortOption) {
            selectedSortIndex = index
        }
    }
    
    private func sortIconFor(_ field: FilmSortField) -> String {
        switch field {
        case .name:
            return "textformat.abc"
        case .popularity:
            return "star.fill"
        case .iso:
            return "camera.aperture"
        case .freshness:
            return "clock"
        }
    }
}

// MARK: - Array Extension

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Preview

#Preview {
    FilterSheetView(
        filter: .constant(FilmFilter()),
        brands: ["Kodak", "Fujifilm", "Ilford", "Cinestill", "Lomography"],
        clearAction: {},
        onSortChanged: nil,
        onBrandChanged: nil
    )
}
