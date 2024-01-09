//
//  PrivateVideoCallView.swift
//  DinotisApp
//
//  Created by Gus Adi on 2019/6/17.
//  Copyright © 2019 Dinotis. All rights reserved.
//

import DinotisData
import DinotisDesignSystem
import DyteiOSCore
import SwiftUI
import SwiftUINavigation
import Lottie

struct PrivateVideoCallView : View {

	@ObservedObject var stateObservable = StateObservable.shared
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isPotrait: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
	
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	@Environment(\.dismiss) var dismiss
	
	@ObservedObject var viewModel: PrivateVideoCallViewModel
	
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
                .onChange(of: isPotrait) { newValue in
                    if newValue {
                        viewModel.dragOffset = CGPoint(x: 0, y: 0)
                    }
                }
                
                GeometryReader { geo in
                    Image.videoCallBackgroundPattern
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                }
                .ignoresSafeArea()
                
				ZStack {

					if viewModel.isSwitchCanvas {
                        LocalFullVideoContainerView(viewModel: viewModel, isMainScreen: true)
					} else {
                        if viewModel.participants.filter({ $0.userId != viewModel.dyteMeeting.localUser.userId }).isEmpty && viewModel.screenShareUser.isEmpty {
                            ZStack {
                                ProgressHUDFlat(
                                    title: LocaleText.waitingOtherToJoin
                                )
                                .padding()
                            }
                        } else {
                            if viewModel.screenShareId != nil {
                                if let video = viewModel.screenShareId?.getScreenShareVideoView() {
                                    UIVideoView(videoView: video, width: .infinity, height: .infinity)
                                        .background(
                                            Color.black
                                        )
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            } else {
                                RemoteFullVideoContainerView(viewModel: viewModel, isMainScreen: true)
                            }
                        }
                    }
                }
				.edgesIgnoringSafeArea(.all)
                .isHidden(!viewModel.isJoined, remove: !viewModel.isJoined)

				VStack {
					HStack {
						GeometryReader { geo in
						ZStack {
                            Group {
                                if viewModel.isSwitchCanvas {
                                    RemoteFullVideoContainerView(viewModel: viewModel, isMainScreen: false)
                                } else {
                                    LocalFullVideoContainerView(viewModel: viewModel, isMainScreen: false)
                                }
                            }
                            .onTapGesture {
                                if !viewModel.participants.filter({ $0.userId != viewModel.dyteMeeting.localUser.userId }).isEmpty && viewModel.screenShareUser.isEmpty {
                                    viewModel.isSwitchCanvas.toggle()
                                }
                            }
                        }
                        .frame(
                            width: isPotrait ? (viewModel.isShowUtilities ? geo.size.width/3.5 : geo.size.width/4) : (viewModel.isShowUtilities ? geo.size.width/5.5 : geo.size.width/6.5),
                            height: isPotrait ? (viewModel.isShowUtilities ? geo.size.height/3.5 : geo.size.height/5) : (viewModel.isShowUtilities ? geo.size.width/4.5 : geo.size.width/5.5))
						.cornerRadius(10)
                        .shadow(
                            color: viewModel.participants.filter({ $0.userId != viewModel.dyteMeeting.localUser.userId }).isEmpty ?
                                .gray.opacity(!viewModel.screenShareUser.isEmpty ? 0 : 0.3) :
                                    .black.opacity(!viewModel.screenShareUser.isEmpty ? 0 : 0.2),
                            radius: 10, 
                            x: 0,
                            y: 0
                        )
						.draggable(by: $viewModel.dragOffset)

						}
					}
					.padding()
                    .isHidden(!viewModel.isJoined, remove: !viewModel.isJoined)
					
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
							.foregroundColor(.black.opacity(0.8))
					)
					.overlay(
						RoundedRectangle(cornerRadius: 7)
							.stroke(Color.DinotisDefault.primary, lineWidth: 1)
					)
                    .isHidden(!viewModel.isJoined, remove: !viewModel.isJoined)
					
					Spacer()
					
					HStack(spacing: 10) {
                        if viewModel.isJoined {
                            Button(action: viewModel.switchCamera) {
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
                            
                            Button(action: viewModel.toggleCamera) {
                                HStack {
                                    Image(systemName: self.viewModel.isCameraOn ? "video.fill" : "video.slash.fill")
                                        .resizable()
                                        .frame(width: 25, height: self.viewModel.isCameraOn ? 15 : 20)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 50, height: 50)
                                .background(self.viewModel.isCameraOn ? Color.white.opacity(0.2) : .red)
                                .clipShape(Circle())
                            }
                            
                            Button(action: viewModel.toggleMicrophone) {
                                HStack {
                                    Image(systemName: !viewModel.isAudioOn ? "mic.slash.fill" : "mic.fill")
                                        .resizable()
                                        .frame(width: !viewModel.isAudioOn ? 16 : 14, height: 23)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 50, height: 50)
                                .background(!viewModel.isAudioOn ? .red : Color.white.opacity(0.2))
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
					}
					.padding()
                    .isHidden(!viewModel.isShowUtilities, remove: !viewModel.isShowUtilities)
				}

				HStack(spacing: 5) {
					Image(systemName: "lock.fill")
						.resizable()
						.scaledToFit()
						.frame(height: 10)
						.foregroundColor(.white)

					Text("End-to-End Encrypted")
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
            .onTapGesture {
                withAnimation(.spring()) {
                    viewModel.isShowUtilities = !viewModel.isShowUtilities
                }
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
								viewModel.endMeetingForce()
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
        
                DinotisLoadingView(.fullscreen, hide: !viewModel.isConnecting && !viewModel.isLoading)

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
						LottieView(name: "session-close-to-end", loopMode: .loop)
							.scaledToFit()
							.frame(height: 250)

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
        .dinotisAlert(
            isPresent: $viewModel.isShowAlert,
            type: .videoCall,
            title: viewModel.alert.title,
            isError: false,
            message: viewModel.alert.message,
            primaryButton: viewModel.alert.primaryButton,
            secondaryButton: viewModel.alert.secondaryButton
        )
        .dinotisAlert(
            isPresent: $viewModel.isMeetingForceEnd,
            type: .videoCall,
            title: LocalizableText.attentionText,
            isError: false,
            message: LocalizableText.videoCallMeetingForceEnd,
            primaryButton: .init(text: LocalizableText.okText, action: {
                if viewModel.isJoined {
                    viewModel.leaveMeeting()
                } else {
                    viewModel.routeToAfterCall()
                }
            })
        )
        .dinotisAlert(
            isPresent: $viewModel.isDuplicate,
            type: .videoCall,
            title: LocalizableText.attentionText,
            isError: true,
            message: LocalizableText.groupVideoCallDuplicateAlert,
            primaryButton: .init(text: LocalizableText.groupVideoCallDisconnectNow, action: {
                viewModel.leaveMeeting()
            })
        )
        .dinotisAlert(
            isPresent: $viewModel.isShowEnd,
            type: .videoCall,
            title: LocaleText.attention,
            isError: false,
            message: LocaleText.sureEndCallSubtitle,
            primaryButton: .init(
                text: LocaleText.yesDeleteText,
                action: {
                    if viewModel.isJoined {
                        viewModel.leaveMeeting()
                    } else {
                        viewModel.routeToAfterCall()
                    }
                }
            ),
            secondaryButton: .init(
                text: LocalizableText.cancelLabel,
                action: {}
            )
        )
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear(perform: {
			UIApplication.shared.isIdleTimerDisabled = false
            AppDelegate.orientationLock = .portrait
		})
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

extension PrivateVideoCallView {
    struct LocalFullVideoContainerView: View {
        
        @ObservedObject var viewModel: PrivateVideoCallViewModel
        let isMainScreen: Bool
        
        var body: some View {
            ZStack(alignment: .topTrailing) {
                if viewModel.dyteMeeting.localUser.videoEnabled {
                    if let video = viewModel.dyteMeeting.localUser.getVideoView() {
                        UIVideoView(videoView: video, width: .infinity, height: .infinity)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .rotationEffect(.degrees(0))
                            .rotation3DEffect(.degrees(viewModel.position == .rear ? 180 : 0), axis: (0, 1, 0))
                    }
                    
                } else {
                    if viewModel.dyteMeeting.localUser.picture == nil {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                            .overlay(
                                Text(viewModel.createInitial(viewModel.dyteMeeting.localUser.name))
                                    .font(.robotoRegular(size: 20))
                                    .foregroundColor(.white)
                                    .background(
                                        Circle()
                                            .frame(width: isMainScreen ? 120 : 60, height: isMainScreen ? 120 : 60)
                                            .foregroundColor(.DinotisDefault.primary)
                                    )
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                            .overlay(
                                ImageLoader(url: viewModel.dyteMeeting.localUser.picture.orEmpty(), width: isMainScreen ? 120 : 60, height: isMainScreen ? 120 : 60)
                                    .frame(width: isMainScreen ? 120 : 60, height: isMainScreen ? 120 : 60)
                                    .clipShape(Circle())
                            )
                    }
                }
                
                if !viewModel.dyteMeeting.localUser.audioEnabled {
                    HStack(spacing: 0) {
                        Image.videoCallMicOffStrokeIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12)
                    }
                    .padding(5)
                    .background(
                        Capsule()
                            .foregroundColor(.gray.opacity(0.5))
                    )
                    .padding(10)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    struct RemoteFullVideoContainerView: View {
        
        @ObservedObject var viewModel: PrivateVideoCallViewModel
        let isMainScreen: Bool
        
        var body: some View {
            ZStack(alignment: .topTrailing) {
                if (viewModel.participants.filter({ $0.userId != viewModel.dyteMeeting.localUser.userId }).first?.videoEnabled).orFalse() {
                    if let video = viewModel.participants.filter({ $0.userId != viewModel.dyteMeeting.localUser.userId }).first?.getVideoView() {
                        UIVideoView(videoView: video, width: .infinity, height: .infinity)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                } else {
                    if viewModel.participants.filter({ $0.userId != viewModel.dyteMeeting.localUser.userId }).first?.picture == nil {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                            .overlay(
                                Text(viewModel.createInitial((viewModel.participants.filter({ $0.userId != viewModel.dyteMeeting.localUser.userId }).first?.name).orEmpty()))
                                    .font(.robotoRegular(size: 20))
                                    .foregroundColor(.white)
                                    .background(
                                        Circle()
                                            .frame(width: isMainScreen ? 120 : 60, height: isMainScreen ? 120 : 60)
                                            .foregroundColor(.DinotisDefault.primary)
                                    )
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                            .overlay(
                                ImageLoader(url: (viewModel.participants.filter({ $0.userId != viewModel.dyteMeeting.localUser.userId }).first?.picture).orEmpty(), width: isMainScreen ? 120 : 60, height: isMainScreen ? 120 : 60)
                                    .frame(width: isMainScreen ? 120 : 60, height: isMainScreen ? 120 : 60)
                                    .clipShape(Circle())
                            )
                    }
                }
                
                if !(viewModel.participants.filter({ $0.userId != viewModel.dyteMeeting.localUser.userId }).first?.audioEnabled).orFalse() {
                    HStack(spacing: 0) {
                        Image.videoCallMicOffStrokeIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: isMainScreen ? 24 : 12)
                    }
                    .padding(5)
                    .background(
                        Capsule()
                            .foregroundColor(.gray.opacity(0.5))
                    )
                    .padding(.top, isMainScreen ? 40 : 10)
                    .padding(.trailing)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

struct PrivateVideoCallView_Previews : PreviewProvider {
	static var previews: some View {
		PrivateVideoCallView(
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
