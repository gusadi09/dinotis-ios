//
//  UserInvoiceBookingView.swift
//  DinotisApp
//
//  Created by Gus Adi on 09/09/21.
//

import SwiftUI
import SwiftKeychainWrapper
import CurrencyFormatter
import DinotisDesignSystem
import SwiftUINavigation

struct UserInvoiceBookingView: View {
	@Environment(\.presentationMode) var presentationMode
	
	@ObservedObject var viewModel: InvoicesBookingViewModel
	
	var body: some View {
		ZStack(alignment: .top) {
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.userScheduleDetail,
                destination: { viewModel in
                    UserScheduleDetail(
                        viewModel: viewModel.wrappedValue
                    )
                },
                onNavigate: {_ in},
                label: {
                    EmptyView()
                }
            )
            
			Image.Dinotis.userTypeBackground
				.resizable()
				.edgesIgnoringSafeArea(.all)
			
			VStack(alignment: .center) {

				if let isInvoiceDataFailed = viewModel.bookingData?.isFailed {
					HeaderView(
						type: .textHeader,
						title: LocalizableText.invoiceLabel,
						headerColor: .clear,
						textColor: .black,
						leadingButton:  {
							if isInvoiceDataFailed {
								DinotisElipsisButton(
									icon: .generalBackIcon,
									iconColor: .DinotisDefault.black1,
									bgColor: .DinotisDefault.white,
									strokeColor: nil,
									iconSize: 12,
									type: .primary, {
										self.viewModel.backToHome()
									}
								)
								.shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 0)

							} else {
								EmptyView()
							}
						}
					)
				}

				ScrollView(.vertical, showsIndicators: false) {
					VStack(alignment: .leading) {

						HStack {

							Spacer()

							if let isInvoiceDataFailed = viewModel.bookingData?.isFailed {
								if isInvoiceDataFailed {
									VStack(alignment: .center, spacing: 15) {
										Image.paymentFailed
											.resizable()
											.scaledToFit()
											.frame(height: 220)

										Text(LocalizableText.invoiceFailedPayment)
											.font(.robotoBold(size: 20))
											.foregroundColor(.DinotisDefault.red)
									}

								} else {
									VStack(alignment: .center, spacing: 15) {
										Image.Dinotis.paymentSuccessImage
											.resizable()
											.scaledToFit()
											.frame(height: 213)

										Text(LocaleText.paymentSuccessfulLabel)
											.font(.robotoBold(size: 20))
											.foregroundColor(.DinotisDefault.primary)
									}
								}
							}

							Spacer()
						}
						.padding(.bottom, 15)

						VStack(alignment: .leading, spacing: 10) {
							VStack(alignment: .leading, spacing: 3) {
								Text(LocaleText.invoiceNumberTitle)
									.font(.robotoRegular(size: 12))

								Text((viewModel.bookingData?.invoiceId).orEmpty())
									.font(.robotoBold(size: 14))
							}

							VStack(alignment: .leading, spacing: 3) {
								Text(LocalizableText.invoiceItemName)
									.font(.robotoRegular(size: 12))

								Text((viewModel.bookingData?.meeting?.title).orEmpty())
									.font(.robotoBold(size: 14))
							}

							VStack(alignment: .leading, spacing: 5) {
								Text(LocaleText.paymentMethodText)
									.font(.robotoRegular(size: 12))

								if let paymentName = viewModel.bookingData?.bookingPayment?.paymentMethod?.name {
									Text(paymentName)
										.font(.robotoBold(size: 14))
								}
							}

							VStack(alignment: .leading, spacing: 5) {
								Text(LocaleText.totalPaymentText)
									.font(.robotoRegular(size: 12))
                                
                                if let price = viewModel.bookingData?.bookingPayment?.amount {
                                    Text(price.toCurrency())
                                        .font(.robotoBold(size: 14))
                                }
                            }
                        }

						Button(action: {
							if (viewModel.bookingData?.isFailed ?? false) {
								viewModel.backToChoosePayment()
							} else {
                                if (viewModel.bookingData?.meetingBundle == nil) {
                                    viewModel.routeToDetailSchedule()
                                } else {
                                    viewModel.backToHome()
                                }
							}
						}, label: {
							HStack {
								Spacer()
                                Text((viewModel.bookingData?.isFailed ?? false) ? LocalizableText.generalOrderAgain : LocalizableText.doneLabel)
									.font(.robotoBold(size: 12))
									.foregroundColor(.white)
								Spacer()
							}
							.padding(.vertical, 15)
							.background(Color.DinotisDefault.primary)
							.cornerRadius(8)
						})
						.padding(.top, 25)

					}
					.buttonStyle(.plain)
					.padding()
				}
				.refreshable {
					await viewModel.getBookingById()
				}
			}

			DinotisLoadingView(hide: !viewModel.isLoading)
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
		.onAppear {
			viewModel.onGetBookingDetail()
		}
	}
}

struct UserInvoiceBookingView_Previews: PreviewProvider {
	static var previews: some View {
        UserInvoiceBookingView(viewModel: InvoicesBookingViewModel(bookingId: "", backToRoot: {}, backToHome: {}, backToChoosePayment: {}))
	}
}
