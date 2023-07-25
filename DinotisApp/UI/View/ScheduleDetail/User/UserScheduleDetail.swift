//
//  UserScheduleDetail.swift
//  DinotisApp
//
//  Created by Gus Adi on 24/08/21.
//

import SwiftUI
import SwiftUITrackableScrollView
import CurrencyFormatter
import SwiftUINavigation
import OneSignal
import DinotisDesignSystem
import DinotisData

struct UserScheduleDetail: View {
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
    
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    @StateObject private var customerChatManager = CustomerChatManager()
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
	
	@ObservedObject var viewModel: ScheduleDetailViewModel
	@ObservedObject var stateObservable = StateObservable.shared
    
    @Binding var mainTabValue: TabRoute
	
	var body: some View {
		GeometryReader { geo in
			ZStack {
				if let meetId = viewModel.dataBooking?.id {
          
                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /HomeRouting.talentProfileDetail,
                        destination: {viewModel in
                            TalentProfileDetailView(viewModel: viewModel.wrappedValue, tabValue: $mainTabValue)
                        },
                        onNavigate: {_ in},
                        label: {
                            EmptyView()
                        }
                    )
                    
                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /HomeRouting.research,
                        destination: {viewModel in
                            GroupVideoCallView(viewModel: viewModel.wrappedValue)
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
					
					NavigationLink(
						unwrapping: $viewModel.route,
						case: /HomeRouting.videoCall,
						destination: {viewModel in
							PrivateVideoCallView(randomId: $viewModel.randomId, meetingId: .constant(meetId), viewModel: viewModel.wrappedValue)
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
					
				}
				
				ZStack(alignment: .top) {
                    Color.DinotisDefault.baseBackground
						.edgesIgnoringSafeArea(.all)
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
								})
							)
						}
						.onAppear {
							stateObservable.spotlightedIdentity = ""
							viewModel.onAppearView()
							StateObservable.shared.cameraPositionUsed = .front
							StateObservable.shared.twilioRole = ""
							StateObservable.shared.twilioUserIdentity = ""
							StateObservable.shared.twilioAccessToken = ""
						}
					
					VStack(spacing: 0) {
                        HeaderView(
                            type: .textHeader,
                            title: LocalizableText.videoCallDetailTitle,
                            leadingButton: {
                                DinotisElipsisButton(
                                    icon: .generalBackIcon,
                                    iconColor: .DinotisDefault.black1,
                                    bgColor: .DinotisDefault.white,
                                    strokeColor: nil,
                                    iconSize: 12,
                                    type: .primary, {
                                        if viewModel.isDirectToHome {
                                            self.viewModel.backToHome()
                                        } else {
                                            self.presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                )
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 0)
                            }
                        )
						
						ScrollableContent(viewModel: viewModel, action: refreshList, participantCount: participantCount(data: viewModel.dataBooking))
							.environmentObject(customerChatManager)
					}
					.onChange(of: viewModel.successDetail) { _ in
						
						guard let meet = viewModel.dataBooking?.meeting else {return}
						
						if meet.isPrivate ?? false {
							privateStreamManager.meetingId = meet.id.orEmpty()
							
							let localParticipant = PrivateLocalParticipantManager()
							let roomManager = PrivateRoomManager()
							
							roomManager.configure(localParticipant: localParticipant)
							
							let speakerVideoViewModelFactory = PrivateSpeakerVideoViewModelFactory()
							let speakersMap = SyncUsersMap()
							
							privateStreamManager.configure(roomManager: roomManager)
							privateStreamViewModel.configure(streamManager: privateStreamManager, speakerSettingsManager: privateSpeakerSettingsManager, meetingId: meet.id.orEmpty())
							privateSpeakerSettingsManager.configure(roomManager: roomManager)
							privateSpeakerViewModel.configure(roomManager: roomManager, speakersMap: speakersMap, speakerVideoViewModelFactory: speakerVideoViewModelFactory)
							
						} else {
							
							streamManager.meetingId = meet.id.orEmpty()
							
							let localParticipant = LocalParticipantManager()
							let roomManager = RoomManager()
							roomManager.configure(localParticipant: localParticipant)
							let roomDocument = SyncRoomDocument()
							let userDocument = SyncUserDocument()
							let speakersMap = SyncUsersMap()
							let raisedHandsMap = SyncUsersMap()
							let viewersMap = SyncUsersMap()
							let speakerVideoViewModelFactory = SpeakerVideoViewModelFactory()
							let syncManager = SyncManager(speakersMap: speakersMap, viewersMap: viewersMap, raisedHandsMap: raisedHandsMap, userDocument: userDocument, roomDocument: roomDocument)
							participantsViewModel.configure(streamManager: streamManager, roomManager: roomManager, speakersMap: speakersMap, viewersMap: viewersMap, raisedHandsMap: raisedHandsMap)
							streamManager.configure(roomManager: roomManager, playerManager: PlayerManager(), syncManager: syncManager, chatManager: chatManager)
							streamViewModel.configure(streamManager: streamManager, speakerSettingsManager: speakerSettingsManager, userDocument: userDocument, meetingId: meet.id.orEmpty(), roomDocument: roomDocument)
							speakerSettingsManager.configure(roomManager: roomManager)
							hostControlsManager.configure(roomManager: roomManager)
							speakerVideoViewModelFactory.configure(meetingId: meet.id.orEmpty(), speakersMap: speakersMap)
							speakerGridViewModel.configure(roomManager: roomManager, speakersMap: speakersMap, speakerVideoViewModelFactory: speakerVideoViewModelFactory)
							presentationLayoutViewModel.configure(roomManager: roomManager, speakersMap: speakersMap, speakerVideoViewModelFactory: speakerVideoViewModelFactory)
						}
						
					}
					
					BottomView(viewModel: viewModel)
						.edgesIgnoringSafeArea(.all)
				}
				
				ZStack {
					Color.black.opacity(viewModel.isShowingRules ? 0.4 : 0)
						.edgesIgnoringSafeArea(.all)
						.onTapGesture {
							withAnimation(.spring()) {
								viewModel.isShowingRules = false
							}
						}
					
					VStack {
						Spacer()
						
						VStack {
							Text(LocalizableText.videoCallRulesLabel)
								.font(.robotoBold(size: 14))
								.foregroundColor(.black)
								.padding()
							
							HTMLStringView(htmlContent: viewModel.HTMLContent)
                                .font(.robotoRegular(size: 14))
								.frame(height: geo.size.height/2)
								.padding([.horizontal, .bottom])
						}
						.background(Color.white)
						.clipShape(RoundedCorner(radius: 18, corners: [.topLeft, .topRight]))
						
					}
					.edgesIgnoringSafeArea(.bottom)
					.offset(y: viewModel.isShowingRules ? .zero : geo.size.height+100)
				}
				.sheet(unwrapping: $viewModel.route, case: /HomeRouting.scheduleNegotiationChat, onDismiss: {
					customerChatManager.hasUnreadMessage = false
				}) { viewModel in
					ScheduleNegotiationChatView(viewModel: viewModel.wrappedValue)
						.environmentObject(customerChatManager)
				}
				.onChange(of: viewModel.tokenConversation) { newValue in
					customerChatManager.connect(accessToken: newValue, conversationName: (viewModel.dataBooking?.meeting?.meetingRequest?.id).orEmpty())
				}
				.onDisappear {
					customerChatManager.disconnect()
				}
			}
			.navigationBarTitle(Text(""))
			.navigationBarHidden(true)
			.sheet(isPresented: $viewModel.startPresented, content: {
				if #available(iOS 16.0, *) {
					VStack(spacing: 15) {
						Image.Dinotis.popoutImage
							.resizable()
							.scaledToFit()
							.frame(height: 200)

						VStack(spacing: 35) {
							VStack(spacing: 10) {
								Text(LocaleText.startMeetingAlertTitle)
                                    .font(.robotoBold(size: 14))
									.foregroundColor(.black)

								Text(LocaleText.talentStartCallLabel)
									.font(.robotoRegular(size: 12))
									.foregroundColor(.black)
									.multilineTextAlignment(.center)
							}

							HStack(spacing: 15) {
								Button(action: {
									viewModel.startPresented.toggle()
								}, label: {
									HStack {
										Spacer()
										Text(LocaleText.cancelText)
											.font(.robotoMedium(size: 12))
											.foregroundColor(.black)
										Spacer()
									}
									.padding()
									.background(Color.secondaryViolet)
									.cornerRadius(12)
									.overlay(
										RoundedRectangle(cornerRadius: 12)
											.stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
									)
								})

								Button(action: {

									guard let meet = viewModel.dataBooking?.meeting else { return }
                                    
                                    viewModel.startPresented.toggle()

									if !(meet.isPrivate ?? false) {
//										self.viewModel.routeToTwilioLiveStream(meeting: meet)
                                        self.viewModel.routeToResearch(meeting: meet)
									} else {
										self.viewModel.routeToVideoCall(meeting: meet)
									}
								}, label: {
									HStack {
										Spacer()
										Text(LocaleText.startNowText)
											.font(.robotoMedium(size: 12))
											.foregroundColor(.white)
										Spacer()
									}
									.padding()
									.background(Color.DinotisDefault.primary)
									.cornerRadius(12)
								})
							}
						}
					}
						.padding()
						.padding(.vertical)
						.presentationDetents([.fraction(0.7), .large])
				} else {
					VStack(spacing: 15) {
						Image.Dinotis.popoutImage
							.resizable()
							.scaledToFit()
							.frame(height: 200)

						VStack(spacing: 35) {
							VStack(spacing: 10) {
								Text(LocaleText.startMeetingAlertTitle)
                                    .font(.robotoBold(size: 14))
									.foregroundColor(.black)

								Text(LocaleText.talentStartCallLabel)
									.font(.robotoRegular(size: 12))
									.foregroundColor(.black)
									.multilineTextAlignment(.center)
							}

							HStack(spacing: 15) {
								Button(action: {
									viewModel.startPresented.toggle()
								}, label: {
									HStack {
										Spacer()
										Text(LocaleText.cancelText)
											.font(.robotoMedium(size: 12))
											.foregroundColor(.black)
										Spacer()
									}
									.padding()
									.background(Color.secondaryViolet)
									.cornerRadius(12)
									.overlay(
										RoundedRectangle(cornerRadius: 12)
											.stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
									)
								})

								Button(action: {

									guard let meet = viewModel.dataBooking?.meeting else { return }

									if (meet.slots).orZero() > 1 {
//										self.viewModel.routeToTwilioLiveStream(meeting: meet)
                                        self.viewModel.routeToResearch(meeting: meet)
									} else {
										self.viewModel.routeToVideoCall(meeting: meet)
									}
								}, label: {
									HStack {
										Spacer()
										Text(LocaleText.startNowText)
											.font(.robotoMedium(size: 12))
											.foregroundColor(.white)
										Spacer()
									}
									.padding()
									.background(Color.DinotisDefault.primary)
									.cornerRadius(12)
								})
							}
						}
					}
						.padding()
						.padding(.vertical)
				}

			})
      .sheet(isPresented: $viewModel.isShowAttachments) {
        if #available(iOS 16.0, *) {
          AttachmentBottomSheet(viewModel: viewModel)
            .presentationDetents([.fraction(0.4), .fraction(0.6), .large])
        } else {
          AttachmentBottomSheet(viewModel: viewModel)
        }
      }
      .sheet(isPresented: $viewModel.isShowWebView) {
        if let url = URL(string: viewModel.attachmentURL) {
#if os(iOS)
          SafariViewWrapper(url: url)
#else
          WebView(url: url)
#endif
        } else {
          if #available(iOS 16.0, *) {
            EmptyURLView(viewModel: viewModel)
              .presentationDetents([.fraction(0.6)])
          } else {
            EmptyURLView(viewModel: viewModel)
          }
        }
      }
      .sheet(isPresented: $viewModel.isShowCollabList, content: {
          if #available(iOS 16.0, *) {
            SelectedCollabCreatorView(
              isEdit: false,
              isAudience: true,
              arrUsername: .constant((viewModel.dataBooking?.meeting?.meetingCollaborations ?? []).compactMap({
                $0.username
            })),
              arrTalent: .constant(viewModel.dataBooking?.meeting?.meetingCollaborations ?? [])) {
                viewModel.isShowCollabList = false
              } visitProfile: { item in
                viewModel.routeToTalentProfile(username: item)
              }
              .presentationDetents([.medium, .large])
          } else {
            SelectedCollabCreatorView(
              isEdit: false,
              isAudience: true,
              arrUsername: .constant((viewModel.dataBooking?.meeting?.meetingCollaborations ?? []).compactMap({
                $0.username
            })),
              arrTalent: .constant(viewModel.dataBooking?.meeting?.meetingCollaborations ?? [])) {
                viewModel.isShowCollabList = false
              } visitProfile: { item in
                viewModel.routeToTalentProfile(username: item)
              }
          }
      })
		}
	}
	
	private func participantCount(data: UserBookingData?) -> Int {
		(data?.meeting?.participants).orZero()
	}
	
	func refreshList() {
		Task {
			await viewModel.getDetailBookingUser()
		}
	}
}

private extension UserScheduleDetail {
	
	struct ScrollableContent: View {
		
		@ObservedObject var viewModel: ScheduleDetailViewModel
		@EnvironmentObject var customerChatManager: CustomerChatManager
		var action: (() -> Void)
		var participantCount: Int
		
		var body: some View {
			RefreshableScrollViews(action: action) {
				if viewModel.isLoading {
					HStack {
						Spacer()
						
						ActivityIndicator(isAnimating: $viewModel.isLoading, color: .black, style: .medium)
						
						Spacer()
					}
					.padding()
				}
				
				
				
				if let detail = viewModel.dataBooking {
					if viewModel.dataBooking?.meeting?.meetingRequest != nil {
						if let detail = viewModel.dataBooking?.meeting {
							VStack {
								Text(LocalizableText.detailScheduleTitle)
									.font(.robotoBold(size: 12))
									.foregroundColor(.black)
								
								HStack(spacing: 12) {
									if UIDevice.current.userInterfaceIdiom == .pad {
										VStack(alignment: .leading) {
											ZStack(alignment: .topLeading) {
												HStack(spacing: 53) {
													Rectangle()
                                                        .foregroundColor(viewModel.isPaymentDone(status: detail.status.orEmpty()) ? .DinotisDefault.primary : Color(.systemGray4))
														.frame(width: 50, height: 2)
														.padding(.leading, 75)

													Rectangle()
														.foregroundColor(
															viewModel.isWaitingCreatorConfirmationDone(
																status: detail.status.orEmpty(),
																isAccepted: detail.meetingRequest?.isAccepted
															) ? .DinotisDefault.primary
															: Color(.systemGray4)
														)
														.frame(width: 50, height: 2)

													Rectangle()
														.foregroundColor(
															viewModel.isScheduleConfirmationDone(
																status: detail.status.orEmpty(),
																isConfirmed: detail.meetingRequest?.isConfirmed
															) ? .DinotisDefault.primary
															: Color(.systemGray4)
														)
														.frame(width: 50, height: 2)

													Rectangle()
														.foregroundColor(
															viewModel.isScheduleStartedDone(status: detail.status.orEmpty()) ?
                                                                .DinotisDefault.primary :
																Color(.systemGray4)
														)
														.frame(width: 50, height: 2)
												}
												.padding(.top, 17.5)

												HStack(alignment: .top, spacing: 3) {
													VStack(spacing: 6) {
                                                        (viewModel.isPaymentDone(status: detail.status.orEmpty()) ? Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon)
															.resizable()
															.scaledToFit()
															.frame(width: 35, height: 35)

														Text(LocalizableText.stepPaymentDone)
															.font(.robotoMedium(size: 10))
                                                            .foregroundColor(.DinotisDefault.primary)
													}
													.multilineTextAlignment(.center)
													.frame(width: 100)
													.padding(.leading, -12)

													VStack(spacing: 6) {
														//FIXME: Fix the conditional logic
														if viewModel.isWaitingCreatorConfirmationDone(
															status: detail.status.orEmpty(),
															isAccepted: detail.meetingRequest?.isAccepted
														) {
															Image.sessionDetailActiveCheckmarkIcon
																.resizable()
																.scaledToFit()
																.frame(width: 35, height: 35)

															Text(LocalizableText.stepWaitingConfirmation)
																.font(.robotoMedium(size: 10))
                                                                .foregroundColor(.DinotisDefault.primary)
														} else if viewModel.isWaitingCreatorConfirmationFailed(
															status: detail.status.orEmpty(),
															isAccepted: detail.meetingRequest?.isAccepted
														) {
															Image.sessionDetailXmarkIcon
																.resizable()
																.scaledToFit()
																.frame(width: 35, height: 35)

															Text(LocalizableText.stepWaitingConfirmation)
																.font(.robotoMedium(size: 10))
																.foregroundColor(.red)
														} else {
															Image.sessionDetailInactiveCheckmarkIcon
																.resizable()
																.scaledToFit()
																.frame(width: 35, height: 35)

															Text(LocalizableText.stepWaitingConfirmation)
																.font(.robotoMedium(size: 10))
																.foregroundColor(Color(.systemGray4))
														}

													}
													.multilineTextAlignment(.center)
													.frame(width: 100)

													VStack(spacing: 6) {
														//FIXME: Fix the conditional logic
														if viewModel.isScheduleConfirmationDone(
															status: detail.status.orEmpty(),
															isConfirmed: detail.meetingRequest?.isConfirmed
														) {
															(Image.sessionDetailActiveCheckmarkIcon)
																.resizable()
																.scaledToFit()
																.frame(width: 35, height: 35)

                                                            Text(LocalizableText.stepSetSessionTime)
																.font(.robotoMedium(size: 10))
																.foregroundColor(.DinotisDefault.primary)
														} else if viewModel.isScheduleConfirmationFailed(
															status: detail.status.orEmpty(),
															isConfirmed: detail.meetingRequest?.isConfirmed
														) {
															Image.sessionDetailXmarkIcon
																.resizable()
																.scaledToFit()
																.frame(width: 35, height: 35)

                                                            Text(LocalizableText.stepSetSessionTime)
																.font(.robotoMedium(size: 10))
																.foregroundColor(.red)
														} else {
                                                            Image.sessionDetailInactiveCheckmarkIcon
																.resizable()
																.scaledToFit()
																.frame(width: 35, height: 35)

                                                            Text(LocalizableText.stepSetSessionTime)
																.font(.robotoMedium(size: 10))
																.foregroundColor(Color(.systemGray4))
														}

													}
													.multilineTextAlignment(.center)
													.frame(width: 100)

													VStack(spacing: 6) {

                                                        (viewModel.isScheduleStartedDone(status: detail.status.orEmpty()) ?
                                                         Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon
                                                        )
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 35, height: 35)

                                                        Text(LocalizableText.stepSessionStart)
															.font(.robotoMedium(size: 10))
															.foregroundColor(
																viewModel.isScheduleStartedDone(status: detail.status.orEmpty()) ?
                                                                    .DinotisDefault.primary :
																	Color(.systemGray4)
															)

													}
													.multilineTextAlignment(.center)
													.frame(width: 100)

													VStack(spacing: 6) {
                                                        (viewModel.isScheduleEndedDone(status: detail.status.orEmpty()) ?
                                                         Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon
                                                        )
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 35, height: 35)

														Text(LocaleText.detailScheduleStepFour)
															.font(.robotoMedium(size: 10))
                                                            .foregroundColor(viewModel.isScheduleEndedDone(status: detail.status.orEmpty()) ? .DinotisDefault.primary : Color(.systemGray4))

													}
													.multilineTextAlignment(.center)
													.frame(width: 100)
												}
												.padding(.horizontal, 10)
											}
										}
									} else {
										ScrollView(.horizontal, showsIndicators: false) {
											VStack(alignment: .leading) {
												ZStack(alignment: .topLeading) {
													HStack(spacing: 53) {
														Rectangle()
                                                            .foregroundColor(viewModel.isPaymentDone(status: detail.status.orEmpty()) ? .DinotisDefault.primary : Color(.systemGray4))
															.frame(width: 50, height: 2)
															.padding(.leading, 75)

														Rectangle()
															.foregroundColor(
																viewModel.isWaitingCreatorConfirmationDone(
																	status: detail.status.orEmpty(),
																	isAccepted: detail.meetingRequest?.isAccepted
																) ? .DinotisDefault.primary
																: Color(.systemGray4)
															)
															.frame(width: 50, height: 2)

														Rectangle()
															.foregroundColor(
																viewModel.isScheduleConfirmationDone(
																	status: detail.status.orEmpty(),
																	isConfirmed: detail.meetingRequest?.isConfirmed
																) ? .DinotisDefault.primary
																: Color(.systemGray4)
															)
															.frame(width: 50, height: 2)

														Rectangle()
															.foregroundColor(
																viewModel.isScheduleStartedDone(status: detail.status.orEmpty()) ?
																	.DinotisDefault.primary :
																	Color(.systemGray4)
															)
															.frame(width: 50, height: 2)
													}
													.padding(.top, 17.5)

													HStack(alignment: .top, spacing: 3) {
														VStack(spacing: 6) {
															(viewModel.isPaymentDone(status: detail.status.orEmpty()) ?
                                                             Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon
                                                            )
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 35, height: 35)

															Text(LocalizableText.stepPaymentDone)
																.font(.robotoMedium(size: 10))
                                                                .foregroundColor(viewModel.isPaymentDone(status: detail.status.orEmpty()) ? .DinotisDefault.primary : Color(.systemGray4))
														}
														.multilineTextAlignment(.center)
														.frame(width: 100)
														.padding(.leading, -12)

														VStack(spacing: 6) {
															//FIXME: Fix the conditional logic
															if viewModel.isWaitingCreatorConfirmationDone(
																status: detail.status.orEmpty(),
																isAccepted: detail.meetingRequest?.isAccepted
															) {
                                                                Image.sessionDetailActiveCheckmarkIcon
																	.resizable()
																	.scaledToFit()
																	.frame(width: 35, height: 35)

                                                                Text(LocalizableText.stepWaitingConfirmation)
																	.font(.robotoMedium(size: 10))
                                                                    .foregroundColor(.DinotisDefault.primary)
															} else if viewModel.isWaitingCreatorConfirmationFailed(
																status: detail.status.orEmpty(),
																isAccepted: detail.meetingRequest?.isAccepted
															) {
																Image.sessionDetailXmarkIcon
																	.resizable()
																	.scaledToFit()
																	.frame(width: 35, height: 35)

                                                                Text(LocalizableText.stepWaitingConfirmation)
																	.font(.robotoMedium(size: 10))
																	.foregroundColor(.red)
															} else {
                                                                Image.sessionDetailInactiveCheckmarkIcon
																	.resizable()
																	.scaledToFit()
																	.frame(width: 35, height: 35)

                                                                Text(LocalizableText.stepWaitingConfirmation)
																	.font(.robotoMedium(size: 10))
																	.foregroundColor(Color(.systemGray4))
															}

														}
														.multilineTextAlignment(.center)
														.frame(width: 100)

														VStack(spacing: 6) {
															//FIXME: Fix the conditional logic
															if viewModel.isScheduleConfirmationDone(
																status: detail.status.orEmpty(),
																isConfirmed: detail.meetingRequest?.isConfirmed
															) {
																Image.sessionDetailActiveCheckmarkIcon
																	.resizable()
																	.scaledToFit()
																	.frame(width: 35, height: 35)

                                                                Text(LocalizableText.stepSetSessionTime)
																	.font(.robotoMedium(size: 10))
                                                                    .foregroundColor(.DinotisDefault.primary)
															} else if viewModel.isScheduleConfirmationFailed(
																status: detail.status.orEmpty(),
																isConfirmed: detail.meetingRequest?.isConfirmed
															) {
                                                                Image.sessionDetailXmarkIcon
																	.resizable()
																	.scaledToFit()
																	.frame(width: 35, height: 35)

                                                                Text(LocalizableText.stepSetSessionTime)
																	.font(.robotoMedium(size: 10))
																	.foregroundColor(.red)
															} else {
                                                                Image.sessionDetailInactiveCheckmarkIcon
																	.resizable()
																	.scaledToFit()
																	.frame(width: 35, height: 35)

                                                                Text(LocalizableText.stepSetSessionTime)
																	.font(.robotoMedium(size: 10))
																	.foregroundColor(Color(.systemGray4))
															}

														}
														.multilineTextAlignment(.center)
														.frame(width: 100)

														VStack(spacing: 6) {

															(viewModel.isScheduleStartedDone(status: detail.status.orEmpty()) ?
                                                             Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon
                                                            )
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 35, height: 35)

															Text(LocalizableText.stepSessionStart)
																.font(.robotoMedium(size: 10))
																.foregroundColor(
																	viewModel.isScheduleStartedDone(status: detail.status.orEmpty()) ?
                                                                        .DinotisDefault.primary :
																		Color(.systemGray4)
																)

														}
														.multilineTextAlignment(.center)
														.frame(width: 100)

														VStack(spacing: 6) {
															(viewModel.isScheduleEndedDone(status: detail.status.orEmpty()) ?
                                                             Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon
                                                            )
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 35, height: 35)

                                                            Text(LocalizableText.stepSessionDone)
																.font(.robotoMedium(size: 10))
                                                                .foregroundColor(viewModel.isScheduleEndedDone(status: detail.status.orEmpty()) ? .DinotisDefault.primary : Color(.systemGray4))

														}
														.multilineTextAlignment(.center)
														.frame(width: 100)
													}
													.padding(.horizontal, 10)
												}
											}
										}
									}
								}
							}
							.padding()
							.background(
								RoundedRectangle(cornerRadius: 12)
									.foregroundColor(.white)
									.shadow(color: Color.dinotisShadow.opacity(0.08), radius: 10, x: 0, y: 0)
							)
							.padding([.top, .horizontal])
						}
					} else {
						if let detail = viewModel.dataBooking?.meeting, let bookingPay = viewModel.dataBooking?.bookingPayment {
							VStack {
                                Text(LocalizableText.detailScheduleTitle)
                                    .font(.robotoBold(size: 12))
                                    .foregroundColor(.black)
								
								HStack(spacing: 3) {
									VStack(alignment: .leading) {
										HStack(spacing: 3) {
											HStack(spacing: 3) {
												
                                                (bookingPay.paidAt != nil ? Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon)
													.resizable()
													.scaledToFit()
													.frame(height: 35)
												
												Rectangle()
                                                    .foregroundColor(bookingPay.paidAt != nil ? .DinotisDefault.primary : Color(.systemGray4))
													.frame(height: 2)
												
											}
											
											HStack(spacing: 3) {
												
												(bookingPay.paidAt != nil ? Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon)
													.resizable()
													.scaledToFit()
													.frame(height: 35)
												
												Rectangle()
                                                    .foregroundColor(bookingPay.paidAt != nil ? .DinotisDefault.primary : Color(.systemGray4))
													.frame(height: 2)
												
											}
											
											HStack(spacing: 3) {
												
												(
													detail.startedAt != nil ||
													detail.startAt.orCurrentDate() <= Date() ?
                                                    Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon
												)
												.resizable()
												.scaledToFit()
												.frame(height: 35)
												
												Rectangle()
													.foregroundColor(
														detail.startedAt != nil ||
														detail.startAt.orCurrentDate() <= Date() ?
                                                            .DinotisDefault.primary :
															Color(.systemGray4)
													)
													.frame(height: 2)
												
											}
											
											HStack(spacing: 3) {
												
												(detail.endedAt != nil ? Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon)
													.resizable()
													.scaledToFit()
													.frame(height: 35)
											}
										}
										.padding(.horizontal, 10)
										
										HStack {
											VStack(spacing: 6) {
                                                Text(LocalizableText.stepPaymentDone)
													.font(.robotoMedium(size: 10))
                                                    .foregroundColor(bookingPay.paidAt != nil ? .DinotisDefault.primary : Color(.systemGray4))
												
                                                Text(DateUtils.dateFormatter(bookingPay.paidAt.orCurrentDate(), forFormat: .ddMMyyyyHHmm))
													.font(.robotoRegular(size: 10))
													.foregroundColor(.black)
											}
											.multilineTextAlignment(.center)
											.frame(width: 55)
											
											Spacer()
											
											VStack(spacing: 6) {
                                                Text(LocalizableText.stepWaitingForSession)
													.font(.robotoMedium(size: 10))
                                                    .foregroundColor(bookingPay.paidAt != nil ? .DinotisDefault.primary : Color(.systemGray4))
												
                                                Text(DateUtils.dateFormatter(bookingPay.paidAt.orCurrentDate(), forFormat: .ddMMyyyyHHmm))
													.font(.robotoRegular(size: 10))
													.foregroundColor(.black)
											}
											.multilineTextAlignment(.center)
											.frame(width: 55)
											
											Spacer()
											
											VStack(spacing: 6) {
                                                Text(LocalizableText.stepSessionStart)
													.font(.robotoMedium(size: 10))
													.foregroundColor(
														detail.startedAt != nil ||
														detail.startAt.orCurrentDate() <= Date() ?
                                                            .DinotisDefault.primary :
															Color(.systemGray4)
													)
												
												Text(
                                                    DateUtils.dateFormatter(detail.startedAt.orCurrentDate(), forFormat: .ddMMyyyyHHmm)
												)
												.font(.robotoRegular(size: 10))
												.foregroundColor(.black)
											}
											.multilineTextAlignment(.center)
											.frame(width: 55)
											
											Spacer()
											
											VStack(spacing: 6) {
                                                Text(LocalizableText.stepSessionDone)
													.font(.robotoMedium(size: 10))
                                                    .foregroundColor(detail.endedAt != nil ? .DinotisDefault.primary : Color(.systemGray4))
												
                                                Text(DateUtils.dateFormatter(detail.endedAt.orCurrentDate(), forFormat: .ddMMyyyyHHmm))
													.font(.robotoRegular(size: 10))
													.foregroundColor(.black)
											}
											.multilineTextAlignment(.center)
											.frame(width: 55)
										}
									}
								}
							}
							.padding()
							.background(
								RoundedRectangle(cornerRadius: 12)
									.foregroundColor(.white)
									.shadow(color: Color.dinotisShadow.opacity(0.08), radius: 10, x: 0, y: 0)
							)
							.padding([.top, .horizontal])
						}
					}
					
					if viewModel.dataBooking?.meeting?.meetingRequest != nil {
						
                        if !(viewModel.dataBooking?.meeting?.meetingRequest?.isConfirmed ?? false) {
                            HStack {
                                Image.Dinotis.noticeIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 23, height: 23)
                                
                                Text(LocaleText.waitingConfirmationCaption)
                                    .font(.robotoRegular(size: 10))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.infoColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.top, 6)
                            .padding(.horizontal)
                        }
						
						if viewModel.dataBooking?.meeting?.startAt == nil {
							Button {
								viewModel.routeToScheduleNegotiationChat()
							} label: {
								HStack {
									Image.Dinotis.messageIcon
										.resizable()
										.scaledToFit()
										.frame(width: 16, height: 16)
									
									Text(LocaleText.discussWithCreator)
										.font(.robotoMedium(size: 12))
										.foregroundColor(.black)
									
									Spacer()
									
									Circle()
										.foregroundColor(.DinotisDefault.primary)
										.scaledToFit()
										.frame(height: 15)
										.isHidden(!customerChatManager.hasUnreadMessage, remove: !customerChatManager.hasUnreadMessage)
									
									Image(systemName: "chevron.right")
										.resizable()
										.scaledToFit()
										.foregroundColor(.black)
										.frame(width: 8)
								}
								.padding()
								.background(
									RoundedRectangle(cornerRadius: 12)
										.foregroundColor(.white)
										.shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
								)
								.padding(.horizontal)
								.padding(.top, 10)
							}
						}
					} else {
						Button {
							withAnimation(.spring()) {
								viewModel.isShowingRules.toggle()
							}
							
						} label: {
							HStack {
								Text(LocalizableText.videoCallRulesLabel)
									.font(.robotoRegular(size: 14))
                                    .foregroundColor(.DinotisDefault.primary)
								
								Spacer()
								
								Image(systemName: "chevron.right")
									.resizable()
									.scaledToFit()
									.frame(height: 10)
                                    .foregroundColor(.DinotisDefault.primary)
							}
							.padding(.horizontal)
							.padding(.vertical, 20)
                            .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.DinotisDefault.lightPrimary))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.DinotisDefault.primary, lineWidth: 1))
							.padding(.top, 10)
							.padding(.horizontal)
						}
					}
					
					VStack(alignment: .leading) {
						HStack(spacing: 15) {
							DinotisImageLoader(
                                urlString: (viewModel.dataBooking?.meeting?.user?.profilePhoto).orEmpty(),
                                width: 40,
                                height: 40
                            )
                            .clipShape(Circle())
                            
                            if viewModel.dataBooking?.meeting?.user?.isVerified ?? false {
                                Text("\((viewModel.dataBooking?.meeting?.user?.name).orEmpty()) \(Image.sessionCardVerifiedIcon)")
                                    .font(.robotoBold(size: 14))
                                    .foregroundColor(.black)
                            } else {
                                Text("\((viewModel.dataBooking?.meeting?.user?.name).orEmpty())")
                                    .font(.robotoBold(size: 14))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
						}
						.padding(.vertical, 10)
						
						VStack(alignment:.leading, spacing: 5) {
							Text((detail.meeting?.title).orEmpty())
								.font(.robotoBold(size: 16))
								.foregroundColor(.black)
							
                            VStack(alignment: .leading) {
                                Text((detail.meeting?.meetingDescription).orEmpty())
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(viewModel.isTextComplete ? nil : 3)
                                
                                HStack {
                                    Button {
                                        withAnimation {
                                            viewModel.isTextComplete.toggle()
                                        }
                                    } label: {
                                        Text(viewModel.isTextComplete ? LocalizableText.bookingRateCardHideFullText : LocalizableText.bookingRateCardShowFullText)
                                            .font(.robotoMedium(size: 12))
                                            .foregroundColor(.DinotisDefault.primary)
                                    }
                                    
                                    Spacer()
                                }
                                .isHidden(
                                    (detail.meeting?.meetingDescription).orEmpty().count < 150,
                                    remove: (detail.meeting?.meetingDescription).orEmpty().count < 150
                                )
                            }
                            .padding(.bottom, 10)
						}
						
						HStack(spacing: 10) {
							Image.sessionCardDateIcon
								.resizable()
								.scaledToFit()
								.frame(height: 18)
							
							if let dateStart = detail.meeting?.startAt {
                                Text(DateUtils.dateFormatter(dateStart, forFormat: .EEEEddMMMMyyyy))
									.font(.robotoRegular(size: 12))
									.foregroundColor(.black)
							} else {
								Text(LocaleText.unconfirmedText)
									.font(.robotoRegular(size: 12))
									.foregroundColor(.black)
							}
						}
						
						HStack(spacing: 10) {
							Image.sessionCardTimeSolidIcon
								.resizable()
								.scaledToFit()
								.frame(height: 18)
							
							if let timeStart = viewModel.dataBooking?.meeting?.startAt,
							   let timeEnd = viewModel.dataBooking?.meeting?.endAt {
                                Text("\(DateUtils.dateFormatter(timeStart, forFormat: .HHmm)) - \(DateUtils.dateFormatter(timeEnd, forFormat: .HHmm))")
									.font(.robotoRegular(size: 12))
									.foregroundColor(.black)
							} else {
                                Text(LocalizableText.unconfirmedText)
									.font(.robotoRegular(size: 12))
									.foregroundColor(.black)
							}
						}
						
						VStack(alignment: .leading, spacing: 20) {
							HStack(spacing: 10) {
								Image.sessionCardPersonSolidIcon
									.resizable()
									.scaledToFit()
									.frame(height: 18)
								
								if let data = viewModel.dataBooking {
                                    Text("\(String.init(participantCount))/\(String.init((data.meeting?.slots).orZero())) \(LocalizableText.participant)")
										.font(.robotoRegular(size: 12))
										.foregroundColor(.black)
									                            
                                    Text(((data.meeting?.slots).orZero() > 1) ? LocalizableText.groupSessionLabelWithEmoji : LocalizableText.privateSessionLabelWithEmoji)
                                    .font(.robotoBold(size: 10))
                                    .foregroundColor(.DinotisDefault.primary)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 5)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
                                    )
								}
							}
						}
						.valueChanged(value: viewModel.isLoadingDetail) { value in
							DispatchQueue.main.async {
								withAnimation(.spring()) {
									self.viewModel.isLoading = value
								}
							}
						}
            
                        Capsule()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                            .opacity(0.2)
                            .padding(.top)
                        
                        CollaboratorView(viewModel: viewModel)
						
						ParticipantView(viewModel: viewModel)
							.padding(.vertical, 8)
                        
                        if detail.meeting?.endedAt != nil {
                            HStack {
                                Spacer()
                                
                                Text(LocalizableText.stepSessionDone)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .foregroundColor(.DinotisDefault.secondary)
                            )
                        }
					}
					.padding()
					.background(Color.white)
					.cornerRadius(12)
					.shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 0)
					.padding(.top, 10)
					.padding(.horizontal)
          .padding(.bottom, 10)
          
          if !(viewModel.dataBooking?.meeting?.meetingUrls?.isEmpty).orFalse() {
            Button {
              viewModel.isShowAttachments = true
            } label: {
              HStack {
                Image.icDocumentSessionDetail
                  .resizable()
                  .scaledToFit()
                  .frame(height: 32)
                
                Text(LocalizableText.attachmentsText)
                  .font(.robotoMedium(size: 14))
                  .foregroundColor(.black)
                
                Spacer()
                
                Image.sessionDetailChevronIcon
                  .resizable()
                  .scaledToFit()
                  .frame(width: 24)
              }
              .padding()
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .foregroundColor(.white)
                  .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
              )
              .padding(.horizontal)
            }
            .padding(.bottom, 10)
          }
					
					Button(action: {
						if let waurl = URL(string: "https://wa.me/6281318506068") {
							if UIApplication.shared.canOpenURL(waurl) {
								UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
							}
						}
					}, label: {
						HStack {
							Image.talentProfileWhatsappIcon
								.resizable()
								.scaledToFit()
								.frame(height: 32)
							
							HStack(spacing: 5) {
                                Text(LocalizableText.needHelpQuestion)
									.font(.robotoRegular(size: 14))
									.foregroundColor(.black)
								
								Text(LocalizableText.contactUsLabel)
									.font(.robotoBold(size: 14))
									.foregroundColor(.black)
							}
							
							Spacer()
							
							Image.sessionDetailChevronIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24)
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 12)
								.foregroundColor(.white)
								.shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
						)
						.padding(.horizontal)
					})
					.padding(.bottom, 100)
				}
			}
		}
	}
	
	struct BottomView: View {
		
		@ObservedObject var viewModel: ScheduleDetailViewModel
		
		@Environment(\.presentationMode) var presentationMode
		
		var body: some View {
			VStack(spacing: 0) {
				Spacer()
				
				HStack {
                    if !(viewModel.dataBooking?.meeting?.meetingRequest?.isAccepted ?? false) && viewModel.dataBooking?.meeting?.meetingRequest != nil  {
                        DinotisPrimaryButton(
                            text: LocalizableText.startNowLabel,
                            type: .adaptiveScreen,
                            textColor: .DinotisDefault.lightPrimaryActive,
                            bgColor: .DinotisDefault.lightPrimary
                        ) {}
						
					} else {
						if viewModel.dataBooking?.meeting?.endedAt == nil {
                            DinotisPrimaryButton(
                                text: LocalizableText.startNowLabel,
                                type: .adaptiveScreen,
                                textColor: viewModel.disableStartButton() ? .DinotisDefault.lightPrimaryActive : .white,
                                bgColor: viewModel.disableStartButton() ? .DinotisDefault.lightPrimary : .DinotisDefault.primary
                            ) {
                                viewModel.startPresented.toggle()
                            }
                            .disabled(viewModel.disableStartButton())
                        } else {
                            DinotisPrimaryButton(
                                text: LocalizableText.giveReviewLabel,
                                type: .adaptiveScreen,
                                textColor: .white,
                                bgColor: .DinotisDefault.primary
                            ) {
                                
                            }
                        }
					}
				}
				.padding()
				.background(Color.white)
				
				Color.white
					.frame(height: 10)
				
			}
		}
	}
  
  struct CollaboratorView: View {
    @ObservedObject var viewModel: ScheduleDetailViewModel
    
    var body: some View {
      VStack {
        if !(viewModel.dataBooking?.meeting?.meetingCollaborations ?? []).isEmpty {
          VStack(alignment: .leading, spacing: 10) {
            Text(LocalizableText.collaboratorSpeakerTitle)
              .font(.robotoRegular(size: 12))
              .foregroundColor(.black)
            
            ForEach((viewModel.dataBooking?.meeting?.meetingCollaborations ?? []).prefix(3), id: \.id) { item in
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
                viewModel.routeToTalentProfile(username: item.username)
              }
            }
            
            if (viewModel.dataBooking?.meeting?.meetingCollaborations ?? []).count > 3 {
              Button {
                viewModel.isShowCollabList.toggle()
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
    }
  }
	
	struct ParticipantView: View {
		@ObservedObject var viewModel: ScheduleDetailViewModel
		
		var body: some View {
			VStack(alignment: .leading, spacing: 10) {
				
                Text(((viewModel.dataBooking?.meeting?.slots).orZero() > 1) ? LocalizableText.groupSessionParticipantTitle : LocalizableText.privateSessionParticipantTitle)
					.font(.robotoRegular(size: 12))
                    .foregroundColor(.black)
                
                ForEach(viewModel.participantDetail.reversed().prefix(4), id: \.id) { item in
                    VStack {
                        HStack {
                            DinotisImageLoader(
                                urlString: item.profilePhoto.orEmpty(),
                                width: 40,
                                height: 40
                            )
                            .clipShape(Circle())
                            
                            Text((item.name).orEmpty())
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            if let first = viewModel.user?.id, let user = item.id {
                                if user == first {
                                    Text(LocalizableText.meLabel)
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.DinotisDefault.primary)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal)
                                        .background(Color.DinotisDefault.lightPrimary)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
                                        )
                                }
                            }
                        }
                    }
                }
                
                if viewModel.participantDetail.reversed().count > 4 {
                    Text(LocalizableText.andMoreParticipant(viewModel.participantDetail.reversed().count-4))
                        .font(.robotoBold(size: 12))
                        .foregroundColor(.black)
                }
            }
        }
	}
  
  struct AttachmentBottomSheet: View {
    
    @ObservedObject var viewModel: ScheduleDetailViewModel
    
    var body: some View {
      VStack(spacing: 18) {
        HStack {
          Text(LocalizableText.attachmentsText)
            .font(.robotoBold(size: 14))
            .foregroundColor(.DinotisDefault.black1)
          
          Spacer()
          
          Button {
            viewModel.isShowAttachments = false
          } label: {
            Image(systemName: "xmark.circle.fill")
              .resizable()
              .scaledToFit()
              .frame(width: 20)
              .foregroundColor(Color(UIColor.systemGray4))
          }
        }
        
        ScrollView(showsIndicators: false) {
          VStack(spacing: 16) {
            if let data = viewModel.dataBooking?.meeting?.meetingUrls {
              ForEach(data, id: \.id) { item in
                Button {
                  viewModel.isShowAttachments = false
                  viewModel.attachmentURL = item.url.orEmpty()
                  
                  DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    viewModel.isShowWebView = true
                  }
                } label: {
                  HStack(spacing: 6) {
                    Image.icGlobeSessionDetail
                      .resizable()
                      .scaledToFit()
                      .frame(width: 24)
                    
                    Text(item.title.orEmpty())
                      .font(.robotoMedium(size: 12))
                      .foregroundColor(.DinotisDefault.primary)
                      .multilineTextAlignment(.leading)
                      .lineLimit(1)
                    
                    Spacer()
                    
                    Image.sessionDetailChevronIcon
                      .resizable()
                      .scaledToFit()
                      .frame(width: 32, height: 32)
                  }
                  .padding()
                  .background(
                    RoundedRectangle(cornerRadius: 8)
                      .foregroundColor(.DinotisDefault.lightPrimary)
                  )
                }
              }
            }
          }
        }
      }
      .padding([.top, .horizontal])
    }
  }
  
  struct EmptyURLView: View {
    
    @ObservedObject var viewModel: ScheduleDetailViewModel
    
    var body: some View {
      VStack {
        Spacer()
        
        Image.searchNotFoundImage
          .resizable()
          .scaledToFit()
          .frame(width: 315)
        
        Text(LocalizableText.emptyFileMessage)
          .font(.robotoBold(size: 20))
          .foregroundColor(.DinotisDefault.black1)
          .multilineTextAlignment(.center)
          .padding(12)
        
        Spacer()
        
        DinotisPrimaryButton(
          text: LocalizableText.okText,
          type: .adaptiveScreen,
          textColor: .white,
          bgColor: .DinotisDefault.primary) {
            viewModel.isShowWebView = false
          }
      }
      .padding()
    }
  }
}
