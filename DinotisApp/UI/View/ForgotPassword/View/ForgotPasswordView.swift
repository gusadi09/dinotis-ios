//
//  ForgotPasswordView.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/08/21.
//

import DinotisDesignSystem
import SwiftUI
import SwiftUINavigation

struct ForgotPasswordView: View {
	
	@ObservedObject var viewModel: ForgotPasswordViewModel
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
        GeometryReader { geo in
            ZStack {
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /PrimaryRouting.verificationOtp,
                    destination: { viewModel in
                        OtpVerificationView(viewModel: viewModel.wrappedValue)
                    },
                    onNavigate: { _ in },
                    label: {
                        EmptyView()
                    }
                )
                
                ZStack(alignment: .topLeading) {
					Color.DinotisDefault.baseBackground
						.edgesIgnoringSafeArea(.all)

					VStack(spacing: 0) {
						HeaderView(
							type: .imageHeader(.generalDinotisImage, 25),
							title: "",
							leadingButton: {
								DinotisElipsisButton(
									icon: .generalBackIcon,
									iconColor: .DinotisDefault.black1,
									bgColor: .DinotisDefault.white,
									strokeColor: nil,
									iconSize: 12,
									type: .primary, {
										self.presentationMode.wrappedValue.dismiss()
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
							VStack(spacing: 20) {
								VStack(spacing: 10) {
									Text(LocalizableText.titleForgotPassword)
										.font(.robotoBold(size: 28))
										.foregroundColor(.DinotisDefault.black1)

									Text(LocalizableText.descriptionForgotPassword)
										.font(.robotoRegular(size: 12))
										.foregroundColor(.DinotisDefault.black2)
								}
								.multilineTextAlignment(.center)

								PhoneNumberTextField(
									LocalizableText.phoneHint,
									text: $viewModel.phone.phone,
									errorText: $viewModel.phoneNumberError
								) {
									Button {
										viewModel.isShowingCountryPicker.toggle()
									} label: {
										HStack(spacing: 5) {
											Text(viewModel.flag(country: viewModel.countrySelected.isoCode))

											Text("+\(viewModel.countrySelected.phoneCode)")

											Image(systemName: "chevron.down")
												.resizable()
												.scaledToFit()
												.frame(height: 5)
										}
										.font(.robotoRegular(size: 12))
										.foregroundColor(.DinotisDefault.black1)
									}
								}
							}
							.padding()
						}

						DinotisPrimaryButton(
							text: LocalizableText.labelSendOTP,
							type: .adaptiveScreen,
							textColor: viewModel.isButtonDisable() ? .DinotisDefault.lightPrimaryActive : .DinotisDefault.white,
							bgColor: viewModel.isButtonDisable() ? .DinotisDefault.lightPrimary : .DinotisDefault.primary
						) {
							viewModel.isShowSelectChannel.toggle()
						}
						.disabled(viewModel.isButtonDisable())
						.padding()
					}
                }
                
                DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
            }
            .sheet(isPresented: $viewModel.isShowingCountryPicker, content: {
                CountryPicker(country: $viewModel.countrySelected)
			})
			.sheet(
				isPresented: $viewModel.isShowSelectChannel,
				onDismiss: {
					viewModel.selectedChannel = .whatsapp
				},
				content: {
					if #available(iOS 16.0, *) {
                        SelectChannelView(channel: $viewModel.selectedChannel, geo: geo) {
                            withAnimation {
                                viewModel.onSendReset()
                                viewModel.isShowSelectChannel = false
                            }
                        }
                        .padding()
                        .padding(.vertical)
                        .presentationDetents([.fraction(0.45), .large])
                    } else {
                        SelectChannelView(channel: $viewModel.selectedChannel, geo: geo) {
                            withAnimation {
                                viewModel.onSendReset()
                                viewModel.isShowSelectChannel = false
                            }
						}
							.padding()
							.padding(.vertical)
					}
				}
			)
			.dinotisAlert(
				isPresent: $viewModel.isShowAlert,
        title: viewModel.alert.title,
        isError: viewModel.alert.isError,
        message: viewModel.alert.message,
        primaryButton: viewModel.alert.primaryButton,
        secondaryButton: viewModel.alert.secondaryButton
			)
		}
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
	}
}

struct ForgotPasswordView_Previews: PreviewProvider {
	static var previews: some View {
		ForgotPasswordView(viewModel: ForgotPasswordViewModel(backToRoot: {}, backToLogin: {}))
	}
}
