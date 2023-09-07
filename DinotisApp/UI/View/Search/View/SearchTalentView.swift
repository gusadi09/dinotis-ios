//
//  SearchTalentView.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/03/22.
//

import DinotisData
import DinotisDesignSystem
import QGrid
import StoreKit
import SwiftUI
import SwiftUINavigation
import Shimmer

struct SearchTalentView: View {
	
	@EnvironmentObject var viewModel: SearchTalentViewModel
    @Binding var tabValue: TabRoute
	
	var body: some View {
		GeometryReader { geo in
			ZStack {

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /HomeRouting.talentProfileDetail,
					destination: {viewModel in
						TalentProfileDetailView(viewModel: viewModel.wrappedValue, tabValue: $tabValue)
					},
					onNavigate: {_ in},
					label: {
						EmptyView()
					}
				)
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.paymentMethod,
                    destination: {viewModel in
                        PaymentMethodView(viewModel: viewModel.wrappedValue, mainTabValue: $tabValue)
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
                            viewModel: viewModel.wrappedValue, mainTabValue: $tabValue
                        )
                    },
                    onNavigate: {_ in},
                    label: {
                        EmptyView()
                    }
                )

                Color.DinotisDefault.baseBackground
					.edgesIgnoringSafeArea(.bottom)
                
				ScrollViewReader { scroll in
					VStack(spacing: 0) {
						VStack(spacing: 0) {
                            SearchTextField(
                                LocalizableText.searchPlaceholder,
                                text: $viewModel.searchText
                            )
							.autocorrectionDisabled(true)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .padding(.top, 6)
                            .valueChanged(value: viewModel.debouncedText) { val in
                                viewModel.takeItem = 30
                                viewModel.sessionTakeItem = 30
                                Task {
									await viewModel.getSearchedData(isMore: false)
                                    await viewModel.getSearchedSession(isMore: false)

									withAnimation {
										scroll.scrollTo(0, anchor: .top)
									}
                                }

                            }

							if !viewModel.searchText.isEmpty {
                                ZStack(alignment: .bottom) {
                                    ZStack {
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.DinotisDefault.lightPrimary)
                                        
                                        Capsule()
                                            .frame(width: geo.size.width/3, height: 1.5)
                                            .foregroundColor(.DinotisDefault.primary)
                                            .offset(x: viewModel.indicatorPosition(filter: viewModel.currentTab, width: geo.size.width))
                                            .animation(.spring(), value: viewModel.currentTab)
                                    }
                                    
                                    HStack {
                                        ForEach(viewModel.tabFilter, id:\.self) { item in
                                            Button {
                                                withAnimation {
                                                    viewModel.currentTab = item
                                                }
                                            } label: {
                                                HStack {
                                                    Spacer()
                                                    
                                                    Text(viewModel.tabText(filter: item))
                                                        .font(viewModel.currentTab == item ? .robotoMedium(size: 14) : .robotoRegular(size: 14))
                                                        .foregroundColor(.DinotisDefault.black1)
                                                        .padding(.bottom)
                                                    
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                }
							}
						}
						.background(Color.white)


						Color.DinotisDefault.baseBackground
							.frame(height: 0.5)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .id(0)
                        
                        if viewModel.searchText.isEmpty {
                            RecommendationView(viewModel: viewModel)
                        } else if (!viewModel.searchText.isEmpty && viewModel.debouncedText.isEmpty) || viewModel.isSearchLoading {
                            VStack {
                                Spacer()
                                DinotisLoadingView(hide: false)
                                Spacer()
                            }
                        } else {
                            TabView(selection: $viewModel.currentTab) {
                                SearchTabAllView(viewModel: viewModel, width: geo.size.width/2.5)
                                    .tag(TabFilter.all)
                                
                                SearchTabSessionView(viewModel: viewModel)
                                    .tag(TabFilter.session)
                                
                                SearchTabCreatorView(viewModel: viewModel)
                                    .tag(TabFilter.creator)
                            }
                            .edgesIgnoringSafeArea(.all)
                            .tabViewStyle(.page(indexDisplayMode: .never))
                        }
					}
				}
			}
		}
        .onChange(of: viewModel.searchText, perform: { _ in
            viewModel.debounceText()
        })
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
    .dinotisAlert(
      isPresent: $viewModel.isShowAlert,
      title: viewModel.alert.title,
      isError: viewModel.alert.isError,
      message: viewModel.alert.message,
      primaryButton: viewModel.alert.primaryButton,
      secondaryButton: viewModel.alert.secondaryButton
    )
        .sheet(
            isPresented: $viewModel.isShowSessionDetail,
            content: {
                if #available(iOS 16.0, *) {
                    SessionDetailView(viewModel: viewModel)
                        .presentationDetents([.fraction(0.8), .large])
                        .dynamicTypeSize(.large)
                } else {
                    SessionDetailView(viewModel: viewModel)
                        .dynamicTypeSize(.large)
                }
            }
        )
        .sheet(
            isPresented: $viewModel.isShowPaymentOption,
            content: {
                if #available(iOS 16.0, *) {
                    PaymentTypeOption(viewModel: viewModel)
                    .presentationDetents([.fraction(viewModel.sessionCard.isPrivate.orFalse() ? 0.44 : 0.33)])
                    .dynamicTypeSize(.large)
                } else {
                    PaymentTypeOption(viewModel: viewModel)
                        .dynamicTypeSize(.large)
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
                    CoinPaymentSheetView(viewModel: viewModel)
                        .presentationDetents([.fraction(0.85), .large])
                        .dynamicTypeSize(.large)
                } else {
                    CoinPaymentSheetView(viewModel: viewModel)
                        .dynamicTypeSize(.large)
                }
            }
        )
        .sheet(
            isPresented: $viewModel.isShowAddCoin,
            content: {
                if #available(iOS 16.0, *) {
                    AddCoinSheetView(viewModel: viewModel)
                        .presentationDetents([.fraction(0.67), .large])
                        .dynamicTypeSize(.large)
                } else {
                    AddCoinSheetView(viewModel: viewModel)
                        .dynamicTypeSize(.large)
                }
            }
        )
        .sheet(isPresented: $viewModel.isShowCollabList, content: {
            if #available(iOS 16.0, *) {
              SelectedCollabCreatorView(
                isEdit: false,
                isAudience: true,
                arrUsername: .constant((viewModel.sessionCard.meetingCollaborations ?? []).compactMap({
                  $0.username
              })),
                arrTalent: .constant(viewModel.sessionCard.meetingCollaborations ?? [])) {
                  viewModel.isShowCollabList = false
                } visitProfile: { item in
                  viewModel.isShowSessionDetail = false
                  viewModel.routeToTalentProfile(username: item)
                }
                .presentationDetents([.medium, .large])
                .dynamicTypeSize(.large)
            } else {
              SelectedCollabCreatorView(
                isEdit: false,
                isAudience: true,
                arrUsername: .constant((viewModel.sessionCard.meetingCollaborations ?? []).compactMap({
                  $0.username
              })),
                arrTalent: .constant(viewModel.sessionCard.meetingCollaborations ?? [])) {
                  viewModel.isShowCollabList = false
                } visitProfile: { item in
                  viewModel.isShowSessionDetail = false
                  viewModel.routeToTalentProfile(username: item)
                }
                .dynamicTypeSize(.large)
            }
        })
	}
}

private extension SearchTalentView {
	struct RecommendationView: View {
		
		@ObservedObject var viewModel: SearchTalentViewModel
		
		var body: some View {
            ScrollView(showsIndicators: false) {
                if viewModel.isLoadingRecommend {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text(LocalizableText.searchRecommendationTitle)
                                .font(.robotoBold(size: 18))
                                .foregroundColor(.DinotisDefault.black1)
                            
                            Spacer()
                        }
                        
                        ForEach(0...5, id: \.self) { _ in
                            HStack(spacing: 12) {
                                Circle()
                                    .scaledToFit()
                                    .frame(width: 16)
                                    .foregroundColor(.gray)
                                
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.gray)
                                    .frame(height: 15)
                                
                                Spacer()
                            }
                            .shimmering()
                        }
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text(LocalizableText.searchRecommendationTitle)
                                .font(.robotoBold(size: 18))
                                .foregroundColor(.DinotisDefault.black1)
                            
                            Spacer()
                        }
                        
                        ForEach(viewModel.recommendedData, id: \.name) { item in
                            Button {
                                withAnimation {
                                    viewModel.searchText = item.name
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    if item.type == .creator {
                                        Image.searchPersonIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16)
                                    } else if item.type == .session {
                                        Image.searchVideoIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16)
                                    }
                                    
                                    Text(item.name)
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.DinotisDefault.black2)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                viewModel.onAppear()
            }
		}
	}

	struct SearchTabAllView: View {
		@ObservedObject var viewModel: SearchTalentViewModel
		let width: Double

		var body: some View {
			List {
				if viewModel.searchedCreator.isEmpty && viewModel.searchedSession.isEmpty {
					Section {
						VStack(spacing: 30) {
							Image.searchNotFoundImage
								.resizable()
								.scaledToFit()
								.frame(width: 315)

							Text(LocalizableText.searchGeneralNotFound)
								.multilineTextAlignment(.center)
								.font(.robotoBold(size: 20))
								.foregroundColor(.DinotisDefault.black2)

							DinotisPrimaryButton(
								text: LocalizableText.searchTellUsLabel,
								type: .adaptiveScreen,
								textColor: .white,
								bgColor: .DinotisDefault.primary) {
									viewModel.openWhatsApp()
								}
								.buttonStyle(.plain)
						}
						.padding(.vertical)

						Spacer()
					}
					.padding()
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)
				} else {
					Section {
						HStack {
							Text(LocalizableText.searchRelatedCreatorTitle)
								.font(.robotoBold(size: 18))
								.foregroundColor(.DinotisDefault.black1)

							Spacer()

							Button {
								withAnimation {
									viewModel.currentTab = .creator
								}
							} label: {
								Text(LocalizableText.searchSeeAllLabel)
									.font(.robotoMedium(size: 12))
									.foregroundColor(.DinotisDefault.primary)
							}
						}
						.padding(.horizontal)
						.padding(.bottom, -35)

						if !viewModel.searchedCreator.isEmpty {
							ScrollView(.horizontal, showsIndicators: false) {
								LazyHStack(spacing: 8) {
									ForEach(viewModel.searchedCreator.prefix(8), id: \.id) { item in
										if let profession = item.professions?[0].profession?.name {
											Button {
												viewModel.routeToTalentProfile(username: item.username.orEmpty())
											} label: {
												CreatorCard(with: CreatorCardModel(
													name: item.name.orEmpty(),
													isVerified: item.isVerified ?? false,
													professions: profession,
                                                    photo: item.profilePhoto.orEmpty()
												), size: 140)
											}
                                            .buttonStyle(.plain)
										}
									}
								}
								.padding(.horizontal)
							}
							.padding(.bottom, -15)
						} else {
							HStack {

								Spacer()

								VStack(spacing: 10) {
									Text(LocalizableText.searchCreatorNotFoundTitle)
										.font(.robotoBold(size: 20))
										.foregroundColor(.DinotisDefault.black2)

									Text(LocalizableText.searchCreatorNotFoundDesc)
										.font(.robotoRegular(size: 16))
										.foregroundColor(.DinotisDefault.black3)
								}
								.multilineTextAlignment(.center)

								Spacer()
							}
							.padding(.vertical)
						}
					}
					.padding(.vertical)
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)

					Section {
						HStack {
							Text(LocalizableText.searchRelatedSessionTitle)
								.font(.robotoBold(size: 18))
								.foregroundColor(.DinotisDefault.black1)

							Spacer()

							Button {
								withAnimation {
									viewModel.currentTab = .session
								}
							} label: {
								Text(LocalizableText.searchSeeAllLabel)
									.font(.robotoMedium(size: 12))
									.foregroundColor(.DinotisDefault.primary)
							}
						}
						.padding(.horizontal)

						if !viewModel.searchedSession.isEmpty {
							Section {
								LazyVGrid(columns: [GridItem(.adaptive(minimum: 440))], spacing: 13) {
									ForEach(viewModel.searchedSession.prefix(8), id: \.id) { item in
										SessionCard(
											with: SessionCardModel(
											title: item.title.orEmpty(),
                                            date: DateUtils.dateFormatter(item.startAt.orCurrentDate(), forFormat: .ddMMMMyyyy),
                                            startAt: DateUtils.dateFormatter(item.startAt.orCurrentDate(), forFormat: .HHmm),
                                            endAt: DateUtils.dateFormatter(item.endAt.orCurrentDate(), forFormat: .HHmm),
											isPrivate: item.isPrivate ?? false,
											isVerified: (item.user?.isVerified) ?? false,
											photo: (item.user?.profilePhoto).orEmpty(),
											name: (item.user?.name).orEmpty(),
											// MARK: - Change the color when backend done
											color: item.background,
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
												viewModel.seeDetailMeeting(from: item)
											} visitProfile: {
												viewModel.routeToTalentProfile(username: (item.user?.username).orEmpty())
											}
									}
								}
							}
							.padding(.horizontal)
							.padding(.bottom, 60)
							.padding(.top, -25)
						} else {
							HStack {

								Spacer()

								VStack(spacing: 10) {
									Text(LocalizableText.searchSessionNotFoundTitle)
										.font(.robotoBold(size: 20))
										.foregroundColor(.DinotisDefault.black2)

									Text(LocalizableText.searchSessionNotFoundDesc)
										.font(.robotoRegular(size: 16))
										.foregroundColor(.DinotisDefault.black3)
								}
								.multilineTextAlignment(.center)

								Spacer()

							}
							.padding(.vertical)
						}
					}
					.padding(.vertical)
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)
				}

			}
			.padding(.horizontal, -18)
			.listStyle(.plain)
			.buttonStyle(.plain)
			.refreshable {
				await viewModel.getSearchedSession(isMore: false)
				await viewModel.getSearchedData(isMore: false)
			}
		}
    }
    
    struct SearchTabSessionView: View {
        @ObservedObject var viewModel: SearchTalentViewModel
        var body: some View {
			ScrollView {
                LazyVStack {
					if !viewModel.searchedSession.isEmpty {
						LazyVGrid(columns: [GridItem(.adaptive(minimum: 440))], spacing: 13) {
							ForEach(viewModel.searchedSession, id: \.id) { item in
								SessionCard(
									with: SessionCardModel(
										title: item.title.orEmpty(),
                                        date: DateUtils.dateFormatter(item.startAt.orCurrentDate(), forFormat: .ddMMMMyyyy),
                                        startAt: DateUtils.dateFormatter(item.startAt.orCurrentDate(), forFormat: .HHmm),
                                        endAt: DateUtils.dateFormatter(item.endAt.orCurrentDate(), forFormat: .HHmm),
										isPrivate: item.isPrivate ?? false,
										isVerified: (item.user?.isVerified) ?? false,
										photo: (item.user?.profilePhoto).orEmpty(),
										name: (item.user?.name).orEmpty(),
										// MARK: - Change the color when backend done
										color: item.background,
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
									viewModel.seeDetailMeeting(from: item)
								} visitProfile: {
									viewModel.routeToTalentProfile(username: (item.user?.username).orEmpty())
								}
								.onAppear {
									if item.id == viewModel.searchedSession.last?.id && viewModel.sessionNextCursor != nil {
										Task {
											viewModel.sessionTakeItem += 30
											await viewModel.getSearchedSession(isMore: true)
										}
									}
								}
							}
						}
					} else {
                        HStack {

                            Spacer()

                            VStack {
                                VStack(spacing: 10) {
                                    Text(LocalizableText.searchSessionNotFoundTitle)
                                        .font(.robotoBold(size: 20))
                                        .foregroundColor(.DinotisDefault.black2)
                                    
                                    Text(LocalizableText.searchSessionNotFoundDesc)
                                        .font(.robotoRegular(size: 16))
                                        .foregroundColor(.DinotisDefault.black3)
                                }
                                .multilineTextAlignment(.center)
                                .padding(.vertical)
                                
                                Spacer()
                            }

                            Spacer()
                        }
                    }
                }
                .padding()
                .padding(.bottom, 60)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .buttonStyle(.plain)
            .refreshable {
                Task {
                    viewModel.sessionTakeItem = 30
					await viewModel.getSearchedSession(isMore: false)
                }
            }
        }
    }
    
    struct SearchTabCreatorView: View {
        
        @ObservedObject var viewModel: SearchTalentViewModel
        
        var body: some View {
            ScrollView {
                LazyVStack {
                    if !viewModel.searchedCreator.isEmpty {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 164))], spacing: 13) {
                            ForEach(viewModel.searchedCreator, id: \.id) { item in
								if let profession = item.professions?[0].profession?.name {
                                    Button {
                                        viewModel.routeToTalentProfile(username: item.username.orEmpty())
                                    } label: {
										CreatorCard(
											with: CreatorCardModel(
												name: item.name.orEmpty(),
												isVerified: item.isVerified ?? false,
												professions: profession,
												photo: item.profilePhoto.orEmpty()
											), size: 170, type: .withDesc
										) {
											HStack(spacing: 4) {
                                                (
                                                Text("\(item.meetingCount.orZero()) ")
                                                    .font(.robotoBold(size: 13))
                                                    .foregroundColor(.DinotisDefault.black2)
                                                +
                                                Text(LocalizableText.sessionCompleted)
                                                    .font(.robotoRegular(size: 13))
                                                    .foregroundColor(.DinotisDefault.black3)
                                                )
                                                .multilineTextAlignment(.leading)
                                                
                                                Spacer()
                                                
                                                Image(systemName: "star.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundColor(.orange)
                                                    .frame(width: 13)
                                                
                                                Text(item.rating.orEmpty())
                                                    .font(.robotoRegular(size: 13))
                                                    .foregroundColor(.DinotisDefault.black2)
                                                
                                            }
                                        }
                                    }
									.onAppear {
										if item.id == viewModel.searchedCreator.last?.id && viewModel.creatorNextCursor != nil {
											Task {
												viewModel.takeItem += 30
												await viewModel.getSearchedData(isMore: true)
											}
										}
									}
                                }
                            }
                        }
                    } else {
                        HStack {
                            Spacer()
                            VStack {
                                VStack(spacing: 10) {
                                    Text(LocalizableText.searchCreatorNotFoundTitle)
                                        .font(.robotoBold(size: 20))
                                        .foregroundColor(.DinotisDefault.black2)
                                    
                                    Text(LocalizableText.searchCreatorNotFoundDesc)
                                        .font(.robotoRegular(size: 16))
                                        .foregroundColor(.DinotisDefault.black3)
                                }
                                .multilineTextAlignment(.center)
                                .padding(.vertical)
                                
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
                .padding()
                .padding(.bottom, 60)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .buttonStyle(.plain)
            .refreshable {
                Task {
                    viewModel.takeItem = 30
					await viewModel.getSearchedData(isMore: false)
                }
            }
        }
    }
    
    struct SessionDetailView: View {

        @ObservedObject var viewModel: SearchTalentViewModel

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
                                viewModel.routeToTalentProfile(username: item.username)
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
        @ObservedObject var viewModel: SearchTalentViewModel
        
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
        
        @ObservedObject var viewModel: SearchTalentViewModel
        
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
        
        @ObservedObject var viewModel: SearchTalentViewModel
        
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

struct SearchTalentView_Previews: PreviewProvider {
	static var previews: some View {
        SearchTalentView(tabValue: .constant(.agenda))
	}
}
