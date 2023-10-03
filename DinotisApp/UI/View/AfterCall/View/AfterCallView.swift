//
//  AfterCallView.swift
//  DinotisApp
//
//  Created by Gus Adi on 02/03/22.
//

import SwiftUI
import DinotisDesignSystem

struct AfterCallView: View {
	
	@ObservedObject var viewModel: AfterCallViewModel
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isPotrait: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
	
	var body: some View {
		ZStack {
			Image.Dinotis.linearGradientBackground
				.resizable()
				.edgesIgnoringSafeArea(.all)
			
			VStack {
				HStack {
					Spacer()
					Text(LocaleText.leaveMeetingTitle)
						.font(.robotoBold(size: 14))
						.padding(.horizontal)
					Spacer()
				}
				.padding()
				
				Spacer()
				
				HStack {
					Spacer()
					
					VStack(spacing: 10) {
						Image.Dinotis.logoutImage
							.resizable()
							.scaledToFit()
							.frame(
                                height: isPotrait ? 150 : 100
							)
						
						Text(LocaleText.leaveMeetingLabel)
                            .font(.robotoBold(size: 14))
							.foregroundColor(.black)
						
						Text(viewModel.sublabelText())
                            .font(.robotoRegular(size: 12))
							.multilineTextAlignment(.center)
							.foregroundColor(.black)
						
						Button {
							viewModel.backToHome()
						} label: {
							HStack {
								Spacer()
								
								Text(LocaleText.leaveMeetingButtonText)
									.font(.robotoMedium(size: 12))
									.foregroundColor(.white)
								
								Spacer()
							}
							.padding(.vertical)
							.background(
								RoundedRectangle(cornerRadius: 10)
									.foregroundColor(.DinotisDefault.primary)
							)
							.padding(.top, 10)
							
						}
						
					}
					
					Spacer()
				}
                .padding(.vertical, 16)
				.padding(.horizontal)
				.background(Color.white)
				.cornerRadius(12)
				.padding(.horizontal)
				.shadow(color: Color("dinotis-shadow-1").opacity(0.1), radius: 15, x: 0.0, y: 0.0)
				.padding(.top, 10)
				
				Spacer()
			}
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct AfterCallView_Previews: PreviewProvider {
	static var previews: some View {
		AfterCallView(viewModel: AfterCallViewModel(backToHome: {}))
	}
}
