//
//  ResetPasswordView.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/04/22.
//

import DinotisDesignSystem
import SwiftUI

struct ResetPasswordView: View {
	
	@ObservedObject var viewModel: ResetPasswordViewModel
	
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		ZStack {
			ZStack(alignment: .topLeading) {
				Color.DinotisDefault.baseBackground
					.edgesIgnoringSafeArea(.all)
                
                Image.backgroundAuthenticationImage
                    .resizable()
                    .ignoresSafeArea()

				VStack(spacing: 0) {
                    HeaderView(
                        type: .textHeader,
                        title: LocalizableText.titleChangePassword,
                        headerColor: .clear,
                        textColor: .white,
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
                        })

					ScrollView(.vertical, showsIndicators: false) {
						VStack(spacing: 20) {
							VStack(spacing: 10) {
                                Image.generalDinotisImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 50)
                                    .padding(.vertical)

								Text(LocalizableText.descriptionChangePassword)
									.font(.robotoRegular(size: 12))
									.foregroundColor(.DinotisDefault.black2)
							}
							.multilineTextAlignment(.center)

							VStack {
								PasswordTextField(
									LocalizableText.hintNewPassword,
									isSecure: $viewModel.isPassShow,
									password: $viewModel.password.password,
									errorText: $viewModel.passwordError
								) {
									Button(action: {
										viewModel.isPassShow.toggle()
									}, label: {
										Image(systemName: viewModel.isPassShow ? "eye.slash.fill" : "eye.fill")
											.resizable()
											.scaledToFit()
											.frame(height: 12)
											.foregroundColor(.DinotisDefault.black2)
									})
								}

								PasswordTextField(
									LocalizableText.hintNewRepassword,
									isSecure: $viewModel.isRepeatPassShow,
									password: $viewModel.password.passwordConfirm,
									errorText: $viewModel.rePasswordError
								) {
									Button(action: {
										viewModel.isRepeatPassShow.toggle()
									}, label: {
										Image(systemName: viewModel.isRepeatPassShow ? "eye.slash.fill" : "eye.fill")
											.resizable()
											.scaledToFit()
											.frame(height: 12)
											.foregroundColor(.DinotisDefault.black2)
									})
								}
							}
                            
                            DinotisPrimaryButton(
                                text: LocalizableText.changeNowLabel,
                                type: .adaptiveScreen,
                                textColor: viewModel.isButtonDisable() ? .DinotisDefault.lightPrimaryActive : .DinotisDefault.white,
                                bgColor: viewModel.isButtonDisable() ? .DinotisDefault.lightPrimary : .DinotisDefault.primary
                            ) {
                                Task {
                                    await viewModel.resetPassword()
                                }
                            }
                            .disabled(viewModel.isButtonDisable())
                            .padding(.vertical)
						}
						.padding()
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
      primaryButton: viewModel.alert.primaryButton,
      secondaryButton: viewModel.alert.secondaryButton
		)
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

fileprivate struct Preview: View {
    
    init() {
        FontInjector.registerFonts()
    }
    
    var body: some View {
        ResetPasswordView(viewModel: ResetPasswordViewModel(phone: "", token: "", backToRoot: {}, backToLogin: {}, backToPhoneSet: {}))
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
	static var previews: some View {
		Preview()
	}
}
