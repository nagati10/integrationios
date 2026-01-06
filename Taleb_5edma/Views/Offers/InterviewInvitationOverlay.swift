//
//  InterviewInvitationOverlay.swift
//  Taleb_5edma
//
//  Created for AI Interview Features
//

import SwiftUI

struct InterviewInvitationOverlay: View {
    let invitation: InterviewInvitation
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    @State private var offset: CGFloat = -150
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#667eea"), Color(hex: "#764ba2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Invitation à une simulation")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text((invitation.fromUserName ?? "Quelqu'un") + " vous invite à passer un entretien blanc.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.bottom, 12)
            
            // Buttons
            HStack(spacing: 12) {
                Button(action: onDecline) {
                    Text("Refuser")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Button(action: onAccept) {
                    Text("Accepter")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#28A745"))
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 16)
        .padding(.top, 8) // Top padding for safe area
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                offset = 0
            }
        }
    }
}
