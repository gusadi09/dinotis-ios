//
//  TalentWithdrawView.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/09/21.
//

import SwiftUI
import SwiftUITrackableScrollView
import CurrencyFormatter

struct TalentWithdrawView: View {
	@State var colorTab = Color.clear
	@State var contentOffset: CGFloat = 0
	@State var minTrans = 50000
	
	@State var money = ""
	@State var value: Double?
	@State var unformattedText: String?
	@State var inputAmount: Double?
	
	@State var biayaAdmin = 5500
	
	@State var moneyInt = 0
	
	@State var isShowAlert = false
	@State var isShowError = false
	
	@State var total = 0
	
	@State var isPresent = false
	
	@State var toggleErrorMin = true
	@State var toggleErrorMaks = true
	@State var toggleErrorSaldo = true
	
	@State var toggleError = false
	
	@Environment(\.presentationMode) var presentationMode
	
	@ObservedObject var userVM = UsersViewModel.shared
	
	@ObservedObject var withdrawVM = WithdrawViewModel.shared
	
	@State var isShowConnection = false
	
	@ObservedObject var bankAccVM = BankAccountViewModel.shared
	
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	var body: some View {
		ZStack {
			Image("user-type-bg")
				.resizable()
				.edgesIgnoringSafeArea(.all)
				.alert(isPresented: $isShowConnection) {
					Alert(
						title: Text(NSLocalizedString("attention", comment: "")),
						message: Text(NSLocalizedString("connection_warning", comment: "")),
						dismissButton: .cancel(Text(NSLocalizedString("return", comment: "")))
					)
				}
			
			VStack(spacing: 0) {
				VStack(spacing: 0) {
					colorTab
						.frame(height: 20)
					
					HStack {
						Button(action: {
							presentationMode.wrappedValue.dismiss()
						}, label: {
							Image("ic-chevron-back")
								.padding()
								.background(Color.white)
								.clipShape(Circle())
						})
						
						Spacer()
						
						Text(NSLocalizedString("withdrawal_amount", comment: ""))
							.font(.custom(FontManager.Montserrat.bold, size: 14))
							.padding(.horizontal)
						
						Spacer()
						Spacer()
					}
					.padding()
					.background(colorTab)
					.alert(isPresented: $withdrawVM.isRefreshFailed) {
						Alert(
							title: Text(NSLocalizedString("attention", comment: "")),
							message: Text(NSLocalizedString("session_expired", comment: "")),
							dismissButton: .default(Text(NSLocalizedString("return", comment: "")), action: {
								
							}))
					}
				}
				
				TrackableScrollView(.vertical, showIndicators: false, contentOffset: $contentOffset) {
					VStack(alignment: .leading) {
						VStack(alignment: .leading) {
							HStack {
								Image("ic-debit-card")
									.resizable()
									.scaledToFit()
									.frame(height: 24)
								
								Text(NSLocalizedString("withdraw_balance_to_account", comment: ""))
									.font(.custom(FontManager.Montserrat.semibold, size: 12))
									.foregroundColor(.black)
								
								Spacer()
							}
							
							if let dataBank = bankAccVM.data?.first {
								HStack {
									VStack(alignment: .leading, spacing: 10) {
										Text("\(dataBank.bank?.name ?? "") \u{2022} \(dataBank.accountName ?? "")")
											.font(Font.custom(FontManager.Montserrat.regular, size: 12))
											.foregroundColor(.black)
											.fixedSize(horizontal: false, vertical: true)
										
										Text(dataBank.accountNumber ?? "")
											.font(Font.custom(FontManager.Montserrat.bold, size: 14))
											.foregroundColor(.black)
									}
									
									Spacer()
								}
								.padding()
								.background(Color("bg-profile-text"))
								.cornerRadius(12)
							}
						}
						.padding()
						.background(Color.white)
						.clipShape(RoundedRectangle(cornerRadius: 12))
						.shadow(color: Color("dinotis-shadow-1").opacity(0.1), radius: 10, x: 0.0, y: 0.0)
						
						VStack {
							HStack {
								Text(NSLocalizedString("enter_amount_label", comment: ""))
									.font(.custom(FontManager.Montserrat.regular, size: 12))
									.foregroundColor(.black)
								
								Spacer()
							}
							
							VStack(spacing: 12) {
								CurrencyTextField("Rp0", value: self.$inputAmount, alwaysShowFractions: false, numberOfDecimalPlaces: 0, currencySymbol: "Rp", font: UIFont(name: FontManager.Montserrat.bold, size: 24))
									.foregroundColor(.black)
									.accentColor(.black)
								
								Capsule()
									.frame(height: 1)
									.foregroundColor(toggleError ? Color(.red) : Color(.systemGray5))
								
								HStack {
									Image("icn-exclamation-circle")
										.resizable()
										.scaledToFit()
										.frame(height: 10)
										.foregroundColor(.red)
									Text(NSLocalizedString("withdraw_amount_over", comment: ""))
										.font(.custom(FontManager.Montserrat.regular, size: 10))
										.foregroundColor(.red)
									
									Spacer()
								}
								.isHidden(toggleErrorMaks, remove: toggleErrorMaks)
								
								HStack {
									Image("icn-exclamation-circle")
										.resizable()
										.scaledToFit()
										.frame(height: 10)
										.foregroundColor(.red)
									Text(NSLocalizedString("withdraw_less", comment: ""))
										.font(.custom(FontManager.Montserrat.regular, size: 10))
										.foregroundColor(.red)
									
									Spacer()
								}
								.isHidden(toggleErrorMin, remove: toggleErrorMin)
								
								HStack {
									Image("icn-exclamation-circle")
										.resizable()
										.scaledToFit()
										.frame(height: 10)
										.foregroundColor(.red)
									Text(NSLocalizedString("over_balance", comment: ""))
										.font(.custom(FontManager.Montserrat.regular, size: 10))
										.foregroundColor(.red)
									
									Spacer()
								}
								.isHidden(toggleErrorSaldo, remove: toggleErrorSaldo)
								
							}
							.padding(.vertical, 10)
							.valueChanged(value: inputAmount) { value in
								if value ?? 0 < 50000.0 {
									toggleErrorSaldo = true
									toggleErrorMin = false
									toggleErrorMaks = true
									toggleError = true
								} else if value ?? 0 > 50000000.0 {
									toggleErrorMin = true
									toggleErrorMaks = false
									toggleError = true
									toggleErrorSaldo = true
								} else if value ?? 0 > Double(userVM.currentBalances) {
									toggleErrorSaldo = false
									toggleErrorMin = true
									toggleErrorMaks = true
									toggleError = true
								} else {
									toggleErrorSaldo = true
									toggleError = false
									toggleErrorMin = true
									toggleErrorMaks = true
								}
							}
							
							HStack {
								Image("ic-btn-wallet")
									.resizable()
									.scaledToFit()
									.frame(height: 24)
								
								HStack(spacing: 4) {
									Text(NSLocalizedString("wallet_balance", comment: ""))
										.font(.custom(FontManager.Montserrat.regular, size: 12))
										.foregroundColor(.black)
									
									Text(userVM.currentBalances.numberString.toCurrency())
										.font(.custom(FontManager.Montserrat.bold, size: 12))
										.foregroundColor(.black)
									
									Spacer()
								}
							}
						}
						.padding()
						.background(Color.white)
						.clipShape(RoundedRectangle(cornerRadius: 12))
						.shadow(color: Color("dinotis-shadow-1").opacity(0.1), radius: 10, x: 0.0, y: 0.0)
						.padding(.top, 10)
					}
					.padding()
					.valueChanged(value: contentOffset) { val in
						colorTab = val > 0 ? Color.white : Color.clear
					}
				}
				.alert(isPresented: $isShowError) {
					Alert(title: Text(NSLocalizedString("fail", comment: "")), message: Text(withdrawVM.error?.errorDescription ?? ""), dismissButton: .cancel(Text(NSLocalizedString("return", comment: ""))))
				}
				.onAppear {
					bankAccVM.getBankAcc()
					userVM.currentBalance()
				}
				
				Spacer()
				
				VStack {
					Button(action: {
						isPresent.toggle()
						
						total = biayaAdmin + Int(inputAmount ?? 0)
						
					}, label: {
						HStack {
							Spacer()
							Text(NSLocalizedString("continue", comment: ""))
								.font(.custom(FontManager.Montserrat.bold, size: 12))
								.foregroundColor(.white)
							
							Spacer()
						}
						.padding()
						.background(
							inputAmount ?? 0 < 50000.0 ||
							inputAmount ?? 0 > 50000000.0 || inputAmount ?? 0 > Double(userVM.currentBalances) ?
							Color("btn-stroke-1").opacity(0.5) : Color("btn-stroke-1"))
						.cornerRadius(8)
						.padding()
					})
					.disabled(inputAmount ?? 0 < 50000.0 || inputAmount ?? 0 > 50000000.0 || inputAmount ?? 0 > Double(userVM.currentBalances) )
					.valueChanged(value: withdrawVM.isSuccessPost) { value in
						isPresent.toggle()
						if value {
							isShowAlert.toggle()
						}
					}
					.valueChanged(value: withdrawVM.isError) { value in
						if value {
							isShowError.toggle()
						}
					}
					
					Color.white
						.frame(height: 2)
				}
				.background(Color.white)
				.alert(isPresented: $isShowAlert) {
					Alert(
						title: Text(NSLocalizedString("success", comment: "")),
						message: Text(NSLocalizedString("withdraw_under_process", comment: "")),
						dismissButton: .default(Text(NSLocalizedString("return", comment: "")), action: {
							presentationMode.wrappedValue.dismiss()
						}))
				}
			}
			.edgesIgnoringSafeArea(.vertical)
			.dinotisSheet(isPresented: $isPresent, options: .hideDismissButton, fraction: 0.6, content: {
				VStack {
					HStack {
						Image("ic-debit-rounded")
							.resizable()
							.scaledToFit()
							.frame(height: 40)

						VStack(alignment: .leading) {
							if let dataBank = bankAccVM.data?.first {
								HStack {
									Text(dataBank.bank?.name ?? "")
										.font(Font.custom(FontManager.Montserrat.regular, size: 12))
										.foregroundColor(.black)

									Circle()
										.scaledToFit()
										.frame(height: 3)
										.foregroundColor(.black)

									Text(dataBank.accountName ?? "")
										.font(Font.custom(FontManager.Montserrat.regular, size: 12))
										.foregroundColor(.black)
								}

								Text(dataBank.accountNumber ?? "")
									.font(Font.custom(FontManager.Montserrat.semibold, size: 14))
									.foregroundColor(.black)
							}
						}

						Spacer()
					}

					HStack {
						Text(NSLocalizedString("withdrawal_amount", comment: ""))
							.font(.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)

						Spacer()

						Text("\(inputAmount.orZero().toCurrency())")
							.font(.custom(FontManager.Montserrat.bold, size: 16))
							.foregroundColor(.black)
					}
					.padding(.top)
					.padding(.bottom, 5)

					HStack {
						Text(NSLocalizedString("admin_fee", comment: ""))
							.font(.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)

						Spacer()

						Text("\(biayaAdmin.numberString.toCurrency())")
							.font(.custom(FontManager.Montserrat.bold, size: 16))
							.foregroundColor(.black)
					}

					Divider()
						.padding(.vertical)

					HStack {
						Text(NSLocalizedString("total_balance_withheld", comment: ""))
							.font(.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)

						Spacer()

						Text("\(total.numberString.toCurrency())")
							.font(.custom(FontManager.Montserrat.bold, size: 16))
							.foregroundColor(.black)
					}
					.padding(.bottom)

					HStack(spacing: 15) {
						Button(action: {
							isPresent.toggle()
						}, label: {
							HStack {
								Spacer()
								Text(NSLocalizedString("cancel", comment: ""))
									.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
									.foregroundColor(.black)
								Spacer()
							}
							.padding()
							.background(Color("btn-color-1"))
							.cornerRadius(8)
							.overlay(
								RoundedRectangle(cornerRadius: 8)
									.stroke(Color("btn-stroke-1"), lineWidth: 1.0)
							)
						})

						Button(action: {
							if let dataBank = bankAccVM.data?.first {
								withdrawVM.withdraw(
									params: WithdrawParams(
										amount: Int(inputAmount ?? 0.0),
										bankId: dataBank.bank?.id ?? 0,
										accountName: dataBank.accountName ?? "",
										accountNumber: dataBank.accountNumber ?? ""
									)
								)

								isPresent.toggle()
							}
						}, label: {
							HStack {
								Spacer()
								Text(NSLocalizedString("withdraw_balance", comment: ""))
									.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
									.foregroundColor(.white)
								Spacer()
							}
							.padding()
							.background(Color("btn-stroke-1"))
							.cornerRadius(8)
						})
					}
				}
			})
			
			LoadingView(isAnimating: $withdrawVM.isLoading)
				.isHidden(
					!withdrawVM.isLoading,
					remove: !withdrawVM.isLoading
				)
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct TalentWithdrawView_Previews: PreviewProvider {
	static var previews: some View {
		TalentWithdrawView()
	}
}
