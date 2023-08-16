//
//  PrivateVideoCallView.swift
//  DinotisApp
//
//  Created by Gus Adi on 2019/6/17.
//  Copyright © 2019 Dinotis. All rights reserved.
//

import DinotisData
import DinotisDesignSystem
import SwiftUI
import SwiftUINavigation
import Lottie

struct PrivateVideoCallView : View {

	@ObservedObject var stateObservable = StateObservable.shared
	
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	@Environment(\.presentationMode) var presentationMode
	
	@Binding var randomId: UInt
	@Binding var meetingId: String
	
	@ObservedObject var viewModel: PrivateVideoCallViewModel
	@EnvironmentObject var streamViewModel: PrivateStreamViewModel
	@EnvironmentObject var streamManager: PrivateStreamManager
	@EnvironmentObject var speakerSettingsManager: PrivateSpeakerSettingsManager
	@EnvironmentObject var speakerGridViewModel: PrivateVideoSpeakerViewModel
	
	var body: some View {
		ZStack {
			ZStack(alignment: .top) {
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
				
				Color.DinotisDefault.primary.edgesIgnoringSafeArea(.vertical)
					.onChange(of: viewModel.isSwitchCam) { newValue in
						streamManager.roomManager?.localParticipant.position = newValue ? .front : .back
					}
				
				ZStack {

					if viewModel.isSwitchCanvas {
						PrivateSpeakerVideoView(speaker: $speakerGridViewModel.localSpeaker, isMainView: true, isLocal: true)
							.rotationEffect(.degrees(0))
							.rotation3DEffect(.degrees(StateObservable.shared.cameraPositionUsed == .back ? 180 : 0), axis: (0, 1, 0))
					} else {
						if speakerGridViewModel.remoteSpeakers.identity.isEmpty {
							GeometryReader { geo in
								ZStack {
									Color.black.edgesIgnoringSafeArea([.bottom, .horizontal])

									ProgressHUDFlat(
                                        title: LocaleText.waitingOtherToJoin,
                                        geo: geo
                                    )
										.padding()
								}
							}
						} else {
							PrivateSpeakerVideoView(speaker: $speakerGridViewModel.remoteSpeakers, isMainView: true, isLocal: false)
						}
					}
				}
				.edgesIgnoringSafeArea(.bottom)

				VStack {
					HStack {
						GeometryReader { geo in
						ZStack {
							Group {
								if viewModel.isSwitchCanvas {
									PrivateSpeakerVideoView(speaker: $speakerGridViewModel.remoteSpeakers, isMainView: false, isLocal: false)
								} else {
									PrivateSpeakerVideoView(speaker: $speakerGridViewModel.localSpeaker, isMainView: false, isLocal: true)
										.rotationEffect(.degrees(0))
										.rotation3DEffect(.degrees(StateObservable.shared.cameraPositionUsed == .back ? 180 : 0), axis: (0, 1, 0))
								}
							}
								.onTapGesture {
									if !speakerGridViewModel.remoteSpeakers.identity.isEmpty {
										viewModel.isSwitchCanvas.toggle()
									}
								}
						}
						.frame(width: geo.size.width/3.5, height: geo.size.height/3.5)
						.cornerRadius(10)
						.shadow(color: speakerGridViewModel.remoteSpeakers.identity.isEmpty ? .gray.opacity(0.3) : .black.opacity(0.2), radius: 10, x: 0, y: 0)
						.draggable(by: $viewModel.dragOffset)

						}
					}
					.padding()
					
					HStack(spacing: 8) {
						
						Image(systemName: "clock")
							.resizable()
							.scaledToFit()
							.frame(height: 12)
						
						Text(viewModel.stringTime)
							.font(.robotoBold(size: 12))
					}
					.foregroundColor(viewModel.isNearbyEnd ? .white : .primaryRed)
					.padding(8)
					.background(
						RoundedRectangle(cornerRadius: 7)
							.foregroundColor(.black.opacity(0.2))
					)
					.overlay(
						RoundedRectangle(cornerRadius: 7)
							.stroke(Color.DinotisDefault.primary, lineWidth: 1)
					)
					
					Spacer()
					
					HStack(spacing: 10) {
						Button(action: switchCamera) {
							HStack {
								Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
									.resizable()
									.frame(width: 25, height: 20)
									.foregroundColor(.white)
							}
							.frame(width: 50, height: 50)
							.background(Color.white.opacity(0.2))
							.clipShape(Circle())
						}

						Button(action: toogleLocalCamera) {
							HStack {
								Image(systemName: self.speakerSettingsManager.isCameraOn ? "video.fill" : "video.slash.fill")
									.resizable()
									.frame(width: 25, height: self.speakerSettingsManager.isCameraOn ? 15 : 20)
									.foregroundColor(.white)
							}
							.frame(width: 50, height: 50)
							.background(self.speakerSettingsManager.isCameraOn ? Color.white.opacity(0.2) : .red)
							.clipShape(Circle())
						}

						Button(action: toggleLocalAudio) {
							HStack {
								Image(systemName: !speakerSettingsManager.isMicOn ? "mic.slash.fill" : "mic.fill")
									.resizable()
									.frame(width: !speakerSettingsManager.isMicOn ? 16 : 14, height: 23)
									.foregroundColor(.white)
							}
							.frame(width: 50, height: 50)
							.background(!speakerSettingsManager.isMicOn ? .red : Color.white.opacity(0.2))
							.clipShape(Circle())
						}

						if stateObservable.userType == 2 {
							Button(action: {
								withAnimation(.spring()) {
									viewModel.showingBottomSheet.toggle()
									viewModel.screenShotMethod()
								}
							}) {
								HStack {
									Image(systemName: "ellipsis")
										.resizable()
										.frame(width: 20, height: 5)
										.foregroundColor(.white)
								}
								.frame(width: 50, height: 50)
								.background(Color.white.opacity(0.2))
								.clipShape(Circle())
							}
						}
						
						if stateObservable.userType == 2 {
							Button(action: {
								viewModel.isShowEnd.toggle()
							}, label: {
								HStack {
									Image(systemName: "phone.down.fill")
										.resizable()
										.frame(width: 30, height: 10)
										.foregroundColor(.white)
								}
								.padding()
								.padding(.vertical, 5)
								.background(Color.red)
								.clipShape(Circle())
							})
						} else {
							Button(action: {
								viewModel.isShowEnd.toggle()
							}, label: {
								HStack {
									Image(systemName: "phone.down.fill")
										.resizable()
										.frame(width: 35, height: 15)
										.foregroundColor(.white)
								}
								.padding()
								.padding(.vertical, 4)
								.padding(.horizontal, 10)
								.background(Color.red)
								.clipShape(Capsule())
							})
						}
						
					}
					.padding()
				}

				HStack(spacing: 5) {
					Image(systemName: "lock.fill")
						.resizable()
						.scaledToFit()
						.frame(height: 10)
						.foregroundColor(.white)

					Text("End-to-End Encryption")
						.font(.robotoRegular(size: 10))
						.foregroundColor(.white)
				}
				.padding(8)
				.background(
					RoundedRectangle(cornerRadius: 10)
						.foregroundColor(.black.opacity(0.2))
				)
				.padding(.top, 8)
				
			}
			
			GeometryReader { proxy in
				ZStack {
					Color.black.opacity(viewModel.showingBottomSheet ? 0.6 : 0).edgesIgnoringSafeArea(.all)
						.onTapGesture {
							withAnimation(.spring()) {
								viewModel.showingBottomSheet = false
							}
						}
						.onChange(of: viewModel.isMeetingForceEnd) { val in
							if val {
								viewModel.endMeetingForce(streamManager: streamManager)
							}
						}
					
					VStack {
						Spacer()
						
						VStack(spacing: 15) {
							HStack {
								Spacer()
								
								Button {
									withAnimation(.spring()) {
										viewModel.showingBottomSheet = false
									}
								} label: {
									Image(systemName: "xmark.circle")
										.resizable()
										.scaledToFit()
										.frame(height: 15)
										.foregroundColor(.black.opacity(0.7))
										.font(.system(size: 15, weight: .bold, design: .rounded))
								}
							}
							
							Button {
								withAnimation(.spring()) {
									viewModel.showingRepostModal.toggle()
									viewModel.showingBottomSheet = false
								}
							} label: {
								HStack {
									Spacer()
									
									Text(LocaleText.reportText)
										.font(.robotoMedium(size: 12))
										.foregroundColor(.white)
									
									Spacer()
								}
								.padding(12)
								.background(
									RoundedRectangle(cornerRadius: 8)
										.foregroundColor(.DinotisDefault.primary)
								)
							}
							.padding(.bottom, 10)
							
						}
						.padding()
						.background(
							RoundedCorner(radius: 10, corners: [.topLeft, .topRight])
								.foregroundColor(.white)
								.edgesIgnoringSafeArea(.bottom)
						)
						.offset(y: viewModel.showingBottomSheet ? .zero : proxy.size.height + 100)
					}
				}
				
				ZStack {
					Color.black.opacity(viewModel.showingRepostModal ? 0.6 : 0).edgesIgnoringSafeArea(.all)
						.onTapGesture {
							withAnimation(.spring()) {
								viewModel.showingRepostModal = false
							}
						}
					
					VStack(alignment: .center, spacing: 12) {
						
						HStack {
							Spacer()
							
							Button {
								withAnimation(.spring()) {
									viewModel.showingBottomSheet = false
									viewModel.showingRepostModal = false
								}
							} label: {
								Image(systemName: "xmark.circle")
									.resizable()
									.scaledToFit()
									.frame(height: 15)
									.foregroundColor(.black.opacity(0.7))
									.font(.system(size: 15, weight: .bold, design: .rounded))
							}
						}
						
						Text(LocaleText.reportAudienceTitle)
							.font(.robotoBold(size: 12))
							.foregroundColor(.black)
							.onChange(of: viewModel.isShowNearEndAlert) { newValue in
								if newValue {
									viewModel.isShowedEnd = true
								}
							}
						
						VStack(spacing: 10) {
							ForEach(viewModel.reasonData, id: \.id) { item in
								Button {
									if viewModel.isSelected(items: item) {
										for items in viewModel.reason where item.id == items.id {
											if let itemToRemoveIndex = viewModel.reason.firstIndex(of: items) {
												viewModel.reason.remove(at: itemToRemoveIndex)
											}
										}
									} else {
										viewModel.reason.append(item)
									}
								} label: {
									HStack {
										if viewModel.isSelected(items: item) {
											Image.Dinotis.filledChecklistIcon
												.resizable()
												.scaledToFit()
												.frame(height: 20)
										} else {
											Image.Dinotis.emptyChecklistIcon
												.resizable()
												.scaledToFit()
												.frame(height: 20)
										}
										
										Text(item.name.orEmpty())
											.font(.robotoRegular(size: 10))
											.foregroundColor(.black)
										
										Spacer()
									}
								}
							}
							
							Button {
								viewModel.isOther.toggle()
							} label: {
								HStack {
									if viewModel.isOther {
										Image.Dinotis.filledChecklistIcon
											.resizable()
											.scaledToFit()
											.frame(height: 20)
									} else {
										Image.Dinotis.emptyChecklistIcon
											.resizable()
											.scaledToFit()
											.frame(height: 20)
									}
									
									Text(LocaleText.otherText)
										.font(.robotoRegular(size: 10))
										.foregroundColor(.black)
									
									Spacer()
								}
							}
							
							if viewModel.isOther {
								TextField(LocaleText.reportNotesPlaceholder, text: $viewModel.report)
									.font(.robotoRegular(size: 12))
									.foregroundColor(.black)
									.accentColor(.black)
									.disableAutocorrection(true)
									.autocapitalization(.none)
									.padding(10)
									.background(Color.white)
									.clipped()
									.overlay(
										RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray5), lineWidth: 1)
									)
									.shadow(color: Color.dinotisShadow.opacity(0.06), radius: 40, x: 0.0, y: 0.0)
							}
						}
						
						Button {
							withAnimation(.spring()) {
								viewModel.showingBottomSheet = false
								viewModel.showingRepostModal = false
								
                                Task {
                                    await viewModel.uploadSingleImage()
                                }
							}
						} label: {
							HStack {
								
								Text(LocaleText.sendText)
									.font(.robotoMedium(size: 12))
									.foregroundColor(.white)
									.padding(10)
									.padding(.horizontal, 20)
									.padding(.vertical, 5)
								
							}
							.background(Color.DinotisDefault.primary)
							.clipShape(RoundedRectangle(cornerRadius: 8))
						}
						
					}
					.padding()
					.background(
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(.white)
					)
					.padding()
					.opacity(viewModel.showingRepostModal ? 1 : 0)
				}
        
        DinotisLoadingView(.fullscreen, hide: streamManager.state != .connecting && !viewModel.isLoading)

				if viewModel.isSuccessSend || viewModel.isErrorSend {
					ZStack {
						HStack {
							Spacer()

							Text(viewModel.hudText())
							.font(.robotoBold(size: 10))
							.multilineTextAlignment(.center)
							.foregroundColor(.white)
							.padding()
							.background(
								Capsule()
									.foregroundColor(.DinotisDefault.primary)
							)

							Spacer()
						}
						.padding(.top)
					}.onAppear {
						DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
							withAnimation {
								viewModel.isSuccessSend = false
								viewModel.isErrorSend = false
							}
						}
					}
				}

				ZStack {
					Color.black.opacity(0.5)
						.edgesIgnoringSafeArea(.all)

					VStack(spacing: 20) {
						LottieView(name: "close-to-end", loopMode: .loop)
							.scaledToFit()
							.frame(height: proxy.size.width/2)

						VStack(spacing: 10) {
							Text(LocaleText.fiveMinuteEndTitle)
								.font(.robotoBold(size: 16))
								.multilineTextAlignment(.center)

							Text(LocaleText.fiveMinuteEndSubtitle)
								.font(.robotoRegular(size: 14))
								.multilineTextAlignment(.center)
						}

						Button {
							withAnimation {
								viewModel.isShowedEnd.toggle()
							}

						} label: {
							Text(LocaleText.okText)
								.font(.robotoMedium(size: 12))
								.foregroundColor(.white)
								.padding(.horizontal, 50)
								.padding(.vertical, 15)
								.background(
									RoundedRectangle(cornerRadius: 12)
										.foregroundColor(.DinotisDefault.primary)
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
							.opacity(viewModel.isShowedEnd ? 1 : 0)

			}
			
		}
    .onChange(of: streamViewModel.alertIdentifier, perform: { _ in
      streamViewModel.showAlertContent {
        presentationMode.wrappedValue.dismiss()
      } routeToAfterCall: {
        viewModel.routeToAfterCall()
      }
    })
    .dinotisAlert(
      isPresent: $streamViewModel.isShowAlert,
      title: streamViewModel.alert.title,
      isError: streamViewModel.alert.isError,
      message: streamViewModel.alert.message,
      primaryButton: streamViewModel.alert.primaryButton,
      secondaryButton: streamViewModel.alert.secondaryButton
    )
    .dinotisAlert(
      isPresent: $viewModel.isShowEnd,
      title: LocaleText.attention,
      isError: false,
      message: LocaleText.sureEndCallSubtitle,
      primaryButton: .init(
        text: LocaleText.yesDeleteText,
        action: {
          self.viewModel.deleteStream {
            self.streamManager.disconnect()
            self.viewModel.routeToAfterCall()
          }
        }
      ),
      secondaryButton: .init(
        text: LocalizableText.cancelLabel,
        action: {}
      )
    )
		.onAppear {
            Task {
                viewModel.futureDate = viewModel.meeting.endAt.orCurrentDate()
                self.viewModel.getRealTime()
                await self.viewModel.getUsers()
                
                await self.viewModel.getReason()
                self.streamManager.connect(meetingId: viewModel.meeting.id.orEmpty())
                
                UIApplication.shared.isIdleTimerDisabled = true
            }
		}
		.onDisappear(perform: {
			UIApplication.shared.isIdleTimerDisabled = false
		})
		
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct PrivateVideoCallView_Previews : PreviewProvider {
	static var previews: some View {
		PrivateVideoCallView(
			randomId: .constant(0),
			meetingId: .constant(""),
			viewModel: PrivateVideoCallViewModel(
				meeting: UserMeetingData(
					id: "",
					title: "",
					meetingDescription: "",
					price: "",
					startAt: nil,
					endAt: nil,
					isPrivate: false,
					isLiveStreaming: false,
					slots: 0,
					participants: 0,
					userID: "",
					startedAt: Date(),
					endedAt: nil,
					createdAt: nil,
					updatedAt: nil,
					deletedAt: nil,
					bookings: nil,
					user: nil,
					participantDetails: nil,
					meetingBundleId: nil,
					meetingRequestId: nil,
					status: nil,
					meetingRequest: nil,
					expiredAt: nil,
					background: nil,
                    meetingCollaborations: nil,
                    meetingUrls: nil,
                    meetingUploads: nil,
                    roomSid: nil,
                    dyteMeetingId: nil,
                    isInspected: nil,
                    reviews: []
				),
				backToHome: {}
			)
		)
	}
}
