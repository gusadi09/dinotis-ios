//
//  LoginViewUser.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/08/21.
//

import DinotisDesignSystem
import SwiftUI
import SwiftUINavigation

struct LoginViewUser: View {

	@ObservedObject var loginVM: LoginViewModel

	@Environment(\.dismiss) var dismiss

	var body: some View {
		GeometryReader { geo in
			ZStack(alignment: .top) {
				Color.DinotisDefault.baseBackground
					.edgesIgnoringSafeArea(.all)

				VStack(spacing: 0) {
					HeaderView(
						type: .imageHeader(Image.generalDinotisImage, 25),
						title: "") {
							DinotisElipsisButton(
								icon: .generalBackIcon,
								iconColor: .DinotisDefault.black1,
								bgColor: .DinotisDefault.white,
								strokeColor: nil,
								iconSize: 12,
								type: .primary, {
									dismiss()
								}
							)
						} trailingButton: {
							Button {
								loginVM.openWhatsApp()
							} label: {
								Image.generalQuestionIcon
									.resizable()
									.scaledToFit()
									.frame(height: 25)
							}
						}
                        .onChange(of: loginVM.phone.phone) { newValue in
                            if newValue.hasPrefix("0") {
                                loginVM.phone.phone = String(newValue.dropFirst(1))
                            }
                        }


					ScrollView(showsIndicators: false) {
						VStack {
							VStack(spacing: 8) {
								Text(loginVM.loginTitleText())
									.font(.robotoBold(size: 28))
									.foregroundColor(.DinotisDefault.black1)

								Text(loginVM.loginDescriptionText())
									.font(.robotoRegular(size: 12))
									.foregroundColor(.DinotisDefault.black2)
							}
							.multilineTextAlignment(.center)
							.padding(.bottom)

							VStack {
								PhoneNumberTextField(
									LocalizableText.phoneHint,
									text: $loginVM.phone.phone,
									errorText: $loginVM.phoneNumberError
								) {
									Button {
										loginVM.isShowingCountryPicker.toggle()
									} label: {
										HStack(spacing: 5) {
											Text(loginVM.flag(country: loginVM.countrySelected.isoCode))

											Text("+\(loginVM.countrySelected.phoneCode)")

											Image(systemName: "chevron.down")
												.resizable()
												.scaledToFit()
												.frame(height: 5)
										}
										.font(.robotoRegular(size: 12))
										.foregroundColor(.DinotisDefault.black1)
									}
								}

								if !loginVM.isRegister {
									PasswordTextField(
										LocalizableText.passwordHint,
										isSecure: $loginVM.isSecure,
										password: $loginVM.phone.password,
										errorText: $loginVM.passwordError
									) {
										Button(action: {
											loginVM.isSecure.toggle()
										}, label: {
											Image(systemName: loginVM.isSecure ? "eye.slash.fill" : "eye.fill")
												.resizable()
												.scaledToFit()
												.frame(height: 12)
												.foregroundColor(.DinotisDefault.black2)
										})
									}


									HStack {
										Spacer()

										DinotisUnderlineButton(
											text: LocalizableText.linkForgot,
											textColor: .DinotisDefault.primary,
											fontSize: 12) {
												loginVM.routeToForgot()
											}
									}
									.padding(.top)
								}

								if loginVM.stateObservable.userType == 2 && loginVM.isRegister {
									DinotisTextField(
										LocalizableText.hintInvitationCode,
										label: nil,
										text: $loginVM.invitationCode,
										errorText: $loginVM.invitationError
									)
									.autocapitalization(.allCharacters)
									.autocorrectionDisabled(true)

									HStack {
										Spacer()

										DinotisUnderlineButton(
											text: LocalizableText.linkRequestInvitation,
											textColor: .DinotisDefault.primary,
											fontSize: 12) {
												loginVM.isShowRequestInvitation.toggle()
											}
									}
									.padding(.top)
								}
							}
							.padding(.bottom, 20)

							VStack(spacing: 10) {
								(
									Text(LocalizableText.labelLoginTermsFirstPart)
										.foregroundColor(.DinotisDefault.black3)
									+
									Text(" \(LocalizableText.labelLoginTermsHighlighted) ")
										.foregroundColor(.DinotisDefault.primary)
									+
									Text(LocalizableText.labelLoginTermsSecondPart)
										.foregroundColor(.DinotisDefault.black3)
								)
								.font(.robotoMedium(size: 10))
								.multilineTextAlignment(.center)
								.onTapGesture {
									loginVM.isShowTerms.toggle()
								}

								HStack {
									Text(loginVM.firstBottomLineText())
										.font(.robotoRegular(size: 12))
										.foregroundColor(.DinotisDefault.black2)

									DinotisUnderlineButton(
										text: loginVM.secondBottomLine(),
										textColor: .DinotisDefault.primary,
										fontSize: 12) {
											withAnimation {
												loginVM.isRegister.toggle()
												loginVM.phone.phone = ""
												loginVM.invitationCode = ""
												loginVM.resetAllError()
											}
										}
								}
							}
						}
						
						Group {
							NavigationLink(
								unwrapping: $loginVM.route,
								case: /PrimaryRouting.tabContainer
							) { viewModel in
								TabViewContainer()
                                    .environmentObject(viewModel.wrappedValue)
							} onNavigate: { _ in } label: {
								EmptyView()
							}

							NavigationLink(
								unwrapping: $loginVM.route,
								case: /PrimaryRouting.homeTalent
							) { viewModel in
								TalentHomeView()
                                    .environmentObject(viewModel.wrappedValue)
							} onNavigate: { _ in } label: {
								EmptyView()
							}

							NavigationLink(
								unwrapping: $loginVM.route,
								case: /PrimaryRouting.verificationOtp
							) { viewModel in
								OtpVerificationView(viewModel: viewModel.wrappedValue)
							} onNavigate: { _ in } label: {
								EmptyView()
							}

							NavigationLink(
								unwrapping: $loginVM.route,
								case: /PrimaryRouting.forgotPassword
							) { viewModel in
								ForgotPasswordView(viewModel: viewModel.wrappedValue)
							} onNavigate: { _ in } label: {
								EmptyView()
							}
						}

					}
					.padding()

					DinotisPrimaryButton(
						text: loginVM.loginButtonText(),
						type: .adaptiveScreen,
						textColor: loginVM.isButtonDisable() ? .DinotisDefault.lightPrimaryActive : .DinotisDefault.white,
						bgColor: loginVM.isButtonDisable() ? .DinotisDefault.lightPrimary : .DinotisDefault.primary
					) {
						Task {
							await loginVM.registerButtonAction()
						}
					}
					.disabled(loginVM.isButtonDisable())
					.padding()
				}
                
                DinotisLoadingView(.fullscreen, hide: !loginVM.isLoading)
			}
			.sheet(isPresented: $loginVM.isShowingCountryPicker){
				if #available(iOS 16.0, *) {
					CountryPicker(country: $loginVM.countrySelected)
						.padding()
						.padding(.vertical)
						.presentationDetents([.fraction(0.8), .large])
                        .dynamicTypeSize(.large)
				} else {
					CountryPicker(country: $loginVM.countrySelected)
						.padding()
						.padding(.vertical)
                        .dynamicTypeSize(.large)
				}

			}
			.sheet(
				isPresented: $loginVM.isShowSelectChannel,
				content: {
					if #available(iOS 16.0, *) {
						SelectChannelView(channel: $loginVM.selectedChannel, geo: geo) {
							loginVM.doRegister()
						}
							.padding()
                            .presentationDetents([.fraction(0.34)])
                            .dynamicTypeSize(.large)
					} else {
						SelectChannelView(channel: $loginVM.selectedChannel, geo: geo) {
							loginVM.doRegister()
						}
							.padding()
							.padding(.vertical)
                            .dynamicTypeSize(.large)
					}

				}
			)
			.sheet(isPresented: $loginVM.isShowRequestInvitation) {
#if os(iOS)
				SafariViewWrapper(url: loginVM.invitationURL())
                    .dynamicTypeSize(.large)
#else
				WebView(url: loginVM.invitationURL())
                    .dynamicTypeSize(.large)
#endif
			}
			.sheet(isPresented: $loginVM.isShowTerms) {
#if os(iOS)
				SafariViewWrapper(url: loginVM.termsURL())
                    .dynamicTypeSize(.large)
#else
				WebView(url: loginVM.termsURL())
                    .dynamicTypeSize(.large)
#endif
			}
			.dinotisAlert(
				isPresent: $loginVM.isError,
				title: LocalizableText.attentionText,
				isError: loginVM.isError,
				message: loginVM.error.orEmpty(),
				primaryButton: .init(
					text: LocalizableText.returnText,
					action: {}
				)
			)

		}
		.onDisappear(perform: {
			loginVM.isLoading = false
			loginVM.onDisappearView()
		})
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)

	}
}

struct LoginViewUser_Previews: PreviewProvider {
	static var previews: some View {
		LoginViewUser(loginVM: LoginViewModel(backToRoot: {}))
	}
}
