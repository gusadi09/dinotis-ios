//
//  UserProfilePage.swift
//  DinotisApp
//
//  Created by Gus Adi on 09/08/21.
//

import SwiftUI
import SwiftUITrackableScrollView
import SwiftUINavigation
import OneSignal

struct UserProfileView: View {

	@ObservedObject var viewModel: ProfileViewModel

	@Environment(\.presentationMode) var presentationMode

	@State var colorTab = Color.clear

	@State var contentOffset = CGFloat.zero

	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder

	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}

	@State var isShowConnection = false

	@ObservedObject var stateObservable = StateObservable.shared

	var body: some View {
		ZStack(alignment: .center) {
			Image.Dinotis.linearGradientBackground
				.resizable()
				.edgesIgnoringSafeArea(.all)
				.alert(isPresented: $viewModel.isRefreshFailed) {
					Alert(
						title: Text(LocaleText.attention),
						message: Text(LocaleText.sessionExpireText),
						dismissButton: .default(Text(LocaleText.returnText), action: {
							viewModel.routeBackLogout()
						})
					)
				}

			VStack(spacing: 0) {
				colorTab
					.edgesIgnoringSafeArea(.all)
					.frame(height: 1)
					.alert(isPresented: $isShowConnection) {
						Alert(
							title: Text(LocaleText.attention),
							message: Text(NSLocalizedString("connection_warning", comment: "")),
							dismissButton: .cancel(Text(LocaleText.returnText))
						)
					}

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
						Text(LocaleText.myAccountTitle)
							.font(.montserratBold(size: 14))
							.foregroundColor(.black)

						Spacer()
					}
				}
				.padding(.top, 5)
				.padding(.bottom)
				.background(colorTab)

				ScrollViews(axes: .vertical, showsIndicators: false) { value in
					if value.y < -2 {
						colorTab = Color.white
					} else {
						colorTab = Color.clear
					}
				} content: {
					VStack(alignment: .center, spacing: 10) {

						HStack {
							Spacer()

							ProfileImageContainer(
								profilePhoto: $viewModel.userPhotos,
								name: $viewModel.names,
								width: 80,
								height: 80
							)
							.padding(.top, 15)

							Spacer()
						}

						HStack {
							Spacer()
							Text(viewModel.nameOfUser())
								.font(.montserratSemiBold(size: 14))
								.foregroundColor(.black)
							Spacer()
						}

						HStack {
							Spacer()
							Text(viewModel.userBio())
								.font(.montserratRegular(size: 12))
								.foregroundColor(.black)
								.multilineTextAlignment(.center)
							Spacer()
						}
						.padding(20)
						.background(Color.backgroundProfile)
						.cornerRadius(12)

						HStack {
							Text(LocaleText.accountSettingText)
								.font(.montserratBold(size: 14))
								.foregroundColor(.black)

							Spacer()
						}
						.padding(.top, 10)

						VStack {
							VStack {
								Button(action: {
									viewModel.routeToEditProfile()
								}, label: {
									HStack {
										Image.Dinotis.editProfileButtonIcon
											.resizable()
											.scaledToFit()
											.frame(height: 34)
											.padding(.trailing, 5)

										Text(LocaleText.editProfileText)
											.font(.montserratSemiBold(size: 12))
											.foregroundColor(.black)

										Spacer()

										Image(systemName: "chevron.right")
											.resizable()
											.scaledToFit()
											.font(.system(size: 12, weight: .semibold))
											.frame(height: 12)
											.foregroundColor(.black)
									}
								})
								.padding(.vertical, 10)
								.padding(.horizontal, 15)
								.clipShape(Rectangle())

								NavigationLink(
									unwrapping: $viewModel.route,
									case: /HomeRouting.editUserProfile,
									destination: { viewModel in
										UserEditProfile(userData: $viewModel.data, viewModel: viewModel.wrappedValue)
									},
									onNavigate: {_ in },
									label: {
										EmptyView()
									}
								)

								Capsule()
									.frame(height: 1)
									.foregroundColor(Color(.systemGray6))
							}

							Button(action: {
								viewModel.routeToChangePass()
							}, label: {
								HStack {
									Image.Dinotis.changePassButtonIcon
										.resizable()
										.scaledToFit()
										.frame(height: 34)
										.padding(.trailing, 5)

									Text(LocaleText.changePasswordTitle)
										.font(.montserratSemiBold(size: 12))
										.foregroundColor(.black)

									Spacer()

									Image(systemName: "chevron.right")
										.resizable()
										.scaledToFit()
										.font(.system(size: 12, weight: .semibold))
										.frame(height: 12)
										.foregroundColor(.black)
								}
							})
							.padding(.vertical, 10)
							.padding(.horizontal, 15)
							.clipShape(Rectangle())

							NavigationLink(
								unwrapping: $viewModel.route,
								case: /HomeRouting.changePassword,
								destination: { viewModel in
									ChangePasswordView(viewModel: viewModel.wrappedValue)
								},
								onNavigate: {_ in },
								label: {
									EmptyView()
								}
							)

							Capsule()
								.frame(height: 1)
								.foregroundColor(Color(.systemGray6))

							Button(action: {
								viewModel.openWhatsApp()
							}, label: {
								HStack {
									Image.Dinotis.customerServiceButtonIcon
										.resizable()
										.scaledToFit()
										.frame(height: 34)
										.padding(.trailing, 5)

									Text(LocaleText.helpText)
										.font(.montserratSemiBold(size: 12))
										.foregroundColor(.black)

									Spacer()

									Image(systemName: "chevron.right")
										.resizable()
										.scaledToFit()
										.font(.system(size: 12, weight: .semibold))
										.frame(height: 12)
										.foregroundColor(.black)
								}
							})
							.padding(.vertical, 10)
							.padding(.horizontal, 15)
							.clipShape(Rectangle())

							Capsule()
								.frame(height: 1)
								.foregroundColor(Color(.systemGray6))

							Button(action: {
								viewModel.toggleDeleteModal()
							}, label: {
								HStack {
									Image.Dinotis.deleteAccountIcon
										.resizable()
										.scaledToFit()
										.frame(height: 34)
										.padding(.trailing, 5)

									Text(LocaleText.deleteAccountText)
										.font(.montserratSemiBold(size: 12))
										.foregroundColor(.primaryRed)

									Spacer()

									Image(systemName: "chevron.right")
										.resizable()
										.scaledToFit()
										.font(.system(size: 12, weight: .semibold))
										.frame(height: 12)
										.foregroundColor(.black)
								}
							})
							.padding(.vertical, 10)
							.padding(.horizontal, 15)
							.clipShape(Rectangle())

							Capsule()
								.frame(height: 1)
								.foregroundColor(Color(.systemGray6))

							Button(action: {
								viewModel.presentLogout()
							}, label: {
								HStack {
									Image.Dinotis.logoutButtonIcon
										.resizable()
										.scaledToFit()
										.frame(height: 34)
										.padding(.trailing, 5)

									Text(LocaleText.exitText)
										.font(.montserratSemiBold(size: 12))
										.foregroundColor(.black)

									Spacer()

									Image(systemName: "chevron.right")
										.resizable()
										.scaledToFit()
										.font(.system(size: 12, weight: .semibold))
										.frame(height: 12)
										.foregroundColor(.black)
								}
							})
							.padding(.vertical, 10)
							.padding(.horizontal, 15)
							.clipShape(Rectangle())
						}
					}
					.padding()
					.background(Color.white)
					.cornerRadius(16)
					.shadow(color: Color.dinotisShadow.opacity(0.2), radius: 15, x: 0.0, y: 0.0)
					.padding()
					.padding(.bottom, 15)
					.padding(.top, 10)
					.valueChanged(value: contentOffset) { val in
						if val > 0 {
							colorTab = Color.white
						} else {
							colorTab = Color.clear
						}
					}
				}
			}

			ZStack {
				Color.black.opacity(0.5)
					.edgesIgnoringSafeArea(.all)

				LoadingView(isAnimating: $viewModel.isLoading)
			}
				.isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)
		}
		.onAppear(perform: {
			viewModel.getUsers()
		})
		.dinotisSheet(
			isPresented: $viewModel.logoutPresented,
			fraction: 0.65,
			content: {
				VStack(spacing: 10) {
					Image.Dinotis.logoutImage
						.resizable()
						.scaledToFit()
						.frame(height: 150)

					Text(LocaleText.exitTitle)
						.font(.montserratBold(size: 14))
						.foregroundColor(.black)

					Text(LocaleText.exitSubtitle)
						.font(.montserratRegular(size: 12))
						.foregroundColor(.black)
						.multilineTextAlignment(.center)
						.padding(.bottom, 35)

					HStack(spacing: 15) {
						Button(action: {
							viewModel.presentLogout()
						}, label: {
							HStack {
								Spacer()
								Text(LocaleText.cancelText)
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(.black)
								Spacer()
							}
							.padding()
							.background(Color.secondaryViolet)
							.cornerRadius(8)
							.overlay(
								RoundedRectangle(cornerRadius: 8)
									.stroke(Color.primaryViolet, lineWidth: 1.0)
							)
						})

						Button(action: {
							viewModel.routeBackLogout()
						}, label: {
							HStack {
								Spacer()
								Text(LocaleText.exitText)
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(.white)
								Spacer()
							}
							.padding()
							.background(Color.primaryViolet)
							.cornerRadius(8)
						})
					}
				}
			}
		)
		.dinotisSheet(
			isPresented: $viewModel.isPresentDeleteModal,
			fraction: 0.6,
			content: {
				VStack(spacing: 10) {
					Image.Dinotis.removeUserImage
						.resizable()
						.scaledToFit()
						.frame(height: 150)

					Text(LocaleText.deleteAccountText)
						.font(.montserratBold(size: 14))
						.foregroundColor(.black)

					Text(LocaleText.deleteAccountModalSubtitle)
						.font(.montserratRegular(size: 12))
						.foregroundColor(.black)
						.multilineTextAlignment(.center)
						.padding(.bottom, 35)

					HStack(spacing: 15) {
						Button(action: {
							viewModel.toggleDeleteModal()
						}, label: {
							HStack {
								Spacer()
								Text(LocaleText.cancelText)
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(.white)
								Spacer()
							}
							.padding()
							.background(Color.primaryViolet)
							.cornerRadius(8)
						})

						Button(action: {
							viewModel.toggleDeleteModal()
							viewModel.deleteAccount()
						}, label: {
							HStack {
								Spacer()
								Text(LocaleText.generalDeleteText)
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(.white)
								Spacer()
							}
							.padding()
							.background(Color.primaryRed)
							.cornerRadius(8)
						})
					}
				}
			}
		)
		.dinotisSheet(
			isPresented: $viewModel.successDelete,
			fraction: 0.65,
			content: {
				VStack(spacing: 10) {
					Image(systemName: "checkmark.seal.fill")
						.resizable()
						.scaledToFit()
						.foregroundColor(.primaryViolet)
						.frame(height: 120)

					Text(LocaleText.successTitle)
						.font(.montserratBold(size: 14))
						.foregroundColor(.black)

					Text(LocaleText.deleteAccountSuccessText)
						.font(.montserratRegular(size: 12))
						.foregroundColor(.black)
						.multilineTextAlignment(.center)
						.padding(.bottom, 35)

					HStack(spacing: 15) {
						Button(action: {
							viewModel.successDelete.toggle()
							viewModel.routeBackLogout()
						}, label: {
							HStack {
								Spacer()
								Text(LocaleText.okText)
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(.white)
								Spacer()
							}
							.padding()
							.background(Color.primaryViolet)
							.cornerRadius(8)
						})
					}
				}
			}
		)
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct UserProfilePage_Previews: PreviewProvider {
	static var previews: some View {
		UserProfileView(viewModel: ProfileViewModel(backToRoot: {}, backToHome: {}))
	}
}
