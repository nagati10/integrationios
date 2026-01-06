
import SwiftUI

struct OfferTypeToggle: View {
    @Binding var selectedType: OfferType
    
    enum OfferType {
        case occasionnel
        case professionnel
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Occasionnel
            toggleButton(
                title: "Occasionnel",
                isSelected: selectedType == .occasionnel,
                action: { selectedType = .occasionnel }
            )
            
            // Professionnel
            toggleButton(
                title: "Professionnel",
                isSelected: selectedType == .professionnel,
                action: { selectedType = .professionnel }
            )
        }
        .padding(4)
        .background(Color.white) // Fixed background for contrast
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    private func toggleButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(hex: 0x7E57C2) : Color.clear)
                )
        }
    }
}
