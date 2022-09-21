//
//  ChangePhoneVerifyView.swift
//  DinotisApp
//
//  Created by Gus Adi on 24/02/22.
//

import SwiftUI
import SwiftUINavigation

struct ChangePhoneVerifyView: View {
	
	@ObservedObject var viewModel: ChangePhoneVerifyViewModel
	
	@State var isShowConnection = false
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		ZStack(alignment: .top) {
			Image.Dinotis.userTypeBackground
				.resizable()
				.edgesIgnoringSafeArea(.all)
				.alert(isPresented: $viewModel.isError) {
					Alert(
						title: Text(LocaleText.attention),
						message: Text((viewModel.error?.errorDescription).orEmpty()),
						dismissButton: .default(Text(LocaleText.okText))
					)
				}
			
			ScrollView(.vertical, showsIndicators: false) {
				VStack(alignment: .center) {
					Image.Dinotis.dinotisLogoFulfilled
						.resizable()
						.frame(minWidth: 46.6, idealWidth: 140, maxWidth: 140, minHeight: 14.6, idealHeight: 44, maxHeight: 44, alignment: .center)
						.padding(.top, 20)
					
					Spacer()
					
					Image.Dinotis.otpVerificationImage
						.resizable()
						.frame(width:
										309, height: 278.85, alignment: .center)
						.padding()
						.alert(isPresented: $isShowConnection) {
							Alert(
								title: Text(NSLocalizedString("attention", comment: "")),
								message: Text(NSLocalizedString("connection_warning", comment: "")),
								dismissButton: .cancel(Text(NSLocalizedString("return", comment: "")))
							)
						}
					
					Spacer()
					
					VStack(alignment: .center, spacing: 15) {
						Text(LocaleText.otpVerificationTitle)
							.font(.montserratBold(size: 18))
							.foregroundColor(.black)
						
						Text(LocaleText.otpSubtitle)
							.font(.montserratRegular(size: 12))
							.padding(.horizontal)
							.fixedSize(horizontal: false, vertical: true)
							.multilineTextAlignment(.center)
							.foregroundColor(.black)
						
						Text(viewModel.phoneNumber)
							.font(.montserratBold(size: 18))
							.foregroundColor(.black)
						
						VStack {
							OTPField { otp, _ in
								viewModel.validateOTP(by: otp)
							}
						}
						.padding()
						
						HStack {
							Text(LocaleText.otpNotReceive)
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.foregroundColor(.black)
							
							VStack(alignment: .leading, spacing: 0) {
								if viewModel.isActive {
									Button(action: {
										viewModel.resendOtp()
										
									}, label: {
										Text(LocaleText.resendText)
											.underline()
											.font(.montserratBold(size: 12))
											.foregroundColor(.black)
											.foregroundColor(.black)
									})
								} else {
									Button(action: {}, label: {
										Text(LocaleText.remainingText(time: viewModel.timeRemaining))
											.underline()
											.font(.montserratBold(size: 12))
											.foregroundColor(.black)
										
									})
									.disabled(true)
								}
							}
						}
						.fixedSize(horizontal: true, vertical: false)
					}
					.padding()
					.background(Color.white)
					.cornerRadius(16)
					.shadow(color: Color.dinotisShadow.opacity(0.2), radius: 40, x: 0.0, y: 0.0)
					.padding()
					.padding(.bottom, 30)
				}
				.onReceive(viewModel.timer) { _ in
					viewModel.onReceiveTimer()
				}
			}
			
			HStack {
				Button(action: {
					self.presentationMode.wrappedValue.dismiss()
					
				}, label: {
					Image.Dinotis.arrowBackIcon
						.padding()
						.background(Color.white)
						.clipShape(Circle())
				})
				.padding(.leading)
				.padding(.top, 20)
				
				Spacer()
			}
			
			if viewModel.isLoading {
				ZStack {
					Color.black.opacity(0.3)
						.edgesIgnoringSafeArea(.all)
					
					ActivityIndicator(isAnimating: $viewModel.isLoading, color: .white, style: .medium)
				}
			}
		}
		.onDisappear(perform: {
			viewModel.timer.upstream.connect().cancel()
		})
		
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct ChangePhoneVerifyView_Previews: PreviewProvider {
	static var previews: some View {
		ChangePhoneVerifyView(viewModel: ChangePhoneVerifyViewModel(phoneNumber: "", onBackToRoot: {}, backToEditProfile: {}))
	}
}
