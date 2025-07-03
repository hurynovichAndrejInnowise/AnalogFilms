import SwiftUI

struct EmptyStateView: View {
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Films Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try adjusting your search or filters, or check your internet connection.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
