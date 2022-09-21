//
//  InvoiceView.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/09/21.
//

import SwiftUI
import SwiftUITrackableScrollView
import SDWebImageSwiftUI
import CurrencyFormatter
import SwiftKeychainWrapper
import SwiftUINavigation
import OneSignal

struct DetailPaymentView: View {
	@State var contentOffset: CGFloat = 0
	@State var colorTab = Color.clear
	
	@State var selected = false
	@State var selectItem: Int?
	
	@State var selectItem2: Int?
	
	@State var isGoToInvoiceBerhasil = false
	
	@State var isGoToHomeUser = false
	@State var isGoToHomeTalent = false
	
	@State var selectedTab = 0
	
	@Binding var methodId: Int
	
	@State var isErrorShow = false
	
	@Binding var price: Int
	
	@ObservedObject var stateObservable = StateObservable.shared
	
	@ObservedObject var invoiceVM = InvoiceViewModel.shared
	@ObservedObject var viewModel: DetailPaymentViewModel
	
	@ObservedObject var bookingVM = UserBookingViewModel.shared
	
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	@Environment(\.presentationMode) var presentationMode
	
	@State var isShowConnection = false
	
	@ObservedObject var usersVM = UsersViewModel.shared
	
	@State var isLoading = false
	
	var body: some View {
		ZStack {
			Image("user-type-bg")
				.resizable()
				.edgesIgnoringSafeArea(.all)
			
			VStack(spacing: 0) {
				VStack(spacing: 0) {
					Color.white
						.frame(height: 20)
					
					HStack {
						Button(action: {
							viewModel.backToHome()
						}, label: {
							Image("ic-chevron-back")
								.padding()
								.background(Color.white)
								.clipShape(Circle())
						})
						
						Spacer()
						
						Text(NSLocalizedString("complete_payment", comment: ""))
							.font(.custom(FontManager.Montserrat.bold, size: 14))
							.padding(.horizontal)
						
						Spacer()
						Spacer()
					}
					.padding()
					.background(Color.white)
					.alert(isPresented: $invoiceVM.isRefreshFailed) {
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
				}
				
				RefreshableScrollView(action: refreshInvoice) {
					if isLoading {
						ActivityIndicator(isAnimating: $isLoading, color: .black, style: .medium)
							.padding(.top)
					}
					
					VStack {
						VStack(alignment: .leading) {
							HStack {
								Text(viewModel.methodName)
									.font(.custom(FontManager.Montserrat.bold, size: 14))
									.foregroundColor(.black)
								
								Spacer()
								
								AnimatedImage(url: URL(string: viewModel.methodIcon)!)
									.resizable()
									.scaledToFit()
									.frame(height: 30)
							}
							
							Divider()
								.padding(.vertical)
							
							VStack(alignment: .leading, spacing: 15) {
								VStack(alignment: .leading, spacing: 5) {
									Text(NSLocalizedString("no_invoice", comment: ""))
										.font(.custom(FontManager.Montserrat.regular, size: 12))
										.foregroundColor(.black)
									
									Text(viewModel.bookingId)
										.font(.custom(FontManager.Montserrat.bold, size: 14))
										.foregroundColor(.black)
								}
								
								if !viewModel.isQR && !viewModel.isEwallet {
									VStack(alignment: .leading, spacing: 5) {
										Text(NSLocalizedString("no_virtual_account", comment: ""))
											.font(.custom(FontManager.Montserrat.regular, size: 12))
											.foregroundColor(.black)
										
										HStack {
											if let number = invoiceVM.data?.number {
												Text(number)
													.font(.custom(FontManager.Montserrat.bold, size: 14))
													.foregroundColor(.black)
												
												Spacer()
												
												Button(action: {
													UIPasteboard.general.string = number
												}, label: {
													Text(NSLocalizedString("copy", comment: ""))
														.font(.custom(FontManager.Montserrat.bold, size: 12))
														.foregroundColor(Color("btn-stroke-1"))
												})
											}
										}
									}
								}
								
								VStack(alignment: .leading, spacing: 5) {
									Text(NSLocalizedString("total_payment", comment: ""))
										.font(.custom(FontManager.Montserrat.regular, size: 12))
										.foregroundColor(.black)
									
									if let doublePrice = String(price).toCurrency() {
										Text(doublePrice)
											.font(.custom(FontManager.Montserrat.bold, size: 14))
											.foregroundColor(.black)
									}
								}
								
								if viewModel.isEwallet {
									Button {
										self.viewModel.backToHome()
										if let url = URL(string: viewModel.redirectUrl.orEmpty()) {
											UIApplication.shared.open(url, options: [:])
										}
									} label: {
										HStack {
											Spacer()
											
											Text(LocaleText.payNowText)
												.foregroundColor(.white)
												.font(.montserratSemiBold(size: 12))
											
											Spacer()
										}
										.padding()
										.background(
											RoundedRectangle(cornerRadius: 10)
												.foregroundColor(.primaryViolet)
										)
									}
									
								} else if viewModel.isQR {
									
									Image.base64Image(with: viewModel.qrCodeUrl.orEmpty())
										.resizable()
										.scaledToFit()
										.frame(height: 250)
										.padding(5)
										.overlay(
											RoundedRectangle(cornerRadius: 15)
												.stroke(Color(.systemGray3), lineWidth: 1.5)
										)
									
									VStack(spacing: 10) {
										HStack {
											Text(LocaleText.howToPayTitle)
												.font(.montserratBold(size: 14))
												.foregroundColor(.black)
											
											Spacer()
										}
										
										HStack {
											Text(LocaleText.howToPayFirstText)
												.font(.montserratRegular(size: 12))
												.multilineTextAlignment(.leading)
												.foregroundColor(.black)
											
											Spacer()
										}
										
										HStack {
											Text(LocaleText.howToPaySecondText)
												.font(.montserratRegular(size: 12))
												.multilineTextAlignment(.leading)
												.foregroundColor(.black)
											
											Spacer()
										}
										
										HStack {
											Text(LocaleText.howToPayThirdText)
												.font(.montserratRegular(size: 12))
												.multilineTextAlignment(.leading)
												.foregroundColor(.black)
											
											Spacer()
										}
										
										HStack {
											Text(LocaleText.howToPayFourthText)
												.font(.montserratRegular(size: 12))
												.multilineTextAlignment(.leading)
												.foregroundColor(.black)
											
											Spacer()
										}
									}
									.padding(.vertical, 5)
								}
								
								HStack {
									Text(NSLocalizedString("complete_payment_before", comment: ""))
										.font(.custom(FontManager.Montserrat.regular, size: 12))
										.foregroundColor(.black)
									
									Spacer()
									
									if let expired = (invoiceVM.data?.expiredAt).orEmpty().toDate(format: .utcV2),
										 let isoDate = expired.toString(format: .HHmm) {
										Text("\(isoDate)")
											.font(.custom(FontManager.Montserrat.bold, size: 12))
											.foregroundColor(.black)
									} else if let anotherExp = bookingVM.data?.data.filter({ value in
										value.bookingPayment.bookingID == viewModel.bookingId
									}).first?.createdAt,
														let expDate = anotherExp.toDate(format: .utcV2)?.addingTimeInterval(1800),
														let hour = expDate.toString(format: .HHmm) {
										Text("\(hour)")
											.font(.custom(FontManager.Montserrat.bold, size: 12))
											.foregroundColor(.black)
									}
								}
								.padding(10)
								.background(Color("btn-color-1"))
								.cornerRadius(5)
								
								if viewModel.methodName.contains("QRIS") {
									HStack {
										Text(LocaleText.attentionQrisText)
											.font(.montserratRegular(size: 12))
											.foregroundColor(.black)
										
										Spacer()
									}
									.padding()
									.background(
										RoundedRectangle(cornerRadius: 8)
											.foregroundColor(Color(.systemGray3))
									)
								}
							}
						}
						.padding()
						.background(Color.white)
						.clipShape(RoundedRectangle(cornerRadius: 12))
						.shadow(color: Color("dinotis-shadow-1").opacity(0.1), radius: 10, x: 0.0, y: 0.0)
						.padding()
						.alert(isPresented: $isErrorShow) {
							Alert(
								title: Text(NSLocalizedString("error", comment: "")),
								message: Text((invoiceVM.error?.errorDescription).orEmpty()),
								dismissButton: .default(Text(NSLocalizedString("return", comment: "")))
							)
						}
						.valueChanged(value: invoiceVM.success, onChange: { value in
							DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
								withAnimation(.spring()) {
									if value {
										self.isLoading = false
									}
								}
							})
						})
						.valueChanged(value: invoiceVM.isLoading) { value in
							DispatchQueue.main.async {
								withAnimation(.spring()) {
									if value {
										self.isLoading = true
									}
								}
							}
						}
						
						Spacer()
						
						NavigationLink(
							unwrapping: $viewModel.route,
							case: /HomeRouting.bookingInvoice,
							destination: { viewModel in
								UserInvoiceBookingView(
									bookingId: self.viewModel.bookingId,
									viewModel: viewModel.wrappedValue
								)
							},
							onNavigate: {_ in},
							label: {
								EmptyView()
							}
						)
						
						if let instructionData = invoiceVM.instruction {
							VStack(spacing: 0) {
								TopBarInstructionView(
									selected: $selectedTab,
									instruction: .constant(
										instructionData
									),
									virtualNumber: .constant(invoiceVM.data?.number ?? "")
								)
								
								ScrollView(.vertical, showsIndicators: false, content: {
									ForEach((instructionData.instructions?[selectedTab].instruction ?? []).indices, id: \.self) { item in
										HStack {
											Text("\(item+1)")
												.font(.custom(FontManager.Montserrat.medium, size: 13))
												.padding(10)
												.overlay(
													Circle()
														.stroke(Color("btn-stroke-1"), lineWidth: 1.5)
												)
											
											Text(
												LocalizedStringKey(
													(instructionData
														.instructions?[selectedTab]
														.instruction?[item] ?? "")
													.replacingOccurrences(
														of: "${number}",
														with: invoiceVM.data?.number ?? ""
													)
												)
												
											)
											.font(.custom(FontManager.Montserrat.regular, size: 13))
											
											Spacer()
										}
										.padding(.horizontal)
									}
									.padding(.vertical)
								})
							}
							.background(Color.white)
							.clipShape(RoundedRectangle(cornerRadius: 10))
							.padding()
						}
					}
					.valueChanged(value: bookingVM.success, onChange: { value in
						if value {
							if let data = bookingVM.data?.data {
								for item in data.filter({ value in
									value.bookingPayment.bookingID == viewModel.bookingId
								}) where item.bookingPayment.paidAt != nil {
									isGoToInvoiceBerhasil.toggle()
								}
							}
						}
					})
					.valueChanged(value: invoiceVM.isError) { value in
						if value {
							isErrorShow.toggle()
							
						}
					}
				}
			}
			.edgesIgnoringSafeArea(.vertical)
			.onAppear {
				if !(viewModel.methodName.contains("Shopeepay") || viewModel.methodName.contains("QRIS") || viewModel.methodName.contains("Gopay")) {
					invoiceVM.getInvoice(by: viewModel.bookingId)
					
					invoiceVM.getInstruction(
						methodId: methodId == 0 ?
						bookingVM.data?.data.filter({ value in
							value.bookingPayment.bookingID == viewModel.bookingId
						}).first?.bookingPayment.paymentMethod?.id ?? 0 :
							methodId
					)
				}
				
				bookingVM.getBookings()
			}
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
	
	private func refreshInvoice() {
		if !(viewModel.methodName.contains("Shopeepay") || viewModel.methodName.contains("QRIS")) {
			invoiceVM.getInvoice(by: viewModel.bookingId)
			
			invoiceVM.getInstruction(methodId: methodId == 0 ? bookingVM.data?.data.filter({ value in
				value.bookingPayment.bookingID == viewModel.bookingId
			}).first?.bookingPayment.paymentMethod?.id ?? 0 : methodId)
		}
		
		bookingVM.getBookings()
		
	}
}

struct InvoiceView_Previews: PreviewProvider {
	static var previews: some View {
		DetailPaymentView(
			methodId: .constant(0),
			price: .constant(0),
			viewModel: DetailPaymentViewModel(
				backToRoot: {},
				backToHome: {},
				methodName: "",
				methodIcon: "",
				redirectUrl: nil,
				qrCodeUrl: nil,
				bookingId: "",
				isQR: false,
				isEwallet: false
			)
		)
	}
}
