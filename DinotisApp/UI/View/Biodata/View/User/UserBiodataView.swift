//
//  UserBiodataView.swift
//  DinotisApp
//
//  Created by Gus Adi on 08/08/21.
//

import DinotisData
import DinotisDesignSystem
import OneSignal
import SwiftUI
import SwiftUINavigation
import WaterfallGrid

struct UserBiodataView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    @ObservedObject var viewModel: BiodataViewModel
    
    @ObservedObject var stateObservable = StateObservable.shared
    
    var body: some View {
        ZStack {
            
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /PrimaryRouting.tabContainer,
                destination: { viewModel in
                    TabViewContainer()
                        .environmentObject(viewModel.wrappedValue)
                },
                onNavigate: {_ in },
                label: {
                    EmptyView()
                }
            )
            
            ZStack(alignment: .top) {
                Color.DinotisDefault.baseBackground
                    .edgesIgnoringSafeArea(.all)
                
                Image.backgroundAuthenticationImage
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    Image.generalDinotisImage
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(height: 35)
                        .padding(.vertical)
                    
                    VStack {
                        ScrollView(.vertical, showsIndicators: false, content: {
                            VStack {
                                Text(LocalizableText.titleFormRegister)
                                    .font(.robotoBold(size: 20))
                                    .foregroundColor(.DinotisDefault.black1)
                                    .padding(.bottom, 24)
                                
                                VStack(spacing: 15) {
                                    DinotisTextField(
                                        LocalizableText.hintFormName,
                                        label: LocalizableText.labelFormName,
                                        text: $viewModel.name,
                                        errorText: $viewModel.nameError
                                    )
									.autocorrectionDisabled(true)
									.autocapitalization(.sentences)

									if stateObservable.userType == 2 {
										DinotisTextField(
											LocalizableText.hintFormUsername,
											label: LocalizableText.labelFormUsername,
											text: $viewModel.url,
											errorText: $viewModel.usernameError,
                                            trailingButton: {
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
										)
										.autocorrectionDisabled(true)
										.autocapitalization(.none)
										.valueChanged(value: viewModel.url) { _ in
											viewModel.startCheckAvail()
										}
										.valueChanged(value: viewModel.name, onChange: { value in
											if stateObservable.userType == 2 {
												if !value.isEmpty {
													viewModel.startCheckingTimer()
												} else {
													viewModel.url = ""
												}
											}
										})

										DinotisTextEditor(
											LocalizableText.hintFormBio,
											label: LocalizableText.labelFormBio,
											text: $viewModel.bio,
											errorText: $viewModel.bioError
										)
										.autocorrectionDisabled(true)
										.autocapitalization(.none)

										VStack(alignment: .leading, spacing: 8) {

											Text(LocaleText.professionTitle)
												.font(.robotoMedium(size: 12))
												.foregroundColor(.black)

											HStack {
												HStack {

													WaterfallGrid(viewModel.profesionSelect, id: \.self) { item in
														HStack {
															Text(viewModel.profesionSelect.isEmpty ? LocaleText.chooseProfession : item)
																.font(.robotoMedium(size: 10))
																.foregroundColor(viewModel.profesionSelect.isEmpty ? Color(.lightGray) : .DinotisDefault.primary)
																.lineLimit(1)

															Image(systemName: "xmark")
																.resizable()
																.scaledToFit()
																.foregroundColor(.DinotisDefault.primary)
																.font(.system(size: 10, weight: .bold, design: .rounded))
																.frame(height: 8)
														}
														.padding(10)
														.background(
															Capsule()
																.foregroundColor(.DinotisDefault.lightPrimary)
														)
														.onTapGesture {
															while viewModel.profesionSelect.contains(item) {
																if let itemToRemoveIndex = viewModel.profesionSelect.firstIndex(of: item) {
																	viewModel.profesionSelect.remove(at: itemToRemoveIndex)
																}
															}
														}

													}
													.gridStyle(
														columnsInPortrait: UIDevice.current.userInterfaceIdiom == .pad ? 5 : 3,
														columnsInLandscape: UIDevice.current.userInterfaceIdiom == .pad ? 5 : 5,
														spacing: 5,
														animation: nil
													)
													.padding(5)

													Spacer()

													Image.Dinotis.chevronBottomIcon
														.resizable()
														.scaledToFit()
														.frame(height: 24)
														.padding(.horizontal)
												}
												.padding(.vertical, 10)
											}
											.background(
												RoundedRectangle(cornerRadius: 8)
													.foregroundColor(.white)
											)
											.overlay(
												RoundedRectangle(cornerRadius: 8)
													.stroke(Color(red: 0.792, green: 0.8, blue: 0.812), lineWidth: 1)
											)
											.onTapGesture(perform: {
												viewModel.showingDropdown()
											})

											if let error = viewModel.professionError {
												ForEach(error, id: \.self) {
													Text($0)
														.font(.robotoMedium(size: 10))
														.foregroundColor(.DinotisDefault.red)
														.multilineTextAlignment(.leading)
												}
											}
										}
									}
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(LocalizableText.labelFormPassword)
                                            .font(.robotoMedium(size: 12))
                                            .foregroundColor(.DinotisDefault.black1)
                                        
                                        PasswordTextField(
                                            LocalizableText.passwordHint,
                                            isSecure: $viewModel.isSecure,
                                            password: $viewModel.password,
											errorText: $viewModel.passwordError
                                        ) {
                                            Button(action: {
                                                viewModel.isSecure.toggle()
                                            }, label: {
                                                Image(systemName: viewModel.isSecure ? "eye.slash.fill" : "eye.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 12)
                                                    .foregroundColor(.DinotisDefault.black2)
                                            })
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(LocalizableText.labelFormRepassword)
                                            .font(.robotoMedium(size: 12))
                                            .foregroundColor(.DinotisDefault.black1)
                                        
                                        PasswordTextField(
                                            LocalizableText.hintFormRepassword,
                                            isSecure: $viewModel.isRepasswordSecure,
                                            password: $viewModel.confirmPassword,
											errorText: $viewModel.repasswordError
                                        ) {
                                            Button(action: {
                                                viewModel.isRepasswordSecure.toggle()
                                            }, label: {
                                                Image(systemName: viewModel.isRepasswordSecure ? "eye.slash.fill" : "eye.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 12)
                                                    .foregroundColor(.DinotisDefault.black2)
                                            })
                                        }
                                    }
                                }
                                
                                DinotisPrimaryButton(
                                    text: LocalizableText.saveLabel,
                                    type: .adaptiveScreen,
                                    textColor: viewModel.isAvailableToSaveUser() ? .DinotisDefault.white : .DinotisDefault.lightPrimaryActive,
                                    bgColor: viewModel.isAvailableToSaveUser() ? .DinotisDefault.primary : .DinotisDefault.lightPrimary) {
                                        Task {
                                            await viewModel.updateUsers()
                                        }
                                    }
                                    .disabled(!viewModel.isAvailableToSaveUser())
                                    .padding(.top, 24)
                                
                            }
							.padding()
                            .padding(.vertical)
                            .background(
                                RoundedRectangle(cornerRadius: 26)
                                    .fill(Color.white)
                                    .shadow(color: Color(red: 0.22, green: 0.29, blue: 0.41).opacity(0.11), radius: 10)
                            )
                            .padding(.horizontal)
                        })
                        
                        Divider()
                        
                        HStack {
                            Button {
                                viewModel.openWhatsApp()
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
					.onAppear {
                        Task {
                            if stateObservable.userType == 2 {
                                await viewModel.getProfession()
                            }
                            await viewModel.getUsers()
                        }
					}
                }
            }
            
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
		.sheet(isPresented: $viewModel.showDropDown, content: {
			if #available(iOS 16.0, *) {
				VStack {
					ScrollView(.vertical, showsIndicators: true) {
						VStack {

							ForEach((viewModel.professionData?.data ?? []).unique(), id: \.id) { item in
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

									viewModel.profesionSelect.append(item.name.orEmpty())
                                    viewModel.profesionSelectID.append(item.id.orZero())
									viewModel.showingDropdown()
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
				.presentationDetents([.fraction(0.5), .large])
                .dynamicTypeSize(.large)
			} else {
				VStack {
					ScrollView(.vertical, showsIndicators: true) {
						VStack {

							ForEach((viewModel.professionData?.data ?? []).unique(), id: \.id) { item in
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

									viewModel.profesionSelect.append(item.name.orEmpty())
                                    viewModel.profesionSelectID.append(item.id.orZero())
									viewModel.showingDropdown()
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
                .dynamicTypeSize(.large)
			}
		})
        .dinotisAlert(
            isPresent: $viewModel.isError,
            title: LocaleText.attention,
            isError: true,
            message: viewModel.error.orEmpty(),
            primaryButton: .init(text: LocalizableText.closeLabel, action: {})
        )
        .dinotisAlert(
            isPresent: $viewModel.isSuccessUpdated,
            title: LocalizableText.titleFormRegisterDialogSuccess,
            isError: false,
            message: LocalizableText.descriptionFormRegisterDialogSuccess,
            primaryButton: .init(text: LocalizableText.closeLabel, action: {
                viewModel.routingToHome()
            })
        )
        .dinotisAlert(
            isPresent: $viewModel.isRefreshFailed,
            title: LocaleText.attention,
            isError: true,
            message: LocaleText.sessionExpireText,
            primaryButton: .init(text: LocalizableText.closeLabel, action: {
                NavigationUtil.popToRootView()
                self.stateObservable.userType = 0
                self.stateObservable.isVerified = ""
                self.stateObservable.refreshToken = ""
                self.stateObservable.accessToken = ""
                self.stateObservable.isAnnounceShow = false
                OneSignal.setExternalUserId("")
            })
        )
    }
}

fileprivate struct Preview: View {
    
    init() {
        FontInjector.registerFonts()
    }
    
    var body: some View {
        UserBiodataView(viewModel: BiodataViewModel())
    }
}

struct UserBiodataView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }
}
