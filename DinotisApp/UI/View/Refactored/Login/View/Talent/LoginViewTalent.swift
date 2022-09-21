//
//  LoginViewTalent.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/08/21.
//

import SwiftUI
import SwiftUINavigation

struct LoginViewTalent: View {
	
	@ObservedObject var loginVM: LoginViewModel
	
	@State var isShowConnection = false
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		GeometryReader { geo in
			ZStack(alignment: .top) {
				Image.Dinotis.userTypeBackground
					.resizable()
					.edgesIgnoringSafeArea(.all)

				ScrollView(.vertical, showsIndicators: false, content: {
					VStack {
						Spacer()
						Image.Dinotis.dinotisLogoFulfilled
							.resizable()
							.scaledToFit()
							.frame(height: 44)
							.padding(.top, 3)

						Spacer()

						Image.Dinotis.talentLoginImage
							.resizable()
							.scaledToFit()
							.frame(height: geo.size.height/3)
							.padding(.horizontal, 50)
							.padding(15)

						Spacer()

						VStack {
							Text(LocaleText.loginAsTalent)
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
											loginVM.phone.role = 2

											loginVM.login(usertype: .talent)
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
													loginVM.phone.role = 2

													loginVM.login(usertype: .talent)
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
													loginVM.phone.role = 2

													loginVM.login(usertype: .talent)
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
									loginVM.phone.role = 2

									loginVM.login(usertype: .talent)
								}, label: {
									HStack {

										Spacer()

										Text(LocaleText.generalLoginText)
											.font(.montserratSemiBold(size: 12))
											.foregroundColor(.white)
											.padding(10)
											.padding(.horizontal, 5)
											.padding(.vertical, 5)

										Spacer()

									}
									.background(Color.primaryViolet)
									.clipShape(RoundedRectangle(cornerRadius: 8))
								})

								NavigationLink(
									unwrapping: $loginVM.route,
									case: /PrimaryRouting.homeTalent
								) { viewModel in
									TalentHomeView(homeVM: viewModel.wrappedValue)
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

							HStack {
								Button {
									loginVM.goToGoogleForm()
								} label: {
									Text(LocaleText.registerBeATalent)
										.font(.montserratRegular(size: 12))
										.underline()
										.foregroundColor(.black)
								}

								Spacer()
							}

						}
						.padding(20)
						.background(Color(.white))
						.cornerRadius(16)
						.shadow(color: Color.dinotisShadow.opacity(0.2), radius: 40, x: 0.0, y: 0.0)
						.padding(.bottom)
					}
					.padding(10)
				})

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
						message: Text(loginVM.loginErrorTextForTalent()),
						dismissButton: .cancel(Text(LocaleText.okText))
					)
				})

				NavigationLink(destination: EmptyView()) {
					EmptyView()
				}

				LoadingView(isAnimating: $loginVM.isLoading)
					.isHidden(!loginVM.isLoading, remove: !loginVM.isLoading)
			}
			.sheet(isPresented: $loginVM.isShowingCountryPicker, content: {
				CountryPicker(country: $loginVM.countrySelected)
			})
		}
		.onDisappear(perform: {
			loginVM.isLoading = false
			loginVM.onDisappearView()
		})
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
		
	}
}

struct LoginViewTalent_Previews: PreviewProvider {
	static var previews: some View {
		LoginViewTalent(loginVM: LoginViewModel(backToRoot: {}))
	}
}
