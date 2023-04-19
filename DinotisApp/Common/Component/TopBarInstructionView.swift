//
//  TopBarInstructionView.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/01/22.
//

import SwiftUI
import DinotisData
import DinotisDesignSystem

struct TopBarInstructionView: View {
	@Binding var selected : Int
	@Binding var instruction: PaymentInstructionData
	@Binding var virtualNumber: String
	
	var body : some View {
		HStack(alignment: .bottom, spacing: 0) {
			
			ForEach((instruction.instructions ?? []).indices, id: \.self) { item in
				VStack {
					Text(instruction.instructions?[item].name ?? "")
						.padding(.vertical, 10)
						.padding(.horizontal)
						.font(self.selected == item ?
                              .robotoBold(size: 14) :
                                .robotoRegular(size: 14))
						.foregroundColor(.black)
						.lineLimit(2)
						.minimumScaleFactor(0.8)
						.multilineTextAlignment(.center)

					Capsule()
						.frame(height: 2)
						.foregroundColor(self.selected == item ? Color("btn-stroke-1") : .white)
						.padding(.horizontal)

				}
				.padding(.top, 10)
				.background(Color(.white))
				.clipShape(Rectangle())
				.onTapGesture {
					self.selected = item
				}
			}
		}
		.background(Color.white.shadow(color: Color("dinotis-shadow-1").opacity(0.08), radius: 30, x: 0.0, y: 0.0))
	}
}
