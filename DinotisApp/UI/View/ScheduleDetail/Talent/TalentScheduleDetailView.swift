//
//  TalentScheduleDetailView.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/08/21.
//

import SwiftUI
import SwiftUITrackableScrollView
import SwiftKeychainWrapper
import CurrencyFormatter
import SwiftUINavigation
import OneSignal

struct TalentScheduleDetailView: View {
	
	@ObservedObject var viewModel: ScheduleDetailViewModel
	@ObservedObject var stateObservable = StateObservable.shared
    
    @StateObject private var streamViewModel = StreamViewModel()
    @StateObject private var participantsViewModel = ParticipantsViewModel()
    @StateObject private var streamManager = StreamManager()
    @StateObject private var speakerSettingsManager = SpeakerSettingsManager()
    @StateObject private var hostControlsManager = HostControlsManager()
    @StateObject private var speakerGridViewModel = SpeakerGridViewModel()
    @StateObject private var presentationLayoutViewModel = PresentationLayoutViewModel()
    @StateObject private var chatManager = ChatManager()

	@StateObject private var privateStreamViewModel = PrivateStreamViewModel()
	@StateObject private var privateStreamManager = PrivateStreamManager()
	@StateObject private var privateSpeakerSettingsManager = PrivateSpeakerSettingsManager()
	@StateObject private var privateSpeakerViewModel = PrivateVideoSpeakerViewModel()
	
	@ObservedObject var detailVM = DetailMeetingViewModel.shared
	@ObservedObject var startVM = StartMeetViewModel.shared
	
	@ObservedObject var talentMeetingVM = TalentMeetingViewModel.shared
	
	@Environment(\.presentationMode) var presentationMode

	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	var body: some View {
		ZStack {
			ZStack(alignment: .top) {
				Image.Dinotis.userTypeBackground
					.resizable()
					.edgesIgnoringSafeArea(.all)
					.alert(isPresented: $viewModel.isError) {
						Alert(
							title: Text(LocaleText.errorText),
							message: Text((viewModel.error?.errorDescription).orEmpty()),
							dismissButton: .cancel(Text(LocaleText.returnText))
						)
					}
				
				VStack(spacing: 0) {
					Color.white.frame(height: 10)
						.edgesIgnoringSafeArea(.all)
						.alert(isPresented: $detailVM.isRefreshFailed) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text(LocaleText.sessionExpireText),
								dismissButton: .default(Text(LocaleText.returnText), action: {
									viewModel.backToRoot()
									stateObservable.userType = 0
									stateObservable.isVerified = ""
									stateObservable.refreshToken = ""
									stateObservable.accessToken = ""
									stateObservable.isAnnounceShow = false
									OneSignal.setExternalUserId("")
								}))
						}
					
					ZStack {
						HStack {
							Spacer()
							Text(NSLocalizedString("video_call_details", comment: ""))
								.font(.montserratBold(size: 14))
								.foregroundColor(.black)
							
							Spacer()
						}
						.padding()
						.alert(isPresented: $viewModel.isEndSuccess) {
							Alert(
								title: Text(LocaleText.successTitle),
								message: Text(NSLocalizedString("ended_meeting_success", comment: "")),
								dismissButton: .default(Text(LocaleText.returnText), action: {
									self.presentationMode.wrappedValue.dismiss()
								}))
						}
						
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
						.alert(isPresented: $viewModel.isDeleteShow) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text(LocaleText.deleteAlertText),
								primaryButton: .default(
									Text(LocaleText.noText)
								),
								secondaryButton: .destructive(
									Text(LocaleText.yesDeleteText),
									action: {
										viewModel.deleteMeeting()
									}
								)
							)
						}
						
					}
					.padding(.top, 25)
					.background(Color.white.shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 20))
					
					RefreshableScrollView(action: refreshList) {
						if viewModel.isLoading {
							HStack {
								Spacer()
								ActivityIndicator(isAnimating: $viewModel.isLoading, color: .black, style: .medium)
									.padding(.top)
								
								Spacer()
							}
						}
						
						if let data = detailVM.data {
							TalentDetailScheduleCardView(
								data: .constant(data),
								onTapEdit: {
									viewModel.goToEdit.toggle()
									viewModel.meetingForm = MeetingForm(
										id: data.id,
										title: data.title.orEmpty(),
										description: data.description.orEmpty(),
										price: Int(data.price.orEmpty()).orZero(),
										startAt: data.startAt.orEmpty(),
										endAt: data.endAt.orEmpty(),
										isPrivate: data.isPrivate ?? true,
										slots: data.slots.orZero()
									)
								}, onTapDelete: {
									viewModel.isDeleteShow.toggle()
								}, onTapEnd: {
									viewModel.isEndShow.toggle()
								}
							)
							.valueChanged(value: viewModel.conteOffset) { val in
								viewModel.tabColor = val > 0 ? Color.white : Color.clear
							}
							
							if data.endedAt != nil {
								Button(action: {
									if let waurl = URL(string: "https://wa.me/6281318506068") {
										if UIApplication.shared.canOpenURL(waurl) {
											UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
										}
									}
								}, label: {
									HStack {
										Image.Dinotis.whatsappLogo
											.resizable()
											.scaledToFit()
											.frame(height: 28)
										
										Text(NSLocalizedString("need_help", comment: "")).font(.montserratRegular(size: 14)).foregroundColor(.black).underline()
										+
										Text(NSLocalizedString("contact_us", comment: "")).font(.montserratBold(size: 14)).foregroundColor(.black).underline()
										
										Spacer()
										
										Image.Dinotis.chevronLeftCircleIcon
									}
									.padding()
									.background(
										RoundedRectangle(cornerRadius: 12)
											.foregroundColor(.white)
											.shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
									)
									.padding(.horizontal)
								})
								
								VStack {
									Text(NSLocalizedString("revenue_summary", comment: ""))
										.font(.montserratBold(size: 16))
									
									HStack {
										if let dataParticipant = data.bookings?.filter({ value in
											value.bookingPayment?.paidAt != nil
										}) {
											Text("\(dataParticipant.count)x")
												.font(.montserratBold(size: 14))
											
											Text(LocaleText.generalParticipant)
												.font(.montserratRegular(size: 14))
											
											Spacer()
											
											Text(data.price.orEmpty().toCurrency())
												.font(.montserratBold(size: 14))
										}
									}
									.padding(.top, 15)
								}
								.padding()
								.background(
									RoundedRectangle(cornerRadius: 12)
										.foregroundColor(.white)
										.shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
								)
								.padding(.horizontal)
								.padding(.bottom, 120)
								
							} else {
								Button(action: {
									if let waurl = URL(string: "https://wa.me/6281318506068") {
										if UIApplication.shared.canOpenURL(waurl) {
											UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
										}
									}
								}, label: {
									HStack {
										Image.Dinotis.whatsappLogo
											.resizable()
											.scaledToFit()
											.frame(height: 28)
										
										Text(NSLocalizedString("need_help", comment: "")).font(.montserratRegular(size: 14)).foregroundColor(.black).underline()
										+
										Text(NSLocalizedString("contact_us", comment: "")).font(.montserratBold(size: 14)).foregroundColor(.black).underline()
										
										Spacer()
										
										Image.Dinotis.chevronLeftCircleIcon
									}
									.padding()
									.background(
										RoundedRectangle(cornerRadius: 12)
											.foregroundColor(.white)
											.shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
									)
									.padding(.horizontal)
								})
								.padding(.bottom, 120)
							}
							
						}
					}
					.alert(isPresented: $viewModel.isEndShow) {
						Alert(
							title: Text(LocaleText.attention),
							message: Text(NSLocalizedString("ended_meeting_label", comment: "")),
							primaryButton: .default(
								Text(LocaleText.noText)
							),
							secondaryButton: .destructive(
								Text(LocaleText.yesDeleteText),
								action: {
									viewModel.endMeeting()
								}
							)
						)
					}
				}
				.edgesIgnoringSafeArea(.all)
				.valueChanged(value: detailVM.success, onChange: { value in
					DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
						withAnimation(.spring()) {
							if value {
								self.viewModel.isLoading = false
							}
						}
					})
				})
				.valueChanged(value: detailVM.isLoading) { value in
					DispatchQueue.main.async {
						withAnimation(.spring()) {
							if value {
								self.viewModel.isLoading = true
							}
						}
					}
				}
				
				NavigationLink(
					destination: EditTalentMeetingView(meetingForm: $viewModel.meetingForm, meetingId: $viewModel.bookingId),
					isActive: $viewModel.goToEdit,
					label: {
						EmptyView()
					})
				
				VStack(spacing: 0) {
					Spacer()
						.alert(isPresented: $startVM.isRefreshFailed) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text(LocaleText.sessionExpireText),
								dismissButton: .default(Text(LocaleText.returnText), action: {
									viewModel.backToRoot()
									stateObservable.userType = 0
									stateObservable.isVerified = ""
									stateObservable.refreshToken = ""
									stateObservable.accessToken = ""
									stateObservable.isAnnounceShow = false
									OneSignal.setExternalUserId("")
								}))
						}
					
					if let dataPrice = detailVM.data {
						HStack {
							Text(NSLocalizedString("total_income", comment: ""))
								.font(.montserratRegular(size: 10))
								.foregroundColor(.black)
							
							Spacer()
							
							Text(viewModel.totalPrice.numberString.toCurrency())
								.font(.montserratSemiBold(size: 14))
								.foregroundColor(.black)
								.onAppear {
									viewModel.totalPrice = (Int(dataPrice.price.orEmpty()).orZero()) * (dataPrice.bookings?.filter({ item in
										item.bookingPayment?.paidAt != nil
									}) ?? []).count
								}
						}
						.padding(.horizontal)
						.padding(.vertical, 10)
						.background(Color.secondaryViolet)
						.isHidden(!(dataPrice.slots.orZero() > 1), remove: !(dataPrice.slots.orZero() > 1))
					}
					
					HStack {
						HStack(spacing: 10) {
							Image.Dinotis.coinIcon
								.resizable()
								.scaledToFit()
								.frame(height: 15)
							
							if let dataPrice = detailVM.data {
								if (dataPrice.price.orEmpty()) == "0" {
									Text(NSLocalizedString("free_text", comment: ""))
										.font(.montserratBold(size: 14))
										.foregroundColor(.primaryViolet)
								} else {
									if dataPrice.slots.orZero() > 1 {
										Text("\(dataPrice.price.orEmpty().toPriceFormat()) \(NSLocalizedString("person_suffix", comment: ""))")
											.font(.montserratBold(size: 14))
											.foregroundColor(.primaryViolet)
									} else {
										Text(dataPrice.price.orEmpty().toPriceFormat())
											.font(.montserratBold(size: 14))
											.foregroundColor(.primaryViolet)
									}
								}
							}
						}
						.padding(.vertical, 10)
						
						Spacer()
							.alert(isPresented: $talentMeetingVM.isRefreshFailed) {
								Alert(
									title: Text(LocaleText.attention),
									message: Text(LocaleText.sessionExpireText),
									dismissButton: .default(Text(LocaleText.returnText), action: {
										viewModel.backToRoot()
										stateObservable.userType = 0
										stateObservable.isVerified = ""
										stateObservable.refreshToken = ""
										stateObservable.accessToken = ""
										stateObservable.isAnnounceShow = false
										OneSignal.setExternalUserId("")
									}))
							}
						
						if detailVM.data?.endedAt == nil {
							Button(action: {
								if (detailVM.data?.startAt).orEmpty().toDate(format: .utcV2).orCurrentDate().addingTimeInterval(-3600) > Date() {
									viewModel.isRestricted.toggle()
								} else {
									viewModel.startPresented.toggle()
								}
							}, label: {
								HStack {
									Text(NSLocalizedString("start_now", comment: ""))
										.font(.montserratSemiBold(size: 14))
										.foregroundColor(.white)
										.padding(10)
										.padding(.horizontal, 5)
										.padding(.vertical, 5)
								}
								.background(Color.primaryViolet)
								.clipShape(RoundedRectangle(cornerRadius: 8))
							})
						}
						
					}
					.padding()
					.background(Color.white)
					.alert(isPresented: $viewModel.isDeleteSuccess) {
						Alert(
							title: Text(LocaleText.successTitle),
							message: Text(NSLocalizedString("meeting_deleted", comment: "")),
							dismissButton: .default(Text(LocaleText.returnText), action: {
								self.talentMeetingVM.getMeeting()
								self.presentationMode.wrappedValue.dismiss()
							}))
					}
					
					if let meetId = detailVM.data?.id {
						NavigationLink(
							unwrapping: $viewModel.route,
							case: /HomeRouting.videoCall,
							destination: {viewModel in
								PrivateVideoCallView(
									randomId: $viewModel.randomId,
									meetingId: .constant(meetId),
									viewModel: viewModel.wrappedValue
								)
									.environmentObject(privateStreamViewModel)
									.environmentObject(privateStreamManager)
									.environmentObject(privateSpeakerViewModel)
									.environmentObject(privateSpeakerSettingsManager)
							},
							onNavigate: {_ in},
							label: {
								EmptyView()
							}
						)
                        NavigationLink(
                            unwrapping: $viewModel.route,
                            case: /HomeRouting.twilioLiveStream,
                            destination: {viewModel in
															TwilioGroupVideoCallView(
                                    viewModel: viewModel.wrappedValue,
                                    meetingId: .constant(meetId), speaker: SpeakerVideoViewModel()
                                )
                                .environmentObject(streamViewModel)
                                .environmentObject(participantsViewModel)
                                .environmentObject(streamManager)
                                .environmentObject(speakerGridViewModel)
                                .environmentObject(presentationLayoutViewModel)
                                .environmentObject(speakerSettingsManager)
                                .environmentObject(hostControlsManager)
                                .environmentObject(chatManager)
                            },
                            onNavigate: {_ in},
                            label: {
                                EmptyView()
                            }
                        )
						.alert(isPresented: $viewModel.isRestricted) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text(NSLocalizedString("one_hour_restricted", comment: "")),
								dismissButton: .default(Text("OK"))
							)
						}
					}
					
					Color.white
						.frame(height: 10)
						.alert(isPresented: $viewModel.isRefreshFailed) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text(LocaleText.sessionExpireText),
								dismissButton: .default(Text(LocaleText.returnText), action: {
									viewModel.backToRoot()
									stateObservable.userType = 0
									stateObservable.isVerified = ""
									stateObservable.refreshToken = ""
									stateObservable.accessToken = ""
									stateObservable.isAnnounceShow = false
									OneSignal.setExternalUserId("")
								}))
						}
					
					NavigationLink(
						destination: EmptyView(),
						label: {
							EmptyView()
						})
				}
				.edgesIgnoringSafeArea(.all)
                .onChange(of: detailVM.success) { newValue in
                    if newValue {

						guard let meet = detailVM.data else {return}

						if detailVM.data?.isPrivate ?? false {
							privateStreamManager.meetingId = meet.id

							let localParticipant = PrivateLocalParticipantManager()
							let roomManager = PrivateRoomManager()

							roomManager.configure(localParticipant: localParticipant)

							let speakerVideoViewModelFactory = PrivateSpeakerVideoViewModelFactory()
							let speakersMap = SyncUsersMap()

							privateStreamManager.configure(roomManager: roomManager)
							privateStreamViewModel.configure(streamManager: privateStreamManager, speakerSettingsManager: privateSpeakerSettingsManager, meetingId: meet.id)
							privateSpeakerSettingsManager.configure(roomManager: roomManager)
							privateSpeakerViewModel.configure(roomManager: roomManager, speakersMap: speakersMap, speakerVideoViewModelFactory: speakerVideoViewModelFactory)

						} else {
							streamManager.meetingId = meet.id

							let localParticipant = LocalParticipantManager()
							let roomManager = RoomManager()
							roomManager.configure(localParticipant: localParticipant)
							let userDocument = SyncUserDocument()
							let roomDocument = SyncRoomDocument()
							let speakersMap = SyncUsersMap()
							let raisedHandsMap = SyncUsersMap()
							let viewersMap = SyncUsersMap()
							let speakerVideoViewModelFactory = SpeakerVideoViewModelFactory()
							let syncManager = SyncManager(speakersMap: speakersMap, viewersMap: viewersMap, raisedHandsMap: raisedHandsMap, userDocument: userDocument, roomDocument: roomDocument)
							participantsViewModel.configure(streamManager: streamManager, roomManager: roomManager, speakersMap: speakersMap, viewersMap: viewersMap, raisedHandsMap: raisedHandsMap)
							streamManager.configure(roomManager: roomManager, playerManager: PlayerManager(), syncManager: syncManager, chatManager: chatManager)
							streamViewModel.configure(streamManager: streamManager, speakerSettingsManager: speakerSettingsManager, userDocument: userDocument, meetingId: meet.id, roomDocument: roomDocument)
							speakerSettingsManager.configure(roomManager: roomManager)
							hostControlsManager.configure(roomManager: roomManager)
							speakerVideoViewModelFactory.configure(meetingId: meet.id, speakersMap: speakersMap)
							speakerGridViewModel.configure(roomManager: roomManager, speakersMap: speakersMap, speakerVideoViewModelFactory: speakerVideoViewModelFactory)
							presentationLayoutViewModel.configure(roomManager: roomManager, speakersMap: speakersMap, speakerVideoViewModelFactory: speakerVideoViewModelFactory)
						}
					}
				}
				
			}
			
			LoadingView(isAnimating: .constant(true))
				.isHidden(
					!startVM.isLoading || (!detailVM.isLoading && detailVM.data == nil),
					remove: !startVM.isLoading || (!detailVM.isLoading && detailVM.data == nil)
				)
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
		.dinotisSheet(isPresented: $viewModel.startPresented, options: .hideDismissButton, fraction: 0.7, content: {
			VStack(spacing: 15) {
				Image("img-popout")
					.resizable()
					.scaledToFit()
					.frame(height: 200)

				VStack(spacing: 35) {
					VStack(spacing: 10) {
						Text(NSLocalizedString("start_meeting_alert", comment: ""))
							.font(Font.custom(FontManager.Montserrat.bold, size: 14))
							.foregroundColor(.black)

						Text(NSLocalizedString("talent_start_call", comment: ""))
							.font(Font.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)
							.multilineTextAlignment(.center)
					}

					HStack(spacing: 15) {
						Button(action: {
							viewModel.startPresented.toggle()
						}, label: {
							HStack {
								Spacer()
								Text(NSLocalizedString("cancel", comment: ""))
									.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
									.foregroundColor(.black)
								Spacer()
							}
							.padding()
							.background(Color("btn-color-1"))
							.cornerRadius(8)
							.overlay(
								RoundedRectangle(cornerRadius: 8)
									.stroke(Color("btn-stroke-1"), lineWidth: 1.0)
							)
						})

						Button(action: {

							guard let detailMeet = detailVM.data else { return }

							startVM.startMeet(by: detailMeet.id)

							if detailMeet.slots.orZero() <= 1 {
								viewModel.routeToVideoCall(meeting: viewModel.convertToUserMeet(meet: detailMeet))
							} else if detailMeet.slots.orZero() > 1 {
								viewModel.routeToTwilioLiveStream(
									meeting: viewModel.convertToUserMeet(meet: detailMeet)
								)
							}

						}, label: {
							HStack {
								Spacer()
								Text(NSLocalizedString("start_now", comment: ""))
									.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
									.foregroundColor(.white)
								Spacer()
							}
							.padding()
							.background(Color("btn-stroke-1"))
							.cornerRadius(8)
						})
					}
				}
			}
		})
		.onAppear(perform: {
			detailVM.getDetailMeeting(id: viewModel.bookingId)
            stateObservable.spotlightedIdentity = ""
			StateObservable.shared.cameraPositionUsed = .front
			StateObservable.shared.twilioRole = ""
			StateObservable.shared.twilioUserIdentity = ""
			StateObservable.shared.twilioAccessToken = ""
		})
		.onDisappear(perform: {
			viewModel.startPresented = false
		})
		.dinotisSheet(isPresented: $viewModel.presentDelete, options: .hideDismissButton, content: {
			VStack(spacing: 15) {
				Image("remove-user-img")
					.resizable()
					.scaledToFit()
					.frame(height: 184)

				VStack(spacing: 35) {
					VStack(spacing: 10) {
						Text(NSLocalizedString("delete_participant_alert", comment: ""))
							.font(Font.custom(FontManager.Montserrat.bold, size: 14))
							.foregroundColor(.black)

						Text(NSLocalizedString("delete_participant", comment: ""))
							.font(Font.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)
							.multilineTextAlignment(.center)
					}

					HStack(spacing: 15) {
						Button(action: {
							viewModel.presentDelete.toggle()
						}, label: {
							HStack {
								Spacer()
								Text(NSLocalizedString("cancel", comment: ""))
									.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
									.foregroundColor(.black)
								Spacer()
							}
							.padding()
							.background(Color("btn-color-1"))
							.cornerRadius(8)
							.overlay(
								RoundedRectangle(cornerRadius: 8)
									.stroke(Color("btn-stroke-1"), lineWidth: 1.0)
							)
						})

						Button(action: {

						}, label: {
							HStack {
								Spacer()
								Text(NSLocalizedString("delete_text", comment: ""))
									.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
									.foregroundColor(.white)
								Spacer()
							}
							.padding()
							.background(Color("btn-stroke-1"))
							.cornerRadius(8)
						})
					}
				}
			}
		})
	}
	
	private func refreshList() {
		detailVM.getDetailMeeting(id: viewModel.bookingId)
	}
}

struct TalentScheduleDetailView_Previews: PreviewProvider {
	static var previews: some View {
		TalentScheduleDetailView(viewModel: ScheduleDetailViewModel(bookingId: "", backToRoot: {}, backToHome: {}))
	}
}
