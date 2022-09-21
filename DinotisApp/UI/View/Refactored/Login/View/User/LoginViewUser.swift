//
//  LoginViewUser.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/08/21.
//

import SwiftUI
import SwiftUINavigation

struct LoginViewUser: View {
	
	@ObservedObject var loginVM: LoginViewModel
	
	@State var isShowConnection = false
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		GeometryReader { geo in
			ZStack(alignment: .top) {
				Image.Dinotis.userTypeBackground
					.resizable()
					.edgesIgnoringSafeArea(.all)

				ScrollView(.vertical, showsIndicators: false) {
					VStack {
						Spacer()
						Image.Dinotis.dinotisLogoFulfilled
							.resizable()
							.scaledToFit()
							.frame(idealHeight: 44)
							.padding(.top, 3)

						Spacer()

						Image.Dinotis.userLoginImage
							.resizable()
							.scaledToFit()
							.frame(height: geo.size.height/3)
							.padding(.horizontal, 50)
							.padding(.top, 15)
							.padding(.bottom, -30)

						VStack {
							Text(loginVM.loginTitleText())
								.font(.montserratBold(size: 18))
								.padding(.bottom, 15)
								.foregroundColor(.black)

							VStack {
								HStack(alignment: .center) {
									Image.Dinotis.phoneIcon
										.resizable()
										.scaledToFit()
										.frame(height: 24)

									Button {
										loginVM.isShowingCountryPicker.toggle()
									} label: {
										HStack(spacing: 5) {
											Text("+\(loginVM.countrySelected.phoneCode)")

											Image(systemName: "chevron.down")
												.resizable()
												.scaledToFit()
												.frame(height: 5)
										}
										.font(.montserratRegular(size: 14))
										.foregroundColor(.black)
									}

									TextField(LocaleText.enterPhoneLabel, text: $loginVM.phone.phone, onCommit: {
										if !loginVM.showingPassField {
											if !loginVM.isRegister {
												loginVM.phone.role = 3

												loginVM.login(usertype: .basicUser)
											} else {
												loginVM.register()
											}
										}
									})
									.font(.montserratRegular(size: 14))
									.foregroundColor(.black)
									.accentColor(.black)
									.disableAutocorrection(true)
									.autocapitalization(.none)
									.keyboardType(.phonePad)
								}
								.padding()

								if loginVM.showingPassField {

									Divider()
										.padding(.horizontal, 5)

									HStack(alignment: .center) {
										Image.Dinotis.lockIcon
											.resizable()
											.scaledToFit()
											.frame(height: 24)

										if loginVM.isPassShow {
											TextField(
												LocaleText.passwordPlaceholder,
												text: $loginVM.phone.password,
												onCommit: {
													loginVM.phone.role = 3

													loginVM.login(usertype: .basicUser)
												}
											)
											.font(.montserratRegular(size: 14))
											.foregroundColor(.black)
											.accentColor(.black)
											.disableAutocorrection(true)
											.autocapitalization(.none)

										} else {
											SecureField(
												LocaleText.passwordPlaceholder,
												text: $loginVM.phone.password,
												onCommit: {
													loginVM.phone.role = 3

													loginVM.login(usertype: .basicUser)
												}
											)
											.font(.montserratRegular(size: 14))
											.foregroundColor(.black)
											.accentColor(.black)
											.disableAutocorrection(true)
											.autocapitalization(.none)
										}

										Button(action: {
											loginVM.isPassShow.toggle()
										}, label: {
											Image(systemName: loginVM.isPassShow ? "eye.slash.fill" : "eye.fill")
												.resizable()
												.scaledToFit()
												.frame(height: 14)
												.foregroundColor(.dinotisGray)
										})
										.valueChanged(value: loginVM.phone.phone) { _ in
											loginVM.showingPassField = false
										}

									}
									.padding()
								}

							}
							.padding(5)
							.background(Color.white)
							.clipped()
							.overlay(
								RoundedRectangle(cornerRadius: 10).stroke(loginVM.fieldError == nil ? Color(.lightGray) : Color(.red), lineWidth: 1)
							)
							.shadow(color: Color.dinotisShadow.opacity(0.06), radius: 40, x: 0.0, y: 0.0)

							VStack {
								if let error = loginVM.fieldError {
									ForEach(error, id: \.itemId) { itemError in
										HStack {
											Image.Dinotis.exclamationCircleIcon
												.resizable()
												.scaledToFit()
												.frame(height: 10)
												.foregroundColor(.red)
											Text(itemError.error ?? "")
												.font(.montserratRegular(size: 10))
												.foregroundColor(.red)

											Spacer()
										}
									}
								}
							}

							if loginVM.showingPassField {
								HStack {

									Spacer()

									Button(action: {
										loginVM.routeToForgot()
									}, label: {
										Text(LocaleText.forgetPasswordText)
											.font(.montserratSemiBold(size: 14))
											.foregroundColor(.primaryViolet)
											.underline()
											.padding(.leading)

									})

								}
								.padding(.top, 15)
							}

							HStack {

								Button(action: {
									if !loginVM.isRegister {
										loginVM.phone.role = 3

										loginVM.login(usertype: .basicUser)
									} else {
										loginVM.isShowSelectChannel.toggle()
									}
								}, label: {
									HStack {

										Spacer()

										Text(loginVM.loginButtonText())
											.font(.montserratSemiBold(size: 12))
											.foregroundColor(loginVM.isRegister && loginVM.phone.phone.isEmpty ? Color(.systemGray3) : .white)
											.padding(10)
											.padding(.horizontal, 5)
											.padding(.vertical, 5)

										Spacer()

									}
									.background(loginVM.isRegister && loginVM.phone.phone.isEmpty ? Color(.systemGray5) : Color.primaryViolet)
									.clipShape(RoundedRectangle(cornerRadius: 8))
								})
								.disabled(loginVM.isRegister && loginVM.phone.phone.isEmpty)

								NavigationLink(
									unwrapping: $loginVM.route,
									case: /PrimaryRouting.homeUser
								) { viewModel in
									UserHomeView(homeVM: viewModel.wrappedValue)
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
							.padding(.vertical)

							Button {
								loginVM.isRegister.toggle()
								loginVM.phone.phone = ""
							} label: {
								(
									Text(loginVM.firstBottomLineText())
										.font(.montserratRegular(size: 14))
									+
									Text(" ")
									+
									Text(loginVM.secondBottomLine())
										.font(.montserratSemiBold(size: 14))
										.underline()
								)
								.foregroundColor(.black)
							}

						}
						.padding(20)
						.background(Color(.white))
						.cornerRadius(16)
						.shadow(color: Color.dinotisShadow.opacity(0.2), radius: 40, x: 0.0, y: 0.0)
						.padding(.bottom)
					}
					.padding(10)
				}

				HStack {
					Button(action: {
						self.presentationMode.wrappedValue.dismiss()

					}, label: {
						Image.Dinotis.arrowBackIcon
							.padding()
					})
					.background(Color.white)
					.clipShape(Circle())
					.padding(.leading)

					Spacer()
				}
				.padding(.top)
				.alert(isPresented: $loginVM.isShowError, content: {
					Alert(
						title: Text(LocaleText.attention),
						message: Text(loginVM.error?.errorDescription ?? ""),
						dismissButton: .cancel(Text(LocaleText.okText))
					)
				})

				LoadingView(isAnimating: $loginVM.isLoading)
					.isHidden(loginVM.isLoading ? false : true, remove: loginVM.isLoading ? false : true)
			}
			.sheet(isPresented: $loginVM.isShowingCountryPicker, content: {
				CountryPicker(country: $loginVM.countrySelected)
			})
			.dinotisSheet(
				isPresented: $loginVM.isShowSelectChannel,
				fraction: 0.45,
				content: {
					SelectChannelView(channel: $loginVM.selectedChannel, geo: geo) {
						withAnimation {
							if loginVM.isRegister {
								loginVM.register()
								loginVM.isShowSelectChannel = false
							}
						}
					}
				}
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
