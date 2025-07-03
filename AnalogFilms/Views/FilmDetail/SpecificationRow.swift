import SwiftUI

struct SpecificationRow: View {
    
    // MARK: - Properties
    
    let title: String
    let value: String
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
