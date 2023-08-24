//
//  ChangePasswordView.swift
//  DinotisApp
//
//  Created by Gus Adi on 04/08/21.
//

import DinotisData
import DinotisDesignSystem
import OneSignal
import SwiftUI
import SwiftKeychainWrapper

struct ChangePasswordView: View {
    
    @ObservedObject var viewModel: ChangesPasswordViewModel
    @ObservedObject var stateObservable = StateObservable.shared
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    var body: some View {
        ZStack {
            ZStack(alignment: .topLeading) {
                Color.DinotisDefault.baseBackground
                    .edgesIgnoringSafeArea(.all)
                    .alert(isPresented: $viewModel.isRefreshFailed) {
                        Alert(
                            title: Text(LocaleText.attention),
                            message: Text(LocaleText.sessionExpireText),
                            dismissButton: .default(Text(LocaleText.returnText), action: {
                                NavigationUtil.popToRootView()
                                self.stateObservable.userType = 0
                                self.stateObservable.isVerified = ""
                                self.stateObservable.refreshToken = ""
                                self.stateObservable.accessToken = ""
                                self.stateObservable.isAnnounceShow = false
                                OneSignal.setExternalUserId("")
                            }))
                    }
                
                VStack(spacing: 0) {
                    HeaderView(
                        type: .textHeader,
                        title: LocalizableText.changePasswordLabel,
                        leadingButton: {
                            DinotisElipsisButton(
                                icon: .generalBackIcon,
                                iconColor: .DinotisDefault.black1,
                                bgColor: .DinotisDefault.white,
                                strokeColor: nil,
                                iconSize: 12,
                                type: .primary, {
                                    dismiss()
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
                        VStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(LocalizableText.formOldPasswordLabel)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.DinotisDefault.black1)
                                
                                PasswordTextField(
                                    LocalizableText.hintFormOldPassword,
                                    isSecure: $viewModel.isSecuredOld,
                                    password: $viewModel.oldPassword,
                                    errorText: $viewModel.oldPasswordError
                                ) {
                                    Button(action: {
                                        viewModel.isSecuredOld.toggle()
                                    }, label: {
                                        Image(systemName: viewModel.isSecuredOld ? "eye.slash.fill" : "eye.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 12)
                                            .foregroundColor(.DinotisDefault.black2)
                                    })
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(LocalizableText.formNewPasswordLabel)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.DinotisDefault.black1)
                                
                                PasswordTextField(
                                    LocalizableText.hintFormNewPassword,
                                    isSecure: $viewModel.isSecured,
                                    password: $viewModel.newPassword,
                                    errorText: $viewModel.newPasswordError
                                ) {
                                    Button(action: {
                                        viewModel.isSecured.toggle()
                                    }, label: {
                                        Image(systemName: viewModel.isSecured ? "eye.slash.fill" : "eye.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 12)
                                            .foregroundColor(.DinotisDefault.black2)
                                    })
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(LocalizableText.formNewRepasswordLabel)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.DinotisDefault.black1)
                                
                                PasswordTextField(
                                    LocalizableText.hintFormNewRepassword,
                                    isSecure: $viewModel.isSecuredRe,
                                    password: $viewModel.confirmPassword,
                                    errorText: $viewModel.newRePasswordError
                                ) {
                                    Button(action: {
                                        viewModel.isSecuredRe.toggle()
                                    }, label: {
                                        Image(systemName: viewModel.isSecuredRe ? "eye.slash.fill" : "eye.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 12)
                                            .foregroundColor(.DinotisDefault.black2)
                                    })
                                }
                            }
                        }
                        .padding()
                    }
                    
                    DinotisPrimaryButton(
                        text: LocalizableText.changeNowLabel,
                        type: .adaptiveScreen,
                        textColor: viewModel.isButtonDisable() ? .DinotisDefault.lightPrimaryActive : .DinotisDefault.white,
                        bgColor: viewModel.isButtonDisable() ? .DinotisDefault.lightPrimary : .DinotisDefault.primary
                    ) {
                        Task {
                            await viewModel.resetPassword {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isButtonDisable())
                    .padding()
                }
                
                DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
            }
            .dinotisAlert(
                isPresent: $viewModel.isShowAlert,
                title: viewModel.alert.title,
                isError: viewModel.alert.isError,
                message: viewModel.alert.message,
                primaryButton: viewModel.alert.primaryButton,
                secondaryButton: viewModel.alert.secondaryButton
            )
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView(viewModel: ChangesPasswordViewModel())
    }
}
