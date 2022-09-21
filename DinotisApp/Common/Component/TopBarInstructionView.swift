//
//  TopBarInstructionView.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/01/22.
//

import SwiftUI

struct TopBarInstructionView: View {
	@Binding var selected : Int
	@Binding var instruction: PaymentInstruction
	@Binding var virtualNumber: String
	
	var body : some View {
		HStack(alignment: .bottom, spacing: 0) {
			
			ForEach((instruction.instructions ?? []).indices, id: \.self) { item in
				Button(action: {
					self.selected = item
				}) {
					
					VStack {
						Text(instruction.instructions?[item].name ?? "")
							.padding(.vertical, 10)
							.padding(.horizontal)
							.font(self.selected == item ?
										Font.custom(FontManager.Montserrat.bold, size: 14) :
											Font.custom(FontManager.Montserrat.regular, size: 14))
							.foregroundColor(.black)
							.lineLimit(2)
							.minimumScaleFactor(0.8)
						
						Capsule()
							.frame(height: 2)
							.isHidden(self.selected == item ? false : true)
							.foregroundColor(Color("btn-stroke-1"))
							.padding(.horizontal)
						
					}
					.background(Color(.white))
					.clipShape(Rectangle())
					
				}
			}
		}
		.background(Color.white.shadow(color: Color("dinotis-shadow-1").opacity(0.08), radius: 30, x: 0.0, y: 0.0))
	}
}
