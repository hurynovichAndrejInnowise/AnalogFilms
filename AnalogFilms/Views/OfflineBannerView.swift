import SwiftUI

struct OfflineBannerView: View {
    let dismissAction: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundColor(.white)
            
            Text("No internet connection")
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                dismissAction()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.red)
        .cornerRadius(8)
        .padding(.horizontal)
        .shadow(radius: 4)
    }
}
