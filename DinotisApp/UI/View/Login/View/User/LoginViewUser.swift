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
                
                Image.backgroundAuthenticationImage
                    .resizable()
                    .edgesIgnoringSafeArea([.top, .horizontal])

				VStack(spacing: 0) {
					HeaderView(
                        type: .textHeader,
                        title: loginVM.isRegister ? LocalizableText.authNewRegisterTitle : LocalizableText.authNewLoginTitle,
                        headerColor: .clear,
                        textColor: .white
                    ) {
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
                            
						}
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
                        .onChange(of: loginVM.phone.phone) { newValue in
                            if newValue.hasPrefix("0") {
                                loginVM.phone.phone = String(newValue.dropFirst(1))
                            }
                            
                            let numericCharacters = newValue.filter { "0"..."9" ~= $0 }
                            loginVM.phone.phone = String(numericCharacters)
                        }


					ScrollView(showsIndicators: false) {
						VStack {
							VStack(spacing: 8) {
                                Image.logoWithText
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 195)
							}
							.multilineTextAlignment(.center)
                            .padding(.vertical, 50)

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
									.padding(.top, 10)
								}
							}
							.padding(.bottom, 20)

							VStack(spacing: 15) {

                                DinotisPrimaryButton(
                                    text: loginVM.loginButtonText(),
                                    type: .adaptiveScreen,
                                    textColor: .DinotisDefault.white,
                                    bgColor: .DinotisDefault.primary
                                ) {
                                    Task {
                                        await loginVM.registerButtonAction()
                                    }
                                }
                                .disabled(loginVM.isButtonDisable())
                                
								HStack {
									Text(loginVM.firstBottomLineText())
										.font(.robotoMedium(size: 14))
                                        .fontWeight(.semibold)
										.foregroundColor(.DinotisDefault.black2)

									DinotisUnderlineButton(
										text: loginVM.secondBottomLine(),
										textColor: .DinotisDefault.primary,
										fontSize: 14) {
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
                    .padding(.horizontal)
                    
                    (
                        Text(LocalizableText.labelLoginTermsFirstPart)
                            .foregroundColor(.DinotisDefault.black3)
                            .font(.robotoRegular(size: 12))
                        +
                        Text(" \(LocalizableText.labelLoginTermsHighlighted) ")
                            .foregroundColor(.DinotisDefault.darkPrimary)
                            .font(.robotoMedium(size: 12))
                        +
                        Text(LocalizableText.labelLoginTermsSecondPart)
                            .foregroundColor(.DinotisDefault.black3)
                            .font(.robotoRegular(size: 12))
                    )
                    .multilineTextAlignment(.center)
                    .onTapGesture {
                        loginVM.isShowTerms.toggle()
                    }
                    .padding()
                    
                    Divider()
                    
                    HStack {
                        Button {
                            loginVM.openWhatsApp()
                        } label: {
                            Image.generalMessageTextIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18)
                            
                            Text(LocalizableText.needHelpQuestion)
                                .font(.robotoMedium(size: 12))
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.DinotisDefault.primary)
                        }

                    }
                    .padding()
				}
                
                DinotisLoadingView(.fullscreen, hide: !loginVM.isLoading)
			}
			.sheet(isPresented: $loginVM.isShowingCountryPicker){
				if #available(iOS 16.0, *) {
					CountryPicker(country: $loginVM.countrySelected)
						.presentationDetents([.fraction(0.8), .large])
                        .dynamicTypeSize(.large)
				} else {
					CountryPicker(country: $loginVM.countrySelected)
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
