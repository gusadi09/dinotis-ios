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
	
	@Environment(\.dismiss) var dismiss
	
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
                    
                    Image.backgroundAuthenticationImage
                        .resizable()
                        .ignoresSafeArea()

					VStack(spacing: 0) {
                        HeaderView(
                            type: .textHeader,
                            title: LocalizableText.titleForgotPassword,
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
                                
                                DinotisPrimaryButton(
                                    text: LocalizableText.labelSendOTP,
                                    type: .adaptiveScreen,
                                    textColor: viewModel.isButtonDisable() ? .DinotisDefault.lightPrimaryActive : .DinotisDefault.white,
                                    bgColor: viewModel.isButtonDisable() ? .DinotisDefault.lightPrimary : .DinotisDefault.primary
                                ) {
                                    viewModel.isShowSelectChannel.toggle()
                                }
                                .disabled(viewModel.isButtonDisable())
                                
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
							}
							.padding()
						}
					}
                }
                
                DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
            }
            .onChange(of: viewModel.phone.phone) { newValue in
                if newValue.hasPrefix("0") {
                    viewModel.phone.phone = String(newValue.dropFirst(1))
                }
                
                let numericCharacters = newValue.filter { "0"..."9" ~= $0 }
                viewModel.phone.phone = String(numericCharacters)
            }
            .sheet(isPresented: $viewModel.isShowingCountryPicker, content: {
                CountryPicker(country: $viewModel.countrySelected)
                    .dynamicTypeSize(.large)
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
                        .presentationDetents([.fraction(0.34)])
                        .dynamicTypeSize(.large)
                    } else {
                        SelectChannelView(channel: $viewModel.selectedChannel, geo: geo) {
                            withAnimation {
                                viewModel.onSendReset()
                                viewModel.isShowSelectChannel = false
                            }
						}
							.padding()
							.padding(.vertical)
                            .dynamicTypeSize(.large)
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

fileprivate struct Preview: View {
    
    init() {
        FontInjector.registerFonts()
    }
    
    var body: some View {
        ForgotPasswordView(viewModel: ForgotPasswordViewModel(backToRoot: {}, backToLogin: {}))
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
	static var previews: some View {
		Preview()
	}
}
