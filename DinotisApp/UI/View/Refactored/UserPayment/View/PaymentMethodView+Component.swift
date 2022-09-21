//
//  PaymentMethodView+Component.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/04/22.
//

import SwiftUI
import SDWebImageSwiftUI

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
					.font(.montserratBold(size: 14))
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
			VStack(alignment: .leading) {
				HStack {
					Text(title)
						.font(.montserratBold(size: 14))
						.foregroundColor(.black)

					Spacer()
				}

				HStack(spacing: 0) {
					Text(LocaleText.vaServiceFeeSubtitle)
						.font(.montserratRegular(size: 12))
						.foregroundColor(.black)

					Text(serviceFee)
						.font(.montserratBold(size: 12))
						.foregroundColor(.black)

					if isEwallet {
						Text(LocaleText.ewalletServiceFeeSubtitle)
							.font(.montserratRegular(size: 12))
							.foregroundColor(.black)
					}

					Spacer()
				}
				.padding(.top, 5)

				ForEach(paymentMethodData, id: \.id) { items in
					VStack {
						HStack(spacing: 10) {
							if let icon = URL(string: items.iconURL.orEmpty()) {
								AnimatedImage(url: icon)
									.resizable()
									.scaledToFit()
									.frame(height: 30)
							}

							Text(items.name)
								.font(.montserratRegular(size: 12))
								.foregroundColor(.black)

							Spacer()

							viewModel.radioButtonSelection(itemId: items.id)
								.resizable()
								.scaledToFit()
								.frame(height: 18)
						}
						.padding(.vertical, 15)

						if items.id != paymentMethodData.last?.id {
							Divider()
						}
					}
					.contentShape(Rectangle())
					.onTapGesture(perform: {
						viewModel.selectItem = items.id
						viewModel.selectedString = items.name
						viewModel.selectedIcon = items.iconURL
						viewModel.serviceFee = items.extraFee.orZero()
						viewModel.isPercentage = items.extraFeeIsPercentage ?? false
					})
				}

			}
			.padding()
			.background(Color.white)
			.clipShape(RoundedRectangle(cornerRadius: 12))
			.shadow(color: Color.dinotisShadow.opacity(0.1), radius: 10, x: 0.0, y: 0.0)
		}
	}

	struct BottomSide: View {

		@ObservedObject var viewModel: PaymentMethodsViewModel

		var body: some View {
			VStack {

				HStack {
					Text(LocaleText.paymentText)
						.font(.montserratRegular(size: 12))
						.foregroundColor(.black)

					Spacer()

					Text(viewModel.selectedString.orEmpty())
						.font(.montserratBold(size: 14))
						.foregroundColor(.primaryViolet)
				}

				VStack(spacing: 5) {
					HStack {
						Text(LocaleText.subtotalText)
							.font(.montserratRegular(size: 12))
							.foregroundColor(.black)

						Spacer()

						if let intPrice = viewModel.price.toCurrency() {
							Text(intPrice)
								.font(.montserratRegular(size: 12))
								.foregroundColor(.black)
						}
					}

					HStack {
						Text(LocaleText.applicationFeeText)
							.font(.montserratRegular(size: 12))
							.foregroundColor(.black)

						Spacer()

						if let doublePrice = String(viewModel.extraFee).toCurrency() {
							Text(doublePrice)
								.font(.montserratRegular(size: 12))
								.foregroundColor(.black)
						}
					}

					HStack {
						Text(LocaleText.serviceFeeText)
							.font(.montserratRegular(size: 12))
							.foregroundColor(.black)

						Spacer()

						Text(viewModel.actualServiceFee)
							.font(.montserratRegular(size: 12))
							.foregroundColor(.black)
					}

					if (viewModel.promoCodeData?.discountTotal).orZero() != 0 {
						HStack {
							Text(LocaleText.discountText)
								.font(.montserratRegular(size: 12))
								.foregroundColor(.black)

							Spacer()

							if let doublePrice = String(viewModel.discount).toCurrency() {
								Text("-\(doublePrice)")
									.font(.montserratBold(size: 12))
									.foregroundColor(.black)
							}
						}
					}

					HStack {
						Text(LocaleText.totalPaymentText)
							.font(.montserratRegular(size: 12))
							.foregroundColor(.black)

						Spacer()

						if let doublePrice = String(viewModel.total).toCurrency() {
							Text(doublePrice)
								.font(.montserratBold(size: 12))
								.foregroundColor(.black)
						}
					}
				}
				.padding(.top, 10)
				.padding(.bottom, 5)

				Button(action: {
					if self.viewModel.selectItem != 0 {
						viewModel.sendPayment()
					}
				}, label: {
					HStack {
						Spacer()
						Text(LocaleText.useMethodText)
							.font(.montserratSemiBold(size: 12))
							.foregroundColor(.white)
						Spacer()
					}
					.padding()
					.background(Color.primaryViolet)
					.cornerRadius(8)
				})

				Color.white.frame(height: 2)
			}
			.padding()
			.background(Color.white)
			.isHidden(viewModel.selectItem == 0, remove: viewModel.selectItem == 0)
			.alert(isPresented: $viewModel.isError) {
				Alert(
					title: Text(LocaleText.attention),
					message: Text((viewModel.error?.errorDescription).orEmpty()),
					dismissButton: .default(Text(LocaleText.returnText))
				)
			}
		}
	}

	struct PromoCodeEntry: View {

		@ObservedObject var viewModel: PaymentMethodsViewModel

		var body: some View {
			VStack(alignment: .leading, spacing: 15) {
				Text(LocaleText.paymentScreenPromoCodeTitle)
					.font(.montserratBold(size: 14))

				VStack(alignment: .leading, spacing: 10) {
					HStack {

						Group {
							if viewModel.promoCodeSuccess {
								HStack {
									Text(viewModel.promoCode)
										.font(.montserratRegular(size: 12))

									Spacer()
								}
							} else {
								TextField(LocaleText.paymentScreenPromoCodePlaceholder, text: $viewModel.promoCode)
									.font(.montserratRegular(size: 12))
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

						Button {
							if viewModel.promoCodeData != nil {
								viewModel.resetStateCode()
							} else {
								viewModel.checkPromoCode()
							}
						} label: {
							HStack {
								Text(viewModel.promoCodeSuccess ? LocaleText.changeVoucherText : LocaleText.applyText)
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(viewModel.promoCode.isEmpty ? Color(.systemGray2) : .white)
							}
							.padding()
							.padding(.horizontal, 5)
							.background(
								RoundedRectangle(cornerRadius: 12)
									.foregroundColor(viewModel.promoCodeSuccess ? .red : (viewModel.promoCode.isEmpty ? Color(.systemGray5) : .primaryViolet))
							)

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
								.font(.montserratRegular(size: 10))
								.foregroundColor(.red)

							Spacer()
						}
					}

					if !viewModel.promoCodeTextArray.isEmpty {
						ForEach(viewModel.promoCodeTextArray, id: \.self) { item in
							Text(item)
								.font(.montserratMedium(size: 10))
								.foregroundColor(.black)
								.multilineTextAlignment(.leading)
						}
					}
				}
			}
			.padding()
			.background(Color.white)
			.clipShape(RoundedRectangle(cornerRadius: 12))
			.shadow(color: Color.dinotisShadow.opacity(0.1), radius: 10, x: 0.0, y: 0.0)
		}
	}
}
