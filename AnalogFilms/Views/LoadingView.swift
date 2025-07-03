import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading films...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
