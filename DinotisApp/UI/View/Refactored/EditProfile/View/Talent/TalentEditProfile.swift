//
//  TalentEditProfile.swift
//  DinotisApp
//
//  Created by Gus Adi on 12/08/21.
//

import SwiftUI
import SwiftUINavigation
import Moya

struct TalentEditProfile: View {

	@Binding var userData: Users?

	@Binding var profesionSelect: [ProfessionElement]

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
											.font(.montserratRegular(size: 12))
											.foregroundColor(.black)
										Spacer()
									}
									.alert(isPresented: $viewModel.isRefreshFailed) {
										Alert(
											title: Text(LocaleText.attention),
											message: Text(LocaleText.sessionExpireText),
											dismissButton: .default(Text(LocaleText.returnText), action: {
												viewModel.autoLogout()
											})
										)
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

								VStack {
									HStack {
										Text(LocaleText.linkUrlTitle)
											.font(.montserratRegular(size: 12))
											.foregroundColor(.black)

										Spacer()
									}

									HStack(spacing: 5) {
										Text(viewModel.constUrl)
											.font(.montserratSemiBold(size: 12))
											.foregroundColor(.black)
											.fixedSize(horizontal: true, vertical: false)
										
										TextField(LocaleText.usernameHint, text: $viewModel.username)
											.font(.montserratRegular(size: 12))
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

								VStack {
									HStack {
										Text(LocaleText.professionTitle)
											.font(.montserratRegular(size: 12))
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
							viewModel.uploadSingleImage()
						}, label: {
							HStack {
								Spacer()
								Text(LocaleText.saveText)
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(viewModel.isAvailableToSaveTalent() ? .white : .black.opacity(0.6))
									.padding(10)
									.padding(.horizontal, 5)
									.padding(.vertical, 5)

								Spacer()
							}
							.background(viewModel.isAvailableToSaveTalent() ? Color.primaryViolet : Color(.systemGray5))
							.clipShape(RoundedRectangle(cornerRadius: 8))
						})
						.padding()
						.background(Color.white)
						.disabled(!viewModel.isAvailableToSaveTalent())

						Color.white
							.frame(height: 10)

					}
					.edgesIgnoringSafeArea(.all)
					.onAppear {
						for item in profesionSelect {
							viewModel.professionSelectID.append(item.profession.id)
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
										for items in profesionSelect where item.id == items.profession.id {
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
											ProfessionElement(
												userID: (userData?.id).orEmpty(),
												professionID: item.id,
												createdAt: "",
												updatedAt: "",
												profession: ProfessionProfession(
													id: item.id,
													name: item.name,
													createdAt: item.createdAt,
													updatedAt: item.updatedAt)
											)
										)
										viewModel.professionSelectID.append(item.id)
										withAnimation(.spring()) {
											viewModel.showDropDown.toggle()
										}
									}, label: {
										VStack {
											HStack {
												Text(item.name)
													.font(.montserratRegular(size: 12))
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

				LoadingView(isAnimating: $viewModel.isLoading)
					.isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)

			}
			.onDisappear(perform: {
				viewModel.professionSelectID = []
				viewModel.image = UIImage()
				viewModel.userHighlightsImage = [UIImage(), UIImage(), UIImage()]
			})
			.onAppear(perform: {
				viewModel.onViewAppear(user: userData)
				viewModel.getProfession()
				viewModel.getUsers()
			})
			.navigationBarTitle(Text(""))
			.navigationBarHidden(true)
		}
	}
}

struct TalentEditProfile_Previews: PreviewProvider {
	static var previews: some View {
		let profesionSelecct = ProfessionElement(userID: "", professionID: 1, createdAt: "", updatedAt: "", profession: ProfessionProfession(id: 1, name: "", createdAt: "", updatedAt: ""))

		let rolesElement = RoleElement(userID: "", roleID: 1, createdAt: "", updatedAt: "")
		let hightLight : [Highlights] = [
			Highlights(imgUrl: "261a2a6eebc8b9d10c134710553769fb77.png", userId: "", createdAt: "", updateAt: ""),
			Highlights(imgUrl: "https://lh3.googleusercontent.com/ogw/ADea4I5gWzpZepxJh60QiaUb-qRJt4ktsCQOZNrhwyOI=s192-c-mo", userId: "", createdAt: "", updateAt: "")]

		TalentEditProfile(
			userData: .constant(Users(id: "",
																email: "hilmy@gmail.com",
																name: "hilmy ghozy",
																username: "ramramzzz",
																phone: "08123123123",
																profilePhoto: "https://lh3.googleusercontent.com/ogw/ADea4I5gWzpZepxJh60QiaUb-qRJt4ktsCQOZNrhwyOI=s192-c-mo",
																profileDescription: "test bio",
																emailVerifiedAt: "hilmy",
																isVerified: true,
																isPasswordFilled: true,
																registeredWith: 1,
																lastLoginAt: "",
																professionID: "",
																createdAt: "",
																updatedAt: "",
																roles: [rolesElement],
																balance: nil,
																profession: "",
																professions: [profesionSelecct],
																calendar: "",
																userHighlights: hightLight,
																coinBalance: nil
															 )
			),
			profesionSelect: .constant([profesionSelecct]),
			viewModel: EditProfileViewModel(backToRoot: {}, backToHome: {}))
	}
}
