//
//  TalentWalletView.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/08/21.
//

import DinotisDesignSystem
import OneSignal
import SwiftUI
import SwiftUINavigation

struct TalentWalletView: View {
	
	@ObservedObject var viewModel: TalentWalletViewModel
	
	@Environment(\.presentationMode) var presentationMode
	
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	var body: some View {
		ZStack(alignment: .top) {
			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.addBankAccount,
				destination: { viewModel in
					TalentAddBankAccountView(viewModel: viewModel.wrappedValue)
				},
				onNavigate: { _ in },
				label: {
					EmptyView()
				}
			)

			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.withdrawTransactionDetail,
				destination: { viewModel in
					TalentTransactionWithdrawView(viewModel: viewModel.wrappedValue)
				},
				onNavigate: { _ in },
				label: {
					EmptyView()
				}
			)

			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.withdrawBalance,
				destination: { viewModel in
					TalentWithdrawView(viewModel: viewModel.wrappedValue)
				},
				onNavigate: { _ in },
				label: {
					EmptyView()
				}
			)

			LinearGradient(colors: [.secondaryViolet, .white, .white], startPoint: .top, endPoint: .bottom)
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
				ZStack {
					HStack {
						Spacer()
						Text(LocaleText.walletText)
							.font(.robotoBold(size: 14))
							.foregroundColor(.black)
						
						Spacer()
					}
					.padding()

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
					
				}
				.padding(.top, 5)
				.alert(isPresented: $viewModel.isError) {
					Alert(
						title: Text(LocaleText.attention),
						message: Text(viewModel.error.orEmpty()),
						dismissButton: .default(Text(LocaleText.returnText))
					)
				}
				
				VStack {
					HStack(spacing: 15) {
						Image.Dinotis.walletButtonIcon
							.resizable()
							.scaledToFit()
							.frame(height: 44)
						
						VStack(alignment: .leading, spacing: 8) {
							Text(LocaleText.walletBalance)
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)
							
							Text(viewModel.currentBalances.toCurrency())
								.font(.robotoBold(size: 18))
								.foregroundColor(.black)
								.multilineTextAlignment(.leading)
						}
						
						Spacer()
					}
					
					HStack {
						if viewModel.bankData.isEmpty {
							Image.Dinotis.handPickedDebitCardIcon
								.resizable()
								.scaledToFit()
								.frame(height: 24)
							
							Text(LocaleText.addAccountText)
								.font(.robotoMedium(size: 12))
								.foregroundColor(.black)
							
						} else {
							VStack(alignment: .leading, spacing: 10) {
								HStack {
									Text("\((viewModel.bankData.first?.bank?.name).orEmpty()) \u{2022} \((viewModel.bankData.first?.accountName).orEmpty())")
										.font(.robotoRegular(size: 12))
										.foregroundColor(.black)
										.fixedSize(horizontal: false, vertical: true)
										.multilineTextAlignment(.leading)
								}
								
								Text((viewModel.bankData.first?.accountNumber).orEmpty())
									.font(.robotoBold(size: 14))
									.foregroundColor(.black)
							}
						}
						
						Spacer()
						
						Button(action: {
							viewModel.routeToAddBankAccount()
						}, label: {
							viewModel.addBankAccountIcon()
								.resizable()
								.scaledToFit()
								.frame(height: 12)
								.padding(10)
								.background(Color.DinotisDefault.primary)
								.clipShape(Circle())
						})

					}
					.padding(.horizontal, 15)
					.padding(.vertical, 10)
					.background(Color(.lightGray).opacity(0.1))
					.cornerRadius(12)
					.padding(.top)
					.padding(.bottom, 5)
					
					(
						Text("\(LocaleText.feeInfoText) ")
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
						+
						Text(5500.toCurrency())
							.font(.robotoBold(size: 12))
							.foregroundColor(.black)
					)
					.fixedSize(horizontal: true, vertical: false)
					.multilineTextAlignment(.leading)
					
					Button(action: {
						DispatchQueue.main.async {
							viewModel.routeToWithdrawal()
						}
					}, label: {
						HStack {
							Spacer()
							
							Text(LocaleText.withdrawBalance)
								.font(.robotoBold(size: 12))
								.foregroundColor(.white)
								.padding(.vertical, 15)
							
							Spacer()
						}
						.background(Color.DinotisDefault.primary)
						.cornerRadius(8)
					})
					.padding(.top, 15)
					.isHidden(
						viewModel.bankData.isEmpty,
						remove: viewModel.bankData.isEmpty
					)
				}
				.padding()
				.background(Color.white)
				.cornerRadius(12)
				.shadow(
					color: Color.dinotisShadow.opacity(0.08),
					radius: 10,
					x: 0.0,
					y: 0.0
				)
				.padding()
				
				VStack(spacing: 0) {
					
					TopBarView(
						selected: $viewModel.selectedTab,
						sectionTitle1: .constant(LocaleText.allText),
						sectionTitle2: .constant(LocaleText.revenueText),
						sectionTitle3: .constant(LocaleText.withdrawText)
					)
					
						DinotisList {
							viewModel.onAppear()
						} introspectConfig: { view in
							view.showsVerticalScrollIndicator = false
							viewModel.use(for: view) { refresh in
								viewModel.onAppear()
								refresh.endRefreshing()
							}
						} content: {
                            if viewModel.balanceDetailFilter().isEmpty {
								VStack(alignment: .center, spacing: 15) {
									Spacer()

									HStack {
										Spacer()

										Image.Dinotis.logoutImage
											.resizable()
											.scaledToFit()
											.frame(height: 110)

										Spacer()
									}

									HStack {
										Spacer()

										Text(LocaleText.historyTransactionEmptyTitle)
											.font(.robotoMedium(size: 14))
											.multilineTextAlignment(.center)

										Spacer()
									}

									Spacer()
								}
								.listRowBackground(Color.clear)
							} else {
								LazyVStack(spacing: 25) {
                                    ForEach(viewModel.balanceDetailFilter(), id: \.id) { items in
										TalentTransactionCard(data: .constant(items))
											.onTapGesture(perform: {
												if items.isOut ?? false {
													viewModel.routeToWithdrawDetail(id: (items.withdraw?.id).orEmpty())
												}
											})
									}
								}
								.padding(.vertical, 15)
								.listRowBackground(Color.clear)
							}
						}

				}
				.edgesIgnoringSafeArea(.bottom)
			}
            
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
		}
		.onAppear {
			viewModel.onAppear()
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct TalentWalletView_Previews: PreviewProvider {
	static var previews: some View {
		TalentWalletView(viewModel: TalentWalletViewModel(backToRoot: {}, backToHome: {}))
	}
}
