
import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            // Professional Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: 0xFFFFFF),
                    Color(hex: 0xF5F7FA)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Rotating Logo
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                // App Title removed for cleaner look

                
                // Tagline or additional text could go here
            }
        }
        .onAppear {
            // Animation Sequence
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                self.opacity = 1.0
                self.scale = 1.0
            }
            
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                self.rotation = 360
            }
            
            // Transition to Main App
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.isActive = false
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(isActive: .constant(false))
    }
}
