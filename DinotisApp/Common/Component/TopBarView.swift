//
//  TopBarView.swift
//  DinotisApp
//
//  Created by Gus Adi on 27/08/21.
//

import SwiftUI
import DinotisDesignSystem

struct TopBarView: View {
	@Binding var selected : Int
	@Binding var sectionTitle1: String?
	@Binding var sectionTitle2: String?
	@Binding var sectionTitle3: String?
	
	var body : some View {
		HStack(alignment: .bottom, spacing: 0) {
			
			if let selection1 = sectionTitle1 {
				Button(action: {
					self.selected = 0
				}) {
					
					VStack {
						Text(selection1)
							.padding(.vertical, 10)
							.padding(.horizontal)
							.font(self.selected == 0 ?
                                .robotoBold(size: 14) :
                                    .robotoRegular(size: 14))
							.foregroundColor(.black)
							.lineLimit(2)
							.minimumScaleFactor(0.8)
						
						Capsule()
							.frame(height: 2)
							.isHidden(self.selected == 0 ? false : true)
							.foregroundColor(Color("btn-stroke-1"))
							.padding(.horizontal)
						
					}
					.background(Color(.white))
					.clipShape(Rectangle())
					
				}
			}
			
			if let selection2 = sectionTitle2 {
				Button(action: {
					
					self.selected = 1
					
				}) {
					
					VStack {
						Text(selection2)
							.padding(10)
							.font(self.selected == 1 ?
                                .robotoBold(size: 14) :
                                    .robotoRegular(size: 14))
							.foregroundColor(.black)
							.lineLimit(2)
							.minimumScaleFactor(0.8)
						
						Capsule()
							.frame(height: 2)
							.isHidden(self.selected == 1 ? false : true)
							.foregroundColor(Color("btn-stroke-1"))
							.padding(.horizontal)
					}
					.background(Color(.white))
					.clipShape(Rectangle())
					
				}
			}
			
			if let selection3 = sectionTitle3 {
				Button(action: {
					
					self.selected = 2
					
				}) {
					
					VStack {
						Text(selection3)
							.padding(.vertical, 10)
							.padding(.horizontal)
							.font(self.selected == 2 ?
                                .robotoBold(size: 14) :
                                    .robotoRegular(size: 14)
                            )
							.foregroundColor(.black)
							.lineLimit(2)
							.minimumScaleFactor(0.8)
						
						Capsule()
							.frame(height: 2)
							.isHidden(self.selected == 2 ? false : true)
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

struct TopBarView_Previews: PreviewProvider {
	static var previews: some View {
		TopBarView(selected: .constant(0),
							 sectionTitle1: .constant("Test"),
							 sectionTitle2: .constant("Test"),
							 sectionTitle3: .constant("Internet Banking"))
	}
}
