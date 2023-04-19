//
//  UserEditProfile.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/08/21.
//

import DinotisData
import DinotisDesignSystem
import OneSignal
import SwiftUI
import SwiftUINavigation

struct UserEditProfile: View {
	@ObservedObject var stateObservable = StateObservable.shared

	@Environment(\.presentationMode) var presentationMode

	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder

	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}

	@ObservedObject var viewModel: EditProfileViewModel

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
				Color.DinotisDefault.baseBackground
					.edgesIgnoringSafeArea(.all)

				VStack(spacing: 0) {
					HeaderView(
						type: .textHeader,
						title: LocalizableText.editProfileTitle,
						leadingButton: {
							DinotisElipsisButton(
								icon: .generalBackIcon,
								iconColor: .DinotisDefault.black1,
								bgColor: .DinotisDefault.white,
								strokeColor: nil,
								iconSize: 12,
								type: .primary, {
									self.presentationMode.wrappedValue.dismiss()
								}
							)
						},
						trailingButton: {
							Button {
								viewModel.openWhatsApp()
							} label: {
								Image.generalQuestionIcon
									.resizable()
									.scaledToFit()
									.frame(height: 25)
							}
						}
					)

					ScrollView(.vertical, showsIndicators: false) {
						VStack(spacing: 20) {
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

							VStack(spacing: 15) {
								DinotisTextField(
									LocalizableText.hintFormName,
									label: LocalizableText.labelFormName,
									text: $viewModel.names,
									errorText: .constant(nil)
								)
								.autocapitalization(.words)
								.disableAutocorrection(true)

								DinotisTextField(
									LocalizableText.phoneHint,
									disabled: true,
									label: LocalizableText.formPhoneLabel,
									text: $viewModel.phone,
									errorText: .constant(nil),
									trailingButton: {
										DinotisPrimaryButton(
											text: LocalizableText.changeLabel,
											type: .mini,
											textColor: .white,
											bgColor: .DinotisDefault.primary
										) {
											viewModel.routeToChangePhone()
										}
									}
								)
							}
						}
						.padding()
					}

					DinotisPrimaryButton(
						text: LocalizableText.changeNowLabel,
						type: .adaptiveScreen,
						textColor: !viewModel.isAvailableToSaveUser() ? .DinotisDefault.lightPrimaryActive : .DinotisDefault.white,
                        bgColor: !viewModel.isAvailableToSaveUser() ? .DinotisDefault.lightPrimary : .DinotisDefault.primary
                    ) {
                        viewModel.onUpload {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(!viewModel.isAvailableToSaveUser())
                    .padding()
                }
                .onAppear {
                    Task {
                        await viewModel.getUsers()
                    }
				}

			}
            
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
		}
    .dinotisAlert(
      isPresent: $viewModel.isShowAlert,
      title: viewModel.alert.title,
      isError: viewModel.alert.isError,
      message: viewModel.alert.message,
      primaryButton: viewModel.alert.primaryButton
    )
		.onDisappear(perform: {
			self.viewModel.image = UIImage()
		})
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}
