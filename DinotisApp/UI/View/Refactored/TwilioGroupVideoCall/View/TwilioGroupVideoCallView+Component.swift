//
//  TwilioLiveStreamView+Component.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import SwiftUI
import SwiftUINavigation
import Combine
import Introspect

extension TwilioGroupVideoCallView {
	
	struct VideoSettingView: View {
		@EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
		@ObservedObject var viewModel: TwilioLiveStreamViewModel
		@EnvironmentObject var streamVM: StreamViewModel
		@EnvironmentObject var chatManager: ChatManager
		@EnvironmentObject var streamManager: StreamManager
		
		var body: some View {
			VStack {
				HStack {
					VStack(alignment: .leading) {
						Text(LocaleText.lockMute)
							.font(.montserratRegular(size: 12))
							.foregroundColor(.white)
						
						Text(LocaleText.muteLockSubtitle)
							.font(.montserratRegular(size: 10))
							.foregroundColor(.white)
					}
					
					Spacer()
					
					Toggle(isOn: $viewModel.isLockAllParticipantAudio) {
						Text("")
					}
					.labelsHidden()
					.onChange(of: viewModel.isLockAllParticipantAudio) { newValue in
						viewModel.lockAllParticipantAudio(streamManager: streamManager)
					}
				}
			}
		}
	}
	
	struct MoreMenuItems: View {
		@EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
		@ObservedObject var viewModel: TwilioLiveStreamViewModel
		@EnvironmentObject var streamVM: StreamViewModel
		@EnvironmentObject var chatManager: ChatManager
		@EnvironmentObject var streamManager: StreamManager
        @EnvironmentObject var participantsViewModel: ParticipantsViewModel
		
		private var columns: [GridItem] {
			[GridItem](
				repeating: GridItem(.flexible(), spacing: 5),
				count: 4
			)
		}
		
		var body: some View {
			LazyVGrid(columns: columns, spacing: 5) {
				
				switch viewModel.state.twilioRole {
				case "host":
					Button {
						withAnimation(.spring()) {
							viewModel.isShowQuestionList.toggle()
							viewModel.showingMoreMenu = false
						}

					} label: {
						VStack {
							ZStack(alignment: .topTrailing) {
								ZStack {
									Circle()
										.stroke(Color.dinotisStrokeSecondary)
										.frame(width: 45, height: 45)
									
									Image(systemName: "bubble.left.and.bubble.right")
										.resizable()
										.scaledToFit()
										.frame(height: 20)
										.foregroundColor(.white)
								}
								
								if streamVM.hasNewQuestion {
									Circle()
										.foregroundColor(.red)
										.frame(width: 12, height: 12)
								}
							}
							
							Text(LocaleText.qna)
								.font(.montserratMedium(size: 12))
								.foregroundColor(.white)
								.multilineTextAlignment(.center)
						}
					}
					
					//FIXME: - Button mute all only
					Button {
						withAnimation(.spring()) {
							viewModel.muteOnlyAllParticipant(streamManager: streamManager)
						}
					} label: {
						VStack {
							ZStack {
								Circle()
									.stroke(Color.dinotisStrokeSecondary)
									.frame(width: 45, height: 45)
								
								Image(systemName: "shareplay.slash")
									.resizable()
									.scaledToFit()
									.frame(height: 20)
									.foregroundColor(.white)
							}
							
							Text(LocaleText.muteAllParticipantText)
								.font(.montserratMedium(size: 10))
								.foregroundColor(.white)
								.multilineTextAlignment(.center)
						}
					}
					
					//FIXME: - Button setting with mute all lock
					Button {
						withAnimation(.spring()) {
							viewModel.showingMoreMenu = false
							viewModel.showSetting.toggle()
						}
					} label: {
						VStack {
							ZStack {
								Circle()
									.stroke(Color.dinotisStrokeSecondary)
									.frame(width: 45, height: 45)
								
								Image(systemName: "gearshape")
									.resizable()
									.scaledToFit()
									.frame(height: 20)
									.foregroundColor(.white)
							}
							
							Text(LocaleText.settingText)
								.font(.montserratMedium(size: 12))
								.foregroundColor(.white)
								.multilineTextAlignment(.center)
						}
					}
                    
                    Button {
						withAnimation(.spring()) {
							viewModel.showingMoreMenu = false
							streamVM.alertIdentifier = .removeAllParticipant
						}
                    } label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .stroke(Color.dinotisStrokeSecondary)
                                    .frame(width: 45, height: 45)
                                
                                Image(systemName: "person.crop.circle.badge.minus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                    .foregroundColor(.white)
                            }
                            
                            Text(LocaleText.removeAllParticipants)
                                .font(.montserratMedium(size: 10))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .onChange(of: participantsViewModel.speakers.count) { _ in
                        if participantsViewModel.speakers.count + participantsViewModel.viewerCount >= 50 && participantsViewModel.speakers.count >= 2 {
							withAnimation(.spring()) {
								viewModel.isButtonActive = true
							}
                        } else if participantsViewModel.speakers.count + participantsViewModel.viewerCount < 50  {
							withAnimation(.spring()) {
								viewModel.isButtonActive = false
							}
                        }
                    }
                    .disabled(!viewModel.isButtonActive)
					
				case "speaker":
					Button {
						withAnimation(.spring()) {
							viewModel.isShowQuestionBox.toggle()
							viewModel.showingMoreMenu = false
						}
					} label: {
						VStack {
							ZStack {
								Circle()
									.stroke(Color.dinotisStrokeSecondary)
									.frame(width: 45, height: 45)
								
								Image(systemName: "bubble.left.and.bubble.right")
									.scaledToFit()
									.frame(height: 25)
									.foregroundColor(.white)
							}
							
							Text(LocaleText.qna)
								.font(.montserratMedium(size: 12))
								.foregroundColor(.white)
								.multilineTextAlignment(.center)
						}
					}
				case "viewer":
					Button {
						withAnimation(.spring()) {
							viewModel.isShowQuestionBox.toggle()
							viewModel.showingMoreMenu = false
						}
					} label: {
						VStack {
							ZStack {
								Circle()
									.stroke(Color.dinotisStrokeSecondary)
									.frame(width: 45, height: 45)
								
								Image(systemName: "bubble.left.and.bubble.right")
									.scaledToFit()
									.frame(height: 25)
									.foregroundColor(.white)
							}
							
							Text(LocaleText.groupCallQuestionBox)
								.font(.montserratMedium(size: 12))
								.foregroundColor(.white)
								.multilineTextAlignment(.center)
						}
					}
					
				default:
					EmptyView()
				}
				
				Button {
					withAnimation(.spring()) {
						viewModel.isShowingChat.toggle()
						viewModel.showingMoreMenu = false
					}
				} label: {
					
					VStack {
						ZStack(alignment: .topTrailing) {
							ZStack {
								Circle()
									.stroke(Color.dinotisStrokeSecondary)
									.frame(width: 45, height: 45)
								
								Image.Dinotis.liveChatGroupIcon
									.renderingMode(.template)
									.resizable()
									.scaledToFit()
									.frame(height: 25)
									.foregroundColor(.white)
							}
							
							if chatManager.hasUnreadMessage {
								Circle()
									.foregroundColor(.red)
									.frame(width: 12, height: 12)
							}
						}
						
						Text(LocaleText.liveScreenLiveChat)
							.font(.montserratMedium(size: 12))
							.foregroundColor(.white)
							.multilineTextAlignment(.center)
					}
				}
				
			}
		}
	}
	
	struct BottomToolbar: View {
		
		@ObservedObject var speakerSettingsManager: SpeakerSettingsManager
		@ObservedObject var viewModel: TwilioLiveStreamViewModel
		@EnvironmentObject var streamVM: StreamViewModel
		@EnvironmentObject var chatManager: ChatManager
		@EnvironmentObject var participantsViewModel: ParticipantsViewModel
		@EnvironmentObject var streamManager: StreamManager
		@EnvironmentObject var speakerGridVM: SpeakerGridViewModel
		
		let closeLive: (() -> Void)
		@Environment(\.presentationMode) var presentationMode
		
		var body: some View {
			HStack {
				Spacer()
				
				switch viewModel.state.twilioRole {
				case "host":
					Button {
						withAnimation(.spring()) {
							speakerSettingsManager.isMicOn.toggle()
						}
					} label: {
						(speakerSettingsManager.isMicOn ? Image.Dinotis.unmuteGroupCallIcon : Image.Dinotis.mutedGroupCallIcon)
							.resizable()
							.scaledToFit()
							.frame(height: 45)
					}
					.isHidden(!viewModel.isStarted, remove: !viewModel.isStarted)
					
					
					Button {
						withAnimation(.spring()) {
							speakerSettingsManager.isCameraOn.toggle()
						}
					} label: {
						(speakerSettingsManager.isCameraOn ? Image.Dinotis.oncamGroupCallIcon : Image.Dinotis.offcamGroupCallIcon)
							.resizable()
							.scaledToFit()
							.frame(height: 45)
					}
					.isHidden(!viewModel.isStarted, remove: !viewModel.isStarted)
					
					Button(action: {
						withAnimation(.spring()) {
							viewModel.isSwitched.toggle()
						}
					}) {
						
						ZStack {
							Circle()
								.stroke(Color.dinotisStrokeSecondary)
								.frame(width: 45, height: 45)
							
							Image(systemName: "arrow.triangle.2.circlepath.camera")
								.resizable()
								.scaledToFit()
								.frame(height: 18)
								.foregroundColor(.black)
						}
					}
					.isHidden(!viewModel.isStarted, remove: !viewModel.isStarted)
					
				case "speaker":
					Button {
						withAnimation(.spring()) {
							speakerSettingsManager.isMicOn.toggle()
						}
					} label: {
						(speakerSettingsManager.isMicOn ? Image.Dinotis.unmuteGroupCallIcon : Image.Dinotis.mutedGroupCallIcon)
							.resizable()
							.scaledToFit()
							.frame(height: 43)
					}
					.disabled(streamVM.isAudioLocked)
					.isHidden(!viewModel.isStarted, remove: !viewModel.isStarted)
					
					Button {
						withAnimation(.spring()) {
							speakerSettingsManager.isCameraOn.toggle()
						}
					} label: {
						(speakerSettingsManager.isCameraOn ? Image.Dinotis.oncamGroupCallIcon : Image.Dinotis.offcamGroupCallIcon)
							.resizable()
							.scaledToFit()
							.frame(height: 45)
					}
					.isHidden(!viewModel.isStarted, remove: !viewModel.isStarted)
					
					Button(action: {
						withAnimation(.spring()) {
							viewModel.isSwitched.toggle()
						}
					}) {
						
						ZStack {
							Circle()
								.stroke(Color.dinotisStrokeSecondary)
								.frame(width: 45, height: 45)
							
							Image(systemName: "arrow.triangle.2.circlepath.camera")
								.resizable()
								.scaledToFit()
								.frame(height: 18)
								.foregroundColor(.black)
						}
					}
					.isHidden(!viewModel.isStarted, remove: !viewModel.isStarted)
					
				case "viewer":
					Button {
						withAnimation(.spring()) {
							streamVM.isHandRaised.toggle()
						}
					} label: {
						(streamVM.isHandRaised ? Image.Dinotis.raiseGroupCallIcon : Image.Dinotis.unraisedGroupCallIcon)
							.resizable()
							.scaledToFit()
							.frame(height: 45)
					}
					.isHidden(!viewModel.isStarted, remove: !viewModel.isStarted)
					
					
				default:
					EmptyView()
				}
				
				Button {
					withAnimation(.spring()) {
						viewModel.isShowingParticipants.toggle()
						participantsViewModel.haveNewRaisedHand = false
					}
				} label: {
					ZStack(alignment: .topTrailing) {
						ZStack {
							Circle()
								.stroke(Color.dinotisStrokeSecondary)
								.frame(width: 45, height: 45)
							
							Image(systemName: "person.2")
								.resizable()
								.scaledToFit()
								.frame(height: 18)
								.foregroundColor(.black)
						}
						
						if participantsViewModel.haveNewRaisedHand && StateObservable.shared.twilioRole == "host" {
							Circle()
								.foregroundColor(.red)
								.frame(width: 12, height: 12)
						}
					}
				}
				.onChange(of: viewModel.isSwitched) { newValue in
					streamManager.roomManager.localParticipant.position = newValue ? .front : .back
				}
				
				Button {
					withAnimation(.spring()) {
						viewModel.showingMoreMenu.toggle()
					}
				} label: {
					ZStack(alignment: .topTrailing) {
						ZStack {
							Circle()
								.stroke(Color.dinotisStrokeSecondary)
								.frame(width: 45, height: 45)
							
							Image.Dinotis.participantGroupIcon
								.resizable()
								.scaledToFit()
								.frame(height: 25)
						}
						
						if (streamVM.hasNewQuestion || chatManager.hasUnreadMessage) && StateObservable.shared.twilioRole == "host" {
							Circle()
								.foregroundColor(.red)
								.frame(width: 12, height: 12)
						}
						
					}
				}
				.isHidden(!viewModel.isStarted, remove: !viewModel.isStarted)
				
				
				Button {
					withAnimation(.spring()) {
						speakerGridVM.isEnd = true
						viewModel.showingCloseAlert()
					}
				} label: {
					Image.Dinotis.closeGroupCallIcon
						.resizable()
						.scaledToFit()
						.frame(height: 45)
				}
				.alert(isPresented: $viewModel.isShowingCloseAlert) {
					switch viewModel.state.twilioRole {
					case "viewer", "speaker":
						return Alert(
							title: Text(LocaleText.attention),
							message: Text(LocaleText.sureEndCallSubtitle),
							primaryButton: .default(
								Text(LocaleText.okText),
								action: {
									if viewModel.isStarted {
										viewModel.deleteStream {
											closeLive()
										}
									} else {
										closeLive()
									}
								}
							),
							secondaryButton: .cancel(Text(LocaleText.cancelText), action: {
								speakerGridVM.isEnd = false
							})
						)
					default:
						return Alert(
							title: Text(LocaleText.attention),
							message: Text(LocaleText.sureEndCallSubtitle),
							primaryButton: .default(
								Text(LocaleText.okText),
								action: {
									viewModel.deleteStream {
										closeLive()
									}
								}
							),
							secondaryButton: .cancel(Text(LocaleText.cancelText), action: {
								speakerGridVM.isEnd = false
							})
						)
					}
				}
				
				Spacer()
			}
		}
	}
	
	struct ParticipantView: View {
		
		@EnvironmentObject var viewModel: ParticipantsViewModel
		@ObservedObject var twilioLiveVM: TwilioLiveStreamViewModel
		@EnvironmentObject var streamManager: StreamManager
		@Environment(\.presentationMode) var presentationMode
		
		var body: some View {
			NavigationView {
				List {
					Section(header: Text("Speakers (\(viewModel.speakers.count))").font(.montserratBold(size: 16)).foregroundColor(.secondaryViolet)) {
						ForEach(viewModel.speakers) { speaker in
							HStack {
								Text(speaker.displayName)
									.font(.montserratRegular(size: 14))
								Spacer()
							}
						}
					}
					Section(header: Text("Viewers (\(viewModel.viewerCount))").font(.montserratBold(size: 14)).foregroundColor(.secondaryViolet)) {
						ForEach(viewModel.viewersWithRaisedHand) { viewer in
							HStack {
								Text("\(viewer.identity) 👋")
									.font(.montserratRegular(size: 14))
									.alert(isPresented: $viewModel.showSpeakerInviteSent) {
										Alert(
											title: Text(LocaleText.invitationSent),
											message: Text("\(LocaleText.speakerInviteMessage1) \(viewer.identity) \(LocaleText.speakerInviteMessage2)"),
											dismissButton: .default(Text(LocaleText.gotIt))
										)
									}
								
								Spacer()
								
								if streamManager.stateObservable.twilioRole == "host" {
									Button(LocaleText.inviteToSpeak) {
										viewModel.sendSpeakerInvite(meetingId: twilioLiveVM.meeting.id, userIdentity: viewer.identity)
									}
									.font(.montserratMedium(size: 14))
									.alert(isPresented: $viewModel.showError) {
										
										Alert(
											title: Text(LocaleText.attention),
											message: Text(viewModel.error?.localizedDescription ?? ""),
											dismissButton: .default(Text(LocaleText.okText))
										)
									}
								}
							}
							.buttonStyle(PlainButtonStyle())
						}
						
						ForEach(viewModel.viewersWithoutRaisedHand) { viewer in
							HStack {
								Text(viewer.identity)
									.font(.montserratRegular(size: 14))
								Spacer()
							}
						}
					}
				}
				.listStyle(.plain)
				.animation(.default)
				.navigationTitle("\(LocaleText.generalParticipant) (\(viewModel.speakers.count + viewModel.viewerCount))")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .confirmationAction) {
						Button(LocaleText.okText) {
							presentationMode.wrappedValue.dismiss()
						}
					}
				}
			}
		}
	}
	
	struct QuestionList: View {
		
		@ObservedObject var viewModel: TwilioLiveStreamViewModel
		@EnvironmentObject var participantVM: ParticipantsViewModel
		@EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
		@EnvironmentObject var streamVM: StreamViewModel
		@Environment(\.presentationMode) var presentationMode
		
		var body: some View {
			NavigationView {
				VStack {
					
					Picker(selection: $viewModel.QnASegment) {
						Text("Unanswered").tag(0)
						
						Text("Answered").tag(1)
					} label: {
						Text("")
					}
					.labelsHidden()
					.pickerStyle(.segmented)
					.padding(.horizontal)

					DinotisList { view in
						view.separatorStyle = .none
					} content: {
						if let data = viewModel.questionData.filter({ item in
							viewModel.QnASegment == 0 ? !(item.isAnswered ?? false) : (item.isAnswered ?? false)
						}) {
							VStack {
								ForEach(data, id:\.id) { item in
									Button {
										viewModel.putQuestion(questionId: item.id.orZero(), item: item, streamVM: streamVM)
									} label: {
										VStack(alignment: .leading) {
											HStack {
												if item.isAnswered ?? false {
													Image(systemName: "checkmark.square")
														.foregroundColor(.primaryViolet)
												} else {
													Image(systemName: "square")
														.foregroundColor(.primaryViolet)
												}

												Text((item.user?.name).orEmpty())
													.font(.montserratBold(size: 14))
													.foregroundColor(.dinotisGray)

												Spacer()

												Text((item.createdAt?.toDate(format: .utcV2)?.toString(format: .HHmm)).orEmpty())
													.font(.montserratRegular(size: 12))
													.foregroundColor(.dinotisGray)
											}

											Divider()

											Text(item.question.orEmpty())
												.font(.montserratRegular(size: 14))
												.foregroundColor(.dinotisGray)
												.multilineTextAlignment(.leading)
										}
										.padding()
										.background(Color.secondaryViolet)
										.cornerRadius(12)
									}
									.disabled(viewModel.QnASegment == 1)
									.buttonStyle(.plain)
									.onAppear {
										print(item)
									}
								}
							}
						}
					}
					
				}
				.padding(.vertical)
				.onAppear {
					viewModel.getQuestion(meetingId: viewModel.meeting.id)
					
					streamVM.hasNewQuestion = false
				}
				.onDisappear(perform: {
					streamVM.hasNewQuestion = false
				})
				.navigationTitle("Q&A")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .confirmationAction) {
						Button("Back") {
							presentationMode.wrappedValue.dismiss()
						}
					}
				}
			}
		}
	}
	
	struct ChatView: View {
		@Environment(\.presentationMode) var presentationMode
		@EnvironmentObject var chatManager: ChatManager
		@State private var isFirstLoadComplete = false
		@ObservedObject var viewModel: TwilioLiveStreamViewModel
		
		var body: some View {
			NavigationView {
				VStack {
				ScrollViewReader { scrollView in
					VStack(spacing: 0) {
						ScrollView {
							LazyVStack {
								ForEach(chatManager.messages) { message in
									VStack(spacing: 9) {
										ChatHeaderView(
											author: message.author,
											isAuthorYou: message.author == viewModel.state.twilioUserIdentity,
											date: message.date
										)
										ChatBubbleView(
											messageBody: message.body,
											isAuthorYou: message.author == viewModel.state.twilioUserIdentity
										)
									}
									.padding(.horizontal)
									.padding(.vertical, 7)
									.id(message.id)
								}

							}

						}
						.onChange(of: chatManager.messages.count) { count in
							withAnimation {
								scrollView.scrollTo((chatManager.messages.last?.id).orEmpty(), anchor: .bottom)
							}
							
							chatManager.hasUnreadMessage = false
						}
						.onChange(of: isFirstLoadComplete) { newValue in
								scrollView.scrollTo((chatManager.messages.last?.id).orEmpty())
						}
						.onAppear {
							isFirstLoadComplete.toggle()
							UIScrollView.appearance().keyboardDismissMode = .interactive
							chatManager.hasUnreadMessage = false
							chatManager.getMessages()
						}
						.onDisappear {
							chatManager.messages = []
						}

						HStack {
							MultilineTextField(LocaleText.liveScreenChatboxPlaceholder, text: $viewModel.messageText)
								.padding(5)
								.overlay(
									RoundedRectangle(cornerRadius: 8)
										.stroke(UIApplication.shared.windows.first?.overrideUserInterfaceStyle == .dark ? Color.white : Color(.systemGray3), lineWidth: 1)
								)

							Button {
								chatManager.sendMessage(viewModel.messageText)
								viewModel.messageText = ""
							} label: {
								Image.Dinotis.sendMessageIcon
									.renderingMode(.template)
									.resizable()
									.scaledToFit()
									.foregroundColor(UIApplication.shared.windows.first?.overrideUserInterfaceStyle == .dark ? .white : .primaryViolet)
									.frame(height: 28)
							}

						}
						.padding()
					}

				}
				}
				.navigationTitle(LocaleText.liveScreenLiveChat)
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .confirmationAction) {
						Button(LocaleText.back) {
							presentationMode.wrappedValue.dismiss()
						}
					}
				}
			}
		}
	}
	
	struct ChatHeaderView: View {
		let author: String
		let isAuthorYou: Bool
		let date: Date
		
		var body: some View {
			HStack {
				if isAuthorYou {

					Text(date, style: .time)

					Spacer()

					Text("\(author)\(isAuthorYou ? " (\(LocaleText.you))" : "")")
						.lineLimit(1)

				} else {
				Text("\(author)\(isAuthorYou ? " (\(LocaleText.you))" : "")")
					.lineLimit(1)
				Spacer()
				Text(date, style: .time)
				}
			}
			.foregroundColor(.white)
			.font(.montserratRegular(size: 12))
		}
	}
	
	struct ChatBubbleView: View {
		let messageBody: String
		let isAuthorYou: Bool
		
		var body: some View {
			HStack {

				if isAuthorYou {
					Spacer()
				}

				Text(messageBody)
					.font(.montserratRegular(size: 14))
					.foregroundColor(.dinotisGray)
					.padding(10)
					.background(isAuthorYou ? Color.secondaryViolet : Color.dinotisStrokeSecondary)
					.cornerRadius(20)
					.multilineTextAlignment(isAuthorYou ? .trailing : .leading)

				if !isAuthorYou {
					Spacer()
				}
			}
		}
	}
	
	struct DetailMeetingView: View {
		var meeting: UserMeeting?
		@ObservedObject var viewModel: TwilioLiveStreamViewModel
		
		var body: some View {
			VStack(alignment: .leading) {
				Text((meeting?.title).orEmpty())
					.font(.montserratBold(size: 14))
					.foregroundColor(.black)
				
				Text((meeting?.meetingDescription).orEmpty())
					.font(.montserratRegular(size: 12))
					.foregroundColor(.black)
					.padding(.bottom, 10)
				
				HStack(spacing: 10) {
					Image.Dinotis.calendarIcon
						.resizable()
						.scaledToFit()
						.frame(height: 18)
					
					if let dateStart = meeting?.startAt?.toDate(format: .utcV2) {
						Text(dateStart.toString(format: .EEEEddMMMMyyyy))
							.font(.montserratRegular(size: 12))
							.foregroundColor(.black)
					}
				}
				
				HStack(spacing: 10) {
					Image.Dinotis.clockIcon
						.resizable()
						.scaledToFit()
						.frame(height: 18)
					
					if let timeStart = meeting?.startAt?.toDate(format: .utcV2),
						 let timeEnd = meeting?.endAt?.toDate(format: .utcV2) {
						Text("\(timeStart.toString(format: .HHmm)) - \(timeEnd.toString(format: .HHmm))")
							.font(Font.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)
					}
					
					Spacer()
				}
				
				VStack(alignment: .leading, spacing: 20) {
					HStack(spacing: 10) {
						Image.Dinotis.peopleCircleIcon
							.resizable()
							.scaledToFit()
							.frame(height: 18)
						
						Text(viewModel.totalParticipant(meeting: meeting))
							.font(.montserratRegular(size: 12))
							.foregroundColor(.black)
						
						Text(viewModel.contentLabel(meeting: meeting))
							.font(Font.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)
							.padding(.vertical, 5)
							.padding(.horizontal)
							.background(Color.secondaryViolet)
							.clipShape(Capsule())
							.overlay(
								Capsule()
									.stroke(Color.primaryViolet, lineWidth: 1.0)
							)
					}
				}
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 12)
					.foregroundColor(.white)
			)
			.padding(EdgeInsets(top: 25, leading: 30, bottom: 25, trailing: 30))
		}
	}
}
