//
//  ForgotPasswordView.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/08/21.
//

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
                    Image.Dinotis.userTypeBackground
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .center) {
                            
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
                                .padding(.top, 20)
                            
                            Spacer()
                            
                            Image.Dinotis.forgotPasswordImage
                                .resizable()
                                .frame(
                                    minWidth: 95,
                                    idealWidth: 285,
                                    maxWidth: 285,
                                    minHeight: 75.3,
                                    idealHeight: 226,
                                    maxHeight: 226,
                                    alignment: .center
                                )
                                .padding()
                            
                            Spacer()
                            
                            VStack(alignment: .center, spacing: 15) {
                                Text(LocaleText.forgetPasswordText)
                                    .font(.montserratBold(size: 18))
                                    .foregroundColor(.black)
                                
                                Text(LocaleText.resetPasswordLabels)
                                    .font(.montserratRegular(size: 12))
                                    .padding(.horizontal, 30)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.black)
                                
                                HStack {
                                    Image.Dinotis.phoneIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 24)
                                    
                                    Button {
                                        viewModel.isShowingCountryPicker.toggle()
                                    } label: {
                                        HStack(spacing: 5) {
                                            Text("+\(viewModel.countrySelected.phoneCode)")

                                            Image(systemName: "chevron.down")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 5)
                                        }
                                        .font(.montserratRegular(size: 14))
                                        .foregroundColor(.black)
                                    }
                                    
                                    TextField(LocaleText.enterPhoneLabel, text: $viewModel.phone.phone)
                                        .font(.montserratRegular(size: 14))
                                        .foregroundColor(.black)
                                        .accentColor(.black)
                                        .disableAutocorrection(true)
                                        .autocapitalization(.none)
                                        .keyboardType(.phonePad)
                                }
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.dinotisStrokeSecondary, lineWidth: 1)
                                )
                                
                                VStack {
                                    if let error = viewModel.fieldError {
                                        ForEach(error, id: \.itemId) { itemError in
                                            HStack {
                                                Image.Dinotis.exclamationCircleIcon
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 10)
                                                    .foregroundColor(.red)
                                                Text(itemError.error ?? "")
                                                    .font(.montserratRegular(size: 10))
                                                    .foregroundColor(.red)
                                                
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    viewModel.isShowSelectChannel.toggle()
                                }, label: {
                                    HStack {
                                        Spacer()
                                        
                                        Text(LocaleText.sendText)
                                            .font(.montserratSemiBold(size: 12))
                                            .foregroundColor(viewModel.phone.phone.isEmpty ? Color(.systemGray3) : .white)
                                            .padding(10)
                                            .padding(.horizontal)
                                            .padding(.vertical, 5)
                                        
                                        Spacer()
                                        
                                    }
                                    .background(viewModel.phone.phone.isEmpty ? Color(.systemGray5) :  Color.primaryViolet)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                })
                                .disabled(viewModel.phone.phone.isEmpty)
                                
                                Button {
                                    viewModel.openWhatsApp()
                                } label: {
                                    HStack(spacing: 5) {
                                        Text(NSLocalizedString("need_help", comment: "")).font(.custom(FontManager.Montserrat.regular, size: 12)).foregroundColor(.black).underline()
                                        +
                                        Text(NSLocalizedString("contact_us", comment: "")).font(.custom(FontManager.Montserrat.bold, size: 12)).foregroundColor(.black).underline()
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.dinotisShadow.opacity(0.2), radius: 40, x: 0.0, y: 0.0)
                            .padding()
                            .padding(.bottom, 30)
                        }
                    }
                    
                    ZStack(alignment: .topLeading) {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }, label: {
                                Image.Dinotis.arrowBackIcon
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                            })
                            .padding(.leading)
                        }
                    }
                }
                
                LoadingView(isAnimating: $viewModel.isLoading)
                    .isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)
            }
            .sheet(isPresented: $viewModel.isShowingCountryPicker, content: {
                CountryPicker(country: $viewModel.countrySelected)
			})
			.dinotisSheet(
				isPresented: $viewModel.isShowSelectChannel,
				onDismiss: {
					viewModel.selectedChannel = .whatsapp
				},
				fraction: 0.45,
				content: {
					SelectChannelView(channel: $viewModel.selectedChannel, geo: geo) {
						withAnimation {
							viewModel.sendResetPassword()
							viewModel.isShowSelectChannel = false
						}

					}
				}
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
