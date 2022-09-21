//
//  TwilioLiveStreamView.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import SwiftUI
import SwiftUINavigation

struct TwilioGroupVideoCallView: View {
	
	@ObservedObject var viewModel: TwilioLiveStreamViewModel
	@EnvironmentObject var streamViewModel: StreamViewModel
	@EnvironmentObject var streamManager: StreamManager
	@EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
	@EnvironmentObject var chatManager: ChatManager
	@EnvironmentObject var participantsViewModel: ParticipantsViewModel
	@EnvironmentObject var speakerGridViewModel: SpeakerGridViewModel
	@EnvironmentObject var presentationLayoutViewModel: PresentationLayoutViewModel
	@EnvironmentObject var hostControlsManager: HostControlsManager
	
	@Binding var meetingId: String
	
	var speaker: SpeakerVideoViewModel
	
	@Environment(\.presentationMode) var presentationMode
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass
	
	private let spacing: CGFloat = 18
	
	private var isPortraitOrientation: Bool {
		verticalSizeClass == .regular && horizontalSizeClass == .compact
	}
	
	var body: some View {
		GeometryReader { geo in
			ZStack {
				NavigationLink(
					unwrapping: $viewModel.route,
					case: /HomeRouting.afterCall,
					destination: { viewModel in
						AfterCallView(viewModel: viewModel.wrappedValue)
					},
					onNavigate: {_ in},
					label: {
						EmptyView()
					}
				)
				
				Image.Dinotis.twilioBackground
					.resizable()
					.ignoresSafeArea()
					.alert(item: $streamViewModel.alertIdentifier) { alertIdentifier in
						switch alertIdentifier {
						case .error:
							return Alert(error: streamViewModel.error) {
								presentationMode.wrappedValue.dismiss()
							}
						case .receivedSpeakerInvite:
							return Alert(
								title: Text(LocaleText.receivedSpeakerInviteTitle),
								message: Text(LocaleText.receivedSpeakerInviteMessage),
								primaryButton: .default(Text(LocaleText.joinNow)) {
									streamManager.changeRole(to: "speaker", meetingId: viewModel.meeting.id)
									streamViewModel.isHandRaised = false
								},
								secondaryButton: .destructive(Text(LocaleText.neverMind)) {
									streamViewModel.isHandRaised = false
								}
							)
						case .speakerMovedToViewersByHost:
							return Alert(
								title: Text(LocaleText.speakerMovedToViewersByHostTitle),
								message: Text(LocaleText.speakerMovedToViewersByHostMessage),
								dismissButton: .default(Text(LocaleText.okText))
							)
						case .streamEndedByHost:
							return Alert(
								title: Text(LocaleText.streamEndedByHostTitle),
								message: Text(LocaleText.streamEndedByHostMessage),
								dismissButton: .default(Text(LocaleText.okText)) {
									presentationMode.wrappedValue.dismiss()
								}
							)
						case .streamWillEndIfHostLeaves:
							return Alert(
								title: Text(LocaleText.streamWillEndIfHostLeavesTitle),
								message: Text(LocaleText.streamWillEndIfHostLeavesMessage),
								primaryButton: .destructive(Text(LocaleText.endEvent)) {
									viewModel.routeToAfterCall()
								},
								secondaryButton: .cancel(Text(LocaleText.neverMind))
							)
						case .viewerConnected:
							return Alert(
								title: Text(LocaleText.welcome),
								message: Text(LocaleText.viewerConnectedMessage),
								dismissButton: .default(Text(LocaleText.gotIt))
							)
						case .mutedByHost:
							return Alert(
								title: Text(streamViewModel.isAudioLocked ? LocaleText.mutedLockByHostTitle : LocaleText.mutedByHostTitle),
								message: Text(streamViewModel.isAudioLocked ? LocaleText.mutedLockByHostMessage : LocaleText.mutedByHostMessage),
								dismissButton: .default(Text(LocaleText.okText))
							)
						case .unlockedMuteByHost:
							return Alert(
								title: Text(LocaleText.unlockedMuteByHostTitle),
								message: Text(LocaleText.unlockedMuteByHostMessage),
								dismissButton: .default(Text(LocaleText.okText))
							)
						case .removeAllParticipant:
							return Alert(
								title: Text(LocaleText.moveAllSpeakerTitle),
								message: Text(LocaleText.moveAllSpeakerMessage),
								primaryButton: .default(Text(LocaleText.okText)) {
									hostControlsManager.moveAllToViewer(on: viewModel.meeting.id)
								},
								secondaryButton: .cancel(Text(LocaleText.cancelText))
							)
						}
					}
				
				VStack {
					HStack {
						Button {
							withAnimation {
								viewModel.isShowingAbout.toggle()
							}
						} label: {
							HStack {
								Image(systemName: "info.circle")
									.resizable()
									.scaledToFit()
									.frame(height: 20)

								Text(LocaleText.groupCallDetailInfo)
									.font(.montserratRegular(size: 12))
									.foregroundColor(.white)
							}
							.foregroundColor(.white)
						}

						Spacer()

						HStack(spacing: viewModel.isStarted ? 8 : 2) {
							if viewModel.isStarted {
								Image(systemName: "clock")
									.resizable()
									.scaledToFit()
									.frame(height: 12)
							} else {
								Text(LocaleText.startInText)
									.font(.montserratRegular(size: 10))
									.foregroundColor(.white)
							}

							Text(viewModel.stringTime)
								.font(.montserratBold(size: 10))
						}
						.foregroundColor(viewModel.isNearbyEnd ? .white : .primaryRed)
						.padding(8)
						.overlay(
							RoundedRectangle(cornerRadius: 7)
								.stroke(viewModel.isNearbyEnd ? Color.white : Color.primaryRed, lineWidth: 1)
						)
					}
					.padding(.horizontal)
					.padding(.top, 10)
					.onChange(of: viewModel.isMeetingForceEnd) { val in
						if val {
							viewModel.deleteStream {
								streamManager.disconnect()
								viewModel.routeToAfterCall()
							}
						}
					}
					
					VStack {
						
						HStack(spacing: 0) {
							if viewModel.isStarted {
								switch viewModel.state.twilioRole {
								case "host", "speaker":
										SpeakerGridView(
											speaker: speaker,
											spacing: spacing,
											role: viewModel.state.twilioRole
										)
								case "viewer":
									SwiftUIPlayerView(player: $streamManager.player)
								default:
									VStack {
										Spacer()
									}
								}
							} else {
								VStack {
									Spacer()
									
									VStack(spacing: 10) {
										LottieView(name: "waiting-talent", loopMode: .loop)
											.scaledToFit()
											.frame(width: geo.size.width/4)
										
										Text(LocaleText.liveScreenWaitingTitle)
											.font(.montserratBold(size: 12))
										
										Text(LocaleText.liveScreenWaitingSubtitle)
											.font(.montserratRegular(size: 10))
											.multilineTextAlignment(.center)
									}
									
									Spacer()
								}
							}
						}
						
					}
					.onChange(of: viewModel.isShowNearEndAlert, perform: { newValue in
						if newValue {
							viewModel.isShowed = true
						}
					})
					
					BottomToolbar(
						speakerSettingsManager: speakerSettingsManager,
						viewModel: viewModel,
						closeLive: {
							if viewModel.isStarted {
								DispatchQueue.main.async {
									streamManager.disconnect()
									viewModel.routeToAfterCall()
								}
							} else {
								viewModel.routeToAfterCall()
							}
						}
					)
					.padding()
					.padding(.bottom, isPortraitOrientation ? 18 : 0)
					.background(Color.white)
					.onChange(of: viewModel.isStarted, perform: { val in
						if val {
							streamManager.connect(meetingId: viewModel.meeting.id)
						}
					})
					.edgesIgnoringSafeArea(.horizontal)
				}

				Color.black.opacity(0.5)
					.edgesIgnoringSafeArea(.all)
					.onTapGesture {
						withAnimation {
							if  viewModel.isShowingAbout {
								viewModel.isShowingAbout.toggle()
							}
						}
					}
					.opacity(viewModel.isShowingAbout || viewModel.isShowed ? 1 : 0)
				
				ZStack {
					DetailMeetingView(meeting: viewModel.meeting, viewModel: viewModel)
				}
				.onTapGesture {
					withAnimation {
						viewModel.isShowingAbout.toggle()
					}
				}
				.opacity(viewModel.isShowingAbout ? 1 : 0)
				
				ZStack {
					VStack(spacing: 20) {
						LottieView(name: "close-to-end", loopMode: .loop)
							.scaledToFit()
							.frame(height: geo.size.width/2)
						
						VStack(spacing: 10) {
							Text(LocaleText.fiveMinuteEndTitle)
								.font(.montserratBold(size: 16))
								.foregroundColor(.black)
								.multilineTextAlignment(.center)
							
							Text(StateObservable.shared.twilioRole == "viewer" || StateObservable.shared.twilioRole == "speaker" ? LocaleText.fiveMinEndViewerMessage : LocaleText.fiveMinuteEndSubtitle)
								.font(.montserratRegular(size: 14))
								.foregroundColor(.black)
								.multilineTextAlignment(.center)
						}
						
						Button {
							withAnimation {
								viewModel.isShowed.toggle()
							}
							
						} label: {
							Text(LocaleText.okText)
								.font(.montserratSemiBold(size: 12))
								.foregroundColor(.white)
								.padding(.horizontal, 50)
								.padding(.vertical, 15)
								.background(
									RoundedRectangle(cornerRadius: 12)
										.foregroundColor(.primaryViolet)
								)
						}
						.padding(.top, 10)
						
					}
					.padding()
					.background(
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor(.white)
					)
					.padding()
				}
				.frame(height: geo.size.height)
				.opacity(viewModel.isShowed ? 1 : 0)
				
				VStack {
					Text(LocaleText.allParticipantIsMuted)
						.foregroundColor(.white)
						.font(.montserratSemiBold(size: 12))
						.padding()
						.background(
							Capsule()
								.foregroundColor(.primaryViolet)
						)
						.onChange(of: viewModel.isMuteOnlyUser) { newValue in
							if newValue {
								DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
									withAnimation {
										viewModel.isMuteOnlyUser = false
									}
								}
							}
							
						}
					
					Spacer()
				}
				.padding()
				.opacity(viewModel.isMuteOnlyUser ? 1 : 0)
			}
			.edgesIgnoringSafeArea(.bottom)
			.dinotisSheet(isPresented: $viewModel.isShowQuestionBox, fraction: 0.6, content: {
				LazyVStack(spacing: 15) {
					LazyVStack(spacing: 10) {
						Text(LocaleText.groupCallQuestionBox)
							.font(.montserratBold(size: 14))
							.foregroundColor(.white)

						Text(LocaleText.groupCallQuestionSub)
							.font(.montserratRegular(size: 12))
							.foregroundColor(.white)
							.multilineTextAlignment(.center)
					}

					TextEditor(text: $viewModel.questionText)
						.background(Color.white)
						.font(.montserratRegular(size: 12))
						.frame(height: geo.size.width > geo.size.height ? geo.size.height/2 : geo.size.height/4)
						.overlay(
							RoundedRectangle(cornerRadius: 8)
								.stroke((UIApplication.shared.windows.first?.overrideUserInterfaceStyle ?? .dark) == .dark ? Color.white : Color(.systemGray3), lineWidth: 1)
						)
						.background(Color.white)
						.clipShape(RoundedRectangle(cornerRadius: 8))

					Button {
						viewModel.postQuestion(meetingId: viewModel.meeting.id)

					} label: {
						HStack {
							Spacer()

							if viewModel.isLoadingQuestion {
								ProgressView()
									.progressViewStyle(.circular)
									.accentColor(.white)
							} else {
								Text(LocaleText.sendText)
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(.white)
							}

							Spacer()
						}
						.padding(15)
						.background(
							RoundedRectangle(cornerRadius: 10)
								.foregroundColor(.primaryViolet)
						)
					}

				}
			})
			
			
			if streamManager.state == .connecting {
				ProgressHUD(title: LocaleText.joiningLoadingEvent, geo: geo)
			} else if streamManager.state == .changingRole || streamManager.isLoading || viewModel.isLoading {
				ProgressHUD(title: LocaleText.loadingText, geo: geo)
			} else if hostControlsManager.loadingState == .removingAllParticipant && hostControlsManager.isLoading {
				ProgressHUD(title: LocaleText.moveAllParticipantsLoading, geo: geo)
			}
		}
		.dinotisSheet(isPresented: $viewModel.showingMoreMenu, fraction: viewModel.state.twilioRole == "host" ? 0.35 : 0.25, content: {
			MoreMenuItems(viewModel: viewModel)
		})
		.dinotisSheet(isPresented: $viewModel.showSetting, fraction: 0.25, content: {
			VideoSettingView(viewModel: viewModel)
		})
		.sheet(isPresented: $viewModel.isShowingParticipants) {
			ParticipantView(twilioLiveVM: viewModel)
		}
		.sheet(isPresented: $viewModel.isShowingChat) {
			ChatView(viewModel: viewModel)
				.onAppear {
					chatManager.hasUnreadMessage = false
				}
		}
		.sheet(isPresented: $viewModel.isShowQuestionList, content: {
			QuestionList(viewModel: viewModel)
				.edgesIgnoringSafeArea(.bottom)
		})
		.onAppear(perform: {
			viewModel.getUsers()
			viewModel.getRealTime()

			UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(named: "btn-stroke-1")
			UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray

			AppDelegate.orientationLock = .all
			UIApplication.shared.isIdleTimerDisabled = true
			UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
		})
		.onChange(of: streamViewModel.hasNewQuestion, perform: { newValue in
			if newValue {
				viewModel.getQuestion(meetingId: viewModel.meeting.id)
			}
		})
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
		.onDisappear {
			UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
			AppDelegate.orientationLock = .portrait
			UIApplication.shared.isIdleTimerDisabled = false
		}
	}
}

struct TwilioGroupVideoCallView_Previews: PreviewProvider {
	static var previews: some View {
		TwilioGroupVideoCallView(
			viewModel: TwilioLiveStreamViewModel(
				backToRoot: {},
				backToHome: {},
				meeting: UserMeeting(id: "")
			),
			meetingId: .constant(""), speaker: SpeakerVideoViewModel()
		)
	}
}

extension Alert {
	init(error: Error?, action: (() -> Void)? = nil) {
		self.init(
			title: Text(LocaleText.errorText),
			message: Text((error?.localizedDescription.debugDescription).orEmpty()),
			dismissButton: .default(Text("OK")) {
				action?()
			}
		)
	}
}
