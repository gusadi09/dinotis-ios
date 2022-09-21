//
//  UserEditProfile.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/08/21.
//

import SwiftUI
import SwiftUINavigation
import OneSignal

struct UserEditProfile: View {

	@Binding var userData: Users?

	@ObservedObject var stateObservable = StateObservable.shared

	@Environment(\.presentationMode) var presentationMode

	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder

	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}

	@ObservedObject var viewModel: EditProfileViewModel

	@State var isShowConnection = false

	var body: some View {
		ZStack {

			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.changePhone,
				destination: { viewModel in
					ChangePhoneView(viewModel: viewModel.wrappedValue)
				},
				onNavigate: {_ in },
				label: {
					EmptyView()
				}
			)

			ZStack(alignment: .top) {
				Image.Dinotis.userTypeBackground
					.resizable()
					.edgesIgnoringSafeArea(.all)
					.alert(isPresented: $isShowConnection) {
						Alert(
							title: Text(LocaleText.attention),
							message: Text(NSLocalizedString("connection_warning", comment: "")),
							dismissButton: .cancel(Text(LocaleText.returnText))
						)
					}

				ScrollView(.vertical, showsIndicators: false, content: {
					VStack {
						HStack {
							Spacer()
							Text(LocaleText.editProfileTitle)
								.font(.montserratBold(size: 14))
								.foregroundColor(.black)

							Spacer()
						}
						.padding(.top)
						.padding()
						.alert(isPresented: $viewModel.isError) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text((viewModel.error?.errorDescription).orEmpty()),
								dismissButton: .default(Text(LocaleText.returnText))
							)
						}

						VStack(spacing: 20) {

							HStack {
								Button(action: {
									viewModel.isShowPhotoLibrary.toggle()
								}, label: {
									ZStack(alignment: .bottomTrailing) {
										if viewModel.image == UIImage() {
											ProfileImageContainer(
												profilePhoto: $viewModel.userPhoto,
												name: $viewModel.name,
												width: 75,
												height: 75
											)
										} else {
											Image(uiImage: viewModel.image)
												.resizable()
												.scaledToFill()
												.frame(width: 75, height: 75)
												.clipShape(Circle())
										}

										Image.Dinotis.editPhotoIcon
											.resizable()
											.scaledToFit()
											.frame(height: 24)
											.clipShape(Circle())
									}
								})
								.sheet(isPresented: $viewModel.isShowPhotoLibrary) {
									ImagePicker(sourceType: .photoLibrary, selectedImage: self.$viewModel.image)
								}

								Spacer()
							}
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
								HStack {
									Text(LocaleText.nameText)
										.font(.montserratRegular(size: 12))
										.foregroundColor(.black)
									Spacer()
								}

								TextField(LocaleText.nameHint, text: $viewModel.names)
									.font(.montserratRegular(size: 12))
									.autocapitalization(.words)
									.disableAutocorrection(true)
									.foregroundColor(.black)
									.accentColor(.black)
									.padding()
									.overlay(
										RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
									)
							}

							VStack(spacing: 8) {
								HStack {
									Text(LocaleText.phoneText)
										.font(.montserratRegular(size: 12))
										.foregroundColor(.black)
									Spacer()
								}

								HStack {
									Text(viewModel.phone)
										.font(.montserratRegular(size: 12))
										.foregroundColor(.black)
										.accentColor(.black)
										.padding()

									Spacer()

									Button(action: {
										viewModel.routeToChangePhone()
									}, label: {
										Text(LocaleText.changeText)
											.font(.montserratSemiBold(size: 10))
											.foregroundColor(.primaryViolet)
											.padding(.horizontal)
											.frame(height: 35)
											.background(Color.secondaryViolet)
											.cornerRadius(8)
											.padding(.trailing, 5)
									})

								}
								.overlay(
									RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
								)
							}

							VStack {
								HStack {
									Text(LocaleText.bioTitle)
										.font(.montserratRegular(size: 12))
										.foregroundColor(.black)
									Spacer()
								}

								MultilineTextField(text: $viewModel.bio)
									.foregroundColor(.black)
									.accentColor(.black)
									.padding(.horizontal, 10)
									.padding(.vertical, 10)
									.overlay(
										RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
									)
							}

						}
						.padding(20)
						.padding(.top)
						.background(Color(.white))
						.cornerRadius(16)
						.shadow(color: Color.dinotisShadow.opacity(0.1), radius: 40, x: 0.0, y: 0.0)
						.padding(.horizontal)
						.padding(.bottom, 100)
						.padding(.top)

						Spacer()
					}
				})
				.alert(isPresented: $viewModel.isSuccessUpdate) {
					Alert(
						title: Text(LocaleText.successTitle),
						message: Text(LocaleText.successUpdateAccount),
						dismissButton: .default(Text(LocaleText.returnText), action: {

							presentationMode.wrappedValue.dismiss()
						}))
				}

				VStack(spacing: 0) {
					Spacer()
					Button(action: {
						viewModel.uploadSingleImage()
					}, label: {
						HStack {
							Spacer()
							Text(LocaleText.saveText)
								.font(.montserratSemiBold(size: 12))
								.foregroundColor(viewModel.isAvailableToSaveUser() ? .white : .black.opacity(0.6))
								.padding(10)
								.padding(.horizontal, 5)
								.padding(.vertical, 5)
							Spacer()
						}
						.background(viewModel.isAvailableToSaveUser() ? Color.primaryViolet : Color(.systemGray5))
						.clipShape(RoundedRectangle(cornerRadius: 8))
					})
					.padding()
					.background(Color.white)
					.disabled(!viewModel.isAvailableToSaveUser())

					Color.white
						.frame(height: 10)

				}
				.edgesIgnoringSafeArea(.all)
				.onAppear {
					viewModel.getUsers()
					viewModel.onViewAppear(user: userData)
				}

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
				.padding(.top)

			}

			LoadingView(isAnimating: $viewModel.isLoading)
				.isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)
		}
		.onDisappear(perform: {
			self.viewModel.image = UIImage()
		})

		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)

	}
}
