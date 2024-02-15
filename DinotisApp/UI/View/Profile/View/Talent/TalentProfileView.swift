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
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            StateObservable.shared.isShowGateway = false
            findNavigationController(viewController: windowScene.windows.filter { $0.isKeyWindow }.first?.rootViewController)?
                .popToRootViewController(animated: true)
        }
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
    
    @State var contentOffset = CGFloat.zero
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.DinotisDefault.baseBackground
                .edgesIgnoringSafeArea(.all)
                .alert(isPresented: $viewModel.isRefreshFailed) {
                    Alert(
                        title: Text(LocaleText.attention),
                        message: Text(LocaleText.sessionExpireText),
                        dismissButton: .default(Text(LocaleText.returnText), action: {
                            viewModel.routeBackLogout()
                        }))
                }
            
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
                case: /HomeRouting.creatorAnalytics,
                destination: { viewModel in
                    CreatorAnalyticsView()
                },
                onNavigate: {_ in },
                label: {
                    EmptyView()
                }
            )
            
            VStack(spacing: 0) {
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
                        Text(LocalizableText.profileCreatorMyAccountTitle)
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                }
                .padding(.top, 3)
                .padding(.bottom, 6)
                .background(Color.clear)
                
                List {
                    VStack {
                        VStack(alignment: .center, spacing: 10) {
                            VStack(alignment: .center, spacing:  8) {
                                HStack(alignment: .top, spacing: 18) {
                                    
                                    ProfileImageContainer(
                                        profilePhoto: $viewModel.userPhotos,
                                        name: $viewModel.names,
                                        width: 80,
                                        height: 80,
                                        shape: RoundedRectangle(cornerRadius: 12)
                                    )
                                    
                                    VStack(
                                        alignment: .leading,
                                        spacing: 6
                                    ) {
                                        Text(LocalizableText.tabCreator)
                                            .font(.robotoMedium(size: 12))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color.DinotisDefault.primary)
                                            .padding(.horizontal, 11)
                                            .padding(.vertical, 5)
                                            .background(
                                                Capsule()
                                                    .foregroundStyle(Color.DinotisDefault.lightPrimary)
                                            )
                                            .padding(.bottom, 2)
                                        
                                        HStack {
                                            
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
                                        }
                                        
                                        HStack {
                                            Text("\(Image.talentProfileManagementIcon) \(viewModel.userProfessionString())")
                                                .font(.robotoRegular(size: 12))
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(2)
                                        }
                                        
                                        HStack {
                                            
                                            (
                                                Text(LocalizableText.managementName)
                                                    .font(.robotoRegular(size: 12))
                                                    .foregroundColor(.DinotisDefault.black3)
                                                +
                                                Text(" \(viewModel.managementsString())")
                                                    .font(.robotoBold(size: 12))
                                                    .foregroundColor(.DinotisDefault.primary)
                                                +
                                                Text("\(LocalizableText.managementPlusOther((viewModel.data?.managements?.count).orZero()))")
                                                    .font(.robotoBold(size: 12))
                                                    .foregroundColor(.DinotisDefault.black3)
                                            )
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                        }
                                        .isHidden(viewModel.managements().isEmpty, remove: true)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                                
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
                                        
                                        Button(action: {
                                            viewModel.copyURL()
                                            
                                        }, label: {
                                            Image.copylinkIcon
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 24)
                                        })
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                                    .background(Color.DinotisDefault.lightPrimary)
                                    .cornerRadius(12)
                                    
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
                                .isHidden(true, remove: true)
                            }
                            
                            HStack {
                                Text(LocaleText.accountSettingText)
                                    .font(.robotoBold(size: 18))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                            
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
                                    .contentShape(Rectangle())
                                })
                                .clipShape(Rectangle())
                                .buttonStyle(.plain)
                                
                                Capsule()
                                    .frame(height: 1)
                                    .foregroundColor(Color(.systemGray5))
                                    .padding(.vertical, 10)
                                
                                Button(action: {
                                    viewModel.routeToCreatorAnalytics()
                                }, label: {
                                    HStack {
                                        Image.profileCreatorAnalyticsIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 34)
                                            .padding(.trailing, 5)
                                        
                                        Text(LocalizableText.profileCreatorAnalytics)
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
                                .clipShape(Rectangle())
                                .buttonStyle(.plain)
                                
                                Capsule()
                                    .frame(height: 1)
                                    .foregroundColor(Color(.systemGray5))
                                    .padding(.vertical, 10)
                                
                                Button(action: {
                                    viewModel.routeToAvailability()
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
                                .buttonStyle(.plain)
                                
                                Capsule()
                                    .frame(height: 1)
                                    .foregroundColor(Color(.systemGray5))
                                    .padding(.vertical, 10)
                                
                                Button(action: {
                                    self.viewModel.showDinotisVerifiedSheet.toggle()
                                }, label: {
                                    HStack {
                                        Image.dinotisVerifiedBtnIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 34)
                                            .padding(.trailing, 5)
                                        
                                        Text(LocalizableText.settingDinotisVerified)
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
                                .buttonStyle(.plain)
                                
                                Capsule()
                                    .frame(height: 1)
                                    .foregroundColor(Color(.systemGray5))
                                    .padding(.vertical, 10)
                                
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
                                    .contentShape(Rectangle())
                                })
                                .clipShape(Rectangle())
                                .buttonStyle(.plain)
                                
                                Capsule()
                                    .frame(height: 1)
                                    .foregroundColor(Color(.systemGray5))
                                    .padding(.vertical, 10)
                                
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
                                    .contentShape(Rectangle())
                                })
                                .clipShape(Rectangle())
                                .buttonStyle(.plain)
                                
                                Capsule()
                                    .frame(height: 1)
                                    .foregroundColor(Color(.systemGray5))
                                    .padding(.vertical, 10)
                                
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
                                    .contentShape(Rectangle())
                                })
                                .clipShape(Rectangle())
                                .buttonStyle(.plain)
                                
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
                                .clipShape(Rectangle())
                                .buttonStyle(.plain)
                                
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
                                .clipShape(Rectangle())
                                .buttonStyle(.plain)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .foregroundStyle(Color.white)
                            )
                            
                        }
                        .cornerRadius(12)
                        .padding(.vertical)
                        .padding(.bottom)
                        .padding(.top, 3)
                        
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.getUsers()
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
        .sheet(
            isPresented: $viewModel.showDinotisVerifiedSheet,
            onDismiss: {
                viewModel.verifRoute = nil
                viewModel.attachedLinks = [ProfileViewModel.LinkModel(link: "")]
            },
            content: {
                if #available(iOS 16.0, *) {
                    RequestVerifiedLandingView()
                        .environmentObject(viewModel)
                        .presentationDetents([.height(700)])
                } else {
                    RequestVerifiedLandingView()
                        .environmentObject(viewModel)
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

extension TalentProfileView {
    
    struct LandingView: View {
        @EnvironmentObject var viewModel: ProfileViewModel
        
        var body: some View {
            VStack {
                ScrollView {
                    VStack {
                        Text(LocalizableText.verifiedLandingTitle)
                            .font(.robotoBold(size: 18))
                            .foregroundStyle(Color.DinotisDefault.black1)
                            .multilineTextAlignment(.center)
                        
                        ZStack(alignment: .bottom) {
                            ProfileImageContainer(
                                profilePhoto: $viewModel.userPhotos,
                                name: $viewModel.names,
                                width: 92,
                                height: 92,
                                shape: RoundedRectangle(cornerRadius: 22)
                            )
                            
                            Image.generalDinotisCircularIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .offset(CGSize(width: 0, height: 15))
                        }
                        .padding(.top, 20)
                        
                        HStack {
                            
                            Text(viewModel.nameOfUser())
                                .font(.robotoBold(size: 18))
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)
                                .foregroundColor(.black)
                            
                            Image.newUserVerifiedIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 16)
                                .isHidden(
                                    !viewModel.isUserVerified(),
                                    remove: !viewModel.isUserVerified()
                                )
                        }
                        .padding(.top, 16)
                        
                        HStack {
                            Text("\(Image.talentProfileManagementIcon) \(viewModel.userProfessionString())")
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .padding(.horizontal)
                        
                        Text(LocalizableText.tabCreator)
                            .font(.robotoMedium(size: 12))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.DinotisDefault.primary)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .foregroundStyle(Color.DinotisDefault.lightPrimary)
                            )
                        
                        VStack(spacing: 10) {
                            ForEach(viewModel.pointerItems, id: \.title) { item in
                                HStack(alignment: .top, spacing: 8) {
                                    Image.profileVerifiedPointerIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 20)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(item.title)
                                                .font(.robotoMedium(size: 14))
                                                .fontWeight(.semibold)
                                                .foregroundStyle(Color.DinotisDefault.black2)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                        }
                                        
                                        Text(item.definition)
                                            .font(.robotoRegular(size: 12))
                                            .foregroundStyle(Color.DinotisDefault.black1)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                            }
                        }
                        .padding(.top, 26)
                        .padding(.bottom, 20)
                        
                        
                    }
                }
                
                NavigationLink {
                    switch viewModel.verifiedStatus {
                    case .notVerified:
                        RequestVerifiedForm()
                            .environmentObject(viewModel)
                    case .waiting:
                        WaitingView()
                    case .verified:
                        VerifiedView()
                    case .failed:
                        FailedView()
                            .environmentObject(viewModel)
                    case nil:
                        RequestVerifiedForm()
                            .environmentObject(viewModel)
                    }
                } label: {
                    HStack {
                        Spacer()
                        
                        Text(LocalizableText.nextLabel)
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.DinotisDefault.primary)
                    )
                }
            }
        }
    }
    
    struct WaitingView: View {
        var body: some View {
            VStack {
                Text(LocalizableText.verifiedWaitingSuccessTitle)
                    .font(.robotoBold(size: 18))
                    .foregroundStyle(Color.DinotisDefault.black1)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Image.profileWaitingVerificationImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 291)
                
                Spacer()
                
                Text(LocalizableText.verifiedWaitingSuccessSubtitle)
                    .font(.robotoRegular(size: 12))
                    .foregroundStyle(Color.DinotisDefault.black3)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .padding(.top, 26)
            .padding(.bottom, 35)
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
        }
    }
    
    struct VerifiedView: View {
        var body: some View {
            VStack(alignment: .center) {
                Text(LocalizableText.verifiedSuccessTitle)
                    .font(.robotoBold(size: 18))
                    .foregroundStyle(Color.DinotisDefault.black1)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Image.profileSuccessVerifiedImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 290)
                
                Spacer()
                
                Text(LocalizableText.verifiedSuccessSubtitle)
                    .font(.robotoRegular(size: 12))
                    .foregroundStyle(Color.DinotisDefault.black3)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .padding(.top, 26)
            .padding(.bottom, 35)
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
        }
    }
    
    struct FailedView: View {
        
        @EnvironmentObject var viewModel: ProfileViewModel
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            VStack(alignment: .center) {
                Text(LocalizableText.verifiedFailedTitle)
                    .font(.robotoBold(size: 18))
                    .foregroundStyle(Color.DinotisDefault.black1)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Image.profileFailedVerifiedImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 290)
                
                Spacer()
                
                DinotisPrimaryButton(
                    text: LocalizableText.verifiedFailedVerifyAgain,
                    type: .adaptiveScreen,
                    height: 45,
                    textColor: .white,
                    bgColor: .DinotisDefault.primary,
                    isLoading: .constant(false)
                ) {
                    viewModel.verifiedStatus = .notVerified
                    dismiss()
                }
                
                Text(LocalizableText.verifiedFailedSubtitle)
                    .font(.robotoRegular(size: 12))
                    .foregroundStyle(Color.DinotisDefault.black3)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .padding(.top, 26)
            .padding(.bottom, 35)
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
        }
    }
    
    struct RequestVerifiedLandingView: View {
        
        @EnvironmentObject var viewModel: ProfileViewModel
        
        var body: some View {
            VStack {
                HStack {
                    Text(LocalizableText.dinotisVerifiedTitle.uppercased())
                        .font(.robotoBold(size: 14))
                        .foregroundStyle(Color.DinotisDefault.black2)
                    
                    Spacer()
                    
                    Button {
                        viewModel.showDinotisVerifiedSheet = false
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.DinotisDefault.black2)
                    }

                }
                .padding([.top, .horizontal], 16)
                
                NavigationView {
                    Group {
                        LandingView()
                            .environmentObject(viewModel)
                        
                    }
                    .padding()
                    .navigationBarTitle(Text(""))
                    .navigationBarHidden(true)
                }
                .navigationViewStyle(.stack)
            }
        }
    }
    
    struct RequestVerifiedForm: View {
        
        @EnvironmentObject var viewModel: ProfileViewModel
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            VStack(spacing: 0) {
                HeaderView(
                    type: .textHeader,
                    title: LocalizableText.verifiedFormTitle,
                    headerColor: .clear,
                    textColor: .DinotisDefault.black1
                ) {
                    Button {
                        dismiss()
                    } label: {
                        Image.generalBackIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                            )
                    }
                    .disabled(
                        viewModel.isLoadingVerified
                    )
                } trailingButton: {
                    
                }

                ScrollView {
                    VStack {
                        ZStack(alignment: .bottom) {
                            ProfileImageContainer(
                                profilePhoto: $viewModel.userPhotos,
                                name: $viewModel.names,
                                width: 92,
                                height: 92,
                                shape: RoundedRectangle(cornerRadius: 22)
                            )
                            
                            Image.generalDinotisCircularIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .offset(CGSize(width: 0, height: 15))
                        }
                        .padding(.top, 5)
                        
                        HStack {
                            
                            Text(viewModel.nameOfUser())
                                .font(.robotoBold(size: 18))
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)
                                .foregroundColor(.black)
                            
                            Image.newUserVerifiedIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 16)
                                .isHidden(
                                    !viewModel.isUserVerified(),
                                    remove: !viewModel.isUserVerified()
                                )
                        }
                        .padding(.top, 16)
                        
                        HStack {
                            Text("\(Image.talentProfileManagementIcon) \(viewModel.userProfessionString())")
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .padding(.horizontal)
                        
                        Text(LocalizableText.tabCreator)
                            .font(.robotoMedium(size: 12))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.DinotisDefault.primary)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .foregroundStyle(Color.DinotisDefault.lightPrimary)
                            )
                            .padding(.bottom, 20)
                        
                        Button {
                            viewModel.showDinotisVerifiedSheet = false
                            viewModel.routeToEditProfile()
                        } label: {
                            HStack(alignment: .center, spacing: 12) {
                                ProfileImageContainer(
                                    profilePhoto: $viewModel.userPhotos,
                                    name: $viewModel.names,
                                    width: 36,
                                    height: 36,
                                    shape: RoundedRectangle(cornerRadius: 12)
                                )
                                
                                VStack(alignment: .leading) {
                                    HStack(alignment: .center) {
                                        Text(LocalizableText.editProfileTitle)
                                            .font(.robotoMedium(size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color.DinotisDefault.black2)
                                            .multilineTextAlignment(.leading)
                                        
                                        ProgressView(value: (viewModel.data?.profilePercentage).orZero(), total: 100.0)
                                            .tint(Color.DinotisDefault.primary)
                                        
                                        Text("\(Int((viewModel.data?.profilePercentage).orZero()))%")
                                            .font(.robotoMedium(size: 12))
                                            .foregroundStyle(Color.DinotisDefault.primary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Text(LocalizableText.verifiedFormCompletedSubtitle)
                                        .font(.robotoRegular(size: 12))
                                        .foregroundStyle(Color.DinotisDefault.black3)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Image.generalChevronRight
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.DinotisDefault.black5, lineWidth: 1)
                            )
                        }
                        .disabled(
                            viewModel.isLoadingVerified
                        )
                        
                        Divider()
                            .padding(.vertical, 20)
                        
                        HStack {
                            (
                                Text(LocalizableText.verifiedFormAttachLinks)
                                    .font(.robotoMedium(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.DinotisDefault.black1)
                                +
                                Text("*")
                                    .font(.robotoMedium(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            )
                            .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        
                        Text(LocalizableText.verifiedFormLinkSubtitle)
                            .font(.robotoRegular(size: 12))
                            .foregroundStyle(Color.DinotisDefault.black3)
                            .multilineTextAlignment(.leading)
                        
                        ForEach(viewModel.attachedLinks.indices, id: \.self) { idx in
                            VStack {
                                DinotisTextField(
                                    LocalizableText.verifiedFormLinkPlaceholder,
                                    label: nil,
                                    text: $viewModel.attachedLinks[idx].link,
                                    errorText: .constant(nil)
                                )
                                .keyboardType(.URL)
                                .textInputAutocapitalization(.never)
                                .disabled(
                                    viewModel.isLoadingVerified
                                )
                                
                                if !viewModel.attachedLinks[idx].link.verifyUrl() {
                                    HStack {
                                        Image.Dinotis.exclamationCircleIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 10)
                                            .foregroundColor(.red)
                                        Text(LocalizableText.verifiedFormInvalidLink)
                                            .font(.robotoRegular(size: 10))
                                            .foregroundColor(.red)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        
                        DinotisPrimaryButton(
                            text: LocalizableText.verifiedFormAddMore,
                            type: .adaptiveScreen,
                            height: 30,
                            textColor: (viewModel.attachedLinks.last?.link.isEmpty ?? true) ? .DinotisDefault.black3 : .white,
                            bgColor: (viewModel.attachedLinks.last?.link.isEmpty ?? true) ? .DinotisDefault.black5 : .DinotisDefault.primary,
                            isLoading: .constant(false)
                        ) {
                            viewModel.attachedLinks.append(ProfileViewModel.LinkModel(link: ""))
                        }
                        .disabled(viewModel.attachedLinks.last?.link.isEmpty ?? true || viewModel.isLoadingVerified)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal)
                }
                
                HStack(spacing: 13) {
                    Button {
                        viewModel.isAgreed.toggle()
                    } label: {
                        (viewModel.isAgreed ? Image.profileChecmarkTrueIcon : Image.profileChecmarkFalseIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                    }
                    .disabled(
                        viewModel.isLoadingVerified
                    )

                    (
                        Text(LocalizableText.verifiedFormAgreementFirst)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.DinotisDefault.black3)
                        +
                        Text(LocalizableText.verifiedFormAgreementMid)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.DinotisDefault.darkPrimary)
                        +
                        Text(LocalizableText.verifiedFormAgreementLast)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.DinotisDefault.black3)
                    )
                    .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                DinotisPrimaryButton(
                    text: LocalizableText.nextLabel,
                    type: .adaptiveScreen,
                    height: 44,
                    textColor: .white,
                    bgColor: .DinotisDefault.primary,
                    isLoading: $viewModel.isLoadingVerified
                ) {
                    Task {
                        await viewModel.sendVerif()
                    }
                }
                .disabled(
                    !viewModel.isAgreed ||
                    (viewModel.attachedLinks.first?.link.isEmpty ?? true) ||
                    !(viewModel.attachedLinks.first?.link.verifyUrl() ?? false) ||
                    ((viewModel.data?.profilePercentage).orZero() < 100) ||
                    viewModel.isLoadingVerified
                )
                .tint(.white)
                .padding(.horizontal)
                
                NavigationLink(
                    unwrapping: $viewModel.verifRoute,
                    case: /HomeRouting.waitingVerif,
                    destination: { viewModel in
                        WaitingView()
                    },
                    onNavigate: {_ in },
                    label: {
                        EmptyView()
                    }
                )
            }
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
        }
    }
}

struct TalentProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        TalentProfileView()
            .environmentObject(ProfileViewModel(backToHome: {}))
    }
}
