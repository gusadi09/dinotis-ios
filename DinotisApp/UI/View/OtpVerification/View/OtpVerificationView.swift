//
//  EmailVerificationView.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/08/21.
//

import SwiftUI
import SwiftUINavigation
import DinotisDesignSystem

struct OtpVerificationView: View {
	
	@ObservedObject var viewModel: OtpVerificationViewModel
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		GeometryReader { geo in
			ZStack {
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
                                Text(viewModel.registerTitleText())
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

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /PrimaryRouting.tabContainer) { viewModel in
						TabViewContainer()
                            .environmentObject(viewModel.wrappedValue)
					} onNavigate: { _ in

					} label: {
						EmptyView()
					}

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /PrimaryRouting.homeTalent) { viewModel in
						TalentHomeView()
                            .environmentObject(viewModel.wrappedValue)
					} onNavigate: { _ in

					} label: {
						EmptyView()
					}

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /PrimaryRouting.biodataUser) { viewModel in
						UserBiodataView(viewModel: viewModel.wrappedValue)
					} onNavigate: { _ in

					} label: {
						EmptyView()
					}

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /PrimaryRouting.resetPassword) { viewModel in
						ResetPasswordView(viewModel: viewModel.wrappedValue)
					} onNavigate: { _ in

					} label: {
						EmptyView()
					}

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
							.padding(.vertical)
							.presentationDetents([.fraction(0.45), .large])
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
		.onDisappear(perform: {
			viewModel.timer.upstream.connect().cancel()
		})
        .dinotisAlert(
            isPresent: $viewModel.isError,
            title: LocaleText.attention,
            isError: true,
            message: viewModel.error.orEmpty(),
            primaryButton: .init(text: LocalizableText.closeLabel, action: {})
        )
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct EmailVerificationView_Previews: PreviewProvider {
	static var previews: some View {
		OtpVerificationView(viewModel: OtpVerificationViewModel(phoneNumber: "", otpType: .login, onBackToRoot: {}, backToLogin: {}, backToPhoneSet: {}))
	}
}
