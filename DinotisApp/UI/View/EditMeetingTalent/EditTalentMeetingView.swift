//
//  EditTalentMeetingView.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/10/21.
//

import SwiftUI

struct EditTalentMeetingView: View {
	@State var colorTab = Color.clear
	
	@ObservedObject var talentMeetingVM = TalentMeetingViewModel.shared
	
	@ObservedObject var additionalVM = AdditionalMeetingViewModel.shared
	
	@ObservedObject var usersVM = UsersViewModel.shared
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	@ObservedObject var detailVM = DetailMeetingViewModel.shared
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	@Binding var meetingForm: MeetingForm
	
	@Binding var meetingId: String
	
	@State var isShowSuccess = false
	
	@State var isShowFieldError = false
	@State var isShowError = false
	@State var errorText = NSLocalizedString("field_error_form_schedule", comment: "")
	
	@Environment(\.presentationMode) var presentationMode
	
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
							Text(NSLocalizedString("edit_video_call_schedule", comment: ""))
								.font(Font.custom(FontManager.Montserrat.bold, size: 14))
								.foregroundColor(.black)
							
							Spacer()
						}
						.alert(isPresented: $isShowError) {
							Alert(
								title: Text(NSLocalizedString("attention", comment: "")),
								message: Text(additionalVM.error?.errorDescription ?? ""),
								dismissButton: .cancel(Text(NSLocalizedString("return", comment: "")))
							)
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
							FormScheduleTalentCardView(meetingForm: $meetingForm, onTapRemove: {}, isShowRemove: false, isEdit: true)
						}
						.padding(.top, 15)
						.padding(.bottom, 100)
					}
				}
				.valueChanged(value: additionalVM.isSuccessEdit) { value in
					if value {
						isShowSuccess.toggle()
					}
				}
				.alert(isPresented: $isShowFieldError) {
					Alert(
						title: Text(NSLocalizedString("attention", comment: "")),
						message: Text(errorText),
						dismissButton: .cancel(Text(NSLocalizedString("return", comment: "")))
					)
				}
				.valueChanged(value: additionalVM.isError) { value in
					if value {
						isShowError.toggle()
					}
				}
				
				VStack(spacing: 0) {
					Spacer()
					
					Button(action: {
						if meetingForm.title.isEmpty ||
								meetingForm.slots == 0 || (!(meetingForm.isPrivate) && meetingForm.slots <= 1) {
							if (!(meetingForm.isPrivate) && meetingForm.slots <= 1) {
								errorText = "Participants for group call must more than 1"
							}

							isShowFieldError.toggle()
						} else {
							additionalVM.editMeeting(meetingId: meetingId, form: meetingForm)
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
						.background(Color("btn-stroke-1"))
						.clipShape(RoundedRectangle(cornerRadius: 8))
					})
					.padding()
					.background(Color.white)
					
					Color.white
						.frame(height: 8)
					
				}
				.edgesIgnoringSafeArea(.all)
				.alert(isPresented: $isShowSuccess) {
					Alert(
						title: Text(NSLocalizedString("success", comment: "")),
						message: Text(NSLocalizedString("edit_schedule_success", comment: "")),
						dismissButton: .default(Text(NSLocalizedString("return", comment: "")), action: {
							self.detailVM.getDetailMeeting(id: meetingId)
							
							self.presentationMode.wrappedValue.dismiss()
						}))
				}
			}
			
			LoadingView(isAnimating: $additionalVM.isLoading)
				.isHidden(
					additionalVM.isLoading ?
					false : true,
					remove: additionalVM.isLoading ?
					false : true
				)
				.alert(isPresented: $additionalVM.isRefreshFailed) {
					Alert(
						title: Text(NSLocalizedString("attention", comment: "")),
						message: Text(NSLocalizedString("session_expired", comment: "")),
						dismissButton: .default(Text(NSLocalizedString("return", comment: "")), action: {
							
						}))
				}
		}
		
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct EditTalentMeetingView_Previews: PreviewProvider {
	static var previews: some View {
		EditTalentMeetingView(
			meetingForm: .constant(
				MeetingForm(
					id: UUID().uuidString,
					title: "",
					description: "",
					price: 0,
					startAt: "",
					endAt: "",
					isPrivate: true,
					slots: 0)
			),
			meetingId: .constant("")
		)
	}
}
