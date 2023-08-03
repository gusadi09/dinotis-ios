//
//  TalentHomeView.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/08/21.
//

import CurrencyFormatter
import DinotisData
import DinotisDesignSystem
import Introspect
import SwiftUI
import SwiftUINavigation
import SwiftUITrackableScrollView

struct TalentHomeView: View {
    
    @ObservedObject var homeVM: TalentHomeViewModel
    @ObservedObject var state = StateObservable.shared
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    var viewController: UIViewController? {
        self.viewControllerHolder.value
    }

	private var columns: [GridItem] {
		[GridItem](
			repeating: GridItem(.flexible(), spacing: 20),
			count: 3
		)
	}
    
    var body: some View {
        ZStack {
            
            NavigationLink(
                unwrapping: $homeVM.route,
                case: /HomeRouting.notification) { viewModel in
                    NotificationView(viewModel: viewModel.wrappedValue)
                } onNavigate: { _ in

                } label: {
                    EmptyView()
                }
            
			NavigationLink(
				unwrapping: $homeVM.route,
				case: /HomeRouting.editScheduleMeeting,
				destination: { viewModel in
					EditTalentMeetingView(viewModel: viewModel.wrappedValue)
				},
				onNavigate: { _ in },
				label: {
					EmptyView()
				}
			)
            .alert(isPresented: $homeVM.isShowDelete) {
                Alert(
                    title: Text(LocaleText.attention),
                    message: Text(LocaleText.deleteAlertText),
                    primaryButton: .default(
                        Text(LocaleText.noText)
                    ),
                    secondaryButton: .destructive(
                        Text(LocaleText.yesDeleteText),
                        action: {
                            homeVM.deleteMeeting()
                        }
					)
				)
            }
            
            ZStack(alignment: .center) {
                
                ZStack(alignment: .bottomTrailing) {
                    VStack {
                        LinearGradient(colors: [.secondaryBackground, .white, .white], startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea([.top, .horizontal])
                            .alert(isPresented: $homeVM.isError) {
                                Alert(
                                    title: Text(LocaleText.attention),
                                    message: Text(homeVM.error.orEmpty()),
                                    dismissButton: .cancel(Text(LocaleText.returnText))
                                )
                            }
                    }
                    
                    VStack(spacing: 0) {
                        HStack {
                            Button(action: {
                                homeVM.routeToProfile()
                            }, label: {
                                HStack(spacing: 15) {
                                    ProfileImageContainer(
                                        profilePhoto: $homeVM.photoProfile,
                                        name: $homeVM.nameOfUser,
                                        width: 48,
                                        height: 48
                                    )
                                    
                                    VStack(alignment: .leading, spacing: 14) {
                                        Text(LocaleText.helloText)
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(.black)
                                        
                                        Text((homeVM.userData?.name).orEmpty())
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.black)
                                    }
                                }
                                
                            })
                            
                            NavigationLink(
                                unwrapping: $homeVM.route,
                                case: /HomeRouting.talentProfile) { viewModel in
                                    TalentProfileView(viewModel: viewModel.wrappedValue)
                                } onNavigate: { _ in
                                    
                                } label: {
                                    EmptyView()
                                }
                            
                            NavigationLink(
                                unwrapping: $homeVM.route,
                                case: /HomeRouting.talentRateCardList) { viewModel in
                                    TalentCardListView(viewModel: viewModel.wrappedValue)
                                } onNavigate: { _ in
                                    
                                } label: {
                                    EmptyView()
                                }
                            
                            Spacer()
                            
                            Button {
                                homeVM.routeToNotification()
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20)
                                        .foregroundColor(.dinotisStrokeSecondary)
                                        .padding(9)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                    
                                    Circle()
                                        .scaledToFit()
                                        .frame(width: 10)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding()
                        .padding(.top, 10)
                        .alert(isPresented: $homeVM.isSuccessDelete) {
                            Alert(
                                title: Text(LocaleText.successTitle),
                                message: Text(LocaleText.meetingDeleted),
                                dismissButton: .default(Text(LocaleText.returnText), action: {
                                    
                                }))
                        }
                        
                        DinotisList {
                            Task {
                                await homeVM.refreshList()
                            }
                            
                        } introspectConfig: { view in
                            view.separatorStyle = .none
                            view.showsVerticalScrollIndicator = false
                            homeVM.use(for: view) { refresh in
                                Task {
                                    await homeVM.refreshList()
                                    refresh.endRefreshing()
                                }
                            }
						} content: {
							Section {
								HStack(spacing: 15) {
									VStack(alignment: .leading, spacing: 15) {
										Text(LocaleText.walletBalance)
											.font(.robotoRegular(size: 12))
											.foregroundColor(.black)

										Text(homeVM.currentBalances.toCurrency())
											.font(.robotoBold(size: 18))
											.foregroundColor(.black)
									}

									Spacer()

									Button(action: {
										homeVM.routeToWallet()
									}, label: {
										VStack {
											Image.Dinotis.walletButtonIcon
												.resizable()
												.scaledToFit()
												.frame(height: 34)

											Text(LocaleText.withdrawBalance)
												.font(.robotoBold(size: 12))
												.foregroundColor(.black)
												.fixedSize(horizontal: true, vertical: false)
										}
									})
									.buttonStyle(.plain)
								}
								.padding(.vertical, 20)
								.padding(.horizontal, 15)
								.background(
									RoundedRectangle(cornerRadius: 12)
										.foregroundColor(.white)
								)
								.shadow(color: Color.dinotisShadow.opacity(0.08), radius: 8, x: 0, y: 0)
								.padding(.top, 10)

								HStack {
									Spacer()

									LazyVGrid(columns: columns) {
										Button {
											homeVM.routeToTalentFormSchedule()
										} label: {
											VStack {
												Image.Dinotis.redCameraVideoIcon
													.resizable()
													.scaledToFit()
													.frame(width: 24)
													.padding(8)
													.background(Color.secondaryViolet)
													.frame(width: 36, height: 36)
													.cornerRadius(8)
													.overlay(
														RoundedRectangle(cornerRadius: 8)
															.stroke(Color.DinotisDefault.primary, lineWidth: 1)
															.frame(width: 36, height: 36)
													)

												Text(LocaleText.createSessionSchedule)
													.foregroundColor(.black)
													.font(.robotoRegular(size: 10))
													.multilineTextAlignment(.center)
											}
										}
										.buttonStyle(.plain)

										Button {
											homeVM.routeToBundling()
										} label: {
											VStack {
												ZStack(alignment: .topTrailing) {
													Image.Dinotis.redPricetagIcon
														.resizable()
														.scaledToFit()
														.frame(width: 24)
														.padding(8)
														.background(Color.secondaryViolet)
														.frame(width: 36, height: 36)
														.cornerRadius(8)
														.overlay(
															RoundedRectangle(cornerRadius: 8)
																.stroke(Color.DinotisDefault.primary, lineWidth: 1)
																.frame(width: 36, height: 36)
														)

													Image.Dinotis.newBadgeIcon
														.resizable()
														.scaledToFit()
														.frame(width: 18, height: 10)
														.padding(.top, -5)
														.padding(.trailing, -9)
												}

												Text(LocaleText.talentHomeBundlingMenu)
													.foregroundColor(.black)
													.font(.robotoRegular(size: 10))
													.multilineTextAlignment(.center)
											}
										}
										.buttonStyle(.plain)

										Button {
											homeVM.routeToTalentRateCardList()
										} label: {
											VStack {
												ZStack(alignment: .topTrailing) {
													Image.Dinotis.rateCardIcon
														.resizable()
														.scaledToFit()
														.frame(width: 36, height: 36)

													Image.Dinotis.newBadgeIcon
														.resizable()
														.scaledToFit()
														.frame(width: 18, height: 10)
														.padding(.top, -5)
														.padding(.trailing, -9)
												}

												Text(LocaleText.rateCardMenu)
													.foregroundColor(.black)
													.font(.robotoRegular(size: 10))
													.multilineTextAlignment(.center)
											}
										}
										.buttonStyle(.plain)
									}

									Spacer()
								}
								.padding()
								.background(Color.white)
								.cornerRadius(12)
								.shadow(color: Color.dinotisShadow.opacity(0.08), radius: 8, x: 0, y: 0)

							}
							.listRowBackground(Color.clear)

							Section {
								VStack {
									if homeVM.tabNumb == 0 {
										VStack {
											HStack {
												Image(systemName: "slider.horizontal.3")
													.resizable()
													.scaledToFit()
													.frame(height: 15)
													.foregroundColor(.DinotisDefault.primary)

												Text(LocaleText.generalFilterSchedule)
													.font(.robotoBold(size: 12))
													.foregroundColor(.DinotisDefault.primary)

												Spacer()

												Menu {
													Picker(selection: $homeVM.filterSelection) {
														ForEach(homeVM.filterOption, id: \.id) { item in
															Text(item.label.orEmpty())
																.tag(item.label.orEmpty())
														}
													} label: {
														EmptyView()
													}
												} label: {
													HStack(spacing: 10) {
														Text(homeVM.filterSelection)
															.font(.robotoRegular(size: 12))
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
													.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.DinotisDefault.primary, lineWidth: 1))
												}
											}
											.buttonStyle(.plain)
											.padding(.bottom, 8)
											.onChange(of: homeVM.filterSelection) { newValue in
												homeVM.filterScheduledMeeting(newValue: newValue)
											}

												if homeVM.meetingData.unique().isEmpty {
													EmptyStateView(
														title: LocaleText.noScheduleLabel,
														description: LocaleText.createScheduleLabel,
														buttonText: LocaleText.createScheduleText,
														primaryAction: homeVM.routeToTalentFormSchedule
													)

												} else {
													LazyVStack(spacing: 20) {

														ForEach(homeVM.meetingData.unique(), id: \.id) { items in
															TalentScheduleCardView(
																data: .constant(items),
																isBundle: false,
																onTapButton: {
																	homeVM.routeToTalentDetailSchedule(meetingId: items.id.orEmpty())
																}, onTapEdit: {
																	homeVM.routeToEditSchedule(id: items.id.orEmpty())
																}, onTapDelete: {
																	homeVM.isShowDelete.toggle()
																	homeVM.meetingId = items.id.orEmpty()
																}
															)
															.onAppear {
																if (homeVM.meetingData.unique().last?.id).orEmpty() == items.id {
																	homeVM.meetingParam.skip = homeVM.meetingParam.take
																	homeVM.meetingParam.take += 15
                                                                    homeVM.getTalentMeeting(isMore: true)
																}
															}
														}
													}
													.padding(.top)
													.padding(.bottom, 40)
												}
										}
									} else {
										VStack {
											HStack {
												Image(systemName: "slider.horizontal.3")
													.resizable()
													.scaledToFit()
													.frame(height: 15)
													.foregroundColor(.DinotisDefault.primary)

												Text(LocaleText.generalFilterSchedule)
													.font(.robotoBold(size: 12))
													.foregroundColor(.DinotisDefault.primary)

												Spacer()

												Menu {
													Picker(selection: $homeVM.filterSelectionRequest) {
														ForEach(homeVM.filterData, id: \.id) { item in
															Text(item.label.orEmpty())
																.tag(item.label.orEmpty())
														}
													} label: {
														EmptyView()
													}
												} label: {
													HStack(spacing: 10) {
														Text(homeVM.filterSelectionRequest)
															.font(.robotoRegular(size: 12))
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
													.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.DinotisDefault.primary, lineWidth: 1))
												}
											}
											.buttonStyle(.plain)
											.padding(.bottom, 8)
											.onChange(of: homeVM.filterSelectionRequest) { item in
												homeVM.filterMeetingRequest(newValue: item)
											}

											if homeVM.meetingRequestData.unique().isEmpty {
												EmptyStateView(
													title: LocaleText.emptyMeetingRequestTitle,
													description: LocaleText.emptyMeetingRequestSubtitle,
													buttonText: LocaleText.createRateCard,
													primaryAction: homeVM.routeToTalentRateCardList
												)
											} else {
												ForEach(homeVM.meetingRequestData.unique(), id:\.id) { item in
													RequestCardView(
														user: item.user,
														item: item,
														onTapDecline: {
															homeVM.requestId = item.id.orEmpty()
															homeVM.confirmationSheet = .declined
														},
														onTapAccept: {
															homeVM.requestId = item.id.orEmpty()
															homeVM.confirmationSheet = .accepted
														}
													)
													.onAppear {
														Task {
															if item.id == homeVM.meetingRequestData.unique().last?.id {
																homeVM.rateCardQuery.skip = homeVM.rateCardQuery.take
																homeVM.rateCardQuery.take += 15
																await homeVM.getMeetingRequest()
															}
														}
													}
													.padding(.bottom, 5)
												}
											}
										}
										.padding(.bottom)
									}
								}
								.buttonStyle(.plain)
							} header: {
								VStack(spacing: 10) {
									HStack(spacing: 0) {
										Button {
											homeVM.tabNumb = 0
										} label: {
											VStack(spacing: 25) {
												HStack(alignment: .center) {
													Text(LocaleText.scheduledSession)
														.font(homeVM.tabNumb == 0 ? .robotoBold(size: 12) : .robotoRegular(size: 12))
														.foregroundColor(.black)

													if !homeVM.meetingCounter.isEmpty {
														Text(homeVM.meetingCounter)
															.font(.robotoMedium(size: 10))
															.foregroundColor(.white)
															.padding(5)
															.background(
																RoundedRectangle(cornerRadius: 8)
																	.foregroundColor(.DinotisDefault.primary)
															)
													}
												}
												.background(Color.clear)
												.padding(.bottom, !homeVM.meetingCounter.isEmpty ? -12 : -5)

												Rectangle()
													.frame(height: 1.5, alignment: .center)
													.foregroundColor(homeVM.tabNumb == 0 ? .DinotisDefault.primary : .DinotisDefault.primary.opacity(0.3))
													.padding(.leading, 5)
											}
										}
										.buttonStyle(.plain)

										Button {
											homeVM.tabNumb = 1
										} label: {
											VStack(spacing: 25) {
												HStack(alignment: .center) {
													Text(LocaleText.scheduleRequest)
														.font(homeVM.tabNumb == 1 ? .robotoBold(size: 12) : .robotoRegular(size: 12))
														.foregroundColor(.black)

													if !homeVM.counterRequest.isEmpty {
														Text(homeVM.counterRequest)
															.font(.robotoMedium(size: 10))
															.foregroundColor(.white)
															.padding(5)
															.background(
																RoundedRectangle(cornerRadius: 10)
																	.foregroundColor(.DinotisDefault.primary)
															)
													}
												}
												.background(Color.clear)
												.padding(.bottom, !homeVM.counterRequest.isEmpty ? -12 : -5)

												Rectangle()
													.frame(height: 1.5, alignment: .center)
													.foregroundColor(homeVM.tabNumb == 1 ? .DinotisDefault.primary : .DinotisDefault.primary.opacity(0.4))
													.padding(.trailing, 5)
											}
										}
										.buttonStyle(.plain)

									}
									.padding([.leading, .trailing, .top])
								}
								.background(
									RoundedCorner(radius: 20, corners: [.topLeft, .topRight])
										.foregroundColor(.white)
										.shadow(color: .black.opacity(0.035), radius: 3, x: 0, y: -5)
								)
								.padding(.horizontal, -20)
							}
							.listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
							.listRowBackground(Color.white)
							.background(
								Color.white
							)

						}
						.alert(isPresented: $homeVM.isRefreshFailed) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text(LocaleText.sessionExpireText),
								dismissButton: .default(Text(LocaleText.returnText), action: {

									homeVM.routeBack()
								}))
						}

					}
                    
                    if !(homeVM.meetingData.filter({ query in
                        !(query.isLiveStreaming ?? false)
                    }).isEmpty) {
                        Button(action: {
                            homeVM.routeToTalentFormSchedule()
                        }, label: {
                            Image.Dinotis.plusIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 22)
                                .padding()
                                .background(Color.DinotisDefault.primary)
                                .clipShape(Circle())
								.shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
                        })
                        .padding()
                    }
                }
                
                NavigationLink(
                    unwrapping: $homeVM.route,
                    case: /HomeRouting.talentFormSchedule,
                    destination: { viewModel in
                        ScheduledFormView(viewModel: viewModel.wrappedValue)
                    },
                    onNavigate: { _ in },
                    label: {
                        EmptyView()
                    }
                )
				.alert(isPresented: $homeVM.successConfirm) {
					Alert(
						title: Text(LocaleText.successTitle),
						message: Text(LocaleText.successConfirmRequestText),
						dismissButton: .default(Text(LocaleText.okText))
					)
				}
                
                NavigationLink(
                    unwrapping: $homeVM.route,
                    case: /HomeRouting.talentWallet,
                    destination: { viewModel in
                        TalentWalletView(viewModel: viewModel.wrappedValue)
                    },
                    onNavigate: { _ in },
                    label: {
                        EmptyView()
                    }
                )
                
                NavigationLink(
                    unwrapping: $homeVM.route,
                    case: /HomeRouting.bundlingMenu,
                    destination: { viewModel in
                        BundlingView(viewModel: viewModel.wrappedValue)
                    },
                    onNavigate: { _ in },
                    label: {
                        EmptyView()
                    }
                )
                
                NavigationLink(
                    unwrapping: $homeVM.route,
                    case: /HomeRouting.talentScheduleDetail,
                    destination: { viewModel in
                        TalentScheduleDetailView(viewModel: viewModel.wrappedValue)
                    },
                    onNavigate: { _ in },
                    label: {
                        EmptyView()
                    }
                )
                .alert(isPresented: $homeVM.isErrorAdditionalShow) {
                    Alert(
                        title: Text(LocaleText.errorText),
                        message: Text(homeVM.error.orEmpty()),
                        dismissButton: .cancel(Text(LocaleText.returnText))
                    )
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
                DinotisLoadingView(.fullscreen, hide: !homeVM.isLoading)
                
                DinotisLoadingView(.fullscreen, hide: !homeVM.isLoadingConfirm)
            }
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
            .onAppear(perform: {
                DispatchQueue.main.async {
                    homeVM.meetingParam.skip = 0
                    homeVM.meetingParam.take = 15
                    homeVM.onAppearView()
                }
            })
            .onDisappear {
                homeVM.meetingData = []
                homeVM.meetingParam.skip = 0
                homeVM.meetingParam.take = 15
            }
			.sheet(
				item: $homeVM.confirmationSheet,
				content: { item in
					switch item {
					case .accepted:
						if #available(iOS 16.0, *) {
							AcceptedSheet(viewModel: homeVM, isOnSheet: true)
								.padding()
								.presentationDetents([.medium])
								.presentationDragIndicator(.hidden)
						} else {
							AcceptedSheet(viewModel: homeVM, isOnSheet: false)
						}
					case .declined:
						if #available(iOS 16.0, *) {
							DeclinedSheet(viewModel: homeVM, isOnSheet: true)
								.padding()
								.presentationDetents([.medium])
						} else {
							DeclinedSheet(viewModel: homeVM, isOnSheet: false)
						}
					}
				}
			)
		}
        .onAppear {
            NotificationCenter.default.addObserver(forName: .creatorMeetingDetail, object: nil, queue: .main) { _ in
                homeVM.routeToTalentDetailSchedule(meetingId: state.meetingId)
            }
            
            NotificationCenter.default.addObserver(forName: .creatorHome, object: nil, queue: .main) { _ in
                homeVM.route = nil
            }
        }
    }
}

extension TalentHomeView {

	struct DeclinedSheet: View {

		@ObservedObject var viewModel: TalentHomeViewModel
		@State var selectedReason = [CancelOptionData]()
		@State var report = ""
		let isOnSheet: Bool

		var body: some View {
			VStack(spacing: 25) {
				HStack {
					Text(LocaleText.cancelConfirmationText)
						.font(.robotoBold(size: 14))
						.foregroundColor(.black)

					Spacer()

					Button(action: {
						viewModel.confirmationSheet = nil
					}, label: {
						Image(systemName: "xmark")
							.resizable()
							.scaledToFit()
							.frame(height: 10)
							.font(.system(size: 10, weight: .bold, design: .rounded))
							.foregroundColor(.black)
					})
				}

				LazyVStack(spacing: 15) {
					ForEach(viewModel.cancelOptionData.unique(), id: \.id) { item in
						Button {
							if isSelected(item: item, arrSelected: selectedReason) {
								if let itemToRemoveIndex = selectedReason.firstIndex(of: item) {
									selectedReason.remove(at: itemToRemoveIndex)
								}
							} else {
								selectedReason.append(item)
							}
						} label: {
							HStack(alignment: .top) {
								if isSelected(item: item, arrSelected: selectedReason) {
									Image.Dinotis.filledChecklistIcon
										.resizable()
										.scaledToFit()
										.frame(height: 15)
								} else {
									Image.Dinotis.emptyChecklistIcon
										.resizable()
										.scaledToFit()
										.frame(height: 15)
								}

								Text(item.name.orEmpty())
									.font(.robotoRegular(size: 12))
									.foregroundColor(.black)
									.multilineTextAlignment(.leading)

								Spacer()
							}
						}
					}

					if selectedReason.contains(where: { $0.id == 5 }) {
						TextField(LocaleText.reportNotesPlaceholder, text: $report)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
							.accentColor(.black)
							.disableAutocorrection(true)
							.autocapitalization(.none)
							.padding(10)
							.background(
								RoundedRectangle(cornerRadius: 10)
									.foregroundColor(.white)
							)
							.clipped()
							.overlay(
								RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray5), lineWidth: 1)
							)
							.shadow(color: Color.dinotisShadow.opacity(0.06), radius: 40, x: 0.0, y: 0.0)
					}
				}

				if isOnSheet {
					Spacer()
				}

				Button {
					Task {
						let selected = selectedReason.compactMap({ $0.id })
						await viewModel.confirmRequest(
							isAccepted: false,
							reasons: selected,
							otherReason: report
						)
					}
				} label: {
					HStack {

						Spacer()

						Text(LocaleText.sendText)
							.font(.robotoMedium(size: 12))
							.foregroundColor(selectedReason.isEmpty || (selectedReason.contains(where: { $0.id == 5 }) && report.isEmpty) ? Color(.systemGray2) : .white)

						Spacer()
					}
					.padding()
					.background(
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor(selectedReason.isEmpty || (selectedReason.contains(where: { $0.id == 5 }) && report.isEmpty) ? Color(.systemGray5) : .DinotisDefault.primary)
					)
				}
				.disabled(selectedReason.isEmpty || (selectedReason.contains(where: { $0.id == 5 }) && report.isEmpty))

			}
		}

		func isSelected(item: CancelOptionData, arrSelected: [CancelOptionData]) -> Bool {
			arrSelected.contains(where: { $0.id == item.id })
		}
	}

	struct AcceptedSheet: View {

		@ObservedObject var viewModel: TalentHomeViewModel
		@State var isAccepted = false
		let isOnSheet: Bool

		var body: some View {
			VStack(spacing: 25) {
				HStack {
					Text(LocaleText.acceptanceConfirmationText)
						.font(.robotoBold(size: 14))
						.foregroundColor(.black)

					Spacer()

					Button(action: {
						viewModel.confirmationSheet = nil
					}, label: {
						Image(systemName: "xmark")
							.resizable()
							.scaledToFit()
							.frame(height: 10)
							.font(.system(size: 10, weight: .bold, design: .rounded))
							.foregroundColor(.black)
					})
				}

				VStack(spacing: 15) {
					Text(LocaleText.acceptanceDescriptionText)
						.font(.robotoRegular(size: 12))
						.multilineTextAlignment(.leading)
						.foregroundColor(.black)

					Button {
						isAccepted.toggle()
					} label: {
						HStack(alignment: .top) {
							if isAccepted {
								Image.Dinotis.filledChecklistIcon
									.resizable()
									.scaledToFit()
									.frame(height: 15)
							} else {
								Image.Dinotis.emptyChecklistIcon
									.resizable()
									.scaledToFit()
									.frame(height: 15)
							}

							Text(LocaleText.privacyPolicyRateCardAcceptance)
								.font(.robotoRegular(size: 12))
								.foregroundColor(.gray)
								.multilineTextAlignment(.leading)

							Spacer()
						}
					}
				}

				if isOnSheet {
					Spacer()
				}

				Button {
					Task {
						await viewModel.confirmRequest(
							isAccepted: true,
							reasons: nil,
							otherReason: nil
						)
					}
				} label: {
					HStack {

						Spacer()

						Text(LocaleText.sendText)
							.font(.robotoMedium(size: 12))
							.foregroundColor(!isAccepted ? Color(.systemGray2) : .white)

						Spacer()
					}
					.padding()
					.background(
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor(!isAccepted ? Color(.systemGray5) : .DinotisDefault.primary)
					)
				}
				.disabled(!isAccepted)

			}
		}
	}
	
	struct EmptyStateView: View {

		let title: String
		let description: String
		let buttonText: String
		var primaryAction: () -> Void

		var body: some View {
			VStack(spacing: 10) {
				Image.Dinotis.emptyScheduleImage
					.resizable()
					.scaledToFit()
					.frame(
						height: 137
					)

				Text(title)
					.font(.robotoBold(size: 14))
					.foregroundColor(.black)

				Text(description)
					.font(.robotoRegular(size: 12))
					.multilineTextAlignment(.center)
					.foregroundColor(.black)

				Button(action: {
					primaryAction()
				}, label: {
					HStack {
						Spacer()
						Text(buttonText)
							.font(.robotoBold(size: 12))
							.foregroundColor(.white)
							.padding()
						Spacer()
					}
					.background(Color.DinotisDefault.primary)
					.cornerRadius(8)
					.padding()
				})
			}
			.padding()
			.background(Color.white)
			.cornerRadius(12)
			.shadow(color: Color.dinotisShadow.opacity(0.1), radius: 10, x: 0.0, y: 0.0)
			.padding(.vertical)
		}
	}
}
