//
//  LoginPasswordResetView.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/04/22.
//

import SwiftUI
import SwiftUINavigation

struct LoginPasswordResetView: View {
	
	@ObservedObject var viewModel: LoginPasswordResetViewModel
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		ZStack {
			
			NavigationLink(
				unwrapping: $viewModel.route,
				case: /PrimaryRouting.homeUser,
				destination: { viewModel in
					UserHomeView(homeVM: viewModel.wrappedValue)
				},
				onNavigate: { _ in },
				label: {
					EmptyView()
				}
			)
			
			NavigationLink(
				unwrapping: $viewModel.route,
				case: /PrimaryRouting.homeTalent,
				destination: { viewModel in
					TalentHomeView(homeVM: viewModel.wrappedValue)
				},
				onNavigate: { _ in },
				label: {
					EmptyView()
				}
			)
			
			ZStack(alignment: .topLeading) {
				Image.Dinotis.userTypeBackground
					.resizable()
					.edgesIgnoringSafeArea(.all)
				
				ScrollView(.vertical, showsIndicators: false) {
					VStack(alignment: .center) {
						
						Image.Dinotis.dinotisLogoFulfilled
							.resizable()
							.frame(
								minWidth: 46.6,
								idealWidth: 140,
								maxWidth: 140,
								minHeight: 14.6,
								idealHeight: 44,
								maxHeight: 44,
								alignment: .center
							)
							.padding(.top, 20)
						
						Spacer()
						
						Image.Dinotis.resetPasswordIllustration
							.resizable()
							.scaledToFit()
							.frame(height: 207)
							.padding()
						
						Spacer()
						
						VStack(alignment: .center, spacing: 15) {
							Text(LocaleText.generalResetPassword)
								.font(.montserratBold(size: 18))
								.foregroundColor(.black)
							
							Text(LocaleText.resetPasswordSubtext)
								.font(.montserratRegular(size: 14))
								.foregroundColor(.black)
								.multilineTextAlignment(.center)
							
							HStack {
								Image.Dinotis.lockIcon
									.resizable()
									.scaledToFit()
									.frame(height: 24)
								
								if viewModel.isPassShow {
									TextField(LocaleText.enterNewPassword, text: $viewModel.password.password)
										.font(.montserratRegular(size: 14))
										.foregroundColor(.black)
										.accentColor(.black)
										.disableAutocorrection(true)
										.autocapitalization(.none)
									
								} else {
									SecureField(LocaleText.enterNewPassword, text: $viewModel.password.password)
										.font(.montserratRegular(size: 14))
										.foregroundColor(.black)
										.accentColor(.black)
										.disableAutocorrection(true)
										.autocapitalization(.none)
								}
								
								Button(action: {
									viewModel.isPassShow.toggle()
								}, label: {
									Image(systemName: viewModel.isPassShow ? "eye.slash.fill" : "eye.fill")
										.resizable()
										.scaledToFit()
										.frame(height: 14)
										.foregroundColor(.dinotisGray)
								})
							}
							.padding()
							.overlay(
								RoundedRectangle(cornerRadius: 10)
									.stroke(Color.dinotisStrokeSecondary, lineWidth: 1)
							)
							.valueChanged(value: viewModel.password.password) { value in
								if value.isEmpty {
									viewModel.passValid = true
								} else {
									viewModel.validator = FieldValidator.shared.isPasswordValid(password: value)
									
									viewModel.passValid = viewModel.validator.valid
									viewModel.passValidMsg = viewModel.validator.message
								}
							}
							
							HStack {
								Image.Dinotis.exclamationCircleIcon
									.resizable()
									.scaledToFit()
									.frame(height: 10)
									.foregroundColor(.red)
								Text(viewModel.passValidMsg)
									.font(.montserratRegular(size: 10))
									.foregroundColor(.red)
								
								Spacer()
							}
							.isHidden(viewModel.passValid, remove: viewModel.passValid)
							
							HStack {
								Image.Dinotis.lockIcon
									.resizable()
									.scaledToFit()
									.frame(height: 24)
								
								if viewModel.isRepeatPassShow {
									TextField(LocaleText.enterConfirmNewPass, text: $viewModel.password.confirmPassword)
										.font(.montserratRegular(size: 14))
										.foregroundColor(.black)
										.accentColor(.black)
										.disableAutocorrection(true)
										.autocapitalization(.none)
									
								} else {
									SecureField(LocaleText.enterConfirmNewPass, text: $viewModel.password.confirmPassword)
										.font(.montserratRegular(size: 14))
										.foregroundColor(.black)
										.accentColor(.black)
										.disableAutocorrection(true)
										.autocapitalization(.none)
								}
								
								Button(action: {
									viewModel.isRepeatPassShow.toggle()
								}, label: {
									Image(systemName: viewModel.isRepeatPassShow ? "eye.slash.fill" : "eye.fill")
										.resizable()
										.scaledToFit()
										.frame(height: 14)
										.foregroundColor(.dinotisGray)
								})
							}
							.padding()
							.overlay(
								RoundedRectangle(cornerRadius: 10)
									.stroke(Color.dinotisStrokeSecondary, lineWidth: 1)
							)
							.valueChanged(value: viewModel.password.confirmPassword) { value in
								if value.isEmpty {
									viewModel.rePassValid = true
								} else {
									viewModel.validator = FieldValidator.shared.isPasswordValid(password: value)
									
									viewModel.rePassValid = viewModel.validator.valid
									viewModel.rePassValidMsg = viewModel.validator.message
								}
							}
							
							HStack {
								Image.Dinotis.exclamationCircleIcon
									.resizable()
									.scaledToFit()
									.frame(height: 10)
									.foregroundColor(.red)
								Text(viewModel.rePassValidMsg)
									.font(.montserratRegular(size: 10))
									.foregroundColor(.red)
								
								Spacer()
							}
							.isHidden(viewModel.rePassValid, remove: viewModel.rePassValid)
							
							if !viewModel.isPasswordSame() {
								HStack {
									Image.Dinotis.exclamationCircleIcon
										.resizable()
										.scaledToFit()
										.frame(height: 10)
										.foregroundColor(.red)
									Text(LocaleText.passwordNotMatch)
										.font(.montserratRegular(size: 10))
										.foregroundColor(.red)
									
									Spacer()
								}
								.padding(.bottom, 10)
							}
							
							Button(action: {
								viewModel.resetPassword()
							}, label: {
								HStack {
									Text(LocaleText.saveText)
										.font(.montserratSemiBold(size: 12))
										.foregroundColor(viewModel.isPasswordSame() ? .white : Color(.systemGray3))
										.padding(10)
										.padding(.horizontal)
										.padding(.vertical, 5)
									
								}
								.background(viewModel.isPasswordSame() ? Color.primaryViolet : Color(.systemGray5))
								.clipShape(RoundedRectangle(cornerRadius: 8))
								.disabled(!viewModel.isPasswordSame())
								
							})
						}
						.padding()
						.background(Color.white)
						.cornerRadius(16)
						.shadow(color: Color.dinotisShadow.opacity(0.2), radius: 40, x: 0.0, y: 0.0)
						.padding()
						.padding(.bottom, 30)
					}
				}
				
				ZStack(alignment: .topLeading) {
					HStack {
						Button(action: {
							if viewModel.isFromHome {
								viewModel.resetState()
								self.viewModel.backToRoot()
							} else {
								self.viewModel.backToLogin()
							}
						}, label: {
							Image.Dinotis.arrowBackIcon
								.padding()
								.background(Color.white)
								.clipShape(Circle())
						})
						.padding(.leading)
					}
				}
			}
			.onAppear {
				if !viewModel.isFromHome {
					withAnimation {
						viewModel.isShowingNotice = true
					}
				}
			}
			
			ZStack {
				Color.black
					.opacity(viewModel.isShowingNotice ? 0.5 : 0)
					.edgesIgnoringSafeArea(.all)
				
				VStack(spacing: 20) {
					Image.Dinotis.addPasswordIllustration
						.resizable()
						.scaledToFit()
						.frame(height: 150)
					
					VStack(spacing: 10) {
						Text(LocaleText.addPasswordAlertTitle)
							.font(.montserratBold(size: 14))
							.multilineTextAlignment(.center)
						
						Text(LocaleText.addPasswordAlertSubtitle)
							.font(.montserratRegular(size: 12))
							.multilineTextAlignment(.center)
					}
					
					Button {
						withAnimation {
							viewModel.isShowingNotice = false
						}
					} label: {
						HStack {
							Spacer()
							
							Text(LocaleText.okText)
								.font(.montserratSemiBold(size: 14))
								.foregroundColor(.white)
							
							Spacer()
						}
						.padding(15)
						.background(
							RoundedRectangle(cornerRadius: 12)
								.foregroundColor(.primaryViolet)
						)
					}
					
				}
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 12)
						.foregroundColor(.white)
				)
				.padding()
				.opacity(viewModel.isShowingNotice ? 1 : 0)
			}
			
			LoadingView(isAnimating: $viewModel.isLoading)
				.isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct LoginPasswordResetView_Previews: PreviewProvider {
	static var previews: some View {
		LoginPasswordResetView(
			viewModel: LoginPasswordResetViewModel(
				isFromHome: false,
				backToRoot: {},
				backToLogin: {}
			)
		)
	}
}
