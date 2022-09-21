//
//  ChangeEmailView.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/08/21.
//

import SwiftUI
import SwiftUINavigation
import OneSignal

struct ChangePhoneView: View {
	
	@ObservedObject var stateObservable = StateObservable.shared
	
	@ObservedObject var viewModel: ChangePhoneViewModel
	
	@State var isShowConnection = false
	
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	@Environment(\.presentationMode) var presentationMode
	
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
                    Image.Dinotis.linearGradientBackground
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
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
                                }))
                        }
                    
                    VStack {
                        
                        ZStack {
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
                                
                                Spacer()
                            }
                            
                            HStack {
                                Spacer()
                                Text(LocaleText.changePhoneNumberTitle)
                                    .font(.montserratBold(size: 14))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            .alert(isPresented: $isShowConnection) {
                                Alert(
                                    title: Text(LocaleText.attention),
                                    message: Text(NSLocalizedString("connection_warning", comment: "")),
                                    dismissButton: .cancel(Text(LocaleText.returnText)))
                            }
                        }
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack {
                                
                                Image.Dinotis.otpVerificationImage
                                    .resizable()
                                    .frame(width:
                                                    309, height: 278.85, alignment: .center)
                                    .padding()
                                    .padding(.top)
                                
                                VStack(alignment: .center, spacing: 15) {
                                    
                                    Text(LocaleText.newPhoneNumberSubtitle)
                                        .font(.montserratRegular(size: 12))
                                        .padding(.horizontal, 5)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.black)
                                    
                                    VStack {
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
                                            
                                            TextField(LocaleText.enterPhoneLabel, text: $viewModel.phone)
                                                .keyboardType(.phonePad)
                                                .font(.montserratRegular(size: 12))
                                                .foregroundColor(.black)
                                                .accentColor(.black)
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
                                                        Text(itemError.error.orEmpty())
                                                            .font(.montserratRegular(size: 10))
                                                            .foregroundColor(.red)
                                                        
                                                        Spacer()
                                                    }
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
                                                .foregroundColor(viewModel.phone.isEmpty ? Color(.systemGray3) : .white)
                                                .padding(10)
                                                .padding(.horizontal)
                                                .padding(.vertical, 5)
                                            
                                            Spacer()
                                            
                                        }
                                        .background(viewModel.phone.isEmpty ? Color(.systemGray5) :  Color.primaryViolet)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    })
                                    .disabled(viewModel.phone.isEmpty)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.dinotisShadow.opacity(0.2), radius: 40, x: 0.0, y: 0.0)
                                .padding()
                                .padding(.bottom, 30)
                            }
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
							viewModel.getOtpCode()
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

struct ChangeEmailView_Previews: PreviewProvider {
	static var previews: some View {
		ChangePhoneView(viewModel: ChangePhoneViewModel(backToRoot: {}, backToHome: {}, backToEditProfile: {}))
	}
}
