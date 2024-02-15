//
//  UserProfilePage.swift
//  DinotisApp
//
//  Created by Gus Adi on 09/08/21.
//

import DinotisData
import DinotisDesignSystem
import OneSignal
import SwiftUI
import SwiftUINavigation
import SwiftUITrackableScrollView
import QGrid
import StoreKit

struct UserProfileView: View {

	@EnvironmentObject var viewModel: ProfileViewModel

	@Environment(\.dismiss) var dismiss

	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder

	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}

	@ObservedObject var stateObservable = StateObservable.shared
    
    @Binding var tabValue: TabRoute

	var body: some View {
		ZStack(alignment: .center) {
			Color.DinotisDefault.baseBackground
				.edgesIgnoringSafeArea(.all)

			VStack(spacing: 0) {
				HeaderView(title: "", headerColor: .DinotisDefault.baseBackground, textColor: .DinotisDefault.baseBackground)
					.frame(height: 15)
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.creatorRoom,
                    destination: { viewModel in
                        CreatorRoomView()
                            .environmentObject(viewModel.wrappedValue)
                    },
                    onNavigate: {_ in },
                    label: {
                        EmptyView()
                    }
                )

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /HomeRouting.editUserProfile,
					destination: { viewModel in
						UserEditProfile(viewModel: viewModel.wrappedValue)
					},
					onNavigate: {_ in },
					label: {
						EmptyView()
					}
				)

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

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /HomeRouting.coinHistory,
					destination: { viewModel in
						CoinHistoryView(viewModel: viewModel.wrappedValue)
					},
					onNavigate: {_ in},
					label: {
						EmptyView()
					}
				)

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /HomeRouting.followedCreator,
					destination: { viewModel in
                        FollowedCreatorView(viewModel: viewModel.wrappedValue, tabValue: $tabValue)
					},
					onNavigate: {_ in},
					label: {
						EmptyView()
					}
				)

                List {
                    
                    HStack(spacing: 20) {
                        
                        ProfileImageContainer(
                            profilePhoto: $viewModel.userPhotos,
                            name: $viewModel.names,
                            width: 80,
                            height: 80,
                            shape: RoundedRectangle(cornerRadius: 12)
                        )
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text((viewModel.data?.name).orEmpty())
                                .font(.robotoBold(size: 20))
                                .foregroundColor(.DinotisDefault.black1)
                                .multilineTextAlignment(.leading)
                            
                            Text((viewModel.data?.phone).orEmpty())
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.DinotisDefault.black2)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 15)
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 15, trailing: 20))
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(LocaleText.homeScreenYourCoin)
                                .font(.robotoBold(size: 12))
                                .foregroundColor(.black)
                            
                            HStack(alignment: .center) {
                                Image.Dinotis.coinIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 15)
                                
                                Text("\(viewModel.userCoin.orEmpty())")
                                    .font(.robotoBold(size: 20))
                                    .foregroundColor(.DinotisDefault.primary)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            viewModel.routeToCoinHistory()
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 16)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    Circle()
                                        .foregroundColor(.DinotisDefault.primary)
                                )
                        }
                        
                        Button {
                            viewModel.showAddCoin.toggle()
                        } label: {
                            Text(LocaleText.homeScreenAddCoin)
                                .font(.robotoBold(size: 12))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.DinotisDefault.primary)
                                )
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 25)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 0)
                    )
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
                    
                    HStack {
                        Text(LocaleText.accountSettingText)
                            .font(.robotoBold(size: 18))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 15, trailing: 20))
                    
                    VStack {
                        VStack {
                            Button(action: {
                                viewModel.routeToEditProfile()
                            }, label: {
                                HStack {
                                    Image.profileEditIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 34)
                                        .padding(.trailing, 5)
                                    
                                    Text(LocaleText.editProfileText)
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .scaledToFit()
                                        .font(.system(size: 12, weight: .semibold))
                                        .frame(height: 12)
                                        .foregroundColor(.black)
                                }
                                .contentShape(Rectangle())
                            })
                            
                            Capsule()
                                .frame(height: 1)
                                .foregroundColor(Color(.systemGray5))
                                .padding(.vertical, 10)
                        }
                        
                        Button(action: {
                            viewModel.routeToCreatorRoom()
                        }, label: {
                            HStack {
                                Image.profileGreenPreferencesIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 34)
                                    .padding(.trailing, 5)
                                
                                Text(LocalizableText.settingCreatorSpace)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text(LocalizableText.settingNewLabel)
                                    .font(.robotoMedium(size: 12))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.DinotisDefault.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 3)
                                            .foregroundStyle(Color.DinotisDefault.lightPrimary)
                                    )
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .font(.system(size: 12, weight: .semibold))
                                    .frame(height: 12)
                                    .foregroundColor(.black)
                            }
                            .contentShape(Rectangle())
                        })
                        .clipShape(Rectangle())
                        
                        Capsule()
                            .frame(height: 1)
                            .foregroundColor(Color(.systemGray5))
                            .padding(.vertical, 10)
                        
                        Button(action: {
                            viewModel.routeToCreatorChoose()
                        }, label: {
                            HStack {
                                Image.profileFavoriteIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 34)
                                    .padding(.trailing, 5)
                                
                                Text(LocalizableText.profileChoosenCreator)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .font(.system(size: 12, weight: .semibold))
                                    .frame(height: 12)
                                    .foregroundColor(.black)
                            }
                            .contentShape(Rectangle())
                        })
                        
                        Capsule()
                            .frame(height: 1)
                            .foregroundColor(Color(.systemGray5))
                            .padding(.vertical, 10)
                        
                        Button(action: {
                            viewModel.routeToChangePass()
                        }, label: {
                            HStack {
                                Image.profileChangePassIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 34)
                                    .padding(.trailing, 5)
                                
                                Text(LocaleText.changePasswordTitle)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .font(.system(size: 12, weight: .semibold))
                                    .frame(height: 12)
                                    .foregroundColor(.black)
                            }
                            .contentShape(Rectangle())
                        })
                        
                        Capsule()
                            .frame(height: 1)
                            .foregroundColor(Color(.systemGray5))
                            .padding(.vertical, 10)
                        
                        Button(action: {
                            viewModel.openWhatsApp()
                        }, label: {
                            HStack {
                                Image.profileHelpIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 34)
                                    .padding(.trailing, 5)
                                
                                Text(LocaleText.helpText)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .font(.system(size: 12, weight: .semibold))
                                    .frame(height: 12)
                                    .foregroundColor(.black)
                            }
                            .contentShape(Rectangle())
                        })
                        
                        Capsule()
                            .frame(height: 1)
                            .foregroundColor(Color(.systemGray5))
                            .padding(.vertical, 10)
                        
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
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.primaryRed)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .font(.system(size: 12, weight: .semibold))
                                    .frame(height: 12)
                                    .foregroundColor(.black)
                            }
                            .contentShape(Rectangle())
                        })
                        
                        Capsule()
                            .frame(height: 1)
                            .foregroundColor(Color(.systemGray5))
                            .padding(.vertical, 10)
                        
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
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .font(.system(size: 12, weight: .semibold))
                                    .frame(height: 12)
                                    .foregroundColor(.black)
                            }
                            .contentShape(Rectangle())
                        })
                        
                    }
                    .buttonStyle(.plain)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .foregroundStyle(Color.white)
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 15, trailing: 20))
                    .padding(.bottom, 45)
                }
                .listStyle(.plain)
                .refreshable {
					await viewModel.getUsers()
				}
			}
            
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
		}
        .dinotisAlert(
            isPresent: $viewModel.isRefreshFailed,
            title: LocalizableText.attentionText,
            isError: true,
            message: LocalizableText.alertSessionExpired,
            primaryButton: .init(
                text: LocalizableText.okText,
                action: {
                    viewModel.routeBackLogout()
                }
            )
        )
        .onAppear(perform: {
            Task {
                viewModel.getProductOnAppear()
                guard viewModel.data == nil else { return }
                await viewModel.getUsers()
            }
        })
		.onDisappear {
			viewModel.onDisappear()
		}
		.onChange(of: viewModel.showAddCoin) { value in
			if !value {
				viewModel.productSelected = nil
			}
		}
		.sheet(
			isPresented: $viewModel.logoutPresented,
			content: {
				if #available(iOS 16.0, *) {
					VStack(spacing: 16) {

						Spacer()
						
						Image.profileLogoutImage
							.resizable()
							.scaledToFit()
							.frame(height: 158)

						Text(LocalizableText.logoutTitleQuestion)
							.font(.robotoBold(size: 14))
							.foregroundColor(.black)

						Text(LocalizableText.logoutDescription)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
							.multilineTextAlignment(.center)

						Spacer()

						HStack(spacing: 15) {
							DinotisSecondaryButton(
								text: LocalizableText.cancelLabel,
								type: .adaptiveScreen,
								textColor: .DinotisDefault.black1,
								bgColor: .DinotisDefault.lightPrimary,
								strokeColor: .DinotisDefault.primary) {
									viewModel.presentLogout()
								}

							DinotisPrimaryButton(
								text: LocalizableText.logoutLabel,
								type: .adaptiveScreen,
								textColor: .white,
								bgColor: .DinotisDefault.primary) {
									viewModel.presentLogout()
									viewModel.routeBackLogout()
								}
						}
					}
						.padding()
						.padding(.vertical)
						.presentationDetents([.height(360)])
                        .dynamicTypeSize(.large)
				} else {
					VStack(spacing: 16) {

						Spacer()

						Image.profileLogoutImage
							.resizable()
							.scaledToFit()
							.frame(height: 158)

						Text(LocalizableText.logoutTitleQuestion)
							.font(.robotoBold(size: 14))
							.foregroundColor(.black)

						Text(LocalizableText.logoutDescription)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
							.multilineTextAlignment(.center)

						Spacer()

						HStack(spacing: 15) {
							DinotisSecondaryButton(
								text: LocalizableText.cancelLabel,
								type: .adaptiveScreen,
								textColor: .DinotisDefault.black1,
								bgColor: .DinotisDefault.lightPrimary,
								strokeColor: .DinotisDefault.primary) {
									viewModel.presentLogout()
								}

							DinotisPrimaryButton(
								text: LocalizableText.logoutLabel,
								type: .adaptiveScreen,
								textColor: .white,
								bgColor: .DinotisDefault.primary) {
									viewModel.presentLogout()
									viewModel.routeBackLogout()
								}
						}
					}
						.padding()
						.padding(.vertical)
                        .dynamicTypeSize(.large)
				}

			}
		)
		.sheet(
			isPresented: $viewModel.isPresentDeleteModal,
			content: {
				if #available(iOS 16.0, *) {
					VStack(spacing: 10) {
						Spacer()

						Image.Dinotis.removeUserImage
							.resizable()
							.scaledToFit()
							.frame(height: 150)

						Text(LocaleText.deleteAccountText)
							.font(.robotoBold(size: 14))
							.foregroundColor(.black)

						Text(LocaleText.deleteAccountModalSubtitle)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
							.multilineTextAlignment(.center)

						Spacer()

						HStack(spacing: 15) {
							Button(action: {
								viewModel.toggleDeleteModal()
							}, label: {
								HStack {
									Spacer()
									Text(LocaleText.cancelText)
										.font(.robotoMedium(size: 12))
										.foregroundColor(.white)
									Spacer()
								}
								.padding()
								.background(Color.DinotisDefault.primary)
								.cornerRadius(8)
							})

							Button(action: {
                                Task {
                                    viewModel.toggleDeleteModal()
                                    await viewModel.deleteAccount()
                                }
							}, label: {
								HStack {
									Spacer()
									Text(LocaleText.generalDeleteText)
										.font(.robotoMedium(size: 12))
										.foregroundColor(.white)
									Spacer()
								}
								.padding()
								.background(Color.primaryRed)
								.cornerRadius(8)
							})
						}
					}
						.padding()
						.padding(.vertical)
						.presentationDetents([.height(380)])
                        .dynamicTypeSize(.large)
				} else {
					VStack(spacing: 10) {
						Spacer()

						Image.Dinotis.removeUserImage
							.resizable()
							.scaledToFit()
							.frame(height: 150)

						Text(LocaleText.deleteAccountText)
							.font(.robotoBold(size: 14))
							.foregroundColor(.black)

						Text(LocaleText.deleteAccountModalSubtitle)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
							.multilineTextAlignment(.center)

						Spacer()

						HStack(spacing: 15) {
							Button(action: {
								viewModel.toggleDeleteModal()
							}, label: {
								HStack {
									Spacer()
									Text(LocaleText.cancelText)
										.font(.robotoMedium(size: 12))
										.foregroundColor(.white)
									Spacer()
								}
								.padding()
								.background(Color.DinotisDefault.primary)
								.cornerRadius(8)
							})

							Button(action: {
                                Task {
                                    viewModel.toggleDeleteModal()
                                    await viewModel.deleteAccount()
                                }
							}, label: {
								HStack {
									Spacer()
									Text(LocaleText.generalDeleteText)
										.font(.robotoMedium(size: 12))
										.foregroundColor(.white)
									Spacer()
								}
								.padding()
								.background(Color.primaryRed)
								.cornerRadius(8)
							})
						}
					}
						.padding()
						.padding(.vertical)
                        .dynamicTypeSize(.large)
				}

			}
		)
		.sheet(
			isPresented: $viewModel.successDelete,
			content: {
				if #available(iOS 16.0, *) {
					VStack(spacing: 10) {

						Spacer()

						Image(systemName: "checkmark.seal.fill")
							.resizable()
							.scaledToFit()
							.foregroundColor(.DinotisDefault.primary)
							.frame(height: 120)

						Text(LocaleText.successTitle)
							.font(.robotoBold(size: 14))
							.foregroundColor(.black)

						Text(LocaleText.deleteAccountSuccessText)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
							.multilineTextAlignment(.center)

						Spacer()

						HStack(spacing: 15) {
							Button(action: {
								viewModel.successDelete.toggle()
								viewModel.routeBackLogout()
							}, label: {
								HStack {
									Spacer()
									Text(LocaleText.okText)
										.font(.robotoMedium(size: 12))
										.foregroundColor(.white)
									Spacer()
								}
								.padding()
								.background(Color.DinotisDefault.primary)
								.cornerRadius(8)
							})
						}
					}
						.padding()
						.padding(.vertical)
						.presentationDetents([.height(380)])
                        .dynamicTypeSize(.large)
				} else {
					VStack(spacing: 10) {

						Spacer()
						
						Image(systemName: "checkmark.seal.fill")
							.resizable()
							.scaledToFit()
							.foregroundColor(.DinotisDefault.primary)
							.frame(height: 120)

						Text(LocaleText.successTitle)
							.font(.robotoBold(size: 14))
							.foregroundColor(.black)

						Text(LocaleText.deleteAccountSuccessText)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
							.multilineTextAlignment(.center)

						Spacer()

						HStack(spacing: 15) {
							Button(action: {
								viewModel.successDelete.toggle()
								viewModel.routeBackLogout()
							}, label: {
								HStack {
									Spacer()
									Text(LocaleText.okText)
										.font(.robotoMedium(size: 12))
										.foregroundColor(.white)
									Spacer()
								}
								.padding()
								.background(Color.DinotisDefault.primary)
								.cornerRadius(8)
							})
						}
					}
						.padding()
						.padding(.vertical)
                        .dynamicTypeSize(.large)
				}

			}
		)
		.sheet(
			isPresented: $viewModel.showAddCoin,
			content: {
				if #available(iOS 16.0, *) {
					VStack(spacing: 20) {

						HStack {
							Text(LocalizableText.addCoinLabel)
								.font(.robotoBold(size: 14))
								.foregroundColor(.black)

							Spacer()

							Button {
								viewModel.showAddCoin.toggle()
							} label: {
								Image(systemName: "xmark.circle.fill")
									.resizable()
									.scaledToFit()
									.frame(width: 20)
									.foregroundColor(Color(UIColor.systemGray4))
							}
						}

						VStack {
							Text(LocalizableText.yourCoinLabel)
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)

							HStack(alignment: .top) {
								Image.coinBalanceIcon
									.resizable()
									.scaledToFit()
									.frame(height: 20)

                                Text("\((viewModel.userCoin).orEmpty())")
									.font(.robotoBold(size: 14))
									.foregroundColor(.DinotisDefault.primary)
							}
							.multilineTextAlignment(.center)

							Text(LocalizableText.descriptionAddCoin)
								.font(.robotoRegular(size: 10))
								.multilineTextAlignment(.center)
								.foregroundColor(.black)
						}

						Group {
							if viewModel.isLoadingTrx {
								ProgressView()
									.progressViewStyle(.circular)
							} else {
								QGrid(viewModel.myProducts, columns: 4, vSpacing: 10, hSpacing: 10, vPadding: 5, hPadding: 5, isScrollable: false, showScrollIndicators: false) { item in

									Button {
										viewModel.productSelected = item
									} label: {
										HStack {
											Spacer()

											Text(item.priceToString())
												.font(.robotoMedium(size: 12))
												.foregroundColor(.DinotisDefault.primary)

											Spacer()
										}
										.padding(.vertical, 10)
										.background(
											RoundedRectangle(cornerRadius: 12)
												.foregroundColor((viewModel.productSelected ?? SKProduct()).id == item.id ? .DinotisDefault.lightPrimary : .clear)
										)
										.overlay(
											RoundedRectangle(cornerRadius: 12)
												.stroke(Color.DinotisDefault.primary, lineWidth: 1)
										)
									}
								}
							}
						}
						.frame(height: 90)

						Spacer()

						VStack {
							DinotisPrimaryButton(
								text: LocalizableText.addCoinLabel,
								type: .adaptiveScreen,
								textColor: viewModel.isLoadingTrx || viewModel.productSelected == nil ? .DinotisDefault.lightPrimaryActive : .white,
								bgColor: viewModel.isLoadingTrx || viewModel.productSelected == nil ? .DinotisDefault.lightPrimary : .DinotisDefault.primary
							) {
								if let product = viewModel.productSelected {
									viewModel.purchaseProduct(product: product)
								}
							}
							.disabled(viewModel.isLoadingTrx || viewModel.productSelected == nil)

							DinotisSecondaryButton(
								text: LocalizableText.helpLabel,
								type: .adaptiveScreen,
								textColor: viewModel.isLoadingTrx ? .white : .DinotisDefault.primary,
								bgColor: viewModel.isLoadingTrx ? Color(UIColor.systemGray3) : .DinotisDefault.lightPrimary,
								strokeColor: .DinotisDefault.primary) {
									viewModel.openWhatsApp()
								}
								.disabled(viewModel.isLoadingTrx)
						}
					}
					.padding()
					.presentationDetents([.height(430)])
                    .dynamicTypeSize(.large)
				} else {
					VStack(spacing: 20) {

						HStack {
							Text(LocalizableText.addCoinLabel)
								.font(.robotoBold(size: 14))
								.foregroundColor(.black)

							Spacer()

							Button {
								viewModel.showAddCoin.toggle()
							} label: {
								Image(systemName: "xmark.circle.fill")
									.resizable()
									.scaledToFit()
									.frame(width: 20)
									.foregroundColor(Color(UIColor.systemGray4))
							}
						}

						VStack {
							Text(LocalizableText.yourCoinLabel)
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)

							HStack(alignment: .top) {
								Image.coinBalanceIcon
									.resizable()
									.scaledToFit()
									.frame(height: 20)

                                Text("\(viewModel.userCoin.orEmpty())")
									.font(.robotoBold(size: 14))
									.foregroundColor(.DinotisDefault.primary)
							}
							.multilineTextAlignment(.center)

							Text(LocalizableText.descriptionAddCoin)
								.font(.robotoRegular(size: 10))
								.multilineTextAlignment(.center)
								.foregroundColor(.black)
						}

						Group {
							if viewModel.isLoadingTrx {
								ProgressView()
									.progressViewStyle(.circular)
							} else {
								QGrid(viewModel.myProducts, columns: 4, vSpacing: 10, hSpacing: 10, vPadding: 5, hPadding: 5, isScrollable: false, showScrollIndicators: false) { item in

									Button {
										viewModel.productSelected = item
									} label: {
										HStack {
											Spacer()

											Text(item.priceToString())
												.font(.robotoMedium(size: 12))
												.foregroundColor(.DinotisDefault.primary)

											Spacer()
										}
										.padding(.vertical, 10)
										.background(
											RoundedRectangle(cornerRadius: 12)
												.foregroundColor((viewModel.productSelected ?? SKProduct()).id == item.id ? .DinotisDefault.lightPrimary : .clear)
										)
										.overlay(
											RoundedRectangle(cornerRadius: 12)
												.stroke(Color.DinotisDefault.primary, lineWidth: 1)
										)
									}
								}
							}
						}
						.frame(height: 90)

						Spacer()

						VStack {
							DinotisPrimaryButton(
								text: LocalizableText.addCoinLabel,
								type: .adaptiveScreen,
								textColor: viewModel.isLoadingTrx || viewModel.productSelected == nil ? .DinotisDefault.lightPrimaryActive : .white,
								bgColor: viewModel.isLoadingTrx || viewModel.productSelected == nil ? .DinotisDefault.lightPrimary : .DinotisDefault.primary
							) {
								if let product = viewModel.productSelected {
									viewModel.purchaseProduct(product: product)
								}
							}
							.disabled(viewModel.isLoadingTrx || viewModel.productSelected == nil)

							DinotisSecondaryButton(
								text: LocalizableText.helpLabel,
								type: .adaptiveScreen,
								textColor: viewModel.isLoadingTrx ? .white : .DinotisDefault.primary,
								bgColor: viewModel.isLoadingTrx ? Color(UIColor.systemGray3) : .DinotisDefault.lightPrimary,
								strokeColor: .DinotisDefault.primary) {
									viewModel.openWhatsApp()
								}
								.disabled(viewModel.isLoadingTrx)
						}
					}
					.padding()
                    .dynamicTypeSize(.large)
				}
			})
		.sheet(isPresented: $viewModel.isTransactionSucceed, content: {
			if #available(iOS 16.0, *) {
				GeometryReader { geo in
					HStack {

						Spacer()

						VStack {
							Spacer()
							VStack(spacing: 15) {
								Image.Dinotis.paymentSuccessImage
									.resizable()
									.scaledToFit()
									.frame(height: geo.size.width/2)

								Text(LocaleText.homeScreenCoinSuccess)
									.font(.robotoBold(size: 16))
									.foregroundColor(.black)
							}

							Spacer()
						}

						Spacer()

					}
				}
				.padding()
				.padding(.vertical)
				.presentationDetents([.height(350)])
                .dynamicTypeSize(.large)
			} else {
				GeometryReader { geo in
					HStack {

						Spacer()

						VStack(spacing: 15) {
							Image.Dinotis.paymentSuccessImage
								.resizable()
								.scaledToFit()
								.frame(height: geo.size.width/2)

							Text(LocaleText.homeScreenCoinSuccess)
								.font(.robotoBold(size: 16))
								.foregroundColor(.black)
						}

						Spacer()

					}
				}
				.padding()
				.padding(.vertical)
                .dynamicTypeSize(.large)
			}

		})
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct UserProfilePage_Previews: PreviewProvider {
	static var previews: some View {
        UserProfileView(tabValue: .constant(.agenda))
            .environmentObject(ProfileViewModel(backToHome: {}))
	}
}
