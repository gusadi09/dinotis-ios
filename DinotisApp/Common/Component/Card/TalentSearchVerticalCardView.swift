//
//  TalentSearchVerticalCardView.swift
//  DinotisApp
//
//  Created by Gus Adi on 17/08/21.
//

import SwiftUI
import DinotisDesignSystem
import DinotisData

struct TalentSearchVerticalCardView: View {
	@State var user: TalentWithProfessionData
	
	var body: some View {
		HStack(spacing: 15) {
            ProfileImageContainer(profilePhoto: .constant(user.profilePhoto), name: .constant(user.name), width: 56, height: 56)
			
			VStack(alignment: .leading, spacing: 10) {
				HStack {
					Text(user.name ?? "")
                        .font(.robotoBold(size: 14))
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

				HStack {
					Text((user.professions?.first?.profession?.name).orEmpty())
                        .font(.robotoRegular(size: 12))
						.foregroundColor(.black)
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
