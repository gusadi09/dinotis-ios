//
//  TalentProfileDetailView+Component.swift
//  DinotisApp
//
//  Created by hilmy ghozy on 19/04/22.
//

import Foundation
import SwiftUINavigation
import SwiftUI
import QGrid
import StoreKit

extension TalentProfileDetailView {

	struct HeaderView: View {

		@ObservedObject var viewModel: TalentProfileDetailViewModel

		@Environment(\.presentationMode) var presentationMode

		var body: some View {
			ZStack {
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

				HStack {
					Spacer()
					Text((viewModel.talentData?.name).orEmpty())
						.font(.montserratBold(size: 14))
						.foregroundColor(.black)

					Spacer()
				}
			}
		}
	}

	struct CardProfile: View {

		@ObservedObject var viewModel: TalentProfileDetailViewModel

		var body: some View {
			VStack(spacing: 10) {
				VStack(spacing: 25) {
					HStack(alignment: .center) {
						Image.Dinotis.personPhoneIcon
							.resizable()
							.scaledToFit()
							.frame(height: 16)

						Text(LocaleText.videoCallSchedule)
							.font(.montserratRegular(size: 14))
							.foregroundColor(.black)

					}
					.background(Color.clear)
					.padding([.top, .bottom], -5)

					Rectangle()
						.frame(height: 1.5, alignment: .center)
						.foregroundColor(Color(.purple).opacity(0.1))
						.padding([.leading, .trailing], 20)

				}
				.padding([.leading, .trailing, .top])

				HStack {
					Image(systemName: "slider.horizontal.3")
						.resizable()
						.scaledToFit()
						.frame(height: 15)
						.foregroundColor(.primaryViolet)

					Text(LocaleText.generalFilterSchedule)
						.font(.montserratSemiBold(size: 12))
						.foregroundColor(.primaryViolet)

					Spacer()

					Menu {
						Picker(selection: $viewModel.filterSelection) {
							ForEach(viewModel.filterOption, id: \.id) { item in
								Text(item.label.orEmpty())
									.tag(item.label.orEmpty())
							}
						} label: {
							EmptyView()
						}
					} label: {
						HStack(spacing: 10) {
							Text(viewModel.filterSelection)
								.font(.montserratRegular(size: 12))
								.foregroundColor(.black)

							Image(systemName: "chevron.down")
								.resizable()
								.scaledToFit()
								.frame(height: 5)
								.foregroundColor(.black)
						}
						.padding(.horizontal, 15)
						.padding(.vertical, 10)
						.background(
							RoundedRectangle(cornerRadius: 10)
								.foregroundColor(.secondaryViolet)
						)
						.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primaryViolet, lineWidth: 1))
					}
				}
				.padding(.horizontal)
				.padding(.bottom, 10)
			}
			.background(Color.secondaryBackground)
		}
	}

	struct EmptyScheduleTalentProfile: View {

		@ObservedObject var viewModel: TalentProfileDetailViewModel

		var body: some View {
			HStack {
				Spacer()
				VStack(spacing: 30) {
					VStack(spacing: 10) {
					Image.Dinotis.emptyScheduleImage
						.resizable()
						.scaledToFit()
						.frame(
							height: 137,
							alignment: .center
						)

					Text(LocaleText.noScheduleLabel)
						.font(.montserratBold(size: 14))
						.foregroundColor(.black)

					Text(LocaleText.talentDetailEmptySchedule)
						.font(.montserratRegular(size: 12))
						.multilineTextAlignment(.center)
						.foregroundColor(.black)
					}

					VStack(spacing: 10) {
						Button {
							viewModel.showingRequest.toggle()
						} label: {
							HStack {
								Spacer()

								Text(LocaleText.requestScheduleText)
									.font(.montserratBold(size: 12))
									.foregroundColor(.white)

								Spacer()
							}
							.padding(.vertical, 14)
							.background(
								RoundedRectangle(cornerRadius: 12)
									.foregroundColor(.primaryViolet)
							)
						}
						.buttonStyle(.plain)

						Text(LocaleText.orText)
							.font(.montserratRegular(size: 12))

						Button {
							viewModel.sendRequest(type: .notifyType)
						} label: {
							HStack {
								Spacer()

								Text(LocaleText.tellMeText)
									.font(.montserratBold(size: 12))
									.foregroundColor(.primaryViolet)

								Spacer()
							}
							.padding(.vertical, 14)
							.background(
								RoundedRectangle(cornerRadius: 12)
									.foregroundColor(.secondaryViolet)
							)
							.overlay(
								RoundedRectangle(cornerRadius: 12)
									.stroke(Color.primaryViolet, lineWidth: 1)
							)
						}
						.buttonStyle(.plain)
					}
				}
				Spacer()
			}
			.padding()
			.background(Color.white)
			.cornerRadius(12)
			.padding(.horizontal)
			.shadow(color: Color.dinotisShadow.opacity(0.1), radius: 20, x: 0.0, y: 0.0)
			.padding(.top, 30)
		}

	}

	struct ScheduleTalent: View {

		@ObservedObject var viewModel: TalentProfileDetailViewModel
		@State var isLoading = false

		var body: some View {
				LazyVStack {

					LazyVStack {
						if isLoading {
							HStack {
								Spacer()
								ActivityIndicator(isAnimating: $isLoading, color: .black, style: .medium)
								Spacer()
							}
							.padding()
						}

						if viewModel.meetingData.isEmpty {
							TalentProfileDetailView.EmptyScheduleTalentProfile(viewModel: viewModel)
						} else {
							if let data = viewModel.meetingData.unique() {
								if data.isEmpty {
									TalentProfileDetailView.EmptyScheduleTalentProfile(viewModel: viewModel)
								} else {
									ForEach(data, id: \.id) { items in
										ProfileTalentScheduleCard(
											items: .constant(items),
											currentUserId: .constant(viewModel.userData?.id ?? ""),
											onTapButton: {
												if viewModel.isHaveMeeting(meet: items, current: (viewModel.userData?.id).orEmpty()) || viewModel.userData?.id ?? "" == items.userID {
													viewModel.bookingId = items.bookings.first?.id ?? ""

													viewModel.routeToUserScheduleDetail()

												} else {
													if items.price.orEmpty() == "0" {
														viewModel.meetingId = items.id.orEmpty()
														viewModel.sendFreePayment()
													} else {
														viewModel.isPresent.toggle()
														viewModel.countPart = items.bookings.filter({ items in
															items.bookingPayment?.paidAt != nil
														}).count
														viewModel.totalPart = items.slots.orZero()
														viewModel.title = items.title.orEmpty()
														viewModel.desc = items.meetingDescription.orEmpty()
														viewModel.meetingId = items.id.orEmpty()
														if let dateStart = items.startAt.orEmpty().toDate(format: .utcV2),
															 let timeStart = items.startAt.orEmpty().toDate(format: .utcV2),
															 let timeEnd = items.endAt.orEmpty().toDate(format: .utcV2) {
															viewModel.date = dateStart.toString(format: .EEEEddMMMMyyyy)
															viewModel.timeStart = timeStart.toString(format: .HHmm)
															viewModel.timeEnd = timeEnd.toString(format: .HHmm)
															viewModel.price = items.price.orEmpty()
														}
													}
												}
											}
										)
										.padding(.bottom, 10)
										.onAppear {
											if (data.last?.id).orEmpty() == items.id.orEmpty() {
												viewModel.meetingParam.skip = viewModel.meetingParam.take
												viewModel.meetingParam.take += 15
												viewModel.getTalentMeeting(by: (viewModel.talentData?.id).orEmpty())
											}
										}
									}
								}
							}
						}
					}

				}
				.background(Color.secondaryBackground)
		}
	}

	struct CoinBuySucceed: View {

		let geo: GeometryProxy
		
		var body: some View {
			HStack {

				Spacer()

				VStack(spacing: 15) {
					Image.Dinotis.paymentSuccessImage
						.resizable()
						.scaledToFit()
						.frame(height: geo.size.width/2)

					Text(LocaleText.homeScreenCoinSuccess)
						.font(.montserratBold(size: 16))
						.foregroundColor(.black)
				}

				Spacer()

			}
			.padding(.vertical)
		}
	}

	struct CoinPaymentSheetView: View {

		@ObservedObject var viewModel: TalentProfileDetailViewModel

		var body: some View {
			LazyVStack(spacing: 15) {
				HStack {
					VStack(alignment: .leading, spacing: 10) {
						Text(LocaleText.homeScreenYourCoin)
							.font(.montserratMedium(size: 12))
							.foregroundColor(.black)

						HStack(alignment: .top) {
							Image.Dinotis.coinIcon
								.resizable()
								.scaledToFit()
								.frame(height: 15)

							Text("\(viewModel.userData?.coinBalance?.current ?? 0)")
								.font(.montserratBold(size: 14))
								.foregroundColor((viewModel.userData?.coinBalance?.current ?? 0) >= viewModel.totalPayment ? .primaryViolet : .red)
						}
					}

					Spacer()

					if (viewModel.userData?.coinBalance?.current ?? 0) <= viewModel.totalPayment {
						Button {
							DispatchQueue.main.async {
								viewModel.isShowCoinPayment.toggle()
							}
							DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
								viewModel.showAddCoin.toggle()
							}
						} label: {
							Text(LocaleText.homeScreenAddCoin)
								.font(.montserratMedium(size: 12))
								.foregroundColor(.primaryViolet)
								.padding(15)
								.overlay(
									RoundedRectangle(cornerRadius: 10)
										.stroke(Color.primaryViolet, lineWidth: 1)
								)
						}

					}
				}
				.padding()
				.background(RoundedRectangle(cornerRadius: 12).foregroundColor(.secondaryViolet))

				VStack(alignment: .leading) {
					Text(LocaleText.paymentScreenPromoCodeTitle)
						.font(.montserratMedium(size: 12))
						.foregroundColor(.black)

					VStack(alignment: .leading, spacing: 10) {
						HStack {

							Group {
								if viewModel.promoCodeSuccess {
									HStack {
										Text(viewModel.promoCode)
											.font(.montserratRegular(size: 12))
											.foregroundColor(viewModel.promoCodeSuccess ? Color(.systemGray) : .black)

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
				.background(RoundedRectangle(cornerRadius: 12).foregroundColor(.secondaryViolet))

				VStack(alignment: .leading, spacing: 10) {

					HStack {
						Text(LocaleText.paymentText)
							.font(.montserratSemiBold(size: 12))
							.foregroundColor(.black)

						Spacer()

						Text(LocaleText.coinSingleText)
							.font(.montserratSemiBold(size: 12))
							.foregroundColor(.black)
					}

					HStack {
						Text(LocaleText.subtotalText)
							.font(.montserratSemiBold(size: 12))
							.foregroundColor(.black)

						Spacer()

						Text("\(Int(viewModel.price).orZero())")
							.font(.montserratSemiBold(size: 12))
							.foregroundColor(.black)
					}

					VStack(alignment: .leading, spacing: 10) {
						HStack {
							Text(LocaleText.applicationFeeText)
								.font(.montserratSemiBold(size: 12))
								.foregroundColor(.black)

							Spacer()

							Text("\(viewModel.extraFee)")
								.font(.montserratSemiBold(size: 12))
								.foregroundColor(.black)
						}

						if (viewModel.promoCodeData?.discountTotal).orZero() != 0 {
							HStack {
								Text(LocaleText.discountText)
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(.black)

								Spacer()

								Text("-\((viewModel.promoCodeData?.discountTotal).orZero())")
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(.red)
							}
						} else if (viewModel.promoCodeData?.amount).orZero() != 0 && (viewModel.promoCodeData?.discountTotal).orZero() == 0 {
							HStack {
								Text(LocaleText.discountText)
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(.black)

								Spacer()

								Text("-\((viewModel.promoCodeData?.amount).orZero())")
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(.red)
							}
						}
					}
					.padding(.bottom, 30)

					RoundedRectangle(cornerRadius: 10)
						.frame(height: 1.5)
						.foregroundColor(.primaryViolet)

					HStack {
						Text(LocaleText.totalPaymentText)
							.font(.montserratBold(size: 12))
							.foregroundColor(.black)

						Spacer()

						Text("\(viewModel.totalPayment)")
							.font(.montserratBold(size: 12))
							.foregroundColor(.black)
					}

				}
				.padding()
				.background(RoundedRectangle(cornerRadius: 12).foregroundColor(.secondaryViolet))

				Button {
					viewModel.coinPayment()
				} label: {
					HStack {
						Spacer()

						if viewModel.isLoadingCoinPay {
							ProgressView()
								.progressViewStyle(CircularProgressViewStyle(tint: .white))
						} else {
							Text(LocaleText.payNowText)
								.font(.montserratSemiBold(size: 12))
								.foregroundColor((viewModel.userData?.coinBalance?.current ?? 0) <= viewModel.totalPayment ? Color(.systemGray) : .white)
						}

						Spacer()
					}
					.padding(.vertical, 15)
					.background(
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor((viewModel.userData?.coinBalance?.current ?? 0) <= viewModel.totalPayment ? Color(.systemGray4) : .primaryViolet)
					)
				}
				.disabled((viewModel.userData?.coinBalance?.current ?? 0) <= viewModel.totalPayment || viewModel.isLoadingCoinPay)

			}
		}
	}

	struct AddCoinSheetView: View {

		@ObservedObject var viewModel: TalentProfileDetailViewModel
		let geo: GeometryProxy

		var body: some View {
			VStack(spacing: 20) {

				VStack {
					Text(LocaleText.homeScreenYourCoin)
						.font(.montserratRegular(size: 12))
						.foregroundColor(.black)

					HStack(alignment: .top) {
						Image.Dinotis.coinIcon
							.resizable()
							.scaledToFit()
							.frame(height: geo.size.width/28)

						Text("\(viewModel.userData?.coinBalance?.current ?? 0)")
							.font(.montserratBold(size: 14))
							.foregroundColor(.primaryViolet)
					}
					.multilineTextAlignment(.center)

					Text(LocaleText.homeScreenCoinDetail)
						.font(.montserratRegular(size: 10))
						.multilineTextAlignment(.center)
						.foregroundColor(.black)
				}

				Group {
					if viewModel.isLoadingTrxs {
						ProgressView()
							.progressViewStyle(.circular)
					} else {
						QGrid(viewModel.myProducts.unique(), columns: 2, vSpacing: 10, hSpacing: 10, vPadding: 5, hPadding: 5, isScrollable: false, showScrollIndicators: false) { item in
							Button {
								viewModel.productSelected = item
							} label: {
								HStack {
									Spacer()
									VStack {
										Text(item.priceToString())

										Group {
											switch item.productIdentifier {
											case viewModel.productIDs[0]:
												Text(LocaleText.valueCoinLabel("16000".toPriceFormat()))
											case viewModel.productIDs[1]:
												Text(LocaleText.valueCoinLabel("65000".toPriceFormat()))
											case viewModel.productIDs[2]:
												Text(LocaleText.valueCoinLabel("109000".toPriceFormat()))
											case viewModel.productIDs[3]:
												Text(LocaleText.valueCoinLabel("159000".toPriceFormat()))
											case viewModel.productIDs[4]:
												Text(LocaleText.valueCoinLabel("209000".toPriceFormat()))
											case viewModel.productIDs[5]:
												Text(LocaleText.valueCoinLabel("259000".toPriceFormat()))
											case viewModel.productIDs[6]:
												Text(LocaleText.valueCoinLabel("309000".toPriceFormat()))
											case viewModel.productIDs[7]:
												Text(LocaleText.valueCoinLabel("429000".toPriceFormat()))
											default:
												Text("")
											}
										}
									}
									Spacer()
								}
								.font((viewModel.productSelected ?? SKProduct()).id == item.id ? .montserratBold(size: 12) : .montserratRegular(size: 12))
								.foregroundColor(.primaryViolet)
								.padding(10)
								.background(
									RoundedRectangle(cornerRadius: 12)
										.foregroundColor((viewModel.productSelected ?? SKProduct()).id == item.id ? .secondaryViolet : .clear)
								)
								.overlay(
									RoundedRectangle(cornerRadius: 12)
										.stroke(Color.primaryViolet, lineWidth: 1)
								)
							}
						}
					}
				}
				.frame(height: 250)

				VStack {
					Button {
						if let product = viewModel.productSelected {
							viewModel.purchaseProduct(product: product)
						}
					} label: {
						HStack {
							Spacer()

							Text(LocaleText.homeScreenAddCoin)
								.font(.montserratSemiBold(size: 12))
								.foregroundColor(viewModel.isLoadingTrxs || viewModel.productSelected == nil ? Color(.systemGray2) : .white)

							Spacer()
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 12)
								.foregroundColor(viewModel.isLoadingTrxs || viewModel.productSelected == nil ? Color(.systemGray5) : .primaryViolet)
						)
					}
					.disabled(viewModel.isLoadingTrxs || viewModel.productSelected == nil)

					Button {
						viewModel.openWhatsApp()
					} label: {
						HStack {
							Spacer()

							Text(LocaleText.helpText)
								.font(.montserratSemiBold(size: 12))
								.foregroundColor(viewModel.isLoadingTrxs ? Color(.systemGray2) : .primaryViolet)

							Spacer()
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 12)
								.foregroundColor(viewModel.isLoadingTrxs ? Color(.systemGray5) : .secondaryViolet)
						)
						.overlay(
							RoundedRectangle(cornerRadius: 12)
								.stroke(viewModel.isLoadingTrxs ? Color(.systemGray2) : Color.primaryViolet, lineWidth: 1)
						)
					}
					.disabled(viewModel.isLoadingTrxs)

				}

			}
		}
	}

	struct PaymentTypeOption: View {
		@ObservedObject var viewModel: TalentProfileDetailViewModel

		var body: some View {
			VStack {

				Button {
					DispatchQueue.main.async {
						viewModel.showPaymentMenu.toggle()
					}
					DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
						withAnimation {
							viewModel.extraFees()
							viewModel.isShowCoinPayment.toggle()
						}
					}
				} label: {
					HStack(spacing: 15) {
						Image.Dinotis.coinIcon
							.resizable()
							.scaledToFit()
							.frame(height: 15)

						Text(LocaleText.coinPaymentText)
							.font(.montserratSemiBold(size: 12))
							.foregroundColor(.primaryViolet)

						Spacer()

						Image.Dinotis.chevronLeftCircleIcon
							.resizable()
							.scaledToFit()
							.frame(height: 37)
					}
					.padding()
					.background(
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor(.secondaryViolet)
					)
				}

				if viewModel.totalPart == 1 {
					Button {
						DispatchQueue.main.async {
							viewModel.showPaymentMenu.toggle()
						}
						DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
							withAnimation {
								viewModel.routeToPaymentMethod(price: viewModel.price, meetingId: viewModel.meetingId)
								viewModel.showPaymentMenu.toggle()
							}
						}
					} label: {
						HStack(spacing: 15) {
							VStack(alignment: .leading, spacing: 5) {
								Text(LocaleText.otherPaymentText)
									.font(.montserratSemiBold(size: 12))

								Text(LocaleText.otherPaymentSubtitle)
									.font(.montserratRegular(size: 10))
							}
							.foregroundColor(.primaryViolet)

							Spacer()

							Image.Dinotis.chevronLeftCircleIcon
								.resizable()
								.scaledToFit()
								.frame(height: 37)
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 12)
								.foregroundColor(.secondaryViolet)
						)
					}
				}
			}
		}
	}

	struct SlideOverCardView: View {

		@ObservedObject var viewModel: TalentProfileDetailViewModel

		var body: some View {
			VStack(alignment: .leading, spacing: 10) {
				HStack {
					ProfileImageContainer(profilePhoto: .constant(viewModel.talentData?.profilePhoto), name: .constant(viewModel.talentData?.name), width: 40, height: 40)

					Text((viewModel.talentData?.name).orEmpty())
						.font(.montserratBold(size: 14))
						.minimumScaleFactor(0.8)
						.lineLimit(1)

					if viewModel.talentData?.isVerified ?? false {
						Image.Dinotis.accountVerifiedIcon
							.resizable()
							.scaledToFit()
							.frame(height: 16)
					}

					Spacer()

				}
				.padding(.bottom, 10)

				Text(viewModel.title)
					.font(.montserratBold(size: 14))
					.foregroundColor(.black)

				Text(viewModel.desc)
					.font(.montserratRegular(size: 12))
					.foregroundColor(.black)
					.padding(.bottom, 10)

				HStack(spacing: 10) {
					Image.Dinotis.calendarIcon
						.resizable()
						.scaledToFit()
						.frame(height: 18)

					Text(viewModel.date)
						.font(.montserratRegular(size: 12))
						.foregroundColor(.black)
				}

				HStack(spacing: 10) {
					Image.Dinotis.clockIcon
						.resizable()
						.scaledToFit()
						.frame(height: 18)

					Text("\(viewModel.timeStart) - \(viewModel.timeEnd)")
						.font(.montserratRegular(size: 12))
						.foregroundColor(.black)
				}

				VStack(alignment: .leading, spacing: 20) {
					HStack(spacing: 10) {
						Image.Dinotis.peopleCircleIcon
							.resizable()
							.scaledToFit()
							.frame(height: 18)

						Text("\(viewModel.countPart)/\(viewModel.totalPart) \(NSLocalizedString("participant", comment: ""))")
							.font(.montserratRegular(size: 12))
							.foregroundColor(.black)

						if viewModel.totalPart > 1 && !(viewModel.isLiveStream) {
							Text(NSLocalizedString("group", comment: ""))
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.foregroundColor(.black)
								.padding(.vertical, 5)
								.padding(.horizontal)
								.background(Color.secondaryViolet)
								.clipShape(Capsule())
								.overlay(
									Capsule()
										.stroke(Color.primaryViolet, lineWidth: 1.0)
								)
						} else if viewModel.isLiveStream {
							Text(LocaleText.liveStreamText)
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.foregroundColor(.black)
								.padding(.vertical, 5)
								.padding(.horizontal)
								.background(Color.secondaryViolet)
								.clipShape(Capsule())
								.overlay(
									Capsule()
										.stroke(Color.primaryViolet, lineWidth: 1.0)
								)
						} else {
							Text(NSLocalizedString("private", comment: ""))
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.foregroundColor(.black)
								.padding(.vertical, 5)
								.padding(.horizontal)
								.background(Color.secondaryViolet)
								.clipShape(Capsule())
								.overlay(
									Capsule()
										.stroke(Color.primaryViolet, lineWidth: 1.0)
								)
						}
					}

					Capsule()
						.frame(height: 1)
						.foregroundColor(.gray)
						.opacity(0.2)
				}

				VStack(spacing: 15) {
					HStack {
						Text(NSLocalizedString("total_cost", comment: ""))
							.font(.montserratRegular(size: 12))
							.foregroundColor(.black)

						Spacer()

						if let intPrice = viewModel.price.toPriceFormat() {
							Text(intPrice)
								.font(.montserratSemiBold(size: 16))
								.foregroundColor(.black)
						}
					}

					HStack {
						Text(NSLocalizedString("complete_payment_before", comment: ""))
							.font(.montserratRegular(size: 12))
							.foregroundColor(.black)

						Spacer()

						Text("\(Date().addingTimeInterval(1800).toString(format: .HHmm))")
							.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
							.foregroundColor(.black)
					}
					.padding(.horizontal)
					.padding(.vertical, 10)
					.background(Color.secondaryViolet)
					.cornerRadius(4)

					HStack {
						Button(action: {
							viewModel.isPresent.toggle()
						}, label: {
							HStack {
								Spacer()
								Text(NSLocalizedString("cancel", comment: ""))
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(.black)
								Spacer()
							}
							.padding()
							.background(Color.secondaryViolet)
							.cornerRadius(8)
							.overlay(
								RoundedRectangle(cornerRadius: 8)
									.stroke(Color.primaryViolet, lineWidth: 1.0)
							)
						})

						Spacer()
						
						Button(action: {
							DispatchQueue.main.async {
								viewModel.isPresent.toggle()
							}
							DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
								withAnimation {
									viewModel.showPaymentMenu.toggle()
								}
							}
						}, label: {
							HStack {
								Spacer()
								Text(NSLocalizedString("pay", comment: ""))
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(.white)
								Spacer()
							}
							.padding()
							.background(Color.primaryViolet)
							.cornerRadius(8)
						})
					}
					.padding(.top)
				}
			}
		}
	}

	struct RequestMenuView: View {

		@ObservedObject var viewModel: TalentProfileDetailViewModel

		var body: some View {
			VStack(spacing: 30) {
				VStack(spacing: 5) {
					Text(LocaleText.requestScheduleText)
						.font(.montserratBold(size: 14))

					Text(LocaleText.requestScheduleSubLabel)
						.font(.montserratRegular(size: 12))
						.multilineTextAlignment(.center)
				}
				.foregroundColor(.black)

				VStack(spacing: 20) {
					Button {
						viewModel.sendRequest(type: .privateType)
					} label: {
						HStack {
							Spacer()

							Text(LocaleText.requestPrivateText)
								.font(.montserratSemiBold(size: 12))
								.foregroundColor(.white)

							Spacer()
						}
					}
					.padding(.vertical)
					.background(
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor(.primaryViolet)
					)

					Button {
						viewModel.sendRequest(type: .groupType)
					} label: {
						HStack {
							Spacer()

							Text(LocaleText.requestGroupText)
								.font(.montserratSemiBold(size: 12))
								.foregroundColor(.white)

							Spacer()
						}
					}
					.padding(.vertical)
					.background(
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor(.primaryViolet)
					)

					Button {
						viewModel.sendRequest(type: .liveType)
					} label: {
						HStack {
							Spacer()

							Text(LocaleText.requestLiveText)
								.font(.montserratSemiBold(size: 12))
								.foregroundColor(.white)

							Spacer()
						}
					}
					.padding(.vertical)
					.background(
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor(.primaryViolet)
					)

					Button {
						viewModel.showingRequest = false
					} label: {
						HStack {
							Spacer()

							Text(LocaleText.cancelText)
								.font(.montserratSemiBold(size: 12))
								.foregroundColor(.black)

							Spacer()
						}
					}
					.padding(.vertical)
					.background(
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor(.secondaryViolet)
					)
					.overlay(
						RoundedRectangle(cornerRadius: 12)
							.stroke(Color.primaryViolet, lineWidth: 1)
					)
				}
			}
			.padding([.top, .trailing, .leading], -12)
			.padding(.bottom)
		}
	}
}
