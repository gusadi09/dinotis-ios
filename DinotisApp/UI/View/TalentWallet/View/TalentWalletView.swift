//
//  TalentWalletView.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/08/21.
//

import SwiftUI
import CurrencyFormatter
import SwiftKeychainWrapper
import OneSignal

struct TalentWalletView: View {
	
	@ObservedObject var viewModel: TalentWalletViewModel
	@ObservedObject var stateObservable = StateObservable.shared
	
	@State var selectedTab = 0
	@State var goToAddBank = false
	
	@State var goToWithdraw = false
	
	@State var isGoToPendapatan = false
	@State var isGoToPenarikan = false
	
	@State var connection = false
	
	@State var selectionHistory: BalanceDetails?
	
	@Environment(\.presentationMode) var presentationMode
	
	@State var accessToken: String = KeychainWrapper.standard.string(forKey: "auth.accessToken") ?? ""
	
	@State var refreshToken: String = KeychainWrapper.standard.string(forKey: "auth.refreshToken") ?? ""
	
	@ObservedObject var userVM = UsersViewModel.shared
	@ObservedObject var bankAccVM = BankAccountViewModel.shared
	
	@State var isGoToDetail = false
	
	@State var isLoading = false
	
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	var body: some View {
		ZStack(alignment: .top) {
			Image("user-type-bg")
				.resizable()
				.edgesIgnoringSafeArea(.all)
			
			VStack(spacing: 0) {
				ZStack {
					HStack {
						Spacer()
						Text(NSLocalizedString("purse", comment: ""))
							.font(Font.custom(FontManager.Montserrat.bold, size: 14))
							.foregroundColor(.black)
						
						Spacer()
					}
					.padding()
					HStack {
						Button(action: {
							presentationMode.wrappedValue.dismiss()
						}, label: {
							Image("ic-chevron-back")
								.padding()
								.background(Color.white)
								.clipShape(Circle())
						})
						.padding(.leading)
						
						Spacer()
					}
					
				}
				.padding(.top, 5)
				.alert(isPresented: $bankAccVM.isRefreshFailed) {
					Alert(
						title: Text(NSLocalizedString("attention", comment: "")),
						message: Text(NSLocalizedString("session_expired", comment: "")),
						dismissButton: .default(Text(NSLocalizedString("return", comment: "")), action: {
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
					HStack(spacing: 15) {
						Image("ic-btn-wallet")
							.resizable()
							.scaledToFit()
							.frame(height: 44)
						
						VStack(alignment: .leading, spacing: 8) {
							Text(NSLocalizedString("wallet_balance", comment: ""))
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.foregroundColor(.black)
							
							Text(userVM.currentBalances.numberString.toCurrency())
								.font(Font.custom(FontManager.Montserrat.bold, size: 18))
								.foregroundColor(.black)
						}
						
						Spacer()
					}
					
					HStack {
						if bankAccVM.data?.isEmpty ?? true {
							Image("ic-debit-card")
								.resizable()
								.scaledToFit()
								.frame(height: 24)
							
							Text(NSLocalizedString("add_account", comment: ""))
								.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
								.foregroundColor(.black)
							
						} else {
							VStack(alignment: .leading, spacing: 10) {
								HStack {
									Text("\(bankAccVM.data?.first?.bank?.name ?? "") \u{2022} \(bankAccVM.data?.first?.accountName ?? "")")
										.font(Font.custom(FontManager.Montserrat.regular, size: 12))
										.foregroundColor(.black)
										.fixedSize(horizontal: false, vertical: true)
								}
								
								Text(bankAccVM.data?.first?.accountNumber ?? "")
									.font(Font.custom(FontManager.Montserrat.bold, size: 14))
									.foregroundColor(.black)
							}
						}
						
						Spacer()
						
						Button(action: {
							goToAddBank.toggle()
						}, label: {
							Image(bankAccVM.data?.isEmpty ?? false ? "ic-plus" : "ic-pencil")
								.resizable()
								.scaledToFit()
								.frame(height: 12)
								.padding(10)
								.background(Color("btn-stroke-1"))
								.clipShape(Circle())
						})
						
						NavigationLink(
							destination: TalentAddBankAccountView(
								dataBank: .constant(
									bankAccVM.data?.first ??
									BankAccount(
										id: 0,
										accountName: "",
										accountNumber: "",
										bankId: 0,
										userId: "",
										createdAt: "",
										updatedAt: "",
										bank: nil
									)
								)
							),
							isActive: $goToAddBank,
							label: {
								EmptyView()
							})
					}
					.padding(.horizontal, 15)
					.padding(.vertical, 10)
					.background(Color(.lightGray).opacity(0.1))
					.cornerRadius(12)
					.padding(.top)
					.padding(.bottom, 5)
					
					(Text("\(NSLocalizedString("fee_info", comment: "")) ")
						.font(Font.custom(FontManager.Montserrat.regular, size: 12))
						.foregroundColor(.black) + Text("Rp5.500")
						.font(Font.custom(FontManager.Montserrat.bold, size: 12))
						.foregroundColor(.black))
					.fixedSize(horizontal: true, vertical: false)
					.multilineTextAlignment(.leading)
					.valueChanged(value: bankAccVM.isSuccessGet, onChange: { value in
						DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
							withAnimation(.spring()) {
								if value {
									self.isLoading = false
								}
							}
						})
					})
					.valueChanged(value: bankAccVM.isLoading) { value in
						DispatchQueue.main.async {
							withAnimation(.spring()) {
								if value {
									self.isLoading = true
								}
							}
						}
					}
					
					Button(action: {
						DispatchQueue.main.async {
							goToWithdraw.toggle()
						}
					}, label: {
						HStack {
							Spacer()
							
							Text(NSLocalizedString("withdraw_balance", comment: ""))
								.font(Font.custom(FontManager.Montserrat.bold, size: 12))
								.foregroundColor(.white)
								.padding(.vertical, 15)
							
							Spacer()
						}
						.background(Color("btn-stroke-1"))
						.cornerRadius(8)
					})
					.padding(.top, 15)
					.isHidden(bankAccVM.data?.isEmpty ?? true ? true : false, remove: bankAccVM.data?.isEmpty ?? true ? true : false)
					
					NavigationLink(
						destination: TalentWithdrawView(),
						isActive: $goToWithdraw,
						label: {
							EmptyView()
						})
				}
				.padding()
				.background(Color.white)
				.cornerRadius(12)
				.shadow(color: Color("dinotis-shadow-1").opacity(0.08), radius: 10, x: 0.0, y: 0.0)
				.padding()
				
				VStack(spacing: 0) {
					
					TopBarView(
						selected: $selectedTab,
						sectionTitle1: .constant(NSLocalizedString("all", comment: "")),
						sectionTitle2: .constant(NSLocalizedString("revenue", comment: "")),
						sectionTitle3: .constant(NSLocalizedString("withdraw", comment: ""))
					)
					
					if let dataHistory = bankAccVM.dataHistory?.balanceDetails?.filter({ value in
						if selectedTab == 0 {
							return true
						} else if selectedTab == 1 {
							return value.isOut == false
						} else {
							return value.isOut == true
						}
					}) {
						if dataHistory.isEmpty {
							RefreshableScrollView(action: refreshHistory) {
								if isLoading {
									ActivityIndicator(isAnimating: $isLoading, color: .black, style: .medium)
										.padding()
								}
								
								VStack(alignment: .center, spacing: 15) {
									Spacer()
									
									HStack {
										Spacer()
										
										Image("logout-img")
											.resizable()
											.scaledToFit()
											.frame(height: 110)
										
										Spacer()
									}
									
									HStack {
										Spacer()
										
										Text(NSLocalizedString("history_trans_empty", comment: ""))
											.font(.custom(FontManager.Montserrat.medium, size: 14))
											.multilineTextAlignment(.center)
										
										Spacer()
									}
									
									Spacer()
								}
								.padding(.horizontal)
							}
							.background(
								Color.white
							)
							
						} else {
							List(dataHistory, id: \.id) { items in
								TalentTransactionCard(data: .constant(items))
									.padding(.top, 15)
									.padding(.bottom, 10)
									.onTapGesture(perform: {
										if items.isOut ?? true {
											isGoToPenarikan.toggle()
											selectionHistory = items
										}
									})
							}
							.listStyle(PlainListStyle())
							.background(
								Color.white
							)
						}
					}
					
					NavigationLink(
						destination: TalentTransactionFeeView(data: $selectionHistory),
						isActive: $isGoToPendapatan,
						label: {
							EmptyView()
						})
					
					NavigationLink(
						destination: TalentTransactionWithdrawView(data: $selectionHistory),
						isActive: $isGoToPenarikan,
						label: {
							EmptyView()
						})
				}
				.edgesIgnoringSafeArea(.bottom)
			}
			.onAppear {
				userVM.currentBalance()
				bankAccVM.getBankAcc()
				bankAccVM.getHistory()
			}
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
	
	private func refreshHistory() {
		bankAccVM.getHistory()
	}
}

struct TalentWalletView_Previews: PreviewProvider {
	static var previews: some View {
		TalentWalletView(viewModel: TalentWalletViewModel(backToRoot: {}, backToHome: {}))
	}
}
