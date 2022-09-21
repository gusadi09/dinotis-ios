//
//  TalentHomeView.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/08/21.
//

import SwiftUI
import CurrencyFormatter
import SwiftUITrackableScrollView
import SwiftKeychainWrapper
import SwiftUINavigation
import Introspect

struct TalentHomeView: View {
	
	@ObservedObject var homeVM: TalentHomeViewModel
	@ObservedObject var state = StateObservable.shared

	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	var body: some View {
		ZStack {
			NavigationLink(
				destination: EditTalentMeetingView(meetingForm: $homeVM.meetingForm, meetingId: $homeVM.meetingId),
				isActive: $homeVM.goToEdit,
				label: {
					EmptyView()
				})
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
						}))
			}

			ZStack(alignment: .center) {
				
				ZStack(alignment: .bottomTrailing) {
					Image.Dinotis.linearGradientBackground
						.resizable()
						.edgesIgnoringSafeArea(.all)
						.alert(isPresented: $homeVM.isError) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text((homeVM.error?.errorDescription).orEmpty()),
								dismissButton: .cancel(Text(LocaleText.returnText))
							)
						}
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
					
					VStack {
						HStack {
							Button(action: {
								homeVM.routeToProfile()
							}, label: {
								HStack(spacing: 15) {
									ProfileImageContainer(
										profilePhoto: $homeVM.photoProfile,
										name: $homeVM.nameOfUser,
										width: 55,
										height: 55
									)
									
									VStack(alignment: .leading, spacing: 15) {
										Text(LocaleText.helloText)
											.font(.montserratRegular(size: 14))
											.foregroundColor(.black)
										
										Text((homeVM.userData?.name).orEmpty())
											.font(.montserratBold(size: 14))
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
							
							Spacer()
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
						
						HStack(spacing: 15) {
							VStack(alignment: .leading, spacing: 15) {
								Text(LocaleText.walletBalance)
									.font(.montserratRegular(size: 12))
									.foregroundColor(.black)
								
								Text(homeVM.currentBalances.numberString.toCurrency())
									.font(.montserratBold(size: 18))
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
										.font(.montserratBold(size: 12))
										.foregroundColor(.black)
										.fixedSize(horizontal: true, vertical: false)
								}
							})
						}
						.padding(.vertical, 20)
						.padding(.horizontal, 15)
						.background(Color.white)
						.cornerRadius(12)
						.shadow(color: Color.dinotisShadow.opacity(0.1), radius: 40, x: 0, y: 0)
						.padding(.bottom, 5)
						.padding(.horizontal)
						
						HStack {
							Text(LocaleText.videoCallSchedule)
								.font(.montserratBold(size: 14))
							Spacer()
						}
						.padding(.horizontal)
						.padding(.top, 10)
						.alert(isPresented: $homeVM.isRefreshFailed) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text(LocaleText.sessionExpireText),
								dismissButton: .default(Text(LocaleText.returnText), action: {
									
									homeVM.routeBack()
								}))
						}

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
						.padding(.bottom, 8)
						.onChange(of: homeVM.filterSelection) { newValue in
							if let optionLabel = homeVM.filterOption.firstIndex(where: { query in
								query.label.orEmpty() == newValue
							}) {
								if newValue == homeVM.filterOption[optionLabel].label.orEmpty() {
									if let isEnded = homeVM.filterOption[optionLabel].queries?.firstIndex(where: { option in
										option.name.orEmpty() == "is_ended"
									}) {
										homeVM.meetingParam.isEnded = (homeVM.filterOption[optionLabel].queries?[isEnded].value).orEmpty()
									} else {
										homeVM.meetingParam.isEnded = ""
									}

									if let isAvail = homeVM.filterOption[optionLabel].queries?.firstIndex(where: { option in
										option.name.orEmpty() == "is_available"
									}) {
										homeVM.meetingParam.isAvailable = (homeVM.filterOption[optionLabel].queries?[isAvail].value).orEmpty()
									} else {
										homeVM.meetingParam.isAvailable = ""
									}
								}

								homeVM.meetingData = []
								homeVM.meetingParam.skip = 0
								homeVM.meetingParam.take = 15
								homeVM.getTalentMeeting()
							}
						}
						
						if let data = homeVM.meetingData.filter({ meet in
							!(meet.isLiveStreaming ?? false)
						}) {
							
							DinotisList { view in
								view.separatorStyle = .none
								view.indicatorStyle = .white
								view.sectionHeaderHeight = -10
								view.showsVerticalScrollIndicator = false
								homeVM.use(for: view) { refresh in
									Task {
										await homeVM.refreshList()
										refresh.endRefreshing()
									}
								}
							} content: {
								if data.isEmpty {
									VStack(spacing: 10) {
										Image.Dinotis.emptyScheduleImage
											.resizable()
											.scaledToFit()
											.frame(
												minWidth: 0,
												idealWidth: 203,
												maxWidth: 203,
												minHeight: 0,
												idealHeight: 137,
												maxHeight: 137,
												alignment: .center
											)

										Text(LocaleText.noScheduleLabel)
											.font(.montserratBold(size: 14))
											.foregroundColor(.black)

										Text(LocaleText.createScheduleLabel)
											.font(.montserratRegular(size: 12))
											.multilineTextAlignment(.center)
											.foregroundColor(.black)

										Button(action: {
											homeVM.routeToTalentFormSchedule()
										}, label: {
											HStack {
												Spacer()
												Text(LocaleText.createScheduleText)
													.font(.montserratBold(size: 12))
													.foregroundColor(.white)
													.padding()
												Spacer()
											}
											.background(Color.primaryViolet)
											.cornerRadius(8)
											.padding()
										})
									}
									.padding()
									.background(Color.white)
									.cornerRadius(12)
									.shadow(color: Color.dinotisShadow.opacity(0.1), radius: 10, x: 0.0, y: 0.0)
									.padding(.vertical)
									.listRowBackground(Color.clear)

								} else {
									LazyVStack(spacing: 20) {

										ForEach(data, id: \.id) { items in
											ScheduleCardView(
												data: .constant(items),
												onTapButton: {
													homeVM.meetingId = items.id.orEmpty()
													homeVM.routeToTalentDetailSchedule()
												}, onTapEdit: {
													homeVM.goToEdit.toggle()
													homeVM.meetingId = items.id.orEmpty()
													homeVM.meetingForm = MeetingForm(
														id: items.id,
														title: items.title.orEmpty(),
														description: items.meetingDescription.orEmpty(),
														price: Int(items.price.orEmpty()) ?? 0,
														startAt: items.startAt.orEmpty(),
														endAt: items.endAt.orEmpty(),
														isPrivate: items.isPrivate ?? false,
														slots: items.slots.orZero()
													)
												}, onTapDelete: {
													homeVM.isShowDelete.toggle()
													homeVM.meetingId = items.id.orEmpty()
												})
											.onAppear {
												if (data.last?.id).orEmpty() == items.id {
													homeVM.meetingParam.skip = homeVM.meetingParam.take
													homeVM.meetingParam.take += 15
													homeVM.getTalentMeeting()
												}
											}
										}
									}
									.listRowBackground(Color.clear)
									.padding(.top)
									.padding(.bottom, 40)
								}
							}

						} else {
							VStack(spacing: 10) {
								Image.Dinotis.emptyScheduleImage
									.resizable()
									.scaledToFit()
									.frame(
										minWidth: 0,
										idealWidth: 203,
										maxWidth: 203,
										minHeight: 0,
										idealHeight: 137,
										maxHeight: 137,
										alignment: .center
									)
								
								Text(LocaleText.noScheduleLabel)
									.font(.montserratBold(size: 14))
									.foregroundColor(.black)
								
								Text(LocaleText.createScheduleLabel)
									.font(.montserratRegular(size: 12))
									.multilineTextAlignment(.center)
									.foregroundColor(.black)
								
								Button(action: {
									homeVM.routeToTalentFormSchedule()
								}, label: {
									HStack {
										Spacer()
										Text(LocaleText.createScheduleText)
											.font(.montserratBold(size: 12))
											.foregroundColor(.white)
											.padding()
										Spacer()
									}
									.background(Color.primaryViolet)
									.cornerRadius(8)
									.padding()
								})
							}
							.padding()
							.background(Color.white)
							.cornerRadius(12)
							.padding(.horizontal)
							.shadow(color: Color.dinotisShadow.opacity(0.1), radius: 20, x: 0.0, y: 0.0)
							.padding(.top, 30)
							
							Spacer()
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
								.frame(height: 24)
								.padding()
								.background(Color.primaryViolet)
								.clipShape(Circle())
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
				
				NavigationLink(
					unwrapping: $homeVM.route,
					case: /HomeRouting.loginResetPassword,
					destination: { viewModel in
						LoginPasswordResetView(viewModel: viewModel.wrappedValue)
					},
					onNavigate: { _ in },
					label: {
						EmptyView()
					}
				)
				
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
						message: Text((homeVM.error?.errorDescription).orEmpty()),
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
		}
		
	}
}

struct TalentHomeView_Previews: PreviewProvider {
	static var previews: some View {
		TalentHomeView(homeVM: TalentHomeViewModel(backToRoot: {}))
	}
}
