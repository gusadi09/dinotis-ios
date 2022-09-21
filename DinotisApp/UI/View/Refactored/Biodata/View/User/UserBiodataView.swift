//
//  UserBiodataView.swift
//  DinotisApp
//
//  Created by Gus Adi on 08/08/21.
//

import SwiftUI
import SwiftUINavigation
import OneSignal

struct UserBiodataView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    @ObservedObject var viewModel: BiodataViewModel
    
    @State var isShowConnection = false
    
    @ObservedObject var stateObservable = StateObservable.shared
    
    var body: some View {
        ZStack {
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /PrimaryRouting.homeUser,
                destination: { viewModel in
                    UserHomeView(homeVM: viewModel.wrappedValue)
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
                                    dismissButton: .default(Text(LocaleText.returnText), action: {
                                        viewModel.backToRoot()
                                        stateObservable.userType = 0
                                        stateObservable.isVerified = ""
                                        stateObservable.refreshToken = ""
                                        stateObservable.accessToken = ""
																			stateObservable.isAnnounceShow = false
																			OneSignal.setExternalUserId("")
                                    })
                                )
                            }
                        
                        Image.Dinotis.biodataImage
                            .resizable()
                            .frame(
                                minWidth: 40,
                                idealWidth: 215,
                                maxWidth: 215,
                                minHeight: 40,
                                idealHeight: 150,
                                maxHeight: 150,
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
                            
                            VStack {
                                HStack {
                                    Text(LocaleText.nameText)
                                        .font(.montserratRegular(size: 12))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                
                                TextField(LocaleText.nameHint, text: $viewModel.name, onCommit: {
                                })
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
                                    Text(LocaleText.bioTitle)
                                        .font(Font.custom(FontManager.Montserrat.regular, size: 12))
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
                            
                            if !viewModel.isPasswordSame() {
                                HStack {
                                    Image.Dinotis.exclamationCircleIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 10)
                                        .foregroundColor(.red)
                                    Text(LocaleText.passwordNotMatch)
                                        .font(.montserratRegular(size: 10))
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(.white))
                        .cornerRadius(16)
                        .shadow(color: Color.dinotisShadow.opacity(0.1), radius: 40, x: 0.0, y: 0.0)
                        .padding(.horizontal)
                        .padding(.bottom, 15)
                        
                        Button {
                            viewModel.backToRoot()
                            stateObservable.userType = 0
                            stateObservable.isVerified = ""
                            stateObservable.refreshToken = ""
                            stateObservable.accessToken = ""
													stateObservable.isAnnounceShow = false
													OneSignal.setExternalUserId("")
                        } label: {
                            Text(LocaleText.biodataScreenLoginAnother)
                                .font(.montserratSemiBold(size: 14))
                                .foregroundColor(.black)
                                .underline()
                        }
                        .padding(.bottom, 100)
                        
                    }
                })
                .onAppear {
                    viewModel.getUsers()
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    Button(action: {
                        viewModel.updateUsers()
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
                        .alert(isPresented: $viewModel.isError) {
                            Alert(
                                title: Text(LocaleText.attention),
                                message: Text((viewModel.error?.errorDescription).orEmpty()),
                                dismissButton: .default(Text(LocaleText.okText))
                            )
                        }
                    
                }
                .edgesIgnoringSafeArea(.all)
            }
            
            LoadingView(isAnimating: $viewModel.isLoading)
            .isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)
        }
        
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        
    }
}

struct UserBiodataView_Previews: PreviewProvider {
    static var previews: some View {
        UserBiodataView(viewModel: BiodataViewModel(backToRoot: {}))
    }
}
