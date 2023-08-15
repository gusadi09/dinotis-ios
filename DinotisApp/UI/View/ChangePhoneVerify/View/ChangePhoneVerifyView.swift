//
//  ChangePhoneVerifyView.swift
//  DinotisApp
//
//  Created by Gus Adi on 24/02/22.
//

import DinotisDesignSystem
import SwiftUI
import SwiftUINavigation

struct ChangePhoneVerifyView: View {
	
	@ObservedObject var viewModel: ChangePhoneVerifyViewModel
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		GeometryReader { geo in
			ZStack(alignment: .top) {
				Color.DinotisDefault.baseBackground
					.edgesIgnoringSafeArea(.all)

				VStack {
					HeaderView(
						type: .imageHeader(Image.generalDinotisImage, 25),
						title: "") {
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

					VStack {

						ScrollView(.vertical, showsIndicators: false) {
							VStack(alignment: .center) {
								Text(LocalizableText.changePhoneTitle)
									.font(.robotoBold(size: 28))
									.foregroundColor(.DinotisDefault.black1)
									.padding(.vertical, 24)

								VStack(alignment: .center, spacing: 6) {
									Text(LocalizableText.hintSendOTP)
										.font(.robotoRegular(size: 14))
										.foregroundColor(.DinotisDefault.black2)

									Text(viewModel.phoneNumber)
										.font(.robotoBold(size: 20))
										.foregroundColor(.DinotisDefault.black2)

								}

								OTPView(
									allCode: $viewModel.otpNumber,
									errorText: $viewModel.otpError
								)
								.padding(.vertical, 16)
								.onChange(of: viewModel.otpNumber) { _ in
                                    Task {
                                        await viewModel.validateOTP()
                                    }
								}

								VStack {
									Text(LocalizableText.hintResendOTP)
										.font(.robotoRegular(size: 12))
										.foregroundColor(.DinotisDefault.black2)

									DinotisNudeButton(
										text: viewModel.timeRemainingText(),
										textColor: .DinotisDefault.primary,
										fontSize: 12) {
											viewModel.isShowSelectChannel.toggle()
										}
										.disabled(!viewModel.isActive)
								}
								.padding(.bottom)
							}
							.onReceive(viewModel.timer) { _ in
								viewModel.onReceiveTimer()
							}
							.padding([.horizontal, .bottom])
						}
					}

					OTPKeyboard(code: $viewModel.otpNumber)
				}
                
                DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
			}
			.sheet(
				isPresented: $viewModel.isShowSelectChannel,
				content: {
					if #available(iOS 16.0, *) {
                        SelectChannelView(channel: $viewModel.selectedChannel, geo: geo) {
                            withAnimation {
                                viewModel.onResendOTP()
                                viewModel.isShowSelectChannel = false
                            }
                        }
                        .padding()
                        .presentationDetents([.fraction(0.34)])
					} else {
						SelectChannelView(channel: $viewModel.selectedChannel, geo: geo) {
							withAnimation {
								viewModel.onResendOTP()
								viewModel.isShowSelectChannel = false
							}
						}
							.padding()
							.padding(.vertical)
					}
				}
			)
		}
    .dinotisAlert(
      isPresent: $viewModel.isShowAlert,
      title: viewModel.alert.title,
      isError: viewModel.alert.isError,
      message: viewModel.alert.message,
      primaryButton: viewModel.alert.primaryButton
    )
		.onDisappear(perform: {
			viewModel.timer.upstream.connect().cancel()
		})
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct ChangePhoneVerifyView_Previews: PreviewProvider {
	static var previews: some View {
		ChangePhoneVerifyView(viewModel: ChangePhoneVerifyViewModel(phoneNumber: "", backToEditProfile: {}))
	}
}
