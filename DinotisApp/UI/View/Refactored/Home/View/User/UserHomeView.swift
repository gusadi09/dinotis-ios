//
//  UserHomeView.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/08/21.
//

import SwiftUI
import Introspect
import QGrid
import StoreKit

struct UserHomeView: View {
	
	@ObservedObject var homeVM: UserHomeViewModel
	@ObservedObject var state = StateObservable.shared
	
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	var body: some View {
		GeometryReader { geo in
			ZStack {
				
				NavigationHelper(homeVM: homeVM)
				
				ZStack(alignment: .center) {
					
					ZStack(alignment: .bottomTrailing) {
						Color.homeBgColor
							.edgesIgnoringSafeArea(.bottom)
						
						VStack(spacing: 0) {
							Color.white.edgesIgnoringSafeArea(.all)
								.frame(height: 10)
								.alert(isPresented: $homeVM.isError) {
									Alert(
										title: Text(LocaleText.attention),
										message: Text(homeVM.errorText()),
										dismissButton: .default(Text(LocaleText.returnText))
									)
								}
							
							HeaderView(homeVM: homeVM)
								.alert(isPresented: $homeVM.isRefreshFailed) {
									Alert(
										title: Text(LocaleText.attention),
										message: Text(LocaleText.sessionExpireText),
										dismissButton: .default(Text(LocaleText.returnText), action: {
											self.homeVM.routeBack()
										})
									)
								}
								.onChange(of: state.isGoToDetailSchedule) { value in
									if value {
										homeVM.routeToScheduleList()
									}
								}
							
							ScrollViewReader { scroll in
								DinotisList { view in
									view.separatorStyle = .none
									view.indicatorStyle = .white
									view.sectionHeaderHeight = -10
									view.showsVerticalScrollIndicator = false
									homeVM.use(for: view) { refresh in
										Task {
											await homeVM.onScreenAppear(geo: geo)
											refresh.endRefreshing()
										}
									}
								} content: {
									VStack {
										VStack(spacing: 15) {

											HStack {
												VStack(alignment: .leading) {
													Text(LocaleText.homeScreenYourCoin)
														.font(.montserratRegular(size: 12))
														.foregroundColor(.black)

													HStack(alignment: .top) {
														Image.Dinotis.coinIcon
															.resizable()
															.scaledToFit()
															.frame(height: 15)

														Text("\(homeVM.userData?.coinBalance?.current ?? 0)")
															.font(.montserratBold(size: 14))
															.foregroundColor(.primaryViolet)
													}
												}

												Spacer()

												Button {
													homeVM.routeToCoinHistory()
												} label: {
													Image(systemName: "clock.arrow.circlepath")
														.resizable()
														.scaledToFit()
														.frame(height: 16)
														.foregroundColor(.primaryViolet)
														.padding(15)
														.overlay(
															RoundedRectangle(cornerRadius: 10)
																.stroke(Color.primaryViolet, lineWidth: 1)
														)
												}

												Button {
													homeVM.showAddCoin.toggle()
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
											.multilineTextAlignment(.center)
											.padding(.horizontal, 15)
											.padding(.vertical, 25)
											.background(
												RoundedRectangle(cornerRadius: 15)
													.foregroundColor(.secondaryViolet)
											)
											.padding([.horizontal, .top])
											.buttonStyle(.plain)

											CategoryList(geo: geo, homeVM: homeVM)
												.buttonStyle(.plain)

											if let notice = homeVM.latestNotice.first {
												HStack(spacing: 20) {
													Image.Dinotis.noticeIcon
														.resizable()
														.scaledToFit()
														.frame(height: 20)

													VStack(alignment: .leading, spacing: 8) {
														Text(notice.title.orEmpty())
															.font(.montserratBold(size: 12))

														Text(notice.description.orEmpty())
															.font(.montserratRegular(size: 10))
															.lineLimit(nil)
															.fixedSize(horizontal: false, vertical: true)
													}
													.foregroundColor(.black)
													.multilineTextAlignment(.leading)
												}
												.padding()
												.background(
													RoundedRectangle(cornerRadius: 12)
														.foregroundColor(.secondaryViolet)
												)
												.padding(.horizontal, 10)
												.padding(.bottom, 5)
											}

											VideoCallScheduleSection(homeVM: homeVM, geo: geo)
												.buttonStyle(.plain)
												.padding(.bottom, 10)

											if !homeVM.firstBannerContents.isEmpty {
												PromotionBannerView(content: $homeVM.firstBannerContents, geo: geo)
											}

											ForEach(homeVM.homeContent, id:\.id) {
												item in

												VStack(spacing: 5) {
													HStack {
														Text(item.name.orEmpty())
															.font(.montserratBold(size: 14))
															.padding(.top, 10)
															.padding(.horizontal)

														Spacer()
													}

													ScrollView(.horizontal, showsIndicators: false) {
														HStack(spacing: 15) {
															ForEach(item.talentHomeTalentList ?? [], id: \.id) { item in
																if let talent = item.user {
																	TalentSearchCard(
																		onTapSee: {
																			homeVM.username = item.user?.username
																			homeVM.routeToTalentProfile()
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

											if !homeVM.secondBannerContents.isEmpty {
												PromotionBannerView(content: $homeVM.secondBannerContents, geo: geo)
													.padding(.top, 10)
											}

											if let original = homeVM.originalSectionContent?.data {

												ForEach(original, id: \.id) { item in
													VStack(spacing: 5) {
														HStack {
															Text(item.name.orEmpty())
																.font(.montserratBold(size: 14))
																.padding(.top, 10)
																.padding(.horizontal)

															Spacer()
														}

														ScrollView(.horizontal, showsIndicators: false) {
															HStack(spacing: 15) {
																ForEach(item.landingPageListContentList, id: \.id) { item in
																	if let user = item.user, let meeting = item.meeting {
																		HomePrivateFeatureCard(
																			user: .constant(user),
																			meeting: .constant(meeting),
																			onTapProfile: {
																				homeVM.username = user.username
																				homeVM.routeToTalentProfile()
																			}
																		)
																	}
																}
															}
															.padding(.horizontal)
															.padding(.vertical, 15)
														}
													}
													.isHidden(
														item.landingPageListContentList.isEmpty, remove: item.landingPageListContentList.isEmpty
													)
												}
											}

											if !homeVM.privateScheduleContent.isEmpty {
												VStack(spacing: 5) {
													HStack {
														Text(LocaleText.homeScreenPrivateVideo)
															.font(.montserratBold(size: 14))
															.padding(.top, 10)
															.padding(.horizontal)

														Spacer()
													}

													ScrollView(.horizontal, showsIndicators: false) {
														HStack(spacing: 15) {
															ForEach(homeVM.privateScheduleContent, id: \.id) { item in
																if let user = item.user {
																	HomePrivateFeatureCard(
																		user: .constant(user),
																		meeting: .constant(item),
																		onTapProfile: {
																			homeVM.username = user.username
																			homeVM.routeToTalentProfile()
																		}
																	)
																}
															}
														}
														.padding(.horizontal)
														.padding(.vertical, 15)
													}
												}
											}

											if !homeVM.groupScheduleContent.isEmpty {
												VStack(spacing: 5) {
													HStack {
														Text(LocaleText.homeScreenGroupVideo)
															.font(.montserratBold(size: 14))
															.padding(.top, 10)
															.padding(.horizontal)

														Spacer()
													}

													ScrollView(.horizontal, showsIndicators: false) {
														HStack(spacing: 15) {
															ForEach(homeVM.groupScheduleContent, id: \.id) { item in
																if let user = item.user {
																	HomePrivateFeatureCard(
																		user: .constant(user),
																		meeting: .constant(item),
																		onTapProfile: {
																			homeVM.username = user.username
																			homeVM.routeToTalentProfile()
																		}
																	)
																}
															}
														}
														.padding(.horizontal)
														.padding(.vertical, 15)
													}
												}
											}
										}
									}
									.listRowBackground(Color.clear)
									.id(0)

									Section {
										VStack {
											if homeVM.searchResult.isEmpty && !homeVM.isSearchLoading {
												EmptySearch()
													.padding(.bottom)
											} else {
												ForEach(homeVM.searchResult.filter({ value in
													if homeVM.selectedProfession != 0 {
														return value.professions?.contains(where: { value in
															value.profession.id == homeVM.selectedProfession
														}) ?? false
													} else {
														return true
													}
												}), id: \.id) { items in
													if #available(iOS 14.0, *) {
														LazyVStack(spacing: -10) {
															if items.id == (homeVM.searchResult.last?.id).orEmpty() {
																Button {
																	homeVM.username = items.username.orEmpty()
																	homeVM.routeToTalentProfile()
																} label: {
																	TalentSearchVerticalCardView(
																		user: items,
																		isLast: true,
																		take: $homeVM.takeItem
																	)
																}
																.buttonStyle(.plain)
																.padding(.bottom, -20)
															} else {
																Button {
																	homeVM.username = items.username.orEmpty()
																	homeVM.routeToTalentProfile()
																} label: {
																	TalentSearchVerticalCardView(
																		user: items,
																		isLast: false,
																		take: $homeVM.takeItem
																	)
																}
																.buttonStyle(.plain)
																.padding(.bottom, -20)
															}
														}
														.padding(.bottom)
														.padding(.top, 10)
													} else {
														VStack(spacing: -10) {
															if items.id == (homeVM.searchResult.last?.id).orEmpty() {
																Button {
																	homeVM.username = items.username.orEmpty()
																	homeVM.routeToTalentProfile()
																} label: {
																	TalentSearchVerticalCardView(
																		user: items,
																		isLast: true,
																		take: $homeVM.takeItem
																	)
																}
																.buttonStyle(.plain)
																.padding(.bottom, -20)
															} else {
																Button {
																	homeVM.username = items.username.orEmpty()
																	homeVM.routeToTalentProfile()
																} label: {
																	TalentSearchVerticalCardView(
																		user: items,
																		isLast: false,
																		take: $homeVM.takeItem
																	)
																}
																.buttonStyle(.plain)
																.padding(.bottom, -20)
															}
														}
														.padding(.bottom)
														.padding(.top, 10)
													}
												}
											}

											HStack {
												Spacer()

												ActivityIndicator(isAnimating: $homeVM.isLoading, color: .black, style: .medium)
													.padding()

												Spacer()
											}
											.isHidden(!homeVM.isSearchLoading, remove: !homeVM.isSearchLoading)
										}
									} header: {
										ScrollView(.horizontal, showsIndicators: false) {
											HStack(spacing: 15) {

												ProfessionButton(
													profession: ProfessionProfession(
														id: 0,
														professionCategoryId: 0,
														name: LocaleText.allText,
														createdAt: Date().toString(format: .utc),
														updatedAt: Date().toString(format: .utc)
													),
													selectedValue: $homeVM.selectedProfession
												) {
													homeVM.selectedProfession = 0
												}

												ForEach(homeVM.profession, id: \.id) { item in
													ProfessionButton(profession: item, selectedValue: $homeVM.selectedProfession) {
														homeVM.selectedProfession = item.id
													}
												}
											}
											.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
										}
										.valueChanged(value: homeVM.takeItem) { _ in
											if homeVM.nextCursor != 0 {
												homeVM.getAllTalents()
											}
										}
									}
									.listRowBackground(Color.clear)
									.listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
								}
								.padding(.horizontal, -20)
								.onChange(of: homeVM.showAddCoin) { value in
									if !value {
										homeVM.productSelected = nil
									}
								}
								.onAppear {
									scroll.scrollTo(0, anchor: .top)
								}
							}
							
						}
					}
					
					if !homeVM.announceData.isEmpty {
						AnnouncementView(
							items: $homeVM.announceData[homeVM.announceIndex],
							action: {
								if homeVM.announceData.last?.id == homeVM.announceData[homeVM.announceIndex].id {
									state.isAnnounceShow = true
								} else {
									homeVM.announceIndex += 1
								}
							}
						)
					}
					
					ZStack {
						Color.black
							.opacity(homeVM.showingPasswordAlert ? 0.5 : 0)
							.edgesIgnoringSafeArea(.all)
						
						VStack(spacing: 20) {
							Image.Dinotis.addPasswordIllustration
								.resizable()
								.scaledToFit()
								.frame(height: 150)
							
							VStack(spacing: 10) {
								Text(LocaleText.addPasswordAlertTitle)
									.font(.montserratBold(size: 14))
									.multilineTextAlignment(.center)
								
								Text(LocaleText.addPasswordAlertSubtitle)
									.font(.montserratRegular(size: 12))
									.multilineTextAlignment(.center)
							}
							
							Button {
								withAnimation {
									homeVM.showingPasswordAlert = false
									homeVM.routeToReset()
								}
							} label: {
								HStack {
									Spacer()
									
									Text(LocaleText.okText)
										.font(.montserratSemiBold(size: 14))
										.foregroundColor(.white)
									
									Spacer()
								}
								.padding(15)
								.background(
									RoundedRectangle(cornerRadius: 12)
										.foregroundColor(.primaryViolet)
								)
							}
							
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 12)
								.foregroundColor(.white)
						)
						.padding()
						.opacity(homeVM.showingPasswordAlert ? 1 : 0)
					}
					
					LoadingView(isAnimating: $homeVM.isLoading)
						.isHidden(!homeVM.isLoading, remove: !homeVM.isLoading)
				}
				.navigationBarTitle(Text(""))
				.navigationBarHidden(true)
				.onAppear {
					Task {
						await homeVM.onScreenAppear(geo: geo)
					}
					
					homeVM.getProductOnAppear()
					AppDelegate.orientationLock = .portrait
				}
				.onDisappear {
					homeVM.firstBannerContents = []
					homeVM.secondBannerContents = []
					homeVM.myProducts = []
					homeVM.onDisappear()
				}
				.dinotisSheet(
					isPresented: $homeVM.showAddCoin,
					fraction: 0.85,
					content: {
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

								Text("\(homeVM.userData?.coinBalance?.current ?? 0)")
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
							if homeVM.isLoadingTrx {
								ProgressView()
									.progressViewStyle(.circular)
							} else {
								QGrid(homeVM.myProducts, columns: 2, vSpacing: 10, hSpacing: 10, vPadding: 5, hPadding: 5, isScrollable: false, showScrollIndicators: false) { item in
									Button {
										homeVM.productSelected = item
									} label: {
										HStack {

											Spacer()

											VStack {
												Text(item.priceToString())
													.font((homeVM.productSelected ?? SKProduct()).id == item.id ? .montserratBold(size: 12) : .montserratRegular(size: 12))
													.foregroundColor(.primaryViolet)

												Group {
													switch item.productIdentifier {
													case homeVM.productIDs[0]:
														Text(LocaleText.valueCoinLabel("16000".toPriceFormat()))
													case homeVM.productIDs[1]:
														Text(LocaleText.valueCoinLabel("65000".toPriceFormat()))
													case homeVM.productIDs[2]:
														Text(LocaleText.valueCoinLabel("109000".toPriceFormat()))
													case homeVM.productIDs[3]:
														Text(LocaleText.valueCoinLabel("159000".toPriceFormat()))
													case homeVM.productIDs[4]:
														Text(LocaleText.valueCoinLabel("209000".toPriceFormat()))
													case homeVM.productIDs[5]:
														Text(LocaleText.valueCoinLabel("259000".toPriceFormat()))
													case homeVM.productIDs[6]:
														Text(LocaleText.valueCoinLabel("309000".toPriceFormat()))
													case homeVM.productIDs[7]:
														Text(LocaleText.valueCoinLabel("429000".toPriceFormat()))
													default:
														Text("")
													}
												}
											}
											.font((homeVM.productSelected ?? SKProduct()).id == item.id ? .montserratBold(size: 12) : .montserratRegular(size: 12))
											.foregroundColor(.primaryViolet)

											Spacer()
										}
										.padding(10)
										.background(
											RoundedRectangle(cornerRadius: 12)
												.foregroundColor((homeVM.productSelected ?? SKProduct()).id == item.id ? .secondaryViolet : .clear)
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
								if let product = homeVM.productSelected {
									homeVM.purchaseProduct(product: product)
								}
							} label: {
								HStack {
									Spacer()

									Text(LocaleText.homeScreenAddCoin)
										.font(.montserratSemiBold(size: 12))
										.foregroundColor(homeVM.isLoadingTrx || homeVM.productSelected == nil ? Color(.systemGray2) : .white)

									Spacer()
								}
								.padding()
								.background(
									RoundedRectangle(cornerRadius: 12)
										.foregroundColor(homeVM.isLoadingTrx || homeVM.productSelected == nil ? Color(.systemGray5) : .primaryViolet)
								)
							}
							.disabled(homeVM.isLoadingTrx || homeVM.productSelected == nil)

							Button {
								homeVM.openWhatsApp()
							} label: {
								HStack {
									Spacer()

									Text(LocaleText.helpText)
										.font(.montserratSemiBold(size: 12))
										.foregroundColor(homeVM.isLoadingTrx ? Color(.systemGray2) : .primaryViolet)

									Spacer()
								}
								.padding()
								.background(
									RoundedRectangle(cornerRadius: 12)
										.foregroundColor(homeVM.isLoadingTrx ? Color(.systemGray5) : .secondaryViolet)
								)
								.overlay(
									RoundedRectangle(cornerRadius: 12)
										.stroke(homeVM.isLoadingTrx ? Color(.systemGray2) : Color.primaryViolet, lineWidth: 1)
								)
							}
							.disabled(homeVM.isLoadingTrx)

						}

					}
				})
				.dinotisSheet(isPresented: $homeVM.isTransactionSucceed, fraction: 0.5, content: {
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
				})
				.sheet(isPresented: $state.isShowInvoice) {
					self.state.bookId = ""
				} content: {
					VStack {
						UserInvoiceBookingView(
							bookingId: state.bookId,
							viewModel: InvoicesBookingViewModel(backToRoot: {}, backToHome: {self.state.isShowInvoice = false})
						)
					}
				}
			}
		}
	}
}

struct UserHomeView_Previews: PreviewProvider {
	static var previews: some View {
		UserHomeView(homeVM: UserHomeViewModel(backToRoot: {}))
	}
}
