//
//  TalentSearchVerticalCardView.swift
//  DinotisApp
//
//  Created by Gus Adi on 17/08/21.
//

import SwiftUI

struct TalentSearchVerticalCardView: View {
	@State var user: Talent
	
	@State var isLast: Bool
	
	@Binding var take: Int
	
	var body: some View {
		HStack(spacing: 15) {
			ProfileImageContainer(profilePhoto: $user.profilePhoto, name: $user.name, width: 56, height: 56)
			
			VStack(alignment: .leading, spacing: 10) {
				HStack {
					Text(user.name ?? "")
						.font(Font.custom(FontManager.Montserrat.bold, size: 14))
						.minimumScaleFactor(0.9)
						.lineLimit(1)
						.foregroundColor(.black)
					
					if user.isVerified ?? false {
						Image("ic-verif-acc")
							.resizable()
							.scaledToFit()
							.frame(height: 15)
					}
				}
				
				if isLast {
					HStack {
						Text((user.professions?.first?.profession.name).orEmpty())
							.font(Font.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)
					}
					.onAppear {
						DispatchQueue.main.async {
							take += 30
						}
					}
				} else {
					HStack {
						Text((user.professions?.first?.profession.name).orEmpty())
							.font(Font.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)
					}
				}
			}
			
			Spacer()
		}
		.padding()
		.background(Color.white)
		.cornerRadius(12)
		.shadow(color: Color("dinotis-shadow-1").opacity(0.1), radius: 8, x: 0.0, y: 0.0)
		.padding(.horizontal)
	}
}
