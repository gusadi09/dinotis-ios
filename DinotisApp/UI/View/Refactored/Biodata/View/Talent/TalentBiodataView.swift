//
//  TalentBiodataView.swift
//  DinotisApp
//
//  Created by Gus Adi on 08/08/21.
//

import SwiftUI
import SwiftUINavigation
import OneSignal

struct TalentBiodataView: View {

	@ObservedObject var viewModel: BiodataViewModel

	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder

	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}

	@State var isShowConnection = false

	@ObservedObject var stateObservable = StateObservable.shared

	var body: some View {
		ZStack {
			NavigationLink(
				unwrapping: $viewModel.route,
				case: /PrimaryRouting.homeTalent,
				destination: { viewModel in
					TalentHomeView(homeVM: viewModel.wrappedValue)
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
						Image.Dinotis.dinotisLogoFulfilled
							.resizable()
							.frame(
								minWidth: 46.6,
								idealWidth: 140,
								maxWidth: 140,
								minHeight: 14.6,
								idealHeight: 44,
								maxHeight: 44,
								alignment: .center
							)
							.padding(.top)
							.padding(.bottom, 15)
							.alert(isPresented: $viewModel.isRefreshFailed) {
								Alert(
									title: Text(LocaleText.attention),
									message: Text(LocaleText.sessionExpireText),
									dismissButton: .default(Text(LocaleText.okText), action: {
										viewModel.backToRoot()
										stateObservable.userType = 0
										stateObservable.isVerified = ""
										stateObservable.refreshToken = ""
										stateObservable.accessToken = ""
										stateObservable.isAnnounceShow = false
										OneSignal.setExternalUserId("")
									}))
							}

						Image.Dinotis.biodataImage
							.resizable()
							.frame(
								minWidth: 40,
								idealWidth: 200,
								maxWidth: 200,
								minHeight: 40,
								idealHeight: 135,
								maxHeight: 135,
								alignment: .center
							)
							.padding(.horizontal, 50)
							.padding(.top, 15)
							.padding(.bottom, -30)

						VStack(spacing: 20) {
							Text(LocaleText.completePersonalDataText)
								.font(.montserratBold(size: 18))
								.padding(.bottom, 15)
								.foregroundColor(.black)
								.alert(isPresented: $viewModel.isError) {
									Alert(
										title: Text(LocaleText.attention),
										message: Text((viewModel.error?.errorDescription).orEmpty()),
                                        dismissButton: .default(Text(LocaleText.okText))
									)
								}

							VStack {
								HStack {
									Text(LocaleText.nameText)
										.font(.montserratRegular(size: 12))
										.foregroundColor(.black)
									Spacer()
								}

								TextField(LocaleText.nameHint, text: $viewModel.name)
									.font(.montserratRegular(size: 12))
									.autocapitalization(.words)
									.disableAutocorrection(true)
									.foregroundColor(.black)
									.accentColor(.black)
									.padding()
									.overlay(
										RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
									)
									.valueChanged(value: viewModel.name, onChange: { value in
										if !value.isEmpty {
											viewModel.startCheckingTimer()
										} else {
											viewModel.url = ""
										}
									})
							}

							VStack {
								HStack {
									Text(LocaleText.usernameTitle)
										.font(.montserratRegular(size: 12))
										.foregroundColor(.black)
									Spacer()
								}

								HStack(spacing: 5) {
									Text(viewModel.constUrl)
										.font(.montserratSemiBold(size: 12))
										.foregroundColor(.black)

									TextField(LocaleText.usernameHint, text: $viewModel.url)
										.font(.montserratRegular(size: 12))
										.disableAutocorrection(true)
										.foregroundColor(.black)
										.accentColor(.black)
										.valueChanged(value: viewModel.url) { _ in
											viewModel.startCheckAvail()
										}

									if viewModel.isUsernameAvail {
										Image.Dinotis.verifiedCorrectIcon
											.resizable()
											.scaledToFit()
											.frame(height: 18)
									} else if !viewModel.isUsernameAvail || viewModel.name.isEmpty || viewModel.url.isEmpty || viewModel.usernameInvalid {
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

							VStack {
								HStack {
									Text(LocaleText.professionTitle)
										.font(.montserratRegular(size: 12))
										.foregroundColor(.black)
									Spacer()
								}

								HStack {
									HStack {
										HStack {
											ForEach(viewModel.profesionSelect, id: \.self) { item in
												HStack {
													Text(viewModel.profesionSelect.isEmpty ? LocaleText.chooseProfession : item)
														.font(.montserratRegular(size: 12))

													Image(systemName: "xmark")
														.resizable()
														.scaledToFit()
														.frame(height: 10)
												}
												.padding(5)
												.background(Color(.systemGray5))
												.cornerRadius(5)
												.onTapGesture {
													while viewModel.profesionSelect.contains(item) {
														if let itemToRemoveIndex = viewModel.profesionSelect.firstIndex(of: item) {
															viewModel.profesionSelect.remove(at: itemToRemoveIndex)
														}
													}
												}
											}
										}
										.foregroundColor(viewModel.profesionSelect.isEmpty ? Color(.lightGray) : .black)
										.padding(5)

										Spacer()

										Image.Dinotis.chevronBottomIcon
											.resizable()
											.scaledToFit()
											.frame(height: 24)
											.padding(.horizontal)
									}
									.padding(.vertical, 10)
									.background(Color.white)
								}
								.overlay(
									RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
								)
								.onTapGesture(perform: {
									viewModel.showingDropdown()
								})
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
                                    Text(LocaleText.newPasswordTitle)
                                        .font(.montserratRegular(size: 12))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                
                                HStack {
                                    Image.Dinotis.lockIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 24)
                                    
                                    if viewModel.isPassShow {
                                        TextField(LocaleText.enterConfirmNewPass, text: $viewModel.password)
                                            .font(.montserratRegular(size: 14))
                                            .foregroundColor(.black)
                                            .accentColor(.black)
                                            .disableAutocorrection(true)
                                            .autocapitalization(.none)
                                        
                                    } else {
                                        SecureField(LocaleText.enterConfirmNewPass, text: $viewModel.password)
                                            .font(.montserratRegular(size: 14))
                                            .foregroundColor(.black)
                                            .accentColor(.black)
                                            .disableAutocorrection(true)
                                            .autocapitalization(.none)
                                    }
                                    
                                    Button(action: {
                                        viewModel.isPassShow.toggle()
                                    }, label: {
                                        Image(systemName: viewModel.isPassShow ? "eye.slash.fill" : "eye.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 14)
                                            .foregroundColor(.dinotisGray)
                                    })
                                }
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.dinotisStrokeSecondary, lineWidth: 1)
                                )
                            }
                            
                            VStack {
                                HStack {
                                    Text(LocaleText.newConfirmPasswordTitle)
                                        .font(.montserratRegular(size: 12))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                
                                HStack {
                                    Image.Dinotis.lockIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 24)
                                    
                                    if viewModel.isRepeatPassShow {
                                        TextField(LocaleText.enterConfirmNewPass, text: $viewModel.confirmPassword)
                                            .font(.montserratRegular(size: 14))
                                            .foregroundColor(.black)
                                            .accentColor(.black)
                                            .disableAutocorrection(true)
                                            .autocapitalization(.none)
                                        
                                    } else {
                                        SecureField(LocaleText.enterConfirmNewPass, text: $viewModel.confirmPassword)
                                            .font(.montserratRegular(size: 14))
                                            .foregroundColor(.black)
                                            .accentColor(.black)
                                            .disableAutocorrection(true)
                                            .autocapitalization(.none)
                                    }
                                    
                                    Button(action: {
                                        viewModel.isRepeatPassShow.toggle()
                                    }, label: {
                                        Image(systemName: viewModel.isRepeatPassShow ? "eye.slash.fill" : "eye.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 14)
                                            .foregroundColor(.dinotisGray)
                                    })
                                }
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.dinotisStrokeSecondary, lineWidth: 1)
                                )
                            }
						}
						.padding(20)
						.background(Color(.white))
						.cornerRadius(16)
						.shadow(color: Color.dinotisShadow.opacity(0.1), radius: 40, x: 0.0, y: 0.0)
						.padding(.horizontal)
						.padding(.bottom, 100)

						Spacer()
					}
				})

				VStack(spacing: 0) {

					Spacer()

					Button(action: {
						viewModel.updateUsers()
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

			}

			GeometryReader { proxy in
				ZStack(alignment: .bottom) {
					Color.black.opacity(viewModel.showDropDown ? 0.35 : 0)
						.onTapGesture {
							viewModel.showingDropdown()
						}

					VStack {
						ScrollView(.vertical, showsIndicators: true) {
							VStack {
								
								ForEach(viewModel.professionData?.data ?? [], id: \.id) { item in
									Button(action: {
										for items in viewModel.profesionSelect where item.name == items {
											if let itemToRemoveIndex = viewModel.profesionSelect.firstIndex(of: items) {
												viewModel.profesionSelect.remove(at: itemToRemoveIndex)
											}
										}

										for items in viewModel.profesionSelectID where item.id == items {
											if let itemToRemoveIndex = viewModel.profesionSelectID.firstIndex(of: items) {
												viewModel.profesionSelectID.remove(at: itemToRemoveIndex)
											}
										}

										viewModel.profesionSelect.append(item.name)
										viewModel.profesionSelectID.append(item.id)
										viewModel.showingDropdown()
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

											if (item.name != (viewModel.professionData?.data?.last?.name).orEmpty()) {
												Divider()
													.padding(.horizontal)
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
			}

            LoadingView(isAnimating: $viewModel.isLoading)
			.isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)
		}
		.onAppear {
			viewModel.getProfession()
			viewModel.getUsers()
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)

	}
}

struct TalentBiodataView_Previews: PreviewProvider {
	static var previews: some View {
		TalentBiodataView(viewModel: BiodataViewModel(backToRoot: {}))
	}
}
