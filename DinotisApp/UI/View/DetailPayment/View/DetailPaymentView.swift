//
//  InvoiceView.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/09/21.
//

import SwiftUI
import SwiftUITrackableScrollView
import SDWebImageSwiftUI
import SwiftUINavigation
import DinotisDesignSystem
import DinotisData

//MARK: - Need Revamp
struct DetailPaymentView: View {
	
	@ObservedObject var stateObservable = StateObservable.shared
	
	@ObservedObject var viewModel: DetailPaymentViewModel
	
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	@Environment(\.dismiss) var dismiss
    
    @Binding var mainTabValue: TabRoute
	
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

			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.bookingInvoice,
				destination: { viewModel in
					UserInvoiceBookingView(
                        viewModel: viewModel.wrappedValue, mainTabValue: $mainTabValue
					)
				},
				onNavigate: {_ in},
				label: {
					EmptyView()
				}
			)
			
			VStack(spacing: 0) {
				VStack(spacing: 0) {
					Color.white
						.frame(height: 20)
					
					HStack {
						Button(action: {
							viewModel.backToHome()
						}, label: {
							Image.Dinotis.arrowBackIcon
								.padding()
								.background(Color.white)
								.clipShape(Circle())
						})
						
						Spacer()
						
						Text(LocaleText.completePaymentText)
							.font(.robotoBold(size: 14))
							.padding(.horizontal)
						
						Spacer()
						Spacer()
					}
					.padding()
					.background(Color.white)
					.alert(isPresented: $viewModel.isError) {
						Alert(
							title: Text(LocaleText.attention),
							message: Text(viewModel.error.orEmpty()),
							dismissButton: .default(Text(LocaleText.returnText))
						)
					}
				}

				DinotisList {
					viewModel.refreshInvoice()
				} introspectConfig: { view in
					view.separatorStyle = .none
					view.showsVerticalScrollIndicator = false
					viewModel.use(for: view) { refresh in
						viewModel.refreshInvoice()
						refresh.endRefreshing()
					}
				} content: {
					VStack {
						VStack(alignment: .leading) {
							HStack {
								Text((viewModel.bookingPayment?.paymentMethod?.name).orEmpty())
									.font(.robotoBold(size: 14))
									.foregroundColor(.black)

								Spacer()

								if let url = URL(string: (viewModel.bookingPayment?.paymentMethod?.iconURL).orEmpty()) {
									AnimatedImage(url: url)
										.resizable()
										.scaledToFit()
										.frame(height: 45)
								}
							}

							Divider()
								.padding(.bottom)

							VStack(alignment: .leading, spacing: 15) {
								VStack(alignment: .leading, spacing: 5) {
									Text(LocaleText.invoiceNumberTitle)
										.font(.robotoRegular(size: 12))
										.foregroundColor(.black)

									Text((viewModel.bookingData?.invoiceId).orEmpty())
										.font(.robotoBold(size: 14))
										.foregroundColor(.black)
								}

								VStack(alignment: .leading, spacing: 5) {
									Text(LocalizableText.invoiceItemName)
										.font(.robotoRegular(size: 12))
										.foregroundColor(.black)

									Text((viewModel.bookingData?.meeting?.title).orEmpty())
										.font(.robotoBold(size: 14))
										.foregroundColor(.black)
								}
								
								if viewModel.isNotQRandEwallet() {
									VStack(alignment: .leading, spacing: 5) {
										Text(LocaleText.vaNumberTitle)
											.font(.robotoRegular(size: 12))
											.foregroundColor(.black)

										HStack {
											if let number = viewModel.invoiceData?.number {
												Text(number)
													.font(.robotoBold(size: 14))
													.foregroundColor(.black)

												Spacer()

												Button(action: {
													UIPasteboard.general.string = number
												}, label: {
													Text(LocaleText.copyText)
														.font(.robotoBold(size: 12))
														.foregroundColor(.DinotisDefault.primary)
												})
											}
										}
									}
								}

								VStack(alignment: .leading, spacing: 5) {
									Text(LocaleText.totalPaymentText)
										.font(.robotoRegular(size: 12))
										.foregroundColor(.black)

                                    HStack {
                                        Text((viewModel.bookingPayment?.amount).orEmpty().toCurrency())
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        Button {
                                            viewModel.isShowDetailPayment.toggle()
                                        } label: {
                                            Text(LocalizableText.seeDetailsLabel)
                                                .font(.robotoBold(size: 12))
                                                .foregroundColor(.DinotisDefault.primary)
                                        }
                                    }
                                }

								if viewModel.isEwallet() {
									Button {
										self.viewModel.backToHome()
										if let url = URL(string: (viewModel.bookingPayment?.redirectUrl).orEmpty()) {
											UIApplication.shared.open(url, options: [:])
										}
									} label: {
										HStack {
											Spacer()

											Text(LocaleText.payNowText)
												.foregroundColor(.white)
												.font(.robotoMedium(size: 12))

											Spacer()
										}
										.padding()
										.background(
											RoundedRectangle(cornerRadius: 10)
												.foregroundColor(.DinotisDefault.primary)
										)
									}

								} else if viewModel.isQR() {

									Image.base64Image(with: (viewModel.bookingPayment?.qrCodeUrl).orEmpty())
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
												.font(.robotoBold(size: 14))
												.foregroundColor(.black)

											Spacer()
										}

										HStack {
											Text(LocaleText.howToPayFirstText)
												.font(.robotoRegular(size: 12))
												.multilineTextAlignment(.leading)
												.foregroundColor(.black)

											Spacer()
										}

										HStack {
											Text(LocaleText.howToPaySecondText)
												.font(.robotoRegular(size: 12))
												.multilineTextAlignment(.leading)
												.foregroundColor(.black)

											Spacer()
										}

										HStack {
											Text(LocaleText.howToPayThirdText)
												.font(.robotoRegular(size: 12))
												.multilineTextAlignment(.leading)
												.foregroundColor(.black)

											Spacer()
										}

										HStack {
											Text(LocaleText.howToPayFourthText)
												.font(.robotoRegular(size: 12))
												.multilineTextAlignment(.leading)
												.foregroundColor(.black)

											Spacer()
										}
									}
									.padding(.vertical, 5)
								}

								HStack {
									Text(LocaleText.completePaymentBefore)
										.font(.robotoRegular(size: 12))
										.foregroundColor(.black)

									Spacer()

									if let expired = viewModel.invoiceData?.expiredAt {
                                        Text("\(DateUtils.dateFormatter(expired, forFormat: .HHmm))")
											.font(.robotoBold(size: 12))
											.foregroundColor(.black)
									} else if let anotherExp = viewModel.bookingData?.createdAt {
                                        Text("\(DateUtils.dateFormatter(anotherExp.addingTimeInterval(1800), forFormat: .HHmm))")
											.font(.robotoBold(size: 12))
											.foregroundColor(.black)
									}
								}
								.padding(10)
								.background(Color.secondaryViolet)
								.cornerRadius(5)

								if viewModel.isQR() {
									HStack {
										Text(LocaleText.attentionQrisText)
											.font(.robotoRegular(size: 12))
											.foregroundColor(.black)

										Spacer()
									}
									.padding()
									.background(
										RoundedRectangle(cornerRadius: 8)
											.foregroundColor(Color(.systemGray3))
									)
								}
                                
                                HStack {
                                    Spacer()
                                    DinotisUnderlineButton(
                                        text: LocalizableText.cancelPaymentQuestion,
                                        textColor: .DinotisDefault.primary,
                                        fontSize: 12) {
                                            viewModel.isCancelSheetShow.toggle()
                                        }
                                    Spacer()
                                }
							}
						}
						.padding()
						.background(Color.white)
						.clipShape(RoundedRectangle(cornerRadius: 12))
						.shadow(color: Color.dinotisShadow.opacity(0.1), radius: 10, x: 0.0, y: 0.0)
						.padding(.vertical)

						Spacer()

						if let instructionData = viewModel.instruction {
							VStack(spacing: 0) {
								TopBarInstructionView(
									selected: $viewModel.selectedTab,
									instruction: .constant(
										instructionData
									),
									virtualNumber: .constant((viewModel.invoiceData?.number).orEmpty())
								)

								ScrollView(.vertical, showsIndicators: false, content: {
									ForEach((instructionData.instructions?[viewModel.selectedTab].instruction ?? []).indices, id: \.self) { item in
										HStack {
											Text("\(item+1)")
												.font(.robotoMedium(size: 13))
												.padding(10)
												.overlay(
													Circle()
														.stroke(Color.DinotisDefault.primary, lineWidth: 1.5)
												)

											Text(
												LocalizedStringKey(
													(instructionData
														.instructions?[viewModel.selectedTab]
														.instruction?[item] ?? "")
													.replacingOccurrences(
														of: "${number}",
														with: (viewModel.invoiceData?.number).orEmpty()
													)
												)

											)
											.font(.robotoRegular(size: 13))
											.multilineTextAlignment(.leading)

											Spacer()
										}
										.padding(.horizontal)
									}
									.padding(.vertical)
								})
							}
							.background(Color.white)
							.clipShape(RoundedRectangle(cornerRadius: 10))
							.padding(.vertical)
						}
					}
					.listRowBackground(Color.clear)

					if viewModel.isLoading {
						HStack {
							Spacer()

							ActivityIndicator(isAnimating: $viewModel.isLoading, color: .black, style: .medium)
								.padding(.top)

							Spacer()
						}
						.listRowBackground(Color.clear)
					}
				}
			}
			.edgesIgnoringSafeArea(.vertical)
			.onAppear {
				viewModel.onAppear()
			}
		}
        .sheet(
            isPresented: $viewModel.isCancelSheetShow,
            content: {
				if #available(iOS 16.0, *) {
					VStack(spacing: 10) {
						HStack {
							Spacer()

							Button {
								viewModel.isCancelSheetShow = false
							} label: {
								Image(systemName: "xmark.circle.fill")
									.resizable()
									.scaledToFit()
									.frame(width: 20)
									.foregroundColor(Color(UIColor.systemGray4))
							}
						}

						Image.paymentCancelImage
							.resizable()
							.scaledToFit()
							.frame(height: 188)

						Text(LocalizableText.cancelPaymentTitleQuestion)
							.font(.robotoBold(size: 14))
							.foregroundColor(.black)

						Text(LocalizableText.cancelPaymentDescription)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)

						Spacer()

						DinotisSecondaryButton(
							text: LocalizableText.detailPaymentCancelConfirmation,
							type: .adaptiveScreen,
							textColor: .DinotisDefault.black1,
							bgColor: .DinotisDefault.lightPrimary,
							strokeColor: .DinotisDefault.primary) {
								viewModel.isCancelSheetShow = false
								viewModel.onDeleteBookings()
							}
					}
						.padding()
						.padding(.vertical)
						.presentationDetents([.fraction(0.5), .large])
                        .dynamicTypeSize(.large)
				} else {
					VStack(spacing: 10) {
						HStack {
							Spacer()

							Button {
								viewModel.isCancelSheetShow = false
							} label: {
								Image(systemName: "xmark.circle.fill")
									.resizable()
									.scaledToFit()
									.frame(width: 20)
									.foregroundColor(Color(UIColor.systemGray4))
							}
						}

						Image.paymentCancelImage
							.resizable()
							.scaledToFit()
							.frame(height: 188)

						Text(LocalizableText.cancelPaymentTitleQuestion)
							.font(.robotoBold(size: 14))
							.foregroundColor(.black)

						Text(LocalizableText.cancelPaymentDescription)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)

						Spacer()

						DinotisSecondaryButton(
							text: LocalizableText.paymentConfirmationTitle,
							type: .adaptiveScreen,
							textColor: .DinotisDefault.black1,
							bgColor: .DinotisDefault.lightPrimary,
							strokeColor: .DinotisDefault.primary) {
								viewModel.isCancelSheetShow = false
								viewModel.onDeleteBookings()
							}
					}
						.padding()
						.padding(.vertical)
                        .dynamicTypeSize(.large)
				}
            }
        )
        .sheet(
            isPresented: $viewModel.isShowDetailPayment,
            content: {
				if #available(iOS 16.0, *) {
					VStack(spacing: 24) {
						HStack {
							Text(LocalizableText.detailPaymentTitle)
								.font(.robotoBold(size: 14))
								.foregroundColor(.black)

							Spacer()

							Button {
								viewModel.isShowDetailPayment = false
							} label: {
								Image(systemName: "xmark.circle.fill")
									.resizable()
									.scaledToFit()
									.frame(width: 20)
									.foregroundColor(Color(UIColor.systemGray4))
							}
						}

						ScrollView(.vertical, showsIndicators: false) {
							VStack(spacing: 6) {
								HStack {
									Text(LocalizableText.feeSubTotalLabel)

									Spacer()

									Text(viewModel.subtotal.toCurrency())
								}
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)

								HStack {
									Text(LocalizableText.feeApplication)

									Spacer()

									Text(viewModel.extraFee.toCurrency())
								}
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)

								HStack {
									Text(LocalizableText.feeService)

									Spacer()

									Text(viewModel.serviceFee)
								}
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)

								HStack {
									Text(LocalizableText.totalLabel)
										.font(.robotoRegular(size: 12))

									Spacer()

									Text((viewModel.bookingPayment?.amount).orEmpty().toCurrency())
										.font(.robotoBold(size: 14))
								}
								.foregroundColor(.black)
							}
						}
					}
						.padding()
						.padding(.vertical)
						.presentationDetents([.fraction(0.35), .large])
                        .dynamicTypeSize(.large)
				} else {
					VStack(spacing: 24) {
						HStack {
							Text(LocalizableText.detailPaymentTitle)
								.font(.robotoBold(size: 14))
								.foregroundColor(.black)

							Spacer()

							Button {
								viewModel.isShowDetailPayment = false
							} label: {
								Image(systemName: "xmark.circle.fill")
									.resizable()
									.scaledToFit()
									.frame(width: 20)
									.foregroundColor(Color(UIColor.systemGray4))
							}
						}

						ScrollView(.vertical, showsIndicators: false) {
							VStack(spacing: 6) {
								HStack {
									Text(LocalizableText.feeSubTotalLabel)

									Spacer()

									Text(viewModel.subtotal.toCurrency())
								}
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)

								HStack {
									Text(LocalizableText.feeApplication)

									Spacer()

									Text(viewModel.extraFee.toCurrency())
								}
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)

								HStack {
									Text(LocalizableText.feeService)

									Spacer()

									Text(viewModel.serviceFee)
								}
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)

								HStack {
									Text(LocalizableText.totalLabel)
										.font(.robotoRegular(size: 12))

									Spacer()

									Text((viewModel.bookingPayment?.amount).orEmpty().toCurrency())
										.font(.robotoBold(size: 14))
								}
								.foregroundColor(.black)
							}
						}
					}
						.padding()
						.padding(.vertical)
                        .dynamicTypeSize(.large)
				}

            }
        )
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
	
	
}

struct InvoiceView_Previews: PreviewProvider {
	static var previews: some View {
		DetailPaymentView(
			viewModel: DetailPaymentViewModel(
				backToHome: {},
				backToChoosePayment: {},
				bookingId: "",
                subtotal: "",
                extraFee: "",
                serviceFee: ""
            ),
            mainTabValue: .constant(.agenda)
		)
	}
}
