//
//  TalentProfileDetailView.swift
//  DinotisApp
//
//  Created by Gus Adi on 25/08/21.
//

import SwiftUI
import SlideOverCard
import CurrencyFormatter
import SwiftUINavigation
import Lottie
import QGrid
import StoreKit

struct TalentProfileDetailView: View {

	@ObservedObject var viewModel: TalentProfileDetailViewModel

	@Environment(\.presentationMode) var presentationMode

	var body: some View {

		GeometryReader { geo in
			ZStack(alignment: .center) {
				Color.secondaryBackground.edgesIgnoringSafeArea(.all)
					.alert(isPresented: $viewModel.isRefreshFailed) {
						Alert(
							title: Text(LocaleText.attention),
							message: Text(LocaleText.sessionExpireText),
							dismissButton: .default(Text(LocaleText.returnText), action: {
								viewModel.routeToRoot()
							})
						)
					}
					.dinotisSheet(
						isPresented: $viewModel.isPresent,
						options: .hideDismissButton,
						fraction: 0.75,
						content: {
							SlideOverCardView(viewModel: viewModel)
						}
					)
					.dinotisSheet(
						isPresented: $viewModel.showPaymentMenu,
						fraction: viewModel.totalPart > 1 ? 0.25 : 0.4,
						content: {
							PaymentTypeOption(viewModel: viewModel)
								.padding(.top)

						}
					)
					.dinotisSheet(
						isPresented: $viewModel.isShowCoinPayment,
						onDismiss: {
							viewModel.resetStateCode()
						},
						options: viewModel.isLoadingCoinPay ? SOCOptions.hideDismissButton : SOCOptions.disableDrag,
						content: {
							CoinPaymentSheetView(viewModel: viewModel)
						}
					)
					.dinotisSheet(
						isPresented: $viewModel.showAddCoin,
						fraction: 0.85,
						content: {
							AddCoinSheetView(viewModel: viewModel, geo: geo)
						}
					)
					.dinotisSheet(
						isPresented: $viewModel.isTransactionSucceed,
						fraction: 0.5,
						content: {
							CoinBuySucceed(geo: geo)
						}
					)

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /HomeRouting.talentProfileDetail,
					destination: { viewModel in
						TalentProfileDetailView(viewModel: viewModel.wrappedValue)
					},
					onNavigate: {_ in},
					label: {
						EmptyView()
					}
				)

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /HomeRouting.bookingInvoice,
					destination: { viewModel in
						UserInvoiceBookingView(
							bookingId: self.viewModel.invoiceNumber,
							viewModel: viewModel.wrappedValue
						)
					},
					onNavigate: {_ in},
					label: {
						EmptyView()
					}
				)
				.alert(isPresented: $viewModel.freeTrans) {
					Alert(
						title: Text(LocaleText.successTitle),
						message: Text(LocaleText.successLabels),
						dismissButton: .default(Text(LocaleText.okText), action: {
							viewModel.backToHome()
						})
					)
				}

				VStack(spacing: 0) {

					HeaderView(viewModel: viewModel)
						.padding(.top, 5)
						.padding(.bottom)
						.background(Color.clear)
						.alert(isPresented: $viewModel.requestSuccess) {
							Alert(
								title: Text(LocaleText.requestSuccessTitle),
								message: Text(LocaleText.requestSuccessSubtitle),
								dismissButton: .default(Text(LocaleText.okText))
							)
						}

					DinotisList { view in
						view.separatorStyle = .none
						view.showsVerticalScrollIndicator = false
						viewModel.use(for: view) { refresh in
							DispatchQueue.main.async {
								refresh.endRefreshing()
							}
						}
					} content: {
						Group {
							if !viewModel.profileBannerContent.isEmpty {
								ProfileBannerView(content: $viewModel.profileBannerContent, geo: geo)
									.background(Color.secondaryBackground)
							} else {
								SingleProfileImageBanner(
									profilePhoto: $viewModel.talentPhoto,
									name: $viewModel.talentName,
									width: geo.size.width/1.07,
									height: geo.size.height/2
								)
							}
						}
						.padding(.bottom, 15)
						.listRowBackground(Color.clear)

						VStack(spacing: 25) {
							HStack(spacing: 15) {
								ProfileImageContainer(
									profilePhoto: $viewModel.talentPhoto,
									name: $viewModel.talentName,
									width: 56,
									height: 56
								)
								.onAppear {
									UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(named: "btn-stroke-1")
									UIPageControl.appearance().pageIndicatorTintColor = UIColor(named: "btn-color-1")
								}

								VStack(alignment: .leading, spacing: 10) {
									HStack(spacing: 5) {
										Text(viewModel.talentName ?? "")
											.font(Font.custom(FontManager.Montserrat.semibold, size: 14))
											.minimumScaleFactor(0.9)
											.lineLimit(1)
											.foregroundColor(.black)

										if viewModel.talentData?.isVerified ?? false {
											Image.Dinotis.accountVerifiedIcon
												.resizable()
												.scaledToFit()
												.frame(height: 16)
										}
									}

									HStack {
										Image.Dinotis.suitcaseIcon
											.resizable()
											.scaledToFit()
											.frame(height: 12)

										if let manageTalent = viewModel.talentData?.userManagement?.userManagementTalents, !manageTalent.isEmpty {
											Text("Management")
												.font(.montserratRegular(size: 12))
												.foregroundColor(.black)
										} else {
											viewModel.textJob
										}

									}
								}
								.valueChanged(value: viewModel.talentData?.name) { _ in
									for item in viewModel.talentData?.professions ?? [] {
										viewModel.textJob = viewModel.textJob + Text(" \(item.profession.name.orEmpty()) ")
											.font(.montserratRegular(size: 12))
											.foregroundColor(.black)
									}
								}

								Spacer()

								Button(action: {
									viewModel.shareSheet(url: "\(viewModel.config.environment.openURL)/user/talent/" + (viewModel.talentData?.username).orEmpty())
								}, label: {
									Image.Dinotis.shareIcon
										.resizable()
										.scaledToFit()
										.frame(height: 36)
								})

							}
							.buttonStyle(.plain)

							HStack {
								Spacer()

								Text((viewModel.talentData?.profileDescription).orEmpty())
									.font(.montserratRegular(size: 12))
									.foregroundColor(.black)
									.padding(.horizontal)
									.padding(.vertical, 20)
									.multilineTextAlignment(.center)

								Spacer()
							}
							.background(Color.white)
							.cornerRadius(12)

							if let talentManaged = viewModel.talentData?.userManagement?.userManagementTalents {
								VStack(spacing: 5) {
									HStack {
										Text(LocaleText.talentDetailMyTalent)
											.font(.montserratBold(size: 14))
											.padding(.top, 10)

										Spacer()
									}

									ScrollView(.horizontal, showsIndicators: false) {
										HStack(spacing: 15) {
											ForEach(talentManaged, id: \.id) { item in
												if let talent = item.user {
													TalentSearchCard(
														onTapSee: {
															viewModel.routeToMyTalent(talent: talent.username.orEmpty())
														},
														user: .constant(talent)
													)
												}
											}
										}
										.padding(.horizontal)
										.padding(.vertical, 15)
									}
								}
							}

							if let management =  viewModel.talentData?.userManagementTalent?.userManagement {
								Button {
									viewModel.routeToManagement()
								} label: {
									HStack {
										Spacer()

										Text(LocaleText.talentDetailManaged(code: management.code.orEmpty()))
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

							if viewModel.talentData?.userManagement == nil {
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
							}
						}
						.padding([.leading, .trailing, .top])
						.background(Color.secondaryBackground)
						.listRowInsets(EdgeInsets(top: -10, leading: 20, bottom: -10, trailing: 20))
						.dinotisSheet(
							isPresented: $viewModel.showingRequest,
							options: .hideDismissButton,
							fraction: 0.75,
							content: {
								RequestMenuView(viewModel: viewModel)
									.padding()
							}
						)

						Section {
							ScheduleTalent(viewModel: viewModel)
								.padding(.top, 10)
								.background(Color.secondaryBackground)
						} header: {
							CardProfile(viewModel: viewModel)
								.padding(.top, -10)
						}
						.listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
						.listRowBackground(Color.clear)
						.onChange(of: viewModel.filterSelection) { newValue in
							if let optionLabel = viewModel.filterOption.firstIndex(where: { query in
								query.label.orEmpty() == newValue
							}) {
								if newValue == viewModel.filterOption[optionLabel].label.orEmpty() {
									if let isEnded = viewModel.filterOption[optionLabel].queries?.firstIndex(where: { option in
										option.name.orEmpty() == "is_ended"
									}) {
										viewModel.meetingParam.isEnded = (viewModel.filterOption[optionLabel].queries?[isEnded].value).orEmpty()
									} else {
										viewModel.meetingParam.isEnded = ""
									}

									if let isAvail = viewModel.filterOption[optionLabel].queries?.firstIndex(where: { option in
										option.name.orEmpty() == "is_available"
									}) {
										viewModel.meetingParam.isAvailable = (viewModel.filterOption[optionLabel].queries?[isAvail].value).orEmpty()
									} else {
										viewModel.meetingParam.isAvailable = ""
									}
								}

								viewModel.meetingData = []
								viewModel.meetingParam.skip = 0
								viewModel.meetingParam.take = 15
								viewModel.getTalentMeeting(by: (viewModel.talentData?.id).orEmpty())
							}
						}
					}
					.padding(.horizontal, -20)
					.background(Color.secondaryBackground)

					NavigationLink(
						unwrapping: $viewModel.route,
						case: /HomeRouting.paymentMethod,
						destination: {viewModel in
							PaymentMethodView(viewModel: viewModel.wrappedValue)
						},
						onNavigate: {_ in},
						label: {
							EmptyView()
						}
					)
					.alert(isPresented: $viewModel.isError) {
						Alert(
							title: Text(LocaleText.errorText),
							message: Text((viewModel.error?.errorDescription).orEmpty()),
							dismissButton: .default(Text(LocaleText.okText))
						)
					}

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
				}

				LoadingView(isAnimating: $viewModel.isLoading)
					.isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)
			}
			.onAppear(perform: {
				Task.init {
					await viewModel.onScreenAppear()
					viewModel.getProductOnAppear()
					AppDelegate.orientationLock = .portrait
				}
			})
			.onDisappear(perform: {
				viewModel.onDisappearView()
			})
			.valueChanged(value: viewModel.success, onChange: { value in
				if value {
					viewModel.talentName = viewModel.talentData?.name
					viewModel.talentPhoto = viewModel.talentData?.profilePhoto
				}
			})
			.navigationBarTitle(Text(""))
			.navigationBarHidden(true)
		}
	}
}

struct TalentProfileDetailView_Previews: PreviewProvider {
	static var previews: some View {
		TalentProfileDetailView(viewModel: TalentProfileDetailViewModel(backToRoot: {}, backToHome: {}, username: "ramzramzz"))
	}
}
