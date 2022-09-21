//
//  EmailVerificationView.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/08/21.
//

import SwiftUI
import SwiftUINavigation

struct OtpVerificationView: View {
	
	@ObservedObject var viewModel: OtpVerificationViewModel
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		GeometryReader { geo in
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
							.scaledToFit()
							.frame(height: 44)
							.padding(.top, 20)

						Spacer()

						Image.Dinotis.otpVerificationImage
							.resizable()
							.scaledToFit()
							.frame(height: geo.size.height/3)
							.padding()

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
											viewModel.isShowSelectChannel.toggle()

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

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /PrimaryRouting.homeUser) { viewModel in
						UserHomeView(homeVM: viewModel.wrappedValue)
					} onNavigate: { _ in

					} label: {
						EmptyView()
					}

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /PrimaryRouting.homeTalent) { viewModel in
						TalentHomeView(homeVM: viewModel.wrappedValue)
					} onNavigate: { _ in

					} label: {
						EmptyView()
					}

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /PrimaryRouting.biodataUser) { viewModel in
						UserBiodataView(viewModel: viewModel.wrappedValue)
					} onNavigate: { _ in

					} label: {
						EmptyView()
					}

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /PrimaryRouting.biodataTalent) { viewModel in
						TalentBiodataView(viewModel: viewModel.wrappedValue)
					} onNavigate: { _ in

					} label: {
						EmptyView()
					}

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /PrimaryRouting.resetPassword) { viewModel in
						ResetPasswordView(viewModel: viewModel.wrappedValue)
					} onNavigate: { _ in

					} label: {
						EmptyView()
					}

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /PrimaryRouting.loginResetPassword) { viewModel in
						LoginPasswordResetView(viewModel: viewModel.wrappedValue)
					} onNavigate: { _ in

					} label: {
						EmptyView()
					}
			}
			.dinotisSheet(
				isPresented: $viewModel.isShowSelectChannel,
				fraction: 0.45,
				content: {
					SelectChannelView(channel: $viewModel.selectedChannel, geo: geo) {
						withAnimation {
							viewModel.resendOtp()
							viewModel.isShowSelectChannel = false
						}
					}
				}
			)
		}
		.onDisappear(perform: {
			viewModel.timer.upstream.connect().cancel()
		})
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct EmailVerificationView_Previews: PreviewProvider {
	static var previews: some View {
		OtpVerificationView(viewModel: OtpVerificationViewModel(phoneNumber: "", otpType: .login, onBackToRoot: {}, backToLogin: {}, backToPhoneSet: {}))
	}
}
