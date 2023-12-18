//
//  ChangeEmailView.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/08/21.
//

import DinotisDesignSystem
import SwiftUI
import SwiftUINavigation
import OneSignal
import DinotisData

struct ChangePhoneView: View {
	
	@ObservedObject var stateObservable = StateObservable.shared
	
	@ObservedObject var viewModel: ChangePhoneViewModel
	
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
        GeometryReader { geo in
            ZStack {
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.changePhoneOtp,
                    destination: { viewModel in
                        ChangePhoneVerifyView(viewModel: viewModel.wrappedValue)
                    },
                    onNavigate: {_ in },
                    label: {
                        EmptyView()
                    }
                )
                
                ZStack(alignment: .topLeading) {
					Color.DinotisDefault.baseBackground
                        .edgesIgnoringSafeArea(.all)

					VStack(spacing: 0) {

						HeaderView(
							type: .imageHeader(Image.generalDinotisImage, 25),
							title: ""
						) {
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
						} trailingButton: {
							Button {
								viewModel.openWhatsApp()
							} label: {
								Image.generalQuestionIcon
									.resizable()
									.scaledToFit()
									.frame(height: 25)
							}
						}

						ScrollView(.vertical, showsIndicators: false) {
							VStack(spacing: 20) {
								VStack(spacing: 10) {
									Text(LocalizableText.changePhoneTitle)
										.font(.robotoBold(size: 28))
										.foregroundColor(.DinotisDefault.black1)

									Text(LocalizableText.descriptionChangePhone)
										.font(.robotoRegular(size: 12))
										.foregroundColor(.DinotisDefault.black2)
								}
								.multilineTextAlignment(.center)

								PhoneNumberTextField(
									LocalizableText.phoneHint,
									text: $viewModel.phone,
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
                        .onChange(of: viewModel.phone) { newValue in
                            if newValue.hasPrefix("0") {
                                viewModel.phone = String(newValue.dropFirst(1))
                            }
                            
                            let numericCharacters = newValue.filter { "0"..."9" ~= $0 }
                            viewModel.phone = String(numericCharacters)
                        }
                    }
                }
                
                DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
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
								viewModel.onGetOTP()
								viewModel.isShowSelectChannel = false
							}

						}
							.padding()
                            .presentationDetents([.fraction(0.34)])
                            .dynamicTypeSize(.large)
					} else {
                        ScrollView {
                            SelectChannelView(channel: $viewModel.selectedChannel, geo: geo) {
                                withAnimation {
                                    viewModel.onGetOTP()
                                    viewModel.isShowSelectChannel = false
                                }
                                
                            }
                            .padding()
                            .padding(.vertical)
                            .dynamicTypeSize(.large)
                        }
					}
				}
			)
			.dinotisAlert(
				isPresent: $viewModel.isShowAlert,
        title: viewModel.alert.title,
        isError: viewModel.alert.isError,
        message: viewModel.alert.message,
        primaryButton: viewModel.alert.primaryButton
			)
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
	}
}

struct ChangeEmailView_Previews: PreviewProvider {
	static var previews: some View {
        ChangePhoneView(viewModel: ChangePhoneViewModel(backToHome: {}, backToEditProfile: {}, phone: ""))
	}
}
