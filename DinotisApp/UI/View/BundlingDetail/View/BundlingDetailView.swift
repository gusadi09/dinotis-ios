//
//  BundlingDetailView.swift
//  DinotisApp
//
//  Created by Garry on 30/09/22.
//

import SwiftUI
import SwiftUINavigation
import DinotisData
import DinotisDesignSystem
import QGrid
import StoreKit

struct BundlingDetailView: View {
    
    @ObservedObject var viewModel: BundlingDetailViewModel
	@ObservedObject var state = StateObservable.shared
	@Environment(\.dismiss) var dismiss
    let isPreview: Bool
    
    @Binding var tabValue: TabRoute
    
    var body: some View {
        GeometryReader { geo in
            
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.talentScheduleDetail,
                destination: { viewModel in
                    TalentScheduleDetailView(viewModel: viewModel.wrappedValue)
                },
                onNavigate: { _ in },
                label: {
                    EmptyView()
                }
            )

			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.editScheduleMeeting,
				destination: { viewModel in
					EditTalentMeetingView(viewModel: viewModel.wrappedValue)
				},
				onNavigate: { _ in },
				label: {
					EmptyView()
				}
			)

			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.userScheduleDetail,
				destination: { viewModel in
					UserScheduleDetail(
                        viewModel: viewModel.wrappedValue, mainTabValue: $tabValue
					)
				},
				onNavigate: {_ in},
				label: {
					EmptyView()
				}
			)
            
            ZStack {
                Color.homeBgColor.edgesIgnoringSafeArea(.all)
                
				VStack(spacing: 0) {
                    HeaderView(viewModel: viewModel, id: 0)

					if viewModel.isLoading {
						Spacer()

						ProgressView()
							.progressViewStyle(.circular)

						Spacer()
					} else {
						DinotisList {
                            Task {
                                await viewModel.getBundleDetail()
                            }
						} introspectConfig: { view in
							view.separatorStyle = .none
							view.indicatorStyle = .white
							view.sectionHeaderHeight = -10
							view.showsVerticalScrollIndicator = false
							viewModel.use(for: view) { refresh in
								DispatchQueue.main.async {
                                    Task {
                                        await viewModel.getBundleDetail()
                                    }
									refresh.endRefreshing()
								}
							}
						} content: {
                            if isPreview {
                                ForEach(viewModel.meetingData, id: \.id) { item in
                                    TalentScheduleCardView(
                                        data: .constant(item),
										isBundle: true,
                                        onTapButton: {
                                            viewModel.meetingId = item.id.orEmpty()
                                            viewModel.routeToTalentDetailSchedule()
                                        }, onTapEdit: {
                                            viewModel.meetingId = item.id.orEmpty()

											viewModel.routeToEditSchedule()
                                        }, onTapDelete: {
                                            viewModel.isShowDelete.toggle()
                                            viewModel.meetingId = item.id.orEmpty()
                                        }
                                    )
                                    .buttonStyle(.plain)
									.listRowBackground(Color.clear)
                                }
                            } else {
                                if !viewModel.isTalent {
                                    ForEach(viewModel.profileDetailBundle, id: \.id) { item in
                                        SessionCard(
                                            with: SessionCardModel(
                                                title: item.title.orEmpty(),
                                                date: DateUtils.dateFormatter(item.startAt.orCurrentDate(), forFormat: .EEEEddMMMMyyyy),
                                                startAt: DateUtils.dateFormatter(item.startAt.orCurrentDate(), forFormat: .HHmm),
                                                endAt: DateUtils.dateFormatter(item.endAt.orCurrentDate(), forFormat: .HHmm),
                                                isPrivate: item.isPrivate ?? false,
                                                isVerified: viewModel.detailData?.user?.isVerified ?? false,
                                                photo: (viewModel.detailData?.user?.profilePhoto).orEmpty(),
                                                name: (viewModel.detailData?.user?.name).orEmpty(),
                                                color: item.background,
                                                participantsImgUrl: item.participantDetails?.compactMap({
                                                    $0.profilePhoto.orEmpty()
                                                }) ?? [],
                                                isActive: item.endAt.orCurrentDate() > Date(),
                                                collaborationCount: (item.meetingCollaborations ?? []).count,
                                                collaborationName: (item.meetingCollaborations ?? []).compactMap({
                                                    (
                                                        $0.user?.name
                                                    ).orEmpty()
                                                }).joined(separator: ", "),
                                                isOnBundling: true,
                                                isAlreadyBooked: false
                                            )
                                        ) {
                                            
                                        } visitProfile: {
                                            
                                        }
                                        .buttonStyle(.plain)
                                        .listRowBackground(Color.clear)
                                    }
                                } else {
                                    ForEach(viewModel.meetingData, id: \.id) { item in
                                        TalentScheduleCardView(
                                            data: .constant(item),
											isBundle: true,
                                            onTapButton: {
                                                viewModel.meetingId = item.id.orEmpty()
                                                viewModel.routeToTalentDetailSchedule()
                                            }, onTapEdit: {
                                                viewModel.meetingId = item.id.orEmpty()

												viewModel.routeToEditSchedule()
                                            }, onTapDelete: {
                                                viewModel.isShowDelete.toggle()
                                                viewModel.meetingId = item.id.orEmpty()
                                            }
                                        )
                                        .buttonStyle(.plain)
										.listRowBackground(Color.clear)
                                    }
                                }
                            }
						}
					}

					if !viewModel.isTalent && viewModel.isActive {
						HStack(spacing: 15) {
							Image.sessionCardPricetagIcon
								.resizable()
								.scaledToFit()
								.frame(height: 20)

							VStack(alignment: .leading, spacing: 5) {
								Text((viewModel.detailData?.title).orEmpty())
									.font(.robotoBold(size: 12))
									.foregroundColor(.black)
									.lineLimit(1)

								Text(LocalizableText.totalSessionValueText(with: viewModel.meetingData.count))
									.font(.robotoRegular(size: 12))
									.foregroundColor(.DinotisDefault.black3)

								if (viewModel.detailData?.price).orEmpty() == "0" {
									Text(LocalizableText.freeText)
										.font(.robotoBold(size: 12))
										.foregroundColor(.black)
								} else {
									Text((viewModel.detailData?.price).orEmpty().toPriceFormat())
										.font(.robotoBold(size: 12))
										.foregroundColor(.black)
								}
							}

							Spacer()

							DinotisPrimaryButton(
								text: LocalizableText.bookingText,
								type: .fixed(geo.size.width/3),
								textColor: .white,
								bgColor: .DinotisDefault.primary
							) {
								viewModel.isPresent.toggle()
							}
						}
						.padding()
						.background(
							Rectangle()
								.foregroundColor(.white)
								.shadow(color: .black.opacity(0.1), radius: 10, x: 2, y: 0)
								.edgesIgnoringSafeArea(.all)
						)
					}
                }
              DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
            }
			.onAppear{
                Task {
                    viewModel.onAppear(isPreview: isPreview)
                    await viewModel.getUsers()
                }
			}
			.onDisappear(perform: {
				viewModel.onDisappear()
			})
			.sheet(
				isPresented: $viewModel.isPresent,
				content: {
					if #available(iOS 16.0, *) {
						SlideOverCardView(viewModel: viewModel)
							.padding()
							.padding(.vertical)
							.padding(.top)
							.presentationDetents([.fraction(0.6), .large])
                            .dynamicTypeSize(.large)
					} else {
						SlideOverCardView(viewModel: viewModel)
							.padding()
							.padding(.vertical)
							.padding(.top)
                            .dynamicTypeSize(.large)
					}

				}
			)
			.sheet(
				isPresented: $viewModel.showPaymentMenu,
				content: {
                    if #available(iOS 16.0, *) {
                        PaymentTypeOption(viewModel: viewModel)
                            .padding(.top)
                            .padding()
                            .padding(.vertical)
                            .presentationDetents([.height(130)])
                            .dynamicTypeSize(.large)
					} else {
						ScrollView {
							PaymentTypeOption(viewModel: viewModel)
								.padding(.top)
								.padding()
								.padding(.vertical)
                                .dynamicTypeSize(.large)
						}
						.padding(.top)
					}
				}
			)
			.sheet(
				isPresented: $viewModel.isShowCoinPayment,
				onDismiss: {
					viewModel.resetStateCode()
				},
				content: {
					if #available(iOS 16.0, *) {
                        CoinPaymentSheetView(viewModel: viewModel, tabValue: $tabValue)
							.padding()
							.padding(.vertical)
							.presentationDetents([.fraction(0.8), .large])
                            .dynamicTypeSize(.large)
					} else {
                        CoinPaymentSheetView(viewModel: viewModel, tabValue: $tabValue)
							.padding()
							.padding(.vertical)
                            .dynamicTypeSize(.large)
					}
				}
			)
			.sheet(
				isPresented: $viewModel.showAddCoin,
				content: {
					if #available(iOS 16.0, *) {
						AddCoinSheetView(viewModel: viewModel, geo: geo)
							.padding()
							.padding(.vertical)
							.presentationDetents([.fraction(0.85), .large])
                            .dynamicTypeSize(.large)
					} else {
						AddCoinSheetView(viewModel: viewModel, geo: geo)
							.padding()
							.padding(.vertical)
                            .dynamicTypeSize(.large)
					}
				}
			)
			.sheet(
				isPresented: $viewModel.isTransactionSucceed,
				content: {
					if #available(iOS 16.0, *) {
						CoinBuySucceed(geo: geo)
							.padding()
							.padding(.vertical)
							.presentationDetents([.fraction(0.5), .large])
                            .dynamicTypeSize(.large)
					} else {
						CoinBuySucceed(geo: geo)
							.padding()
							.padding(.vertical)
                            .dynamicTypeSize(.large)
					}

				}
			)
			.dinotisAlert(
				isPresent: $viewModel.isShowAlert,
        title: viewModel.alert.title,
        isError: viewModel.alert.isError,
        message: viewModel.alert.message,
        primaryButton: viewModel.alert.primaryButton,
        secondaryButton: viewModel.alert.secondaryButton
			)
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
        }
    }
}

extension BundlingDetailView {
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
						.font(.robotoBold(size: 16))
						.foregroundColor(.black)
				}

				Spacer()

			}
			.padding(.vertical)
		}
	}
	
    struct HeaderView: View {
        @Environment(\.dismiss) var dismiss
        
        @ObservedObject var viewModel: BundlingDetailViewModel
        
        var id: Int
        
        var body: some View {
            ZStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image.Dinotis.arrowBackIcon
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    })
                    .padding(10)
                    
                    Spacer()
                }
                
				Text((viewModel.detailData?.title).orEmpty())
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: UIScreen.main.bounds.width - 120)
            }
			.padding(.bottom, 2)
        }
    }

	struct AddCoinSheetView: View {

		@ObservedObject var viewModel: BundlingDetailViewModel
		let geo: GeometryProxy

		var body: some View {
			VStack(spacing: 20) {

				VStack {
					Text(LocaleText.homeScreenYourCoin)
						.font(.robotoRegular(size: 12))
						.foregroundColor(.black)

					HStack(alignment: .top) {
						Image.Dinotis.coinIcon
							.resizable()
							.scaledToFit()
							.frame(height: geo.size.width/28)

                        Text("\((viewModel.userData?.coinBalance?.current).orEmpty().toPriceFormat())")
							.font(.robotoBold(size: 14))
							.foregroundColor(.DinotisDefault.primary)
					}
					.multilineTextAlignment(.center)

					Text(LocaleText.homeScreenCoinDetail)
						.font(.robotoRegular(size: 10))
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
								.font((viewModel.productSelected ?? SKProduct()).id == item.id ? .robotoBold(size: 12) : .robotoRegular(size: 12))
								.foregroundColor(.DinotisDefault.primary)
								.padding(10)
								.background(
									RoundedRectangle(cornerRadius: 12)
										.foregroundColor((viewModel.productSelected ?? SKProduct()).id == item.id ? .secondaryViolet : .clear)
								)
								.overlay(
									RoundedRectangle(cornerRadius: 12)
										.stroke(Color.DinotisDefault.primary, lineWidth: 1)
								)
							}
						}
					}
				}
				.frame(height: 250)

				Spacer()

				VStack {
					Button {
						if let product = viewModel.productSelected {
							viewModel.purchaseProduct(product: product)
						}
					} label: {
						HStack {
							Spacer()

							Text(LocaleText.homeScreenAddCoin)
								.font(.robotoMedium(size: 12))
								.foregroundColor(viewModel.isLoadingTrxs || viewModel.productSelected == nil ? Color(.systemGray2) : .white)

							Spacer()
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 12)
								.foregroundColor(viewModel.isLoadingTrxs || viewModel.productSelected == nil ? Color(.systemGray5) : .DinotisDefault.primary)
						)
					}
					.disabled(viewModel.isLoadingTrxs || viewModel.productSelected == nil)

					Button {
						viewModel.openWhatsApp()
					} label: {
						HStack {
							Spacer()

							Text(LocaleText.helpText)
								.font(.robotoMedium(size: 12))
								.foregroundColor(viewModel.isLoadingTrxs ? Color(.systemGray2) : .DinotisDefault.primary)

							Spacer()
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 12)
								.foregroundColor(viewModel.isLoadingTrxs ? Color(.systemGray5) : .secondaryViolet)
						)
						.overlay(
							RoundedRectangle(cornerRadius: 12)
								.stroke(viewModel.isLoadingTrxs ? Color(.systemGray2) : Color.DinotisDefault.primary, lineWidth: 1)
						)
					}
					.disabled(viewModel.isLoadingTrxs)

				}

			}
		}
	}

	struct CoinPaymentSheetView: View {

		@ObservedObject var viewModel: BundlingDetailViewModel
        @Binding var tabValue: TabRoute

		var body: some View {
			VStack(spacing: 15) {
				HStack {
					VStack(alignment: .leading, spacing: 10) {
						Text(LocaleText.homeScreenYourCoin)
							.font(.robotoMedium(size: 12))
							.foregroundColor(.black)

						HStack(alignment: .top) {
							Image.Dinotis.coinIcon
								.resizable()
								.scaledToFit()
								.frame(height: 15)

                            Text("\((viewModel.userData?.coinBalance?.current).orEmpty().toPriceFormat())")
								.font(.robotoBold(size: 14))
								.foregroundColor((Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) >= viewModel.totalPayment ? .DinotisDefault.primary : .red)
						}
					}

					Spacer()

					if (Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment {
						Button {
							DispatchQueue.main.async {
								viewModel.isShowCoinPayment.toggle()
							}
							DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
								viewModel.showAddCoin.toggle()
							}
						} label: {
							Text(LocaleText.homeScreenAddCoin)
								.font(.robotoMedium(size: 12))
								.foregroundColor(.DinotisDefault.primary)
								.padding(15)
								.overlay(
									RoundedRectangle(cornerRadius: 10)
										.stroke(Color.DinotisDefault.primary, lineWidth: 1)
								)
						}

					}
				}
				.padding()
				.background(RoundedRectangle(cornerRadius: 12).foregroundColor(.secondaryViolet))

				VStack(alignment: .leading) {
					Text(LocaleText.paymentScreenPromoCodeTitle)
						.font(.robotoMedium(size: 12))
						.foregroundColor(.black)

					VStack(alignment: .leading, spacing: 10) {
						HStack {

							Group {
								if viewModel.promoCodeSuccess {
									HStack {
										Text(viewModel.promoCode)
											.font(.robotoRegular(size: 12))
											.foregroundColor(viewModel.promoCodeSuccess ? Color(.systemGray) : .black)

										Spacer()
									}
								} else {
									TextField(LocaleText.paymentScreenPromoCodePlaceholder, text: $viewModel.promoCode)
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

							Button {
								Task {
									if viewModel.promoCodeData != nil {
										viewModel.resetStateCode()
									} else {
										await viewModel.checkPromoCode()
									}
								}
							} label: {
								HStack {
									Text(viewModel.promoCodeSuccess ? LocaleText.changeVoucherText : LocaleText.applyText)
										.font(.robotoMedium(size: 12))
										.foregroundColor(viewModel.promoCode.isEmpty ? Color(.systemGray2) : .white)
								}
								.padding()
								.padding(.horizontal, 5)
								.background(
									RoundedRectangle(cornerRadius: 12)
										.foregroundColor(viewModel.promoCodeSuccess ? .red : (viewModel.promoCode.isEmpty ? Color(.systemGray5) : .DinotisDefault.primary))
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
				.padding()
				.background(RoundedRectangle(cornerRadius: 12).foregroundColor(.secondaryViolet))

				VStack(alignment: .leading, spacing: 10) {

					HStack {
						Text(LocaleText.paymentText)
							.font(.robotoMedium(size: 12))
							.foregroundColor(.black)

						Spacer()

						Text(LocaleText.coinSingleText)
							.font(.robotoMedium(size: 12))
							.foregroundColor(.black)
					}

					HStack {
						Text(LocaleText.subtotalText)
							.font(.robotoMedium(size: 12))
							.foregroundColor(.black)

						Spacer()

						Text("\(Int((viewModel.detailData?.price).orEmpty()).orZero())")
							.font(.robotoMedium(size: 12))
							.foregroundColor(.black)
					}

					VStack(alignment: .leading, spacing: 10) {
						HStack {
							Text(LocaleText.applicationFeeText)
								.font(.robotoMedium(size: 12))
								.foregroundColor(.black)

							Spacer()

							Text("\(viewModel.extraFee)")
								.font(.robotoMedium(size: 12))
								.foregroundColor(.black)
						}

						if (viewModel.promoCodeData?.discountTotal).orZero() != 0 {
							HStack {
								Text(LocaleText.discountText)
									.font(.robotoMedium(size: 12))
									.foregroundColor(.black)

								Spacer()

								Text("-\((viewModel.promoCodeData?.discountTotal).orZero())")
									.font(.robotoMedium(size: 12))
									.foregroundColor(.red)
							}
						} else if (viewModel.promoCodeData?.amount).orZero() != 0 && (viewModel.promoCodeData?.discountTotal).orZero() == 0 {
							HStack {
								Text(LocaleText.discountText)
									.font(.robotoMedium(size: 12))
									.foregroundColor(.black)

								Spacer()

								Text("-\((viewModel.promoCodeData?.amount).orZero())")
									.font(.robotoMedium(size: 12))
									.foregroundColor(.red)
							}
						}
					}
					.padding(.bottom, 30)

					RoundedRectangle(cornerRadius: 10)
						.frame(height: 1.5)
						.foregroundColor(.DinotisDefault.primary)

					HStack {
						Text(LocaleText.totalPaymentText)
							.font(.robotoBold(size: 12))
							.foregroundColor(.black)

						Spacer()

						Text("\(viewModel.totalPayment)")
							.font(.robotoBold(size: 12))
							.foregroundColor(.black)
					}

				}
				.padding()
				.background(RoundedRectangle(cornerRadius: 12).foregroundColor(.secondaryViolet))

				Spacer()

				Button {
					Task {
                        await viewModel.coinPayment(onSuccess: { tabValue = .agenda })
					}
				} label: {
					HStack {
						Spacer()

						if viewModel.isLoadingCoinPay {
							ProgressView()
								.progressViewStyle(CircularProgressViewStyle(tint: .white))
						} else {
							Text(LocaleText.payNowText)
								.font(.robotoMedium(size: 12))
								.foregroundColor((Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment ? Color(.systemGray) : .white)
						}

						Spacer()
					}
					.padding(.vertical, 15)
					.background(
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor((Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment ? Color(.systemGray4) : .DinotisDefault.primary)
					)
				}
				.disabled((Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment || viewModel.isLoadingCoinPay)

			}
		}
	}

	struct PaymentTypeOption: View {
		@ObservedObject var viewModel: BundlingDetailViewModel

		var body: some View {
			VStack {
                Spacer()
				Button {
					DispatchQueue.main.async {
						viewModel.showPaymentMenu.toggle()
					}
					DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
						withAnimation {
							viewModel.onPaymentTypeOption()
						}
					}
				} label: {
					HStack(spacing: 15) {
						Image.Dinotis.coinIcon
							.resizable()
							.scaledToFit()
							.frame(height: 15)

						Text(LocaleText.coinPaymentText)
							.font(.robotoMedium(size: 12))
							.foregroundColor(.DinotisDefault.primary)

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

private extension BundlingDetailView {
	struct SlideOverCardView: View {

		@ObservedObject var viewModel: BundlingDetailViewModel

		var body: some View {
			VStack(alignment: .leading, spacing: 10) {
				ScrollView {
					VStack(alignment: .leading, spacing: 10) {
						HStack {
                            ProfileImageContainer(profilePhoto: .constant((viewModel.detailData?.user?.profilePhoto).orEmpty()), name: .constant((viewModel.detailData?.user?.name).orEmpty()), width: 40, height: 40)

							Text((viewModel.detailData?.user?.name).orEmpty())
								.font(.robotoBold(size: 14))
								.minimumScaleFactor(0.8)
								.lineLimit(1)

                            if viewModel.detailData?.user?.isVerified ?? false {
								Image.Dinotis.accountVerifiedIcon
									.resizable()
									.scaledToFit()
									.frame(height: 16)
							}

							Spacer()

						}
						.padding(.bottom, 10)

						Text((viewModel.detailData?.title).orEmpty())
							.font(.robotoBold(size: 14))
							.foregroundColor(.black)

						Text((viewModel.detailData?.description).orEmpty())
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
							.padding(.bottom, 10)

						HStack(spacing: 10) {
							Image.Dinotis.calendarIcon
								.resizable()
								.scaledToFit()
								.frame(height: 18)

								Text(LocaleText.sessionCountText(count: viewModel.meetingData.count))
									.font(.robotoRegular(size: 12))
									.foregroundColor(.black)
						}

						Capsule()
							.frame(height: 1)
							.foregroundColor(.gray)
							.opacity(0.2)

						HStack {
							Text(NSLocalizedString("total_cost", comment: ""))
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)

							Spacer()

							if (viewModel.detailData?.price).orEmpty() == "0" {
								Text(LocalizableText.freeText)
									.font(.robotoMedium(size: 16))
                                    .foregroundColor(.black)
                            } else {
                                Text((viewModel.detailData?.price).orEmpty().toPriceFormat())
                                    .font(.robotoMedium(size: 16))
                                    .foregroundColor(.black)
                            }
						}


						HStack {
							Text(NSLocalizedString("complete_payment_before", comment: ""))
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)

							Spacer()

							Text("\(DateUtils.dateFormatter(Date().addingTimeInterval(1800), forFormat: .HHmm))")
                                .font(.robotoMedium(size: 12))
								.foregroundColor(.black)
						}
						.padding(.horizontal)
						.padding(.vertical, 10)
						.background(Color.secondaryViolet)
						.cornerRadius(4)
					}
				}

				VStack(spacing: 15) {

					HStack {
						Button(action: {
							viewModel.isPresent.toggle()
						}, label: {
							HStack {
								Spacer()
								Text(NSLocalizedString("cancel", comment: ""))
									.font(.robotoMedium(size: 12))
									.foregroundColor(.black)
								Spacer()
							}
							.padding()
							.background(Color.secondaryViolet)
							.cornerRadius(8)
							.overlay(
								RoundedRectangle(cornerRadius: 8)
									.stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
							)
						})

						Spacer()

						Button(action: {
							DispatchQueue.main.async {
								viewModel.isPresent.toggle()
							}
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
								if (viewModel.detailData?.price).orEmpty() == "0" {
									viewModel.onSendFreePayment()
								} else {
									withAnimation {
										viewModel.showPaymentMenu.toggle()
									}
								}
							}
						}, label: {
							HStack {
								Spacer()
								Text(NSLocalizedString("pay", comment: ""))
									.font(.robotoMedium(size: 12))
									.foregroundColor(.white)
								Spacer()
							}
							.padding()
							.background(Color.DinotisDefault.primary)
							.cornerRadius(8)
						})
					}
					.padding(.top)
				}
			}
		}
	}
}

struct BundlingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BundlingDetailView(viewModel: BundlingDetailViewModel(bundleId: "", meetingIdArray: ["",""], backToHome: {}, isTalent: true, isActive: false), isPreview: false, tabValue: .constant(.agenda))
    }
}
