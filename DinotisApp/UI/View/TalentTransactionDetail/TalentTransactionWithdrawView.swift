//
//  TalentTransactionWithdrawView.swift
//  DinotisApp
//
//  Created by Gus Adi on 09/09/21.
//

import SwiftUI
import SwiftUITrackableScrollView
import CurrencyFormatter
import SwiftKeychainWrapper

struct TalentTransactionWithdrawView: View {
	@State var colorTab = Color.clear
	@State var contentOffset: CGFloat = 0
	
	@State var process = -1
	
	@Binding var data: BalanceDetails?
	
	@Environment(\.presentationMode) var presentationMode
	
	@ObservedObject var withdrawVM = WithdrawViewModel.shared
	
	@State var accessToken: String = KeychainWrapper.standard.string(forKey: "auth.accessToken") ?? ""
	
	@State var refreshToken: String = KeychainWrapper.standard.string(forKey: "auth.refreshToken") ?? ""
	
	@State var isShowConnection = false
	
	@ObservedObject var usersVM = UsersViewModel.shared
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
						
						Text(NSLocalizedString("withdraw", comment: ""))
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
					VStack {
						VStack(alignment: .leading) {
							HStack {
								Image("ic-withdraw-talent")
									.resizable()
									.scaledToFit()
									.frame(height: 40)
								
								VStack(alignment: .leading, spacing: 5) {
									Text(NSLocalizedString("withdraw", comment: ""))
										.font(.custom(FontManager.Montserrat.bold, size: 14))
										.foregroundColor(.black)
									
									if let dateISO = (data?.createdAt)?.toDate(format: .utc), let dateStr = dateISO.toString(format: .EEEEddMMMMyyyy) {
										Text(dateStr)
											.font(.custom(FontManager.Montserrat.regular, size: 12))
											.foregroundColor(.black)
									}
								}
								
								Spacer()
								
								Text("- \((data?.amount?.numberString).orEmpty().toCurrency())")
									.font(Font.custom(FontManager.Montserrat.bold, size: 14))
									.foregroundColor(.black)
							}
							
							Divider()
								.padding(.vertical, 10)
							
							HStack {
								VStack(alignment: .leading, spacing: 20) {
									
									HStack(spacing: 10) {
										Image("ic-debit-card")
											.resizable()
											.scaledToFit()
											.frame(height: 32)
										
										VStack(alignment: .leading, spacing: 5) {
											Text(NSLocalizedString("bank_name", comment: ""))
												.font(.custom(FontManager.Montserrat.regular, size: 12))
												.foregroundColor(.black)
											
											Text(withdrawVM.dataDetail?.bankAccount?.accountNumber ?? "")
												.font(.custom(FontManager.Montserrat.bold, size: 14))
												.foregroundColor(.black)
										}
									}
									
									HStack(spacing: 10) {
										Image("ic-people-circle")
											.resizable()
											.scaledToFit()
											.frame(height: 32)
										
										VStack(alignment: .leading, spacing: 5) {
											Text(NSLocalizedString("account_name", comment: ""))
												.font(.custom(FontManager.Montserrat.regular, size: 12))
												.foregroundColor(.black)
											
											Text(withdrawVM.dataDetail?.bankAccount?.accountName ?? "")
												.font(.custom(FontManager.Montserrat.bold, size: 14))
												.foregroundColor(.black)
										}
									}
									
									HStack(spacing: 10) {
										Image("ic-calendar")
											.resizable()
											.scaledToFit()
											.frame(height: 32)
										
										VStack(alignment: .leading, spacing: 5) {
											Text(NSLocalizedString("withdrawal_date", comment: ""))
												.font(.custom(FontManager.Montserrat.regular, size: 12))
												.foregroundColor(.black)
											
											if let dateISO = (data?.withdraw?.createdAt).orEmpty().toDate(format: .utc), let date = dateISO.toString(format: .EEEEddMMMMyyyy) {
												Text(date)
													.font(.custom(FontManager.Montserrat.bold, size: 14))
													.foregroundColor(.black)
											}
										}
									}
									
									HStack(spacing: 10) {
										Image("ic-clock")
											.resizable()
											.scaledToFit()
											.frame(height: 32)
										
										VStack(alignment: .leading, spacing: 5) {
											Text(NSLocalizedString("withdrawal_time", comment: ""))
												.font(.custom(FontManager.Montserrat.regular, size: 12))
												.foregroundColor(.black)
											
											if let timeISO = (data?.withdraw?.createdAt)?.toDate(format: .utc), let time = timeISO.toString(format: .HHmm) {
												Text(time)
													.font(.custom(FontManager.Montserrat.bold, size: 14))
													.foregroundColor(.black)
											}
										}
									}
								}
								
								Spacer()
							}
							.padding(.bottom, 15)
							
							if data?.withdraw?.doneAt == nil && !(data?.withdraw?.isFailed ?? true) {
								HStack {
									Spacer()
									
									Text(NSLocalizedString("in_process", comment: ""))
										.font(.custom(FontManager.Montserrat.semibold, size: 12))
									
									Spacer()
								}
								.padding()
								.background(Color("btn-color-1"))
								.cornerRadius(8)
								.overlay(
									RoundedRectangle(cornerRadius: 8).stroke(Color("btn-stroke-1"), lineWidth: 1.0)
								)
							} else if data?.withdraw?.doneAt != nil {
								HStack {
									Spacer()
									
									Text(NSLocalizedString("success", comment: ""))
										.font(.custom(FontManager.Montserrat.semibold, size: 12))
									
									Spacer()
								}
								.padding()
								.background(Color("color-green-complete"))
								.cornerRadius(8)
								.overlay(
									RoundedRectangle(cornerRadius: 8).stroke(Color("color-green-stroke"), lineWidth: 1.0)
								)
							} else if data?.withdraw?.isFailed ?? true {
								HStack {
									Spacer()
									
									Text(NSLocalizedString("fail", comment: ""))
										.font(.custom(FontManager.Montserrat.semibold, size: 12))
									
									Spacer()
								}
								.padding()
								.background(Color("color-red-failed"))
								.cornerRadius(8)
								.overlay(
									RoundedRectangle(cornerRadius: 8).stroke(Color("color-red-stroke"), lineWidth: 1.0)
								)
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
					.onAppear {
						withdrawVM.withdrawDetail(withdrawId: data?.withdraw?.id ?? "")
					}
				}
			}
			.edgesIgnoringSafeArea(.vertical)
			
			LoadingView(isAnimating: $withdrawVM.isLoading)
				.isHidden(
					withdrawVM.isLoading ?
					false : true,
					remove: withdrawVM.isLoading ?
					false : true
				)
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}
