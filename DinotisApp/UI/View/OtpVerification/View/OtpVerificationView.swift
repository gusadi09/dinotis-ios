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
	
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		GeometryReader { geo in
			ZStack {
                Color.DinotisDefault.baseBackground
					.edgesIgnoringSafeArea(.all)
                
                Image.backgroundAuthenticationImage
                    .resizable()
                    .ignoresSafeArea()
                    
                VStack {
                    HeaderView(
                        type: .textHeader,
                        title: viewModel.headerTitle,
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
                    
                    VStack {
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .center) {
                                Image.generalDinotisImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 50)
                                    .padding(.vertical)
                                
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
                                viewModel.receiveTimerBackground()
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
                            .dynamicTypeSize(.large)
					} else {
						SelectChannelView(channel: $viewModel.selectedChannel, geo: geo) {
							withAnimation {
								viewModel.onResendOTP()
								viewModel.isShowSelectChannel = false
							}
						}
							.padding()
							.padding(.vertical)
                            .dynamicTypeSize(.large)
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

fileprivate struct Preview: View {
    
    init() {
        FontInjector.registerFonts()
    }
    
    var body: some View {
        OtpVerificationView(viewModel: OtpVerificationViewModel(phoneNumber: "", otpType: .register, onBackToRoot: {}, backToLogin: {}, backToPhoneSet: {}))
    }
}

struct EmailVerificationView_Previews: PreviewProvider {
	static var previews: some View {
		Preview()
	}
}
