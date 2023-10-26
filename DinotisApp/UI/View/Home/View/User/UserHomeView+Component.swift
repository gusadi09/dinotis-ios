//
//  UserHomeView+Component.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/04/22.
//

import SwiftUI
import SwiftUINavigation
import SDWebImageSwiftUI
import DinotisDesignSystem
import DinotisData
import Shimmer

extension UserHomeView {

	struct NavigationHelper: View {

		@EnvironmentObject var homeVM: UserHomeViewModel
        
        @Binding var tabValue: TabRoute

		var body: some View {
			NavigationLink(
				unwrapping: $homeVM.route,
				case: /HomeRouting.talentProfileDetail,
				destination: { viewModel in
					TalentProfileDetailView(viewModel: viewModel.wrappedValue, tabValue: $tabValue)
				},
				onNavigate: {_ in},
				label: {
					EmptyView()
				}
			)

			NavigationLink(
				unwrapping: $homeVM.route,
				case: /HomeRouting.coinHistory,
				destination: { viewModel in
					CoinHistoryView(viewModel: viewModel.wrappedValue)
				},
				onNavigate: {_ in},
				label: {
					EmptyView()
				}
			)

			NavigationLink(
				unwrapping: $homeVM.route,
				case: /HomeRouting.scheduleList,
				destination: {viewModel in
                    ScheduleListView(mainTabSelection: .constant(.search))
                        .environmentObject(viewModel.wrappedValue)
				},
				onNavigate: {_ in},
				label: {
					EmptyView()
				}
			)
		}
	}

	struct HeaderView: View {

		@EnvironmentObject var homeVM: UserHomeViewModel

		var body: some View {
			VStack(spacing: 25) {

                HStack(spacing: 5) {
                    Image.logoWithText
                        .resizable()
                        .scaledToFit()
                        .frame(height: 35)
                    
                    NavigationLink(
                        unwrapping: $homeVM.route,
                        case: /HomeRouting.inbox,
                        destination: { viewModel in
                            InboxView()
                                .environmentObject(viewModel.wrappedValue)
                        },
                        onNavigate: { _ in },
                        label: {
                            EmptyView()
                        }
                    )

					NavigationLink(
						unwrapping: $homeVM.route,
						case: /HomeRouting.notification) { viewModel in
							NotificationView(viewModel: viewModel.wrappedValue)
						} onNavigate: { _ in

						} label: {
							EmptyView()
						}

					Spacer()

                    Button {
                        homeVM.routeToInbox()
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            
                            Circle()
                                .scaledToFit()
                                .frame(height: 48)
                                .foregroundColor(Color.white)
                                .overlay(
                                    Image.homeTalentChatPrimaryIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 21)
                                )
                                .shadow(color: Color(red: 0.22, green: 0.29, blue: 0.41).opacity(0.06), radius: 20, x: 0, y: 0)
                            
                            if homeVM.hasNewNotifInbox {
                                Text(homeVM.notificationInboxBadgeCountStr)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 3)
                                    .padding(.vertical, 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .foregroundColor(.red)
                                    )
                                
                            }
                        }
                    }
                    
                    Button {
                        homeVM.routeToNotification()
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            
                            Circle()
                                .scaledToFit()
                                .frame(height: 48)
                                .foregroundColor(Color.white)
                                .overlay(
                                    Image.homeTalentNotificationIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 20)
                                )
                                .shadow(color: Color(red: 0.22, green: 0.29, blue: 0.41).opacity(0.06), radius: 20, x: 0, y: 0)
                            
                            if homeVM.hasNewNotif {
                                Text(homeVM.notificationBadgeCountStr)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 3)
                                    .padding(.vertical, 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .foregroundColor(.red)
                                    )
                            }
                        }
                    }
				}
			}
			.padding()
		}
	}

	struct CategoryList: View {

		var geo: GeometryProxy
		@ObservedObject var homeVM: UserHomeViewModel

		var body: some View {
			HStack {
				ForEach((homeVM.categoryData?.data ?? []).prefix(4), id: \.id) { item in
					Button {
						homeVM.selectedCategory = item.name.orEmpty()
						homeVM.selectedCategoryId = item.id.orZero()
						homeVM.routeToSearch()
					} label: {
						VStack(spacing: 10) {
							WebImage(url: item.icon?.toURL())
								.resizable()
								.indicator(.activity)
								.transition(.fade(duration: 0.5))
								.scaledToFit()
								.frame(width: UIDevice.current.userInterfaceIdiom == .pad ? geo.size.width/8.5 : geo.size.width/5.5)

							Text(item.name.orEmpty())
								.font(.robotoMedium(size: 11))
								.foregroundColor(.black)
						}
					}

					if item.id != homeVM.categoryData?.data?.last?.id {
						Spacer()
					}
				}
			}
			.padding()
		}
	}

	struct VideoCallScheduleSection: View {

		@ObservedObject var homeVM: UserHomeViewModel
		var geo: GeometryProxy

		var body: some View {
			VStack {
				HStack {
					Text(LocaleText.videoCallSchedule)
						.font(.robotoBold(size: 14))

					Spacer()
				}
				.padding(.horizontal)

				Button {
					homeVM.routeToScheduleList()
				} label: {
					HStack {
						Image.Dinotis.sheduleIllustrate

						VStack(alignment: .leading) {
							Text(LocaleText.checkSchedule)
								.font(.robotoBold(size: 12))

							Text(LocaleText.checkScheduleSubtitle)
								.font(.robotoRegular(size: 12))

						}
						.foregroundColor(.black)
						.multilineTextAlignment(.leading)
						.padding(.leading, 15)

						Spacer()

						Image.Dinotis.buttonScheduleChevronIcon
					}
					.padding(.horizontal)
					.background(
						Image.Dinotis.scheduleButtonBackground
							.resizable()
							.frame(width: geo.size.width - 40, height: 123)
					)
					.frame(width: geo.size.width - 40, height: 123)
				}

			}
		}
	}

	struct EmptySearch: View {
		var body: some View {
			HStack {
				Spacer()
				VStack(spacing: 10) {
					Image.Dinotis.searchNotFoundImage
						.resizable()
						.scaledToFit()
						.frame(
							height: 137
						)

					Text(NSLocalizedString("no_search_label", comment: ""))
                        .font(.robotoBold(size: 14))
						.foregroundColor(.black)

					Text(NSLocalizedString("another_keyword_label", comment: ""))
                        .font(.robotoRegular(size: 12))
						.multilineTextAlignment(.center)
						.foregroundColor(.black)
				}
				.padding()

				Spacer()
			}
			.background(Color.white)
			.cornerRadius(12)
			.padding(.horizontal)
			.shadow(color: Color("dinotis-shadow-1").opacity(0.08), radius: 10, x: 0.0, y: 0.0)

		}
	}

	struct ProfessionButton: View {
		private let profession: ProfessionElement
		@Binding private var selectedValue: Int
		private let action: (() -> Void)

		init(profession: ProfessionElement, selectedValue: Binding<Int>, action: @escaping (() -> Void)) {
			self.profession = profession
			self._selectedValue = selectedValue
			self.action = action
		}

		var body: some View {
			Button {
				action()
			} label: {
				Text(profession.name.orEmpty())
					.font(.robotoRegular(size: 14))
					.foregroundColor(.black)
					.padding(10)
					.background(
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(selectedValue == profession.id ? .secondaryViolet : Color(.systemGray6))
					)
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(selectedValue == profession.id ? Color.DinotisDefault.primary : Color(.systemGray5), lineWidth: 1)
					)
			}
		}
	}

	struct ScrolledContent: View {

		@EnvironmentObject var homeVM: UserHomeViewModel
		let geo: GeometryProxy

		var body: some View {
			ScrollViewReader { scroll in
				List {
					Section {
						LazyVStack(spacing: 15) {

							if let notice = homeVM.latestNotice.first {
								HStack(spacing: 20) {
									Image.Dinotis.noticeIcon
										.resizable()
										.scaledToFit()
										.frame(height: 20)

									VStack(alignment: .leading, spacing: 8) {
										Text(notice.title.orEmpty())
											.font(.robotoBold(size: 12))

										Text(notice.description.orEmpty())
											.font(.robotoRegular(size: 10))
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

							if !homeVM.isLoadingFirstBanner {
								PromotionBannerView(content: $homeVM.firstBannerContents, geo: geo)
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(.gray)
                                    .frame(height: geo.size.width/2.2)
                                    .shimmering(active: homeVM.isLoadingFirstBanner)
                                    .padding()
                            }

                            if !homeVM.isLoadingHomeContent {
                                LazyVStack(spacing: 15) {
                                    ForEach(homeVM.homeContent, id:\.id) {
                                        item in
                                        
                                        VStack(spacing: 10) {
                                            HStack {
                                                Text(item.name.orEmpty())
                                                    .font(.robotoBold(size: 14))
                                                    .padding(.horizontal)
                                                
                                                Spacer()
                                            }
                                            
                                            ScrollView([.horizontal], showsIndicators: false) {
                                                ScrollView([.horizontal], showsIndicators: false) {
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
                                                    .padding(.vertical, 10)
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                LazyVStack(spacing: 15) {
                                        VStack(spacing: 10) {
                                            HStack {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .frame(width: 100)
                                                    .foregroundColor(.gray)
                                                    .shimmering()
                                                
                                                Spacer()
                                            }
                                            .padding(.leading)
                                            
                                            ScrollView {
                                                ScrollView([.horizontal], showsIndicators: false) {
                                                    HStack(spacing: 15) {
                                                        ForEach(0...2, id: \.self) { _ in
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .foregroundColor(.gray)
                                                                .frame(width: 200, height: 220)
                                                                .shimmering()
                                                        }
                                                    }
                                                    .padding(.horizontal)
                                                    .padding(.vertical, 10)
                                                }
                                            }
                                        }
                                }
                            }

							if !homeVM.isLoadingSecondBanner {
								PromotionBannerView(content: $homeVM.secondBannerContents, geo: geo)
							} else {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(.gray)
                                    .frame(height: geo.size.width/2.2)
                                    .shimmering(active: homeVM.isLoadingFirstBanner)
                                    .padding()
                            }

                            if !homeVM.isLoadingOriginalSection {
                                if let original = homeVM.originalSectionContent?.data {
                                    
                                    ForEach(original, id: \.id) { item in
                                        VStack(spacing: 5) {
                                            HStack {
                                                Text(item.name.orEmpty())
                                                    .font(.robotoBold(size: 14))
                                                    .padding(.top, 5)
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
                                                .padding(.vertical, 10)
                                            }
                                        }
                                        .isHidden(
                                            item.landingPageListContentList.isEmpty, remove: item.landingPageListContentList.isEmpty
                                        )
                                    }
                                }
                            } else {
                                VStack(spacing: 5) {
                                    HStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .frame(width: 100)
                                            .foregroundColor(.gray)
                                            .shimmering()
                                        
                                        Spacer()
                                    }
                                    .padding(.leading)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(0...2, id: \.self) { _ in
                                                RoundedRectangle(cornerRadius: 12)
                                                    .foregroundColor(.gray)
                                                    .frame(width: 290, height: 190)
                                                    .shimmering()
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 10)
                                    }
                                }
                            }

							if !homeVM.isLoadingPrivateFeature {
                                if !homeVM.privateScheduleContent.isEmpty {
                                    VStack(spacing: 5) {
                                        HStack {
                                            Text(LocaleText.homeScreenPrivateVideo)
                                                .font(.robotoBold(size: 14))
                                                .padding(.top, 5)
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
                                            .padding(.vertical, 10)
                                        }
                                    }
                                }
							} else {
                                VStack(spacing: 5) {
                                    HStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .frame(width: 100)
                                            .foregroundColor(.gray)
                                            .shimmering()
                                        
                                        Spacer()
                                    }
                                    .padding(.leading)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(0...2, id: \.self) { _ in
                                                RoundedRectangle(cornerRadius: 12)
                                                    .foregroundColor(.gray)
                                                    .frame(width: 290, height: 190)
                                                    .shimmering()
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 10)
                                    }
                                }
                            }

							if !homeVM.isLoadingGroupFeature {
                                if !homeVM.groupScheduleContent.isEmpty {
                                    VStack(spacing: 5) {
                                        HStack {
                                            Text(LocaleText.homeScreenGroupVideo)
                                                .font(.robotoBold(size: 14))
                                                .padding(.top, 5)
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
                                            .padding(.vertical, 10)
                                        }
                                    }
                                }
							} else {
                                VStack(spacing: 5) {
                                    HStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .frame(width: 100)
                                            .foregroundColor(.gray)
                                            .shimmering()
                                        
                                        Spacer()
                                    }
                                    .padding(.leading)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(0...2, id: \.self) { _ in
                                                RoundedRectangle(cornerRadius: 12)
                                                    .foregroundColor(.gray)
                                                    .frame(width: 290, height: 190)
                                                    .shimmering()
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 10)
                                    }
                                }
                            }
						}
					}
					.listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: -20, trailing: 20))
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)

					Section {

							if homeVM.searchResult.isEmpty && !homeVM.isSearchLoading {
								EmptySearch()
									.padding(.bottom)
							} else {
								ForEach(homeVM.talentArray(), id: \.id) { item in
									if item.id == homeVM.talentArray().last?.id {
										LazyVStack(spacing: 15) {
											Button {
												homeVM.username = item.username.orEmpty()
												homeVM.routeToTalentProfile()
											} label: {
												TalentSearchVerticalCardView(
													user: item
												)
											}
											.buttonStyle(.plain)
											.onAppear {
												if item.id == homeVM.talentArray().last?.id {
                                                    if homeVM.nextCursor != nil {
                                                        homeVM.takeItem += 10
                                                        homeVM.onGetSearchedTalent()
                                                    }
												}
											}

											HStack {
												Spacer()

                                                ProgressView()
                                                    .progressViewStyle(.circular)
													.padding()

												Spacer()
											}
											.isHidden(!homeVM.isSearchLoading, remove: !homeVM.isSearchLoading)
										}
										.padding(.bottom, 50)
									} else {
										LazyVStack {
											Button {
												homeVM.username = item.username.orEmpty()
												homeVM.routeToTalentProfile()
											} label: {
												TalentSearchVerticalCardView(
													user: item
												)
											}
											.buttonStyle(.plain)
											.onAppear {
												if item.id == homeVM.talentArray().last?.id {
                                                    if homeVM.nextCursor != nil {
                                                        homeVM.takeItem += 10
                                                        homeVM.onGetSearchedTalent()
                                                    }
												}
											}
										}
									}

								}
							}

					} header: {
						ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                if !homeVM.isLoadingProfession {
                                    ProfessionButton(
                                        profession: ProfessionElement(
                                            id: 0,
                                            professionCategoryId: 0,
                                            name: LocaleText.allText,
                                            createdAt: Date(),
                                            updatedAt: Date()
                                        ),
                                        selectedValue: $homeVM.selectedProfession
                                    ) {
                                        homeVM.selectedProfession = 0
                                    }
                                    
                                    
                                    ForEach(homeVM.profession, id: \.id) { item in
                                        ProfessionButton(profession: item, selectedValue: $homeVM.selectedProfession) {
                                            homeVM.selectedProfession = item.id.orZero()
                                        }
                                    }
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.gray)
                                        .frame(width: 80, height: 35)
                                        .shimmering()
                                }
							}
							.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
						}
					}
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)
					.listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))

				}
				.padding(.horizontal, -18)
				.listStyle(.plain)
				.refreshable(action: {
					await homeVM.onScreenAppear(geo: geo)
				})
			}
		}
	}
}
