//
//  TalentProfilePage.swift
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

struct NavigationUtil {
    static func popToRootView() {
        findNavigationController(viewController: UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController)?
            .popToRootViewController(animated: true)
    }
    
    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }
        
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }
        
        return nil
    }
}

struct TalentProfileView: View {
    
    @EnvironmentObject var viewModel: ProfileViewModel
    
    @ObservedObject var stateObservable = StateObservable.shared
    
    @Environment(\.dismiss) var dismiss
    
    @State var colorTab = Color.clear
    
    @State var contentOffset = CGFloat.zero
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
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
                        }))
                }
            
            VStack(spacing: 0) {
                colorTab
                    .edgesIgnoringSafeArea(.all)
                    .frame(height: 1)
                
                ZStack {
                    HStack {
                        Button(action: {
                            dismiss()
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
                            .font(.robotoBold(size: 14))
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
                    VStack {
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
                                    .font(.robotoMedium(size: 14))
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                    .foregroundColor(.black)
                                
                                Image.Dinotis.accountVerifiedIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 16)
                                    .isHidden(
                                        !viewModel.isUserVerified(),
                                        remove: !viewModel.isUserVerified()
                                    )
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 5) {
                                ForEach(viewModel.userProfession(), id: \.professionId) { item in
                                    HStack {
                                        Spacer()
                                        
                                        Text((item.profession?.name).orEmpty())
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.bottom, 5)
                            
                            HStack(spacing: 10) {
                                HStack(spacing: 15) {
                                    Image.Dinotis.linkedIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 26)
                                    
                                    Text(viewModel.userLink())
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding(15)
                                .background(Color.backgroundProfile)
                                .cornerRadius(12)
                                
                                Spacer()
                                
                                Button(action: {
                                    viewModel.copyURL()
                                    
                                }, label: {
                                    VStack {
                                        Image.Dinotis.copyIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 20)
                                        
                                        Text(LocaleText.copyText)
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(.black)
                                    }
                                })
                            }
                            
                            HStack {
                                Spacer()
                                Text(viewModel.userBio())
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                            .padding(20)
                            .background(Color.backgroundProfile)
                            .cornerRadius(12)
                            
                            HStack {
                                Text(LocaleText.accountSettingText)
                                    .font(.robotoBold(size: 14))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            .padding(.top, 10)
                            
                            VStack {
                                VStack {
                                    Button(action: {
                                        viewModel.routeToEditProfile()
                                        viewModel.profesionSelect = viewModel.userProfession()
                                    }, label: {
                                        HStack {
                                            Image.Dinotis.editProfileButtonIcon
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
                                    })
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                                    .clipShape(Rectangle())
                                    
                                    NavigationLink(
                                        unwrapping: $viewModel.route,
                                        case: /HomeRouting.editTalentProfile,
                                        destination: { viewModel in
                                            TalentEditProfile(profesionSelect: $viewModel.profesionSelect, viewModel: viewModel.wrappedValue)
                                        },
                                        onNavigate: {_ in },
                                        label: {
                                            EmptyView()
                                        }
                                    )
                                    
                                    NavigationLink(
                                        unwrapping: $viewModel.route,
                                        case: /HomeRouting.talentWallet,
                                        destination: { viewModel in
                                            TalentWalletView(viewModel: viewModel.wrappedValue)
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
                                        viewModel.routeToPreviewProfile()
                                    }, label: {
                                        HStack {
                                            Image.Dinotis.previewProfileIcon
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 34)
                                                .padding(.trailing, 5)
                                            
                                            Text(LocaleText.previewProfileTitle)
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
                                    })
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                                    .clipShape(Rectangle())
                                    
                                    NavigationLink(
                                        unwrapping: $viewModel.route,
                                        case: /HomeRouting.previewTalent,
                                        destination: { viewModel in
                                            PreviewTalentView(viewModel: viewModel.wrappedValue)
                                        },
                                        onNavigate: {_ in },
                                        label: {
                                            EmptyView()
                                        }
                                    )
                                }
                                
                                Capsule()
                                    .frame(height: 1)
                                    .foregroundColor(Color(.systemGray6))
                                
                                VStack {
                                    
                                    Button(action: {
                                        viewModel.routeToAvailability()
                                    }, label: {
                                        HStack {
                                            Image.profileGreenPreferencesIcon
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 34)
                                                .padding(.trailing, 5)
                                            
                                            Text(LocalizableText.profileAvailabilityLabel)
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
                                    })
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                                    .clipShape(Rectangle())
                                    
                                    NavigationLink(
                                        unwrapping: $viewModel.route,
                                        case: /HomeRouting.creatorAvailability,
                                        destination: { viewModel in
                                            CreatorAvailabilityView(viewModel: viewModel.wrappedValue)
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
                                        viewModel.routeToChangePass()
                                    }, label: {
                                        HStack {
                                            Image.Dinotis.changePassButtonIcon
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
                                        viewModel.routeToWallet()
                                    }, label: {
                                        HStack {
                                            Image.Dinotis.reportIcon
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 34)
                                                .padding(.trailing, 5)
                                            
                                            Text(LocaleText.financialStatementText)
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
                                    })
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                                    .clipShape(Rectangle())
                                    
                                    Capsule()
                                        .frame(height: 1)
                                        .foregroundColor(Color(.systemGray6))
                                }
                                
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
                        .padding(.bottom)
                        .padding(.top, 10)
                        
                    }
                }
            }
            
            Text(LocaleText.successCopyText)
                .font(.robotoMedium(size: 14))
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
                .opacity(viewModel.showCopied ? 1 : 0)
            
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
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
        .onAppear {
            Task {
                await viewModel.getUsers()
            }
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
    }
}

struct TalentProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        TalentProfileView()
            .environmentObject(ProfileViewModel(backToHome: {}))
    }
}
