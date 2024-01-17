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
import QGrid
import StoreKit

extension UserHomeView {

	struct NavigationHelper: View {

		@EnvironmentObject var homeVM: UserHomeViewModel
        
        @Binding var tabValue: TabRoute

		var body: some View {
			NavigationLink(
				unwrapping: $homeVM.route,
				case: /HomeRouting.talentProfileDetail,
				destination: { viewModel in
					CreatorProfileDetailView(viewModel: viewModel.wrappedValue, tabValue: $tabValue)
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
            
            NavigationLink(
                unwrapping: $homeVM.route,
                case: /HomeRouting.followedCreator,
                destination: {viewModel in
                    FollowedCreatorView(viewModel: viewModel.wrappedValue, tabValue: $tabValue)
                },
                onNavigate: {_ in},
                label: {
                    EmptyView()
                }
            )
            
            NavigationLink(
                unwrapping: $homeVM.route,
                case: /HomeRouting.paymentMethod,
                destination: { viewModel in
                    PaymentMethodView(viewModel: viewModel.wrappedValue, mainTabValue: $tabValue)
                },
                onNavigate: {_ in},
                label: {
                    EmptyView()
                }
            )
            
            NavigationLink(
                unwrapping: $homeVM.route,
                case: /HomeRouting.bookingInvoice,
                destination: { viewModel in
                    UserInvoiceBookingView(
                        viewModel: viewModel.wrappedValue, mainTabValue: $tabValue
                    )
                },
                onNavigate: {_ in},
                label: {
                    EmptyView()
                }
            )
            
            NavigationLink(
                unwrapping: $homeVM.route,
                case: /HomeRouting.detailVideo,
                destination: { viewModel in
                    DetailVideoView()
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
        @Namespace var namespace

		var body: some View {
			VStack(spacing: 0) {

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
                .padding([.horizontal, .top])
                
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            withAnimation {
                                homeVM.currentMainTab = .forYou
                            }
                        } label: {
                            Text(LocalizableText.forYouLabel)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(homeVM.currentMainTab == .forYou ? .DinotisDefault.black1 : .DinotisDefault.black3)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .overlay(alignment: .bottom) {
                                    if homeVM.currentMainTab == .forYou {
                                        Rectangle()
                                            .fill(Color.DinotisDefault.primary)
                                            .frame(height: 2)
                                            .matchedGeometryEffect(id: "TAB", in: namespace)
                                    }
                                }
                        }
                        
                        Button {
                            withAnimation {
                                homeVM.currentMainTab = .following
                            }
                        } label: {
                            Text(LocalizableText.talentDetailFollowing)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(homeVM.currentMainTab == .following ? .DinotisDefault.black1 : .DinotisDefault.black3)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .overlay(alignment: .bottom) {
                                    if homeVM.currentMainTab == .following {
                                        Rectangle()
                                            .fill(Color.DinotisDefault.primary)
                                            .frame(height: 2)
                                            .matchedGeometryEffect(id: "TAB", in: namespace)
                                    }
                                }
                        }
                    }
                    .animation(.easeIn, value: homeVM.currentMainTab)
                    
                    Divider()
                }
			}
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

	struct ForYouContent: View {

		@EnvironmentObject var homeVM: UserHomeViewModel
        @Binding var tabValue: TabRoute
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
                            
                            Group {
                                if !homeVM.isLoadingFirstBanner {
                                    PromotionBannerView(content: $homeVM.firstBannerContents, geo: geo)
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(.gray)
                                        .frame(height: geo.size.width/2.2)
                                        .shimmering(active: homeVM.isLoadingFirstBanner)
                                        .padding()
                                }
                            }
                            .padding(.top, 20)
						}
					}
					.listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)
                    
                    Section {
                        if !homeVM.isLoadingGroupFeature && !homeVM.isLoadingPrivateFeature {
                            if !homeVM.groupScheduleContent.isEmpty || !homeVM.privateScheduleContent.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(homeVM.sessionContent.prefix(6), id: \.id) { item in
                                                if let user = item.user {
                                                    SessionCard(
                                                        with: SessionCardModel(
                                                            title: item.title.orEmpty(),
                                                            date: DateUtils.dateFormatter(item.startAt.orCurrentDate(), forFormat: .EEEEddMMMMyyyy),
                                                            startAt: DateUtils.dateFormatter(item.startAt.orCurrentDate(), forFormat: .HHmm),
                                                            endAt: DateUtils.dateFormatter(item.endAt.orCurrentDate(), forFormat: .HHmm),
                                                            isPrivate: item.isPrivate ?? false,
                                                            isVerified: (item.user?.isVerified) ?? false,
                                                            photo: (item.user?.profilePhoto).orEmpty(),
                                                            name: (item.user?.name).orEmpty(),
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
                                                            isAlreadyBooked: false
                                                        )
                                                    ) {
                                                        homeVM.seeDetailMeeting(from: item)
                                                    } visitProfile: {
                                                        homeVM.username = user.username
                                                        homeVM.routeToTalentProfile()
                                                    }
                                                    .frame(maxWidth: 310)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
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
                    } header: {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(LocalizableText.detailVideoUpcomingSessionDesc)
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.DinotisDefault.black2)
                                
                                Spacer()
                                
                                Button {
                                    tabValue = .search
                                } label: {
                                    Text(LocalizableText.searchSeeAllLabel)
                                        .font(.robotoBold(size: 12))
                                        .foregroundColor(.DinotisDefault.primary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal)
                            
                            HStack(spacing: 8) {
                                Button {
                                    withAnimation {
                                        homeVM.sessionTab = .groupSession
                                    }
                                } label: {
                                    Text(LocalizableText.groupVideoCallLabel)
                                        .font(homeVM.sessionTab == .groupSession ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                        .foregroundColor(homeVM.sessionTab == .groupSession ? .DinotisDefault.primary : .DinotisDefault.black2)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(homeVM.sessionTab == .groupSession ? Color.DinotisDefault.lightPrimary : Color.clear)
                                        )
                                        .overlay {
                                            Capsule()
                                                .inset(by: 0.5)
                                                .stroke(homeVM.sessionTab == .groupSession ? Color.DinotisDefault.primary : Color.DinotisDefault.lightPrimary, lineWidth: 1)
                                        }
                                }
                                .buttonStyle(.plain)
                                .isHidden(homeVM.groupScheduleContent.isEmpty, remove: true)
                                
                                Button {
                                    withAnimation {
                                        homeVM.sessionTab = .privateSession
                                    }
                                } label: {
                                    Text(LocalizableText.privateVideoCallLabel)
                                        .font(homeVM.sessionTab == .privateSession ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                        .foregroundColor(homeVM.sessionTab == .privateSession ? .DinotisDefault.primary : .DinotisDefault.black2)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(homeVM.sessionTab == .privateSession ? Color.DinotisDefault.lightPrimary : Color.clear)
                                        )
                                        .overlay {
                                            Capsule()
                                                .inset(by: 0.5)
                                                .stroke(homeVM.sessionTab == .privateSession ? Color.DinotisDefault.primary : Color.DinotisDefault.lightPrimary, lineWidth: 1)
                                        }
                                }
                                .buttonStyle(.plain)
                                .isHidden(homeVM.privateScheduleContent.isEmpty, remove: true)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 10)
                        .padding(.bottom, 6)
                        .isHidden(homeVM.isLoadingGroupFeature && homeVM.isLoadingPrivateFeature, remove: true)
                    }
                    .background(Color.DinotisDefault.baseBackground)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    
                    Group {
                        if homeVM.isLoadingRateCard {
                            Rectangle()
                                .fill(Color.gray)
                                .shimmering(active: homeVM.isLoadingRateCard)
                        } else {
                            if !homeVM.rateCardList.isEmpty {
                                ZStack(alignment: .topLeading) {
                                    VStack(spacing: 21) {
                                        Text(LocalizableText.homePrivateCallTitle)
                                            .font(.robotoRegular(size: 20))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                            .opacity(homeVM.imgOpacity1)
                                        
                                        Image.homeEyes3dImage
                                            .resizable()
                                            .scaledToFit()
                                            .opacity(homeVM.imgOpacity1)
                                    }
                                    .frame(width: 146, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 33)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: 10) {
                                            ForEach(homeVM.rateCardList.prefix(8), id:\.id) { item in
                                                Button {
                                                    homeVM.username = (item.user?.username).orEmpty()
                                                    homeVM.routeToTalentProfile(showingRequest: true)
                                                } label: {
                                                    PrivateCallCard(
                                                        imageURL: (item.user?.profilePhoto).orEmpty(),
                                                        title: item.title.orEmpty(),
                                                        name: (item.user?.name).orEmpty(),
                                                        isVerified: (item.user?.isVerified).orFalse(),
                                                        price: (Int(item.price.orEmpty())).orZero()
                                                    )
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding(.vertical, 20)
                                        .padding(.horizontal, 16)
                                        .padding(.leading, 162)
                                        .offsetH("RATECARD") { scroll in
                                            if scroll <= 0 && scroll >= -100 {
                                                homeVM.rateCardImgOpacity = scroll/100
                                            }
                                        }
                                    }
                                    .coordinateSpace(name: "RATECARD")
                                }
                                .frame(height: 345)
                                .background(
                                    ZStack {
                                        Color.DinotisDefault.primary
                                        
                                        Image.homeLineGradientPurpleImage
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 654)
                                    }
                                )
                            }
                        }
                    }
                    .frame(height: 345)
                    .clipShape(Rectangle())
                    .padding(.top, 20)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: [GridItem(.fixed(88)), GridItem(.fixed(88)), GridItem(.fixed(88))], spacing: 10) {
                                ForEach(homeVM.allSessionData.prefix(9), id: \.id) { item in
                                    Button {
                                        homeVM.seeDetailMeeting(from: item)
                                    } label: {
                                        SmallSessionCard(
                                            imageURL: (item.user?.profilePhoto).orEmpty(),
                                            name: (item.user?.name).orEmpty(),
                                            title: item.title.orEmpty(),
                                            isGroupSession: !(item.isPrivate.orFalse()),
                                            date: item.startAt.orCurrentDate()
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 6)
                    } header: {
                        HStack {
                            Text(LocalizableText.homeRecentSessionTitle)
                                .font(.robotoBold(size: 16))
                                .foregroundColor(.DinotisDefault.black2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                            Button {
                                tabValue = .search
                            } label: {
                                Text(LocalizableText.searchSeeAllLabel)
                                    .font(.robotoBold(size: 12))
                                    .foregroundColor(.DinotisDefault.primary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.DinotisDefault.baseBackground)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .isHidden(homeVM.allSessionData.isEmpty, remove: true)
                    
                    if !homeVM.isLoadingRecentCreator {
                        Section {
                            ZStack(alignment: .topLeading) {
                                VStack(alignment: .leading, spacing: 13) {
                                    Text(LocalizableText.homeNewCreatorTitle)
                                        .font(.robotoRegular(size: 18))
                                        .foregroundColor(.white)
                                    
                                    Image.homeBasketball3dImage
                                        .resizable()
                                        .scaledToFit()
                                        .offset(y: 24)
                                }
                                .frame(width: 124, alignment: .leading)
                                .padding(.horizontal, 19)
                                .padding(.top, 15)
                                .opacity(homeVM.imgOpacity2)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 10) {
                                        ForEach(homeVM.recentCreatorList.prefix(8), id: \.id) { talent in
                                            Button {
                                                homeVM.username = talent.username
                                                homeVM.routeToTalentProfile()
                                            } label: {
                                                CreatorCard(
                                                    with: CreatorCardModel(
                                                        name: talent.name.orEmpty(),
                                                        isVerified: talent.isVerified.orFalse(),
                                                        professions: (talent.stringProfessions ?? []).joined(separator: ", "),
                                                        photo: talent.profilePhoto.orEmpty()
                                                    ),
                                                    size: 174
                                                )
                                                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.leading, 144)
                                    .padding(.vertical, 20)
                                    .offsetH("CREATOR") { scroll in
                                        if scroll <= 0 && scroll >= -100 {
                                            homeVM.creatorImgOpacity = scroll/100
                                        }
                                    }
                                }
                                .coordinateSpace(name: "CREATOR")
                            }
                            .frame(height: 214)
                            .background(
                                ZStack(alignment: .top) {
                                    Color.DinotisDefault.pink
                                    
                                    Image.homeLineGradientOrangeImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 610)
                                        .offset(y: -40)
                                }
                            )
                            .frame(height: 214)
                            .clipShape(Rectangle())
                            .padding(.top)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .padding(.top, 10)
                        .isHidden(homeVM.recentCreatorList.isEmpty, remove: true)
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
                    
                    if !homeVM.isLoadingPopularCreator {
                        Section {
                            if !homeVM.isFollowed.isEmpty,
                               !homeVM.isLoadingFollowUnfollow.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 10) {
                                        ForEach(homeVM.popularCreatorList.prefix(10).indices, id: \.self) { index in
                                            let talent = homeVM.popularCreatorList[index]
                                            Button {
                                                homeVM.username = talent.username.orEmpty()
                                                homeVM.routeToTalentProfile()
                                            } label: {
                                                CreatorCardWithFollowButton(
                                                    imageURL: talent.profilePhoto.orEmpty(),
                                                    name: talent.name.orEmpty(),
                                                    isVerified: talent.isVerified.orFalse(),
                                                    professions: (talent.stringProfessions ?? []).joined(separator: ", "),
                                                    isFollowed: $homeVM.isFollowed[index],
                                                    isLoading: $homeVM.isLoadingFollowUnfollow[index]
                                                ) {
                                                    homeVM.onFollowUnfollowCreator(id: talent.id, index: index)
                                                }
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                }
                                .padding(.bottom)
                            }
                        } header: {
                            HStack {
                                Text(LocalizableText.homePopularCreatorTitle)
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.DinotisDefault.black2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button {
                                    tabValue = .search
                                } label: {
                                    Text(LocalizableText.searchSeeAllLabel)
                                        .font(.robotoBold(size: 12))
                                        .foregroundColor(.DinotisDefault.primary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color.DinotisDefault.baseBackground)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .isHidden(homeVM.popularCreatorList.isEmpty, remove: true)
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
                    
                    Section {
                        Group {
                            if !homeVM.isLoadingSecondBanner {
                                PromotionBannerView(content: $homeVM.secondBannerContents, geo: geo)
                                    .padding(.top)
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(.gray)
                                    .frame(height: geo.size.width/2.2)
                                    .shimmering(active: homeVM.isLoadingFirstBanner)
                                    .padding()
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.bottom, 90)
				}
				.padding(.horizontal, -20)
				.listStyle(.plain)
				.refreshable(action: {
					homeVM.onScreenAppear(geo: geo)
				})
			}
		}
	}
    
    struct FollowingContent: View {
        
        @EnvironmentObject var homeVM: UserHomeViewModel
        let geo: GeometryProxy
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        
        private var isRegularWidth: Bool {
            horizontalSizeClass == .regular
        }
        
        private var gridItems: [GridItem] {
//            if isRegularWidth {
                return [
                    GridItem(.adaptive(minimum: geo.size.width/3)),
                    GridItem(.adaptive(minimum: geo.size.width/3)),
                    GridItem(.adaptive(minimum: geo.size.width/3))
                ]
//            } else {
//                return [GridItem(.adaptive(minimum: geo.size.width))]
//            }
        }
        
        private var cardHeight: CGFloat {
            if isRegularWidth {
                return (geo.size.width / 3) * (5 / 9)
            } else {
                return geo.size.width * (5 / 9)
            }
        }
        
        private var cardWidth: CGFloat {
            if isRegularWidth {
                return (geo.size.width / 3) - 56
            } else {
                return geo.size.width - 32
            }
        }
        
        var body: some View {
            List {
                if homeVM.isLoadingFollowedCreator {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(height: 274)
                        .shimmering()
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } else {
                    if homeVM.followedCreator.isEmpty {
                        VStack(spacing: 16) {
                            Image.loginCreatorImage
                                .resizable()
                                .scaledToFit()
                            
                            Text(LocalizableText.homeEmptyFollowedCreatorDesc)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.DinotisDefault.black2)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 4)
                            
                            DinotisPrimaryButton(
                                text: LocalizableText.homeFindCreatorLabel,
                                type: .adaptiveScreen,
                                height: 40,
                                textColor: .white,
                                bgColor: .DinotisDefault.primary
                            ) {
                                withAnimation {
                                    homeVM.currentMainTab = .forYou
                                }
                            }
                        }
                        .frame(maxWidth: 292, maxHeight: 306)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .padding(.vertical)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    } else {
                        Section {
                            ZStack {
                                ZStack(alignment: .bottomLeading) {
                                    Color.DinotisDefault.primary
                                    
                                    Image.homeLineGradientPurpleImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 470)
                                        .rotationEffect(Angle(degrees: 30))
                                        .offset(x: 40, y: -30)
                                }
                                .frame(height: 274)
                                .clipShape(Rectangle())
                                
                                VStack(alignment: .leading, spacing: 20) {
                                    Button {
                                        homeVM.routeToFollowedCreator()
                                    } label: {
                                        HStack {
                                            Text(LocalizableText.homeFollowedCreatorTitle)
                                                .font(.robotoBold(size: 16))
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: 10) {
                                            ForEach(homeVM.followedCreator, id:\.id) { item in
                                                Button {
                                                    homeVM.username = item.username
                                                    homeVM.routeToTalentProfile()
                                                } label: {
                                                    CreatorCard(
                                                        with: CreatorCardModel(
                                                            name: item.name.orEmpty(),
                                                            isVerified: item.isVerified.orFalse(),
                                                            professions: (item.stringProfessions?.joined(separator: ", ")).orEmpty(),
                                                            photo: item.profilePhoto.orEmpty()
                                                        ),
                                                        size: 174
                                                    )
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            }
                            .frame(height: 274)
                            .clipShape(Rectangle())
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                
                Section {
                    Group {
                        if homeVM.isLoadingFollowingSession {
                            LazyVStack(spacing: 10) {
                                ForEach(0...5, id:\.self) { _ in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(height: cardHeight)
                                        .shimmering()
                                }
                            }
                        } else {
                            if isRegularWidth {
                                LazyVGrid(columns: gridItems, spacing: 12) {
                                    switch homeVM.followingSessionTab {
                                    case .privateSession:
                                        FollowingPrivateList(homeVM: homeVM)
                                    case .groupSession:
                                        FollowingGroupList(homeVM: homeVM)
                                    case .exclusiveVideo:
                                        FollowingVideoList(homeVM: homeVM, cardHeight: cardHeight, cardWidth: cardWidth)
                                    }
                                }
                            } else {
                                switch homeVM.followingSessionTab {
                                case .privateSession:
                                    FollowingPrivateList(homeVM: homeVM)
                                case .groupSession:
                                    FollowingGroupList(homeVM: homeVM)
                                case .exclusiveVideo:
                                    FollowingVideoList(homeVM: homeVM, cardHeight: cardHeight, cardWidth: cardWidth)
                                }
                            }
                        }
                        
                        if homeVM.isLoadMoreFollowingSession {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .frame(width: 50, height: 50)
                                .frame(maxWidth: .infinity)
                        }
                        
                        Color.clear
                            .frame(height: 52)
                    }
                    .animation(.spring, value: homeVM.followingSessionTab)
                    .padding(.horizontal)
                } header: {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(homeVM.followingSessionSections, id:\.self) { section in
                                Button {
                                    withAnimation {
                                        homeVM.followingSessionTab = section
                                    }
                                    homeVM.onGetFollowingSession(isMore: false)
                                } label: {
                                    Text(homeVM.followingTabText(section))
                                        .font(section == homeVM.followingSessionTab ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                        .foregroundColor(section == homeVM.followingSessionTab ? .DinotisDefault.primary : .DinotisDefault.black2)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(section == homeVM.followingSessionTab ? Color.DinotisDefault.lightPrimary : Color.clear)
                                        )
                                        .overlay {
                                            Capsule()
                                                .inset(by: 0.5)
                                                .stroke(section == homeVM.followingSessionTab ? Color.DinotisDefault.primary : Color.DinotisDefault.lightPrimary, lineWidth: 1)
                                        }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    .background(Color.DinotisDefault.baseBackground)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .isHidden(homeVM.followedCreator.isEmpty, remove: true)
            }
            .padding(.horizontal, -20)
            .listStyle(.plain)
            .listRowSpacing(12)
            .refreshable {
                homeVM.onGetFollowedCreator()
                homeVM.onGetFollowingSession(onRefresh: true, isMore: false)
            }
            .onAppear {
                if homeVM.followedCreator.isEmpty {
                    homeVM.onGetFollowedCreator()
                }
                homeVM.onGetFollowingSession(isMore: false)
            }
        }
    }
    
    struct FollowingPrivateList: View {
        
        @ObservedObject var homeVM: UserHomeViewModel
        
        var body: some View {
            if homeVM.followingPrivate.isEmpty {
                Text(LocalizableText.homeEmptyPrivateSessionDesc)
                    .font(.robotoRegular(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.DinotisDefault.black3)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(homeVM.followingPrivate, id:\.id) { item in
                    if let user = item.user {
                        SessionCard(
                            with: SessionCardModel(
                                title: item.title.orEmpty(),
                                date: DateUtils.dateFormatter(item.startAt.orCurrentDate(), forFormat: .EEEEddMMMMyyyy),
                                startAt: DateUtils.dateFormatter(item.startAt.orCurrentDate(), forFormat: .HHmm),
                                endAt: DateUtils.dateFormatter(item.endAt.orCurrentDate(), forFormat: .HHmm),
                                isPrivate: item.isPrivate ?? false,
                                isVerified: (item.user?.isVerified) ?? false,
                                photo: (item.user?.profilePhoto).orEmpty(),
                                name: (item.user?.name).orEmpty(),
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
                                isAlreadyBooked: false
                            )
                        ) {
                            homeVM.seeDetailMeeting(from: item)
                        } visitProfile: {
                            homeVM.username = user.username
                            homeVM.routeToTalentProfile()
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            if homeVM.followingPrivate.last?.id == item.id,
                               homeVM.followingPrivateNextCursor != nil {
                                homeVM.onGetFollowingSession(isMore: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct FollowingGroupList: View {
        
        @ObservedObject var homeVM: UserHomeViewModel
        
        var body: some View {
            if homeVM.followingGroup.isEmpty {
                Text(LocalizableText.homeEmptyGroupSessionDesc)
                    .font(.robotoRegular(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.DinotisDefault.black3)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(homeVM.followingGroup, id:\.id) { item in
                    if let user = item.user {
                        SessionCard(
                            with: SessionCardModel(
                                title: item.title.orEmpty(),
                                date: DateUtils.dateFormatter(item.startAt.orCurrentDate(), forFormat: .EEEEddMMMMyyyy),
                                startAt: DateUtils.dateFormatter(item.startAt.orCurrentDate(), forFormat: .HHmm),
                                endAt: DateUtils.dateFormatter(item.endAt.orCurrentDate(), forFormat: .HHmm),
                                isPrivate: item.isPrivate ?? false,
                                isVerified: (item.user?.isVerified) ?? false,
                                photo: (item.user?.profilePhoto).orEmpty(),
                                name: (item.user?.name).orEmpty(),
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
                                isAlreadyBooked: false
                            )
                        ) {
                            homeVM.seeDetailMeeting(from: item)
                        } visitProfile: {
                            homeVM.username = user.username
                            homeVM.routeToTalentProfile()
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            if homeVM.followingGroup.last?.id == item.id,
                               homeVM.followingGroupNextCursor != nil {
                                homeVM.onGetFollowingSession(isMore: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct FollowingVideoList: View {
        
        @ObservedObject var homeVM: UserHomeViewModel
        @State var cardHeight: CGFloat
        @State var cardWidth: CGFloat
        
        var body: some View {
            if homeVM.followingVideos.isEmpty {
                Text(LocalizableText.homeEmptyUploadedVideoDesc)
                    .font(.robotoRegular(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.DinotisDefault.black3)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(homeVM.followingVideos, id:\.id) { item in
                    if let user = item.user,
                       let videoId = item.id {
                        Button {
                            homeVM.routeToDetailVideo(id: videoId)
                        } label: {
                            VStack(spacing: 8) {
                                DinotisImageLoader(urlString: item.cover.orEmpty())
                                    .scaledToFill()
                                    .frame(width: cardWidth, height: cardHeight)
                                    .overlay {
                                        Color.black.opacity(0.4)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay {
                                        Image(systemName: "play.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(.white)
                                    }
                                
                                HStack(alignment: .top, spacing: 12) {
                                    DinotisImageLoader(urlString: user.profilePhoto.orEmpty())
                                        .scaledToFill()
                                        .frame(width: 30, height: 30)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.title.orEmpty())
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.DinotisDefault.black1)
                                            
                                        HStack(spacing: 6) {
                                            Text(user.username.orEmpty())
                                            
                                            Circle()
                                                .frame(width: 3.4, height: 3.4)
                                            
                                            Text((item.createdAt?.toStringFormat(with: .ddMMM_yyyy)).orEmpty())
                                        }
                                        .lineLimit(1)
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.DinotisDefault.black3)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                }
                            }
                            .padding(.bottom, 12)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            if homeVM.followingVideos.last?.id == item.id,
                               homeVM.followingVideoNextCursor != nil {
                                homeVM.onGetFollowingSession(isMore: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct SessionDetailView: View {
        
        @ObservedObject var viewModel: UserHomeViewModel
        
        var body: some View {
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                HStack(spacing: -8) {
                                    DinotisImageLoader(
                                        urlString: (viewModel.sessionCard.user?.profilePhoto).orEmpty(),
                                        width: 40,
                                        height: 40
                                    )
                                    .clipShape(Circle())
                                    
                                    if (viewModel.sessionCard.meetingCollaborations?.count).orZero() > 0 {
                                        Text("+\((viewModel.sessionCard.meetingCollaborations?.count).orZero())")
                                            .font(.robotoMedium(size: 16))
                                            .foregroundColor(.white)
                                            .background(
                                                Circle()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(Color(hex: "#CD2DAD")?.opacity(0.75))
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.white, lineWidth: 2)
                                                            .frame(width: 40, height: 40)
                                                    )
                                            )
                                    }
                                }
                                
                                HStack {
                                    Text((viewModel.sessionCard.user?.name).orEmpty())
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                    
                                    if (viewModel.sessionCard.user?.isVerified) ?? false {
                                        Image.sessionCardVerifiedIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(viewModel.sessionCard.title.orEmpty())
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(viewModel.sessionCard.description.orEmpty())
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(viewModel.isDescComplete ? nil : 3)
                                    
                                    Button {
                                        withAnimation {
                                            viewModel.isDescComplete.toggle()
                                        }
                                    } label: {
                                        Text(viewModel.isDescComplete ? LocalizableText.bookingRateCardHideFullText : LocalizableText.bookingRateCardShowFullText)
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.primary)
                                    }
                                    .isHidden(
                                        viewModel.sessionCard.description.orEmpty().count < 150,
                                        remove: viewModel.sessionCard.description.orEmpty().count < 150
                                    )
                                }
                            }
                        }
                        
                        VStack {
                            if !(viewModel.sessionCard.meetingCollaborations ?? []).isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("\(LocalizableText.withText):")
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(.black)
                                    
                                    ForEach((viewModel.sessionCard.meetingCollaborations ?? []).prefix(3), id: \.id) { item in
                                        HStack(spacing: 10) {
                                            ImageLoader(url: (item.user?.profilePhoto).orEmpty(), width: 40, height: 40)
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                            
                                            Text((item.user?.name).orEmpty())
                                                .lineLimit(1)
                                                .font(.robotoBold(size: 14))
                                                .foregroundColor(.DinotisDefault.black1)
                                            
                                            Spacer()
                                        }
                                        .onTapGesture {
                                            viewModel.isShowSessionDetail = false
                                            viewModel.username = item.username
                                            viewModel.routeToTalentProfile()
                                        }
                                    }
                                    
                                    if (viewModel.sessionCard.meetingCollaborations ?? []).count > 3 {
                                        Button {
                                            viewModel.isShowSessionDetail = false
                                            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                                viewModel.isShowCollabList.toggle()
                                            }
                                        } label: {
                                            Text(LocalizableText.searchSeeAllLabel)
                                                .font(.robotoBold(size: 12))
                                                .foregroundColor(.DinotisDefault.primary)
                                                .underline()
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                Image.sessionCardDateIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17)
                                
                                Text((viewModel.sessionCard.startAt?.toStringFormat(with: .ddMMMMyyyy)).orEmpty())
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 10) {
                                Image.sessionCardTimeSolidIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17)
                                
                                Text("\((viewModel.sessionCard.startAt?.toStringFormat(with: .HHmm)).orEmpty()) – \((viewModel.sessionCard.endAt?.toStringFormat(with: .HHmm)).orEmpty())")
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 10) {
                                Image.sessionCardPersonSolidIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17)
                                
                                Text("\(viewModel.sessionCard.slots.orZero()) \(LocalizableText.participant)")
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                
                                Text(LocalizableText.limitedQuotaLabelWithEmoji)
                                    .font(.robotoBold(size: 10))
                                    .foregroundColor(.DinotisDefault.red)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 8)
                                    .background(Color.DinotisDefault.red.opacity(0.1))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.DinotisDefault.red, lineWidth: 1.0)
                                    )
                                
                                Spacer()
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text(LocalizableText.priceLabel)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            if viewModel.sessionCard.price.orEmpty() == "0" {
                                Text(LocalizableText.freeText)
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.black)
                            } else {
                                Text(viewModel.sessionCard.price.orEmpty().toPriceFormat())
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    DinotisSecondaryButton(
                        text: LocalizableText.cancelLabel,
                        type: .adaptiveScreen,
                        textColor: .DinotisDefault.black1,
                        bgColor: .DinotisDefault.lightPrimary,
                        strokeColor: .DinotisDefault.primary) {
                            viewModel.isShowSessionDetail = false
                        }
                    
                    DinotisPrimaryButton(
                        text: LocalizableText.payLabel,
                        type: .adaptiveScreen,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary) {
                            
                            if viewModel.freeTrans {
                                viewModel.onSendFreePayment()
                            } else {
                                viewModel.isShowSessionDetail = false
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                    withAnimation {
                                        viewModel.isShowPaymentOption = true
                                    }
                                }
                            }
                        }
                    
                }
                .padding(.top)
            }
            .padding()
            .padding(.vertical)
            .onDisappear {
                viewModel.isDescComplete = false
            }
        }
    }
    
    struct PaymentTypeOption: View {
        @ObservedObject var viewModel: UserHomeViewModel
        
        var body: some View {
            VStack(spacing: 16) {
                HStack {
                    Text(LocalizableText.paymentMethodLabel)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button {
                        viewModel.isShowPaymentOption = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                }
                
                Spacer()
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        Button {
                            DispatchQueue.main.async {
                                viewModel.isShowPaymentOption.toggle()
                                
                                Task {
                                    await viewModel.extraFees()
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                withAnimation {
                                    viewModel.isShowCoinPayment = true
                                }
                            }
                        } label: {
                            HStack(spacing: 15) {
                                Image.paymentAppleIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 28)
                                    .foregroundColor(.DinotisDefault.primary)
                                
                                Text(LocalizableText.inAppPurchaseLabel)
                                    .font(.robotoBold(size: 12))
                                    .foregroundColor(.DinotisDefault.primary)
                                
                                Spacer()
                                
                                Image.sessionDetailChevronIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 37)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(.DinotisDefault.lightPrimary)
                            )
                        }
                        
                        Button {
                            viewModel.isShowPaymentOption = false
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                withAnimation {
                                    viewModel.routeToPaymentMethod()
                                }
                            }
                        } label: {
                            HStack(spacing: 15) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(LocalizableText.otherPaymentMethodTitle)
                                        .font(.robotoBold(size: 12))
                                    
                                    Text(LocalizableText.otherPaymentMethodDescription)
                                        .font(.robotoRegular(size: 10))
                                }
                                .foregroundColor(.DinotisDefault.primary)
                                
                                Spacer()
                                
                                Image.sessionDetailChevronIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 37)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(.DinotisDefault.lightPrimary)
                            )
                        }
                        .isHidden(!viewModel.sessionCard.isPrivate.orFalse(), remove: !viewModel.sessionCard.isPrivate.orFalse())
                    }
                    .padding(.bottom)
                }
                
            }
            .padding([.top, .horizontal])
        }
    }
    
    struct CoinPaymentSheetView: View {
        
        @ObservedObject var viewModel: UserHomeViewModel
        
        var body: some View {
            VStack(spacing: 15) {
                HStack {
                    Text(LocalizableText.paymentConfirmationTitle)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button {
                        viewModel.isShowCoinPayment = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(LocalizableText.yourCoinLabel)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.black)
                        
                        HStack(alignment: .top) {
                            Image.coinBalanceIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 15)
                            
                            Text("\((viewModel.userData?.coinBalance?.current).orEmpty().toPriceFormat())")
                                .font(.robotoBold(size: 14))
                                .foregroundColor((Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) >= viewModel.totalPayment ? .DinotisDefault.primary : .DinotisDefault.red)
                        }
                    }
                    
                    Spacer()
                    
                    if (Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment {
                        Button {
                            DispatchQueue.main.async {
                                viewModel.isShowCoinPayment.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                viewModel.isShowAddCoin.toggle()
                            }
                        } label: {
                            Text(LocalizableText.addCoinLabel)
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
                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.DinotisDefault.lightPrimary))
                
                VStack(alignment: .leading) {
                    Text(LocalizableText.promoCodeTitle)
                        .font(.robotoBold(size: 12))
                        .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Group {
                                if viewModel.promoCodeSuccess {
                                    HStack {
                                        Text(viewModel.promoCode)
                                            .font(.robotoMedium(size: 12))
                                            .foregroundColor(viewModel.promoCodeSuccess ? Color(.systemGray) : .black)
                                        
                                        Spacer()
                                    }
                                } else {
                                    TextField(LocalizableText.promoCodeLabel, text: $viewModel.promoCode)
                                        .font(.robotoMedium(size: 12))
                                        .autocapitalization(.allCharacters)
                                        .disableAutocorrection(true)
                                }
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(UIColor.systemGray3), lineWidth: 1)
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
                                    Text(viewModel.promoCodeSuccess ? LocalizableText.changeLabel : LocalizableText.enterLabel)
                                        .font(.robotoBold(size: 12))
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
                                Image.talentProfileAttentionIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 10)
                                    .foregroundColor(.red)
                                Text(LocalizableText.paymentPromoNotFound)
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
                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.DinotisDefault.lightPrimary))
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(LocalizableText.paymentLabel)
                            
                            Spacer()
                            
                            Text(LocalizableText.applePayText)
                        }
                        
                        HStack {
                            Text(LocalizableText.feeSubTotalLabel)
                            
                            Spacer()
                            
                            Text("\(Int(viewModel.sessionCard.price.orEmpty()).orZero())".toCurrency())
                        }
                        
                        HStack {
                            Text(LocalizableText.feeApplication)
                            
                            Spacer()
                            
                            Text("\(viewModel.extraFee)".toCurrency())
                            
                        }
                        
                        HStack {
                            Text(LocalizableText.feeService)
                            
                            Spacer()
                            
                            Text("0".toCurrency())
                            
                        }
                    }
                    .font(.robotoMedium(size: 12))
                    .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        if (viewModel.promoCodeData?.discountTotal).orZero() != 0 {
                            HStack {
                                Text(LocalizableText.discountLabel)
                                    .font(.robotoMedium(size: 10))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("-\((viewModel.promoCodeData?.discountTotal).orZero())".toCurrency())
                                    .font(.robotoMedium(size: 10))
                                    .foregroundColor(.red)
                            }
                        } else if (viewModel.promoCodeData?.amount).orZero() != 0 && (viewModel.promoCodeData?.discountTotal).orZero() == 0 {
                            HStack {
                                Text(LocalizableText.discountLabel)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("-\((viewModel.promoCodeData?.amount).orZero())".toCurrency())
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 1.5)
                        .foregroundColor(.DinotisDefault.primary)
                    
                    HStack {
                        Text(LocalizableText.totalLabel)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("\(viewModel.totalPayment)")
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.black)
                    }
                    
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.DinotisDefault.lightPrimary))
                
                Spacer()
                
                DinotisPrimaryButton(
                    text: LocalizableText.continuePaymentLabel,
                    type: .adaptiveScreen,
                    textColor: (Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment ? Color(.systemGray) : .white,
                    bgColor: (Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment ? Color(.systemGray4) : .DinotisDefault.primary) {
                        Task {
                            await viewModel.coinPayment()
                        }
                    }
                    .disabled((Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment || viewModel.isLoadingCoinPay)
            }
            .padding()
            .padding(.vertical)
            .onAppear {
                viewModel.getProductOnAppear()
            }
        }
    }
    
    struct AddCoinSheetView: View {
        
        @ObservedObject var viewModel: UserHomeViewModel
        
        var body: some View {
            VStack(spacing: 20) {
                
                HStack {
                    Text(LocalizableText.addCoinLabel)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button {
                        viewModel.isShowAddCoin.toggle()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                }
                
                VStack {
                    Text(LocalizableText.yourCoinLabel)
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.black)
                    
                    HStack(alignment: .top) {
                        Image.coinBalanceIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                        
                        Text("\((viewModel.userData?.coinBalance?.current).orEmpty().toPriceFormat())")
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.DinotisDefault.primary)
                    }
                    .multilineTextAlignment(.center)
                    
                    Text(LocalizableText.descriptionAddCoin)
                        .font(.robotoRegular(size: 10))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                }
                
                VStack {
                    if viewModel.isLoadingTrx {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        QGrid(viewModel.myProducts, columns: 4, vSpacing: 10, hSpacing: 10, vPadding: 5, hPadding: 5, isScrollable: false, showScrollIndicators: false) { item in
                            
                            Button {
                                viewModel.productSelected = item
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Text(item.priceToString())
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(.DinotisDefault.primary)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor((viewModel.productSelected ?? SKProduct()).id == item.id ? .DinotisDefault.lightPrimary : .clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .frame(height: 90)
                
                Spacer()
                
                VStack {
                    DinotisPrimaryButton(
                        text: LocalizableText.addCoinLabel,
                        type: .adaptiveScreen,
                        textColor: viewModel.isLoadingTrx || viewModel.productSelected == nil ? .DinotisDefault.lightPrimaryActive : .white,
                        bgColor: viewModel.isLoadingTrx || viewModel.productSelected == nil ? .DinotisDefault.lightPrimary : .DinotisDefault.primary
                    ) {
                        if let product = viewModel.productSelected {
                            viewModel.purchaseProduct(product: product)
                        }
                    }
                    .disabled(viewModel.isLoadingTrx || viewModel.productSelected == nil)
                    
                    DinotisSecondaryButton(
                        text: LocalizableText.helpLabel,
                        type: .adaptiveScreen,
                        textColor: viewModel.isLoadingTrx ? .white : .DinotisDefault.primary,
                        bgColor: viewModel.isLoadingTrx ? Color(UIColor.systemGray3) : .DinotisDefault.lightPrimary,
                        strokeColor: .DinotisDefault.primary) {
                            viewModel.openWhatsApp()
                        }
                        .disabled(viewModel.isLoadingTrx)
                }
            }
            .padding()
            .padding(.vertical)
        }
    }
}
