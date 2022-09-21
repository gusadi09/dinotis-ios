//
//  ResetPasswordView.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/04/22.
//

import SwiftUI

struct ResetPasswordView: View {
	
	@ObservedObject var viewModel: ResetPasswordViewModel
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		ZStack {
			ZStack(alignment: .topLeading) {
				Image.Dinotis.userTypeBackground
					.resizable()
					.edgesIgnoringSafeArea(.all)
				
				ScrollView(.vertical, showsIndicators: false) {
					VStack(alignment: .center) {
						
						Image.Dinotis.dinotisLogoFulfilled
							.resizable()
							.scaledToFit()
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
								.padding(.bottom, 15)
							
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
									viewModel.validator = FieldValidator.shared.isPasswordValid(password: viewModel.password.password)
									
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
									TextField(LocaleText.enterConfirmNewPass, text: $viewModel.password.passwordConfirm)
										.font(.montserratRegular(size: 14))
										.foregroundColor(.black)
										.accentColor(.black)
										.disableAutocorrection(true)
										.autocapitalization(.none)
									
								} else {
									SecureField(LocaleText.enterConfirmNewPass, text: $viewModel.password.passwordConfirm)
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
							.padding(.bottom, viewModel.isPasswordSame() ? 10 : 0)
							.valueChanged(value: viewModel.password.passwordConfirm) { value in
								if value.isEmpty {
									viewModel.rePassValid = true
								} else {
									viewModel.validator = FieldValidator.shared.isPasswordValid(password: viewModel.password.passwordConfirm)
									
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
										.foregroundColor(viewModel.isPasswordSame() ? .white : Color(.systemGray2))
										.padding(10)
										.padding(.horizontal)
										.padding(.vertical, 5)
									
								}
								.background(viewModel.isPasswordSame() ? Color.primaryViolet : Color(.systemGray5))
								.clipShape(RoundedRectangle(cornerRadius: 8))
								
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
							viewModel.backToPhoneSet()
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
			
			LoadingView(isAnimating: $viewModel.isLoading)
				.isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct ResetPasswordView_Previews: PreviewProvider {
	static var previews: some View {
		ResetPasswordView(viewModel: ResetPasswordViewModel(phone: "", token: "", backToRoot: {}, backToLogin: {}, backToPhoneSet: {}))
	}
}
