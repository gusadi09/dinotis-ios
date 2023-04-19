//
//  PaymentMethodView+Component.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/04/22.
//

import SwiftUI
import SDWebImageSwiftUI
import DinotisDesignSystem
import DinotisData

extension PaymentMethodView {
	
	struct NavigationHeader: View {

		@Binding var colorTab: Color
		@Environment(\.presentationMode) var presentationMode

		init(colorTab: Binding<Color>) {
			self._colorTab = colorTab
		}

		var body: some View {
			HStack {
				Button(action: {
					presentationMode.wrappedValue.dismiss()
				}, label: {
					Image.Dinotis.arrowBackIcon
						.padding()
						.background(Color.white)
						.clipShape(Circle())
				})

				Spacer()

				Text(LocaleText.selectPaymentText)
					.font(.robotoBold(size: 14))
					.padding(.horizontal)

				Spacer()
				Spacer()
			}
			.padding()
			.background(colorTab)
		}
	}

	struct PaymentMethodGroup: View {

		var title: String
		var serviceFee: String
		var isEwallet: Bool
		var paymentMethodData: [PaymentMethodData]
		@ObservedObject var viewModel: PaymentMethodsViewModel

		var body: some View {

			ExpandedSection {
				VStack(alignment: .leading, spacing: 10) {
					HStack {
						Text(title)
							.font(.robotoBold(size: 14))
							.foregroundColor(.black)

						Spacer()
					}

					HStack(spacing: 0) {
						Text(LocaleText.vaServiceFeeSubtitle)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)

						Text(serviceFee)
							.font(.robotoBold(size: 12))
							.foregroundColor(.black)

						if isEwallet {
							Text(LocaleText.ewalletServiceFeeSubtitle)
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)
						}

						Spacer()
					}
				}
				.padding(.top, 10)
			} content: {
				LazyVStack(alignment: .leading) {

					ForEach(paymentMethodData, id: \.id) { items in
						VStack {
							HStack(spacing: 10) {
								if let icon = URL(string: items.iconURL.orEmpty()) {
									AnimatedImage(url: icon)
										.resizable()
										.scaledToFit()
										.frame(height: 45)
								}

								Text(items.name.orEmpty())
									.font(.robotoRegular(size: 12))
									.foregroundColor(.black)

								Spacer()

								viewModel.radioButtonSelection(itemId: items.id.orZero())
									.resizable()
									.scaledToFit()
									.frame(height: 18)
							}
							.padding(.vertical, 5)

							if items.id != paymentMethodData.last?.id {
								Divider()
							}
						}
						.contentShape(Rectangle())
						.onTapGesture(perform: {
							viewModel.selectItem = items.id.orZero()
							viewModel.selectedString = items.name
							viewModel.selectedIcon = items.iconURL
							viewModel.serviceFee = items.extraFee.orZero()
							viewModel.isPercentage = items.extraFeeIsPercentage ?? false
						})
					}

				}
				.padding(.horizontal, 5)
			}
		}
	}

	struct BottomSide: View {

		@ObservedObject var viewModel: PaymentMethodsViewModel

		var body: some View {
			VStack {

				if viewModel.selectItem != 0 {
					PromoCodeEntry(viewModel: viewModel)
				}

				Divider()
					.padding(.vertical, 10)

				HStack {
					Text(LocaleText.paymentText)
						.font(.robotoRegular(size: 12))
						.foregroundColor(.black)

					Spacer()

					Text(viewModel.selectedString.orEmpty())
						.font(.robotoBold(size: 14))
						.foregroundColor(.DinotisDefault.primary)
				}

				VStack(spacing: 5) {
					HStack {
						Text(LocaleText.subtotalText)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
                        
                        Spacer()
                        
                        Text(viewModel.price.toCurrency())
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.black)
                    }

					HStack {
						Text(LocaleText.applicationFeeText)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text(String(viewModel.extraFee).toCurrency())
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.black)
                    }

					HStack {
						Text(LocaleText.serviceFeeText)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)

						Spacer()

						Text(viewModel.actualServiceFee)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
					}

					if (viewModel.promoCodeData?.discountTotal).orZero() != 0 {
						HStack {
							Text(LocaleText.discountText)
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)

							Spacer()
                            
                            Text("-\(String(viewModel.discount).toCurrency())")
                                .font(.robotoBold(size: 12))
                                .foregroundColor(.black)
                        }
					}

					HStack {
						Text(LocaleText.totalPaymentText)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
                        
                        Spacer()
                        
                        Text(String(viewModel.total).toCurrency())
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.black)
                    }
				}
				.padding(.top, 5)
				.padding(.bottom, 5)

				DinotisPrimaryButton(
					text: LocaleText.useMethodText,
					type: .adaptiveScreen,
					textColor: .white,
					bgColor: .DinotisDefault.primary
				) {
					if self.viewModel.selectItem != 0 {
						Task {
							await viewModel.sendPayment()
						}
					}
				}
				.padding(.bottom, 10)
			}
			.padding()
			.background(
				Color.white
					.shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
					.edgesIgnoringSafeArea(.all)
			)
			.isHidden(viewModel.selectItem == 0, remove: viewModel.selectItem == 0)
		}
	}

	struct PromoCodeEntry: View {

		@ObservedObject var viewModel: PaymentMethodsViewModel

		var body: some View {
			VStack(alignment: .leading, spacing: 15) {
				Text(LocaleText.paymentScreenPromoCodePlaceholder)
					.font(.robotoMedium(size: 12))

				VStack(alignment: .leading, spacing: 10) {
					HStack {

						Group {
							if viewModel.promoCodeSuccess {
								HStack {
									Text(viewModel.promoCode)
										.font(.robotoRegular(size: 12))

									Spacer()
								}
							} else {
								TextField(LocaleText.paymentScreenPromoCodeTitle, text: $viewModel.promoCode)
									.font(.robotoRegular(size: 12))
									.autocapitalization(.allCharacters)
									.disableAutocorrection(true)
							}
						}
						.padding()
						.overlay(
							RoundedRectangle(cornerRadius: 10)
								.stroke(Color.dinotisStrokeSecondary, lineWidth: 1)
						)
						.background(
							RoundedRectangle(cornerRadius: 10)
								.foregroundColor(viewModel.promoCodeSuccess ? Color(.systemGray5) : .white)
						)

						DinotisPrimaryButton(
							text: viewModel.promoCodeSuccess ? LocaleText.changeVoucherText : LocaleText.applyText,
							type: .wrappedContent,
							textColor: viewModel.promoCode.isEmpty ? Color(.systemGray2) : .white,
							bgColor: viewModel.promoCodeSuccess ? .red : (viewModel.promoCode.isEmpty ? Color(.systemGray5) : .DinotisDefault.primary)
						) {
							if viewModel.promoCodeData != nil {
								viewModel.resetStateCode()
							} else {
								Task {
									await viewModel.checkPromoCode()
								}
							}
						}
						.disabled(viewModel.promoCode.isEmpty)

					}

					if viewModel.promoCodeError {
						HStack {
							Image.Dinotis.exclamationCircleIcon
								.resizable()
								.scaledToFit()
								.frame(height: 10)
								.foregroundColor(.red)
							Text(LocaleText.paymentScreenPromoNotFound)
								.font(.robotoRegular(size: 10))
								.foregroundColor(.red)

							Spacer()
						}
					}

					if !viewModel.promoCodeTextArray.isEmpty {
						ForEach(viewModel.promoCodeTextArray, id: \.self) { item in
							Text(item)
								.font(.robotoMedium(size: 10))
								.foregroundColor(.black)
								.multilineTextAlignment(.leading)
						}
					}
				}
			}
		}
	}
}
