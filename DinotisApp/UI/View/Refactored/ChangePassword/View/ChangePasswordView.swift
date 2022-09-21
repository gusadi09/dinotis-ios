//
//  ChangePasswordView.swift
//  DinotisApp
//
//  Created by Gus Adi on 04/08/21.
//

import SwiftUI
import SwiftKeychainWrapper
import OneSignal

struct ChangePasswordView: View {
	
	@ObservedObject var viewModel: ChangesPasswordViewModel
	@ObservedObject var stateObservable = StateObservable.shared
	
	@Environment(\.presentationMode) var presentationMode
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	var body: some View {
		ZStack {
			ZStack(alignment: .topLeading) {
				Image.Dinotis.linearGradientBackground
					.resizable()
					.edgesIgnoringSafeArea(.all)
					.alert(isPresented: $viewModel.isRefreshFailed) {
						Alert(
							title: Text(LocaleText.attention),
							message: Text(LocaleText.sessionExpireText),
							dismissButton: .default(Text(LocaleText.returnText), action: {
								viewModel.backToRoot()
								stateObservable.userType = 0
								stateObservable.isVerified = ""
								stateObservable.refreshToken = ""
								stateObservable.accessToken = ""
								stateObservable.isAnnounceShow = false
								OneSignal.setExternalUserId("")
							}))
					}
				
				VStack {
					ZStack {
						HStack {
							Button(action: {
								presentationMode.wrappedValue.dismiss()
							}, label: {
								Image.Dinotis.arrowBackIcon
									.padding()
									.background(Color.white)
									.clipShape(Circle())
							})
							.padding(.leading)
							
							Spacer()
						}
						
						HStack {
							Spacer()
							Text(LocaleText.changePasswordTitle)
								.font(.montserratBold(size: 14))
								.foregroundColor(.black)
							
							Spacer()
						}
						.alert(isPresented: $viewModel.isError, content: {
							return Alert(
								title: Text(LocaleText.attention),
								message: Text(viewModel.error?.errorDescription ?? ""),
								dismissButton: .cancel(Text(LocaleText.returnText))
							)
						})
						
					}
					
					VStack(alignment: .center, spacing: 10) {
						VStack {
							HStack {
								Text(LocaleText.oldPasswordText)
									.font(.montserratRegular(size: 12))
									.foregroundColor(.black)
								
								Spacer()
							}
							.padding(.top, 8)
							
							HStack {
								if viewModel.isSecuredOld {
									SecureField(LocaleText.oldPasswordPlaceholder, text: $viewModel.oldPassword)
										.font(.montserratRegular(size: 12))
										.foregroundColor(.black)
										.accentColor(.black)
								} else {
									TextField(LocaleText.oldPasswordPlaceholder, text: $viewModel.oldPassword)
										.font(.montserratRegular(size: 12))
										.foregroundColor(.black)
										.accentColor(.black)
								}
								
								Button(action: {
									viewModel.isSecuredOld.toggle()
								}) {
									Image(systemName: self.viewModel.isSecuredOld ? "eye.fill" : "eye.slash.fill")
										.accentColor(Color.dinotisGray)
								}
							}
							.padding()
							.overlay(
								RoundedRectangle(cornerRadius: 10)
									.stroke(Color.dinotisStrokeSecondary, lineWidth: 1)
							)
							.valueChanged(value: viewModel.oldPassword) { value in
								if value.isEmpty {
									viewModel.oldPassValid = true
								} else {
									viewModel.validator = FieldValidator.shared.isPasswordValid(password: viewModel.oldPassword)
									
									viewModel.oldPassValid = viewModel.validator.valid
									viewModel.oldPassValidMsg = viewModel.validator.message
								}
							}
							
							HStack {
								Image.Dinotis.exclamationCircleIcon
									.resizable()
									.scaledToFit()
									.frame(height: 10)
									.foregroundColor(.red)
								Text(viewModel.oldPassValidMsg)
									.font(.montserratRegular(size: 10))
									.foregroundColor(.red)
								
								Spacer()
							}
							.isHidden(viewModel.oldPassValid, remove: viewModel.oldPassValid)
							
							VStack {
								HStack {
									Text(LocaleText.newPasswordTitle)
										.font(.montserratRegular(size: 12))
										.foregroundColor(.black)
									
									Spacer()
								}
								.padding(.top, 8)
								.alert(isPresented: $viewModel.success, content: {
									Alert(
										title: Text(LocaleText.successTitle),
										message: Text(LocaleText.passwordChangedText),
										dismissButton: .cancel(
											Text(LocaleText.returnText),
											action: {
												presentationMode.wrappedValue.dismiss()
											}
										)
									)
								})
								
								HStack {
									if viewModel.isSecured {
										SecureField(LocaleText.enterNewPassword, text: $viewModel.newPassword)
											.font(.montserratRegular(size: 12))
											.foregroundColor(.black)
											.accentColor(.black)
									} else {
										TextField(LocaleText.enterNewPassword, text: $viewModel.newPassword)
											.font(.montserratRegular(size: 12))
											.foregroundColor(.black)
											.accentColor(.black)
									}
									Button(action: {
										viewModel.isSecured.toggle()
									}) {
										Image(systemName: self.viewModel.isSecured ? "eye.fill" : "eye.slash.fill")
											.accentColor(Color.dinotisGray)
									}
								}
								.padding()
								.overlay(
									RoundedRectangle(cornerRadius: 10)
										.stroke(Color.dinotisStrokeSecondary, lineWidth: 1)
								)
								.valueChanged(value: viewModel.newPassword) { value in
									if value.isEmpty {
										viewModel.passValid = true
									} else {
										viewModel.validator = FieldValidator.shared.isPasswordValid(password: viewModel.newPassword)
										
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
							}
							
							VStack {
								HStack {
									Text(LocaleText.repeatNewPassword)
										.font(.montserratRegular(size: 12))
										.foregroundColor(.black)
									
									Spacer()
								}
								.padding(.top, 8)
								
								HStack {
									if viewModel.isSecuredRe {
										SecureField(LocaleText.repeatNewPasswordPlaceholder, text: $viewModel.confirmPassword)
											.font(.montserratRegular(size: 12))
											.foregroundColor(.black)
											.accentColor(.black)
									} else {
										TextField(LocaleText.repeatNewPasswordPlaceholder, text: $viewModel.confirmPassword)
											.font(.montserratRegular(size: 12))
											.foregroundColor(.black)
											.accentColor(.black)
									}
									Button(action: {
										viewModel.isSecuredRe.toggle()
									}) {
										Image(systemName: self.viewModel.isSecuredRe ? "eye.fill" : "eye.slash.fill")
											.accentColor(Color.dinotisGray)
									}
								}
								.padding()
								.overlay(
									RoundedRectangle(cornerRadius: 10)
										.stroke(Color.dinotisStrokeSecondary, lineWidth: 1)
								)
								.valueChanged(value: viewModel.confirmPassword) { value in
									if value.isEmpty {
										viewModel.rePassValid = true
									} else {
										viewModel.validator = FieldValidator.shared.isPasswordValid(password: viewModel.confirmPassword)
										
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
							}
							
							Button(action: {
								viewModel.resetPassword()
							}, label: {
								HStack {
									
									Text(LocaleText.saveText)
										.font(.montserratSemiBold(size: 12))
										.foregroundColor(
											(viewModel.newPassword.isEmpty || viewModel.confirmPassword.isEmpty || viewModel.oldPassword.isEmpty) ||
											(viewModel.passValid == false || viewModel.rePassValid == false || viewModel.oldPassValid == false) ||
											!viewModel.isPasswordSame() ?
											Color(.systemGray3) : .white
										)
										.padding(10)
										.padding(.horizontal)
										.padding(.vertical, 3)
									
								}
								.background(
									(viewModel.newPassword.isEmpty || viewModel.confirmPassword.isEmpty || viewModel.oldPassword.isEmpty) ||
									(viewModel.passValid == false || viewModel.rePassValid == false || viewModel.oldPassValid == false) ||
									!viewModel.isPasswordSame() ?
									Color(.systemGray5) : Color.primaryViolet
								)
								.clipShape(RoundedRectangle(cornerRadius: 8))
							})
							.disabled(
								(viewModel.newPassword.isEmpty || viewModel.confirmPassword.isEmpty || viewModel.oldPassword.isEmpty) ||
								(viewModel.passValid == false || viewModel.rePassValid == false || viewModel.oldPassValid == false) ||
								!viewModel.isPasswordSame()
							)
							.padding(.vertical)
						}
						.padding()
						.background(Color.white)
						.cornerRadius(16)
						.shadow(color: Color.dinotisShadow.opacity(0.2), radius: 40, x: 0.0, y: 0.0)
						.padding()
						.padding(.bottom, 30)
					}
				}
				
				LoadingView(isAnimating: $viewModel.isLoading)
					.isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)
			}
			.navigationBarTitle(Text(""))
			.navigationBarHidden(true)
		}
	}
}

struct ChangePasswordView_Previews: PreviewProvider {
	static var previews: some View {
		ChangePasswordView(viewModel: ChangesPasswordViewModel(backToRoot: {}))
	}
}
