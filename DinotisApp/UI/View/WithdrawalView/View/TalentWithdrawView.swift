//
//  TalentWithdrawView.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/09/21.
//

import CurrencyFormatter
import DinotisDesignSystem
import SwiftUI
import SwiftUITrackableScrollView

struct TalentWithdrawView: View {
	
	@Environment(\.dismiss) var dismiss
	
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}

	@ObservedObject var viewModel: TalentWithdrawalViewModel
	
	var body: some View {
		ZStack {
			Image.Dinotis.userTypeBackground
				.resizable()
				.edgesIgnoringSafeArea(.all)
				.alert(isPresented: $viewModel.isRefreshFailed) {
					Alert(
						title: Text(LocaleText.attention),
						message: Text(LocaleText.sessionExpireText),
						dismissButton: .default(
							Text(LocaleText.returnText),
							action: {
								viewModel.routeToRoot()
							}
						)
					)
				}
			
			VStack(spacing: 0) {
				VStack(spacing: 0) {
					
					HStack {
						Button(action: {
							dismiss()
						}, label: {
							Image.Dinotis.arrowBackIcon
								.padding()
								.background(Color.white)
								.clipShape(Circle())
						})
						.alert(isPresented: $viewModel.isError) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text(viewModel.error.orEmpty()),
								dismissButton: .default(Text(LocaleText.returnText))
							)
						}
						
						Spacer()
						
						Text(LocaleText.withdrawAmountText)
							.font(.robotoBold(size: 14))
							.padding(.horizontal)
							.alert(isPresented: $viewModel.success) {
								Alert(
									title: Text(LocaleText.successTitle),
									message: Text(LocaleText.withdrawUnderProcessText),
									dismissButton: .default(Text(LocaleText.returnText), action: {
										viewModel.isPresent.toggle()
										dismiss()
									}))
							}
						
						Spacer()
						Spacer()
					}
					.padding()
					.background(
						viewModel.colorTab
							.edgesIgnoringSafeArea(.vertical)
					)

				}
				
				TrackableScrollView(.vertical, showIndicators: false, contentOffset: $viewModel.contentOffset) {
					VStack(alignment: .leading) {
						VStack(alignment: .leading) {
							HStack {
								Image.Dinotis.handPickedDebitCardIcon
									.resizable()
									.scaledToFit()
									.frame(height: 24)
								
								Text(LocaleText.withdrawToAccount)
									.font(.robotoMedium(size: 12))
									.foregroundColor(.black)
								
								Spacer()
							}
							
							if let dataBank = viewModel.bankData.first {
								HStack {
									VStack(alignment: .leading, spacing: 10) {
										Text("\(dataBank.bank?.name ?? "") \u{2022} \(dataBank.accountName ?? "")")
											.font(.robotoRegular(size: 12))
											.foregroundColor(.black)
											.fixedSize(horizontal: false, vertical: true)
											.multilineTextAlignment(.leading)
										
										Text(dataBank.accountNumber.orEmpty())
											.font(.robotoBold(size: 14))
											.foregroundColor(.black)
											.multilineTextAlignment(.leading)
									}
									
									Spacer()
								}
								.padding()
								.background(Color.backgroundProfile)
								.cornerRadius(12)
							}
						}
						.padding()
						.background(Color.white)
						.clipShape(RoundedRectangle(cornerRadius: 12))
						.shadow(color: Color.dinotisShadow.opacity(0.1), radius: 10, x: 0.0, y: 0.0)
						
						VStack {
                            DinotisCurrencyTextField(
                                amount: $viewModel.inputAmount,
                                label: LocaleText.enterAmountLabel,
                                errorText: $viewModel.amountError
                            )
                            .padding(.vertical, 10)
                            .valueChanged(value: viewModel.inputAmount.orZero()) { value in
                                viewModel.balanceInputErrorChecker(amount: value)
                            }
                            
							HStack {
								Image.Dinotis.walletButtonIcon
									.resizable()
									.scaledToFit()
									.frame(height: 24)
								
								HStack(spacing: 4) {
									Text(LocaleText.walletBalance)
										.font(.robotoRegular(size: 12))
										.foregroundColor(.black)
									
									Text(viewModel.currentBalances.toCurrency())
										.font(.robotoBold(size: 12))
										.foregroundColor(.black)
									
									Spacer()
								}
							}
						}
						.padding()
						.background(Color.white)
						.clipShape(RoundedRectangle(cornerRadius: 12))
						.shadow(color: Color.dinotisShadow.opacity(0.1), radius: 10, x: 0.0, y: 0.0)
						.padding(.top, 10)
					}
					.padding()
					.valueChanged(value: viewModel.contentOffset) { val in
						viewModel.colorTab = val > 0 ? Color.white : Color.clear
					}
				}
				
				Spacer()
				
				VStack {
					Button(action: {
						viewModel.isPresent.toggle()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
						viewModel.total = viewModel.adminFee + Int(viewModel.inputAmount.orZero())
						
					}, label: {
						HStack {
							Spacer()
							Text(LocaleText.continueAlt)
								.font(.robotoBold(size: 12))
								.foregroundColor(.white)
							
							Spacer()
						}
						.padding()
						.background(
							viewModel.isEnableWithdraw() ? Color.DinotisDefault.primary.opacity(0.5) : Color.DinotisDefault.primary
						)
						.cornerRadius(8)
						.padding()
					})
					.disabled(viewModel.isEnableWithdraw())
					
					Color.white
						.frame(height: 2)
				}
				.background(Color.white.edgesIgnoringSafeArea(.vertical))

			}
			
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
		}
		.sheet(isPresented: $viewModel.isPresent, content: {
			if #available(iOS 16.0, *) {
				VStack {
                    if viewModel.isLoadingWithdraw {
                        Spacer()
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                        
                        Spacer()
                    } else if !viewModel.isLoadingWithdraw && viewModel.success {
                        
                        Spacer()
                        
                        Image.Dinotis.paymentSuccessImage
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                        
                        VStack(spacing: 5) {
                            Text(LocalizableText.generalSuccess)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.DinotisDefault.black1)
                                .multilineTextAlignment(.center)
                            
                            Text(LocalizableText.withdrawSuccessSubtitle)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.DinotisDefault.black1)
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                        
                        DinotisPrimaryButton(
                            text: LocalizableText.closeLabel,
                            type: .adaptiveScreen,
                            height: 45,
                            textColor: .white,
                            bgColor: .DinotisDefault.primary
                        ) {
                            viewModel.isPresent = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) {
                                dismiss()
                            }
                        }
                    } else {
                        HStack {
                            Image.Dinotis.handPickedDebitCardWithRoundedRectangle
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                            
                            VStack(alignment: .leading) {
                                if let dataBank = viewModel.bankData.first {
                                    HStack {
                                        Text((dataBank.bank?.name).orEmpty())
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(.black)
                                        
                                        Circle()
                                            .scaledToFit()
                                            .frame(height: 3)
                                            .foregroundColor(.black)
                                        
                                        Text(dataBank.accountName.orEmpty())
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(.black)
                                    }
                                    
                                    Text(dataBank.accountNumber.orEmpty())
                                        .font(.robotoMedium(size: 14))
                                        .foregroundColor(.black)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text(LocaleText.withdrawAmountText)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("\(viewModel.inputAmount.orZero().toCurrency())")
                                .font(.robotoBold(size: 16))
                                .foregroundColor(.black)
                        }
                        .padding(.top)
                        .padding(.bottom, 5)
                        
                        HStack {
                            Text(LocaleText.adminFeeText)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("\(viewModel.adminFee.numberString.toCurrency())")
                                .font(.robotoBold(size: 16))
                                .foregroundColor(.black)
                        }
                        
                        Divider()
                            .padding(.vertical)
                        
                        HStack {
                            Text(LocaleText.totalBalanceWithHeld)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("\(viewModel.total.numberString.toCurrency())")
                                .font(.robotoBold(size: 16))
                                .foregroundColor(.black)
                        }
                        .padding(.bottom)
                        
                        Spacer()
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                viewModel.isPresent.toggle()
                            }, label: {
                                HStack {
                                    Spacer()
                                    Text(LocaleText.cancelText)
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.secondaryViolet)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
                                )
                            })
                            
                            Button(action: {
                                Task {
                                    await viewModel.withdraw()
                                }
                            }, label: {
                                HStack {
                                    Spacer()
                                    Text(LocaleText.withdrawBalance)
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.DinotisDefault.primary)
                                .cornerRadius(8)
                            })
                        }
                    }
				}
					.padding()
					.padding(.vertical)
                    .presentationDetents([.height(380)])
                    .presentationDragIndicator(.hidden)
                    .dynamicTypeSize(.large)
			} else {
				VStack {
                    if viewModel.isLoading {
                        Spacer()
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                        
                        Spacer()
                    } else if !viewModel.isLoadingWithdraw && viewModel.success {
                        
                        Spacer()
                        
                        Image.Dinotis.paymentSuccessImage
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                        
                        VStack(spacing: 5) {
                            Text(LocalizableText.generalSuccess)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.DinotisDefault.black1)
                                .multilineTextAlignment(.center)
                            
                            Text(LocalizableText.withdrawSuccessSubtitle)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.DinotisDefault.black1)
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                        
                        DinotisPrimaryButton(
                            text: LocalizableText.closeLabel,
                            type: .adaptiveScreen,
                            height: 45,
                            textColor: .white,
                            bgColor: .DinotisDefault.primary
                        ) {
                            viewModel.isPresent = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) {
                                dismiss()
                            }
                        }
                    } else {
                        HStack {
                            Image.Dinotis.handPickedDebitCardWithRoundedRectangle
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                            
                            VStack(alignment: .leading) {
                                if let dataBank = viewModel.bankData.first {
                                    HStack {
                                        Text((dataBank.bank?.name).orEmpty())
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(.black)
                                        
                                        Circle()
                                            .scaledToFit()
                                            .frame(height: 3)
                                            .foregroundColor(.black)
                                        
                                        Text(dataBank.accountName.orEmpty())
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(.black)
                                    }
                                    
                                    Text(dataBank.accountNumber.orEmpty())
                                        .font(.robotoMedium(size: 14))
                                        .foregroundColor(.black)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text(LocaleText.withdrawAmountText)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("\(viewModel.inputAmount.orZero().toCurrency())")
                                .font(.robotoBold(size: 16))
                                .foregroundColor(.black)
                        }
                        .padding(.top)
                        .padding(.bottom, 5)
                        
                        HStack {
                            Text(LocaleText.adminFeeText)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("\(viewModel.adminFee.numberString.toCurrency())")
                                .font(.robotoBold(size: 16))
                                .foregroundColor(.black)
                        }
                        
                        Divider()
                            .padding(.vertical)
                        
                        HStack {
                            Text(LocaleText.totalBalanceWithHeld)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("\(viewModel.total.numberString.toCurrency())")
                                .font(.robotoBold(size: 16))
                                .foregroundColor(.black)
                        }
                        .padding(.bottom)
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                viewModel.isPresent.toggle()
                            }, label: {
                                HStack {
                                    Spacer()
                                    Text(LocaleText.cancelText)
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.secondaryViolet)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
                                )
                            })
                            
                            Button(action: {
                                Task {
                                    await viewModel.withdraw()
                                }
                            }, label: {
                                HStack {
                                    Spacer()
                                    Text(LocaleText.withdrawBalance)
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.DinotisDefault.primary)
                                .cornerRadius(8)
                            })
                        }
                    }
				}
					.padding()
					.padding(.vertical)
                    .dynamicTypeSize(.large)
			}
		})
		.onAppear {
			viewModel.onAppear()
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct TalentWithdrawView_Previews: PreviewProvider {
	static var previews: some View {
		TalentWithdrawView(viewModel: TalentWithdrawalViewModel(backToHome: {}))
	}
}
