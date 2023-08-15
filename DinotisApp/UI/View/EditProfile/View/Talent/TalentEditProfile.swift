//
//  TalentEditProfile.swift
//  DinotisApp
//
//  Created by Gus Adi on 12/08/21.
//

import DinotisData
import DinotisDesignSystem
import Moya
import SwiftUI
import SwiftUINavigation

struct TalentEditProfile: View {

	@Binding var profesionSelect: [ProfessionData]

	@Environment(\.presentationMode) var presentationMode

	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder

	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}

	@ObservedObject var viewModel: EditProfileViewModel
	@ObservedObject var stateObservable = StateObservable.shared

	var body: some View {
		GeometryReader { proxy in
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

					ScrollView(.vertical, showsIndicators: false, content: {
						VStack {

							TitleHeader(viewModel: viewModel)

							VStack(spacing: 20) {

								ProfilePicture(viewModel: viewModel)

								HighlightSection(geo: proxy, viewModel: viewModel)

								VStack {
									HStack {
										Text(LocaleText.nameText)
											.font(.robotoRegular(size: 12))
											.foregroundColor(.black)
										Spacer()
									}

									TextField(LocaleText.nameHint, text: $viewModel.names)
										.font(.robotoRegular(size: 12))
										.autocapitalization(.words)
										.disableAutocorrection(true)
										.foregroundColor(.black)
										.accentColor(.black)
										.padding()
										.overlay(
											RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
										)
								}

								VStack {
									HStack {
										Text(LocaleText.linkUrlTitle)
											.font(.robotoRegular(size: 12))
											.foregroundColor(.black)

										Spacer()
									}

									HStack(spacing: 5) {
										Text(viewModel.constUrl)
											.font(.robotoMedium(size: 12))
											.foregroundColor(.black)
											.fixedSize(horizontal: true, vertical: false)
										
										TextField(LocaleText.usernameHint, text: $viewModel.username)
											.font(.robotoRegular(size: 12))
											.disableAutocorrection(true)
											.autocapitalization(.none)
											.foregroundColor(.black)
											.accentColor(.black)
											.valueChanged(value: viewModel.username) { _ in
												viewModel.startCheckAvail()
											}

										Spacer()

										if viewModel.isUsernameAvail {
											Image.Dinotis.verifiedCorrectIcon
												.resizable()
												.scaledToFit()
												.frame(height: 18)
										} else if !viewModel.isUsernameAvail && !viewModel.username.isEmpty {
											if viewModel.username == viewModel.userData?.username {
												EmptyView()
											} else {
												Image(systemName: "xmark")
													.resizable()
													.font(Font.system(size: 8, weight: .semibold))
													.scaledToFit()
													.frame(height: 8)
													.padding(3)
													.foregroundColor(Color.white)
													.background(Color.red)
													.clipShape(Circle())
											}
										} else if viewModel.usernameInvalid {
											Image(systemName: "xmark")
												.resizable()
												.font(Font.system(size: 8, weight: .semibold))
												.scaledToFit()
												.frame(height: 8)
												.padding(3)
												.foregroundColor(Color.white)
												.background(Color.red)
												.clipShape(Circle())
										}
									}
									.padding()
									.overlay(
										RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
									)
								}

								VStack(spacing: 8) {
									HStack {
										Text(LocaleText.phoneText)
											.font(.robotoRegular(size: 12))
											.foregroundColor(.black)
										Spacer()
									}

									HStack {
										Text(viewModel.phone)
											.font(.robotoRegular(size: 12))
											.foregroundColor(.black)
											.accentColor(.black)
											.padding()

										Spacer()

										Button(action: {
											viewModel.routeToChangePhone()
										}, label: {
											Text(LocaleText.changeText)
												.font(.robotoMedium(size: 10))
												.foregroundColor(.DinotisDefault.primary)
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
											.font(.robotoRegular(size: 12))
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

								VStack {
									HStack {
										Text(LocaleText.professionTitle)
											.font(.robotoRegular(size: 12))
											.foregroundColor(.black)
										Spacer()
									}

									HStack {
										HStack {
											ChipsContentView(viewModel: viewModel, profesionSelect: $profesionSelect, geo: proxy)
												.foregroundColor(profesionSelect.isEmpty ? Color(.lightGray) : .black)
												.frame(width: proxy.size.width/2, alignment: .leading)
												.fixedSize(horizontal: true, vertical: false)

											Spacer()

											Image.Dinotis.chevronBottomIcon
												.resizable()
												.scaledToFit()
												.frame(height: 24)
												.padding(.horizontal)
										}
										.background(Color.white)
									}
									.overlay(
										RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
									)
									.clipShape(RoundedRectangle(cornerRadius: 6))
									.onTapGesture(perform: {
										withAnimation(.spring()) {
											viewModel.showDropDown.toggle()
										}

									})
								}
							}
							.padding(20)
							.padding(.top)
							.background(Color(.white))
							.cornerRadius(16)
							.shadow(color: Color.dinotisShadow.opacity(0.1), radius: 40, x: 0.0, y: 0.0)
							.padding(.horizontal)
							.padding(.bottom, 80)
							.padding(.top)
						}
					})

					VStack(spacing: 0) {
                        Spacer()
                        Button(action: {
                            viewModel.onUpload {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }, label: {
                            HStack {
                                Spacer()
								Text(LocaleText.saveText)
									.font(.robotoMedium(size: 12))
									.foregroundColor(viewModel.isAvailableToSaveUser() ? .white : .black.opacity(0.6))
									.padding(10)
									.padding(.horizontal, 5)
									.padding(.vertical, 5)

								Spacer()
							}
							.background(viewModel.isAvailableToSaveUser() ? Color.DinotisDefault.primary : Color(.systemGray5))
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
						for item in profesionSelect {
                            viewModel.professionSelectID.append((item.profession?.id).orZero())
						}
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

				ZStack(alignment: .bottom) {
					Color.black.opacity(viewModel.showDropDown ? 0.35 : 0)
						.onTapGesture {
							withAnimation(.spring()) {
								viewModel.showDropDown.toggle()
							}
						}

					VStack {
						ScrollView(.vertical, showsIndicators: true) {
							VStack {

								ForEach(viewModel.professionData?.data ?? [], id: \.id) { item in
									Button(action: {
										for items in profesionSelect where item.id == (items.profession?.id).orZero() {
											if let itemToRemoveIndex = profesionSelect.firstIndex(of: items) {
												profesionSelect.remove(at: itemToRemoveIndex)
											}
										}

										for items in viewModel.professionSelectID where item.id == items {
											if let itemToRemoveIndex = viewModel.professionSelectID.firstIndex(of: items) {
												viewModel.professionSelectID.remove(at: itemToRemoveIndex)
											}
										}

										profesionSelect.append(
											ProfessionData(
                                                userId: (viewModel.userData?.id).orEmpty(),
                                                professionId: item.id,
												createdAt: Date(),
												updatedAt: Date(),
                                                profession: ProfessionElement(id: item.id, professionCategoryId: item.professionCategoryId, name: item.name, createdAt: item.createdAt, updatedAt: item.updatedAt)
											)
										)
                                        viewModel.professionSelectID.append(item.id.orZero())
										withAnimation(.spring()) {
											viewModel.showDropDown.toggle()
										}
									}, label: {
										VStack {
											HStack {
												Text(item.name.orEmpty())
													.font(.robotoRegular(size: 12))
													.foregroundColor(.black)
													.padding(.horizontal)
													.padding(.vertical)

												Spacer()
											}

											if !(item.name == viewModel.professionData?.data?.last?.name ?? "") {
												Divider()
													.padding(.horizontal)
											} else {
												Capsule()
													.foregroundColor(.clear)
													.frame(height: 1)
											}
										}
									})
									.padding(.top, 5)

								}

							}

						}
					}
					.padding(.vertical)
					.background(
						RoundedCorner(radius: 10, corners: [.topLeft, .topRight])
							.foregroundColor(.white)
					)
					.frame(height: proxy.size.height/2.5)
					.offset(y: viewModel.showDropDown ? .zero : proxy.size.height+150)

				}
				.edgesIgnoringSafeArea(.vertical)

                DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
			}
            .onAppear {
                viewModel.onAppearLoad()
            }
			.onDisappear(perform: {
				viewModel.professionSelectID = []
				viewModel.image = UIImage()
				viewModel.userHighlightsImage = [UIImage(), UIImage(), UIImage()]
			})
			.navigationBarTitle(Text(""))
			.navigationBarHidden(true)
		}
    .dinotisAlert(
      isPresent: $viewModel.isShowAlert,
      title: viewModel.alert.title,
      isError: viewModel.alert.isError,
      message: viewModel.alert.message,
      primaryButton: viewModel.alert.primaryButton
    )
	}
}

struct TalentEditProfile_Previews: PreviewProvider {
	static var previews: some View {

		TalentEditProfile(
			profesionSelect: .constant([]),
			viewModel: EditProfileViewModel(backToHome: {}))
	}
}
