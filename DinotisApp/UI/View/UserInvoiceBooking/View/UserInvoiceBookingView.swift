//
//  UserInvoiceBookingView.swift
//  DinotisApp
//
//  Created by Gus Adi on 09/09/21.
//

import SwiftUI
import SwiftKeychainWrapper
import CurrencyFormatter

struct UserInvoiceBookingView: View {
	var bookingId: String
	
	@Environment(\.presentationMode) var presentationMode
	
	@ObservedObject var viewModel: InvoicesBookingViewModel
	
	var body: some View {
		ZStack(alignment: .top) {
			Image("user-type-bg")
				.resizable()
				.edgesIgnoringSafeArea(.all)
			
			VStack(alignment: .center) {
				
				Text(LocaleText.invoiceText)
					.font(.montserratBold(size: 14))
					.foregroundColor(.black)
					.padding()
				
				VStack(alignment: .leading) {
					
					Group {
						if let invoiceData = viewModel.bookingData?.isFailed {
							if invoiceData {
								VStack(spacing: 15) {
									Text(NSLocalizedString("payment_failed_card_text", comment: ""))
										.font(.custom(FontManager.Montserrat.bold, size: 14))
									
									Text(NSLocalizedString("payment_failed_sublabel", comment: ""))
										.font(.montserratRegular(size: 12))
										.multilineTextAlignment(.leading)
										.lineSpacing(5)
								}
								
							} else {
								VStack(alignment: .center, spacing: 15) {
									Image("payment-success-img")
										.resizable()
										.scaledToFit()
										.frame(height: 213)
									
									Text(NSLocalizedString("payment_successful!_label", comment: ""))
										.font(.custom(FontManager.Montserrat.bold, size: 14))
								}
							}
						}
					}
					
					Divider()
						.padding(.vertical, 10)
					
					VStack(alignment: .leading, spacing: 10) {
						VStack(alignment: .leading, spacing: 3) {
							Text(NSLocalizedString("no_invoice", comment: ""))
								.font(.custom(FontManager.Montserrat.regular, size: 12))
							
							Text(bookingId)
								.font(.custom(FontManager.Montserrat.bold, size: 14))
						}
						
						VStack(alignment: .leading, spacing: 5) {
							Text(NSLocalizedString("payment_method", comment: ""))
								.font(.custom(FontManager.Montserrat.regular, size: 12))
							
							if let paymentName = viewModel.bookingData?.bookingPayment.paymentMethod?.name {
								Text(paymentName)
									.font(.custom(FontManager.Montserrat.bold, size: 14))
							}
						}
						
						VStack(alignment: .leading, spacing: 5) {
							Text(NSLocalizedString("total_payment", comment: ""))
								.font(.custom(FontManager.Montserrat.regular, size: 12))
							
							if let price = viewModel.bookingData?.bookingPayment.amount {
								if let currencyPrice = price.toCurrency() {
									Text(currencyPrice)
										.font(.custom(FontManager.Montserrat.bold, size: 14))
								}
							}
						}
					}
					
					Button(action: {
						viewModel.backToHome()
					}, label: {
						HStack {
							Spacer()
							Text(LocaleText.backToHome)
								.font(.custom(FontManager.Montserrat.bold, size: 12))
								.foregroundColor(.white)
							Spacer()
						}
						.padding(.vertical, 10)
						.background(Color("btn-stroke-1"))
						.cornerRadius(8)
					})
					.padding(.top, 25)
					
				}
				.padding()
				.background(Color.white)
				.cornerRadius(12)
				.padding()
			}

			ZStack {
				Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)

				ProgressView()
					.progressViewStyle(CircularProgressViewStyle(tint: .white))
			}
			.opacity(viewModel.isLoading ? 1 : 0)
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
		.onAppear {
			viewModel.getBookingById(bookingId: bookingId)
		}
	}
}

struct UserInvoiceBookingView_Previews: PreviewProvider {
	static var previews: some View {
		UserInvoiceBookingView(bookingId: "", viewModel: InvoicesBookingViewModel(backToRoot: {}, backToHome: {}))
	}
}
