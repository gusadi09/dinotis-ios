//
//  TalentSearchCard.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/08/21.
//

import SwiftUI
import DinotisDesignSystem
import DinotisData

struct TalentSearchCard: View {
	var onTapSee: (() -> Void)
	
	@Binding var user: UserResponse
	
	var body: some View {
		VStack(spacing: 0) {
				VStack(spacing: 0) {
                    TalentPhotoProfile(profilePhoto: .constant(user.profilePhoto), name: .constant(user.name), width: 195, height: 200)
						.frame(height: 200)
					
					VStack(spacing: 5) {
                        if user.isVerified ?? false {
                            Text("\(user.name.orEmpty()) \(Image.Dinotis.accountVerifiedIcon)")
                                .font(.robotoBold(size: 12))
                                .lineLimit(2)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("\(user.name.orEmpty())")
                                .font(.robotoBold(size: 12))
                                .lineLimit(2)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }
					}
                    .padding(.top, 8)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
				}
		}
		.frame(width: 195)
		.background(Color.white)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.shadow(color: Color.dinotisShadow.opacity(0.08), radius: 8, x: 0.0, y: 0.0)
		.onTapGesture {
			onTapSee()
		}
	}
}
