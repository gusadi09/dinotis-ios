//
//  ScheduledFormView.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/08/21.
//

import SwiftUI
import SwiftUITrackableScrollView
import SwiftKeychainWrapper
import OneSignal

struct ScheduledFormView: View {
	@State var colorTab = Color.clear
	
	@State var isShowFieldError = false
	@State var isShowError = false
	@State var groupCallError = false
	
	@State var errorText = ""
	
	@State var meetingArr = [MeetingForm(id: String.random(), title: "", description: "", price: 0, startAt: "", endAt: "", isPrivate: true, slots: 1)]
	
	@State private var scrollViewContentOffset = CGFloat(0)
	
	@ObservedObject var addMeetingVM = AddMeetingViewModel.shared
	
	@ObservedObject var talentMeetingVM = TalentMeetingViewModel.shared
	
	@Environment(\.presentationMode) var presentationMode
	
	@ObservedObject var usersVM = UsersViewModel.shared
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	@ObservedObject var stateObservable = StateObservable.shared
	
	@ObservedObject var viewModel: ScheculedFormViewModel
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	@State var isShowConnection = false
	
	var body: some View {
		ZStack {
			ZStack(alignment: .topLeading) {
				Image("linear-gradient-bg")
					.resizable()
					.edgesIgnoringSafeArea(.all)
					.alert(isPresented: $isShowConnection) {
						Alert(
							title: Text(NSLocalizedString("attention", comment: "")),
							message: Text(NSLocalizedString("connection_warning", comment: "")),
							dismissButton: .cancel(Text(NSLocalizedString("return", comment: "")))
						)
					}
				
				VStack(spacing: 0) {
					colorTab
						.edgesIgnoringSafeArea(.all)
						.frame(height: 1)
					ZStack {
						HStack {
							Spacer()
							Text(NSLocalizedString("create_video_call_schedule", comment: ""))
								.font(Font.custom(FontManager.Montserrat.bold, size: 14))
								.foregroundColor(.black)
							
							Spacer()
						}
						
						HStack {
							Button(action: {
								presentationMode.wrappedValue.dismiss()
							}, label: {
								Image("ic-chevron-back")
									.padding()
									.background(Color.white)
									.clipShape(Circle())
							})
							.padding(.leading)
							
							Spacer()
						}
						.alert(isPresented: $talentMeetingVM.isRefreshFailed) {
							Alert(
								title: Text(NSLocalizedString("attention", comment: "")),
								message: Text(NSLocalizedString("session_expired", comment: "")),
								dismissButton: .default(Text(NSLocalizedString("return", comment: "")), action: {
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
						
					}
					.padding(.top)
					.padding(.bottom)
					.background(colorTab)
					
					ScrollViews(axes: .vertical, showsIndicators: false) { value in
						DispatchQueue.main.async {
							if value.y < 0 {
								self.colorTab = Color.white
							} else {
								self.colorTab = Color.clear
							}
						}
					} content: {
						VStack {
							ForEach($meetingArr, id: \.id) { value in
								FormScheduleTalentCardView(
									meetingForm: value,
									onTapRemove: {
										if let index = meetingArr.firstIndex(where: { item in
											value.wrappedValue.id == item.id
										}) {
											meetingArr.remove(at: index)
										}
									},
									isShowRemove: value.wrappedValue.id != meetingArr.first?.id,
									isEdit: false
								)
							}
						}
						.padding(.top, 15)
						.padding(.bottom, 100)
					}
					.alert(isPresented: $groupCallError) {
						Alert(
							title: Text(NSLocalizedString("attention", comment: "")),
							message: Text(NSLocalizedString("error_minimun_people", comment: "")),
							dismissButton: .cancel(Text(NSLocalizedString("return", comment: "")))
						)
					}
				}
				.valueChanged(value: addMeetingVM.success) { value in
					if value {
						self.talentMeetingVM.getMeeting()
						self.presentationMode.wrappedValue.dismiss()
					}
				}
				
				VStack(spacing: 0) {
					Spacer()
					HStack {
						Spacer()
						Button(action: {
							meetingArr.append(MeetingForm(id: String.random(), title: "", description: "", price: 0, startAt: "", endAt: "", isPrivate: true, slots: 1))
						}, label: {
							Image("ic-plus")
								.resizable()
								.scaledToFit()
								.frame(height: 24)
								.padding()
								.background(Color("btn-stroke-1"))
								.clipShape(Circle())
						})
						.padding()
					}
					.alert(isPresented: $isShowFieldError) {
						Alert(
							title: Text(NSLocalizedString("attention", comment: "")),
							message: Text(errorText),
							dismissButton: .cancel(Text(NSLocalizedString("return", comment: ""))))
					}
					.valueChanged(value: addMeetingVM.isError) { value in
						if value {
							isShowError.toggle()
						}
					}
					
					Button(action: {
						for items in meetingArr.indices {
							if meetingArr[items].title.isEmpty ||
									meetingArr[items].description.isEmpty ||
									meetingArr[items].slots == 0 {
								isShowFieldError.toggle()
								errorText = NSLocalizedString("field_error_form_schedule", comment: "")
								break
							} else if meetingArr[items].slots < 2 && !meetingArr[items].isPrivate {
								groupCallError.toggle()
								
							} else if meetingArr[items].slots <= 1 && !(meetingArr[items].isPrivate) {
								errorText = "Participant must more than 1 for group call"
								isShowFieldError.toggle()
							} else {
								if meetingArr[items].endAt.isEmpty && meetingArr[items].startAt.isEmpty {
									meetingArr[items].endAt = Date().addingTimeInterval(3600).toString(format: .utcV2)
									
									meetingArr[items].startAt = Date().toString(format: .utcV2)
									addMeetingVM.addMeeting(meeting: meetingArr[items])
								} else if meetingArr[items].endAt.isEmpty {
									if let time = meetingArr[items].startAt.toDate(format: .utcV2) {
										meetingArr[items].endAt = time.addingTimeInterval(3600).toString(format: .utcV2)
										addMeetingVM.addMeeting(meeting: meetingArr[items])
									}
								} else if meetingArr[items].startAt.isEmpty {
									meetingArr[items].endAt = Date().addingTimeInterval(3600).toString(format: .utcV2)
									
									meetingArr[items].startAt = Date().toString(format: .utcV2)
									addMeetingVM.addMeeting(meeting: meetingArr[items])
								} else {
									addMeetingVM.addMeeting(meeting: meetingArr[items])
								}
							}
						}
					}, label: {
						HStack {
							Spacer()
							Text(NSLocalizedString("save_schedule", comment: ""))
								.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
								.foregroundColor(.white)
								.padding(10)
								.padding(.horizontal, 5)
								.padding(.vertical, 5)
							
							Spacer()
						}
						.background(
							Color("btn-stroke-1")
						)
						.clipShape(RoundedRectangle(cornerRadius: 8))
					})
					.padding()
					.background(Color.white)
					.alert(isPresented: $addMeetingVM.isRefreshFailed) {
						Alert(
							title: Text(NSLocalizedString("attention", comment: "")),
							message: Text(NSLocalizedString("session_expired", comment: "")),
							dismissButton: .default(Text(NSLocalizedString("return", comment: "")), action: {
								viewModel.backToRoot()
								stateObservable.userType = 0
								stateObservable.isVerified = ""
								stateObservable.refreshToken = ""
								stateObservable.accessToken = ""
								stateObservable.isAnnounceShow = false
								OneSignal.setExternalUserId("")
							}))
					}
					
					Color.white
						.frame(height: 8)
						.alert(isPresented: $isShowError) {
							Alert(
								title: Text(NSLocalizedString("attention", comment: "")),
								message: Text(addMeetingVM.error?.errorDescription ?? ""),
								dismissButton: .cancel(Text(NSLocalizedString("return", comment: "")))
							)
						}
					
				}
				.edgesIgnoringSafeArea(.all)
			}
			
			LoadingView(isAnimating: $addMeetingVM.isLoading)
				.isHidden(
					addMeetingVM.isLoading ?
					false : true,
					remove: addMeetingVM.isLoading ?
					false : true
				)
		}
		
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct ScheduledFormView_Previews: PreviewProvider {
	static var previews: some View {
		ScheduledFormView(viewModel: ScheculedFormViewModel(backToRoot: {}, backToHome: {}))
	}
}
