//
//  EditTalentMeetingView.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/10/21.
//

import DinotisDesignSystem
import SwiftUI

struct EditTalentMeetingView: View {
	@State var colorTab = Color.clear

	@ObservedObject var viewModel: EditTalentMeetingViewModel
	
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		ZStack {
			ZStack(alignment: .topLeading) {
				Image.Dinotis.linearGradientBackground
					.resizable()
					.edgesIgnoringSafeArea(.all)
					.alert(isPresented: $viewModel.isRefreshFailed) {
						Alert(
							title: Text(LocaleText.attention),
							message: Text(LocaleText.sessionExpireText),
							dismissButton: .default(
								Text(LocaleText.returnText),
								action: viewModel.routeToRoot
							)
						)
					}
				
				VStack(spacing: 0) {
					ZStack {
						HStack {
							Spacer()
							Text(LocaleText.editVideoCallSchedule)
								.font(.robotoBold(size: 14))
								.foregroundColor(.black)
							
							Spacer()
						}
						.alert(isPresented: $viewModel.isError) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text(viewModel.error.orEmpty()),
								dismissButton: .cancel(Text(LocaleText.returnText))
							)
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
						
					}
					.padding(.vertical)
					.background(
						colorTab
							.edgesIgnoringSafeArea(.vertical)
					)
					
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
                            FormScheduleTalentCardView(collab: $viewModel.talent, managements: $viewModel.managements, meetingForm: $viewModel.meetingForm, onTapRemove: {}, isShowRemove: false, isEdit: true)
						}
						.padding(.vertical, 15)
					}

					VStack(spacing: 0) {
						Button(action: {
							viewModel.editMeeting()
						}, label: {
							HStack {
								Spacer()
								Text(LocaleText.saveText)
									.font(.robotoMedium(size: 12))
									.foregroundColor(!viewModel.meetingForm.urls.isEmpty && viewModel.meetingForm.urls.allSatisfy({
                                        !$0.url.validateURL()
                                    }) ? .DinotisDefault.primary.opacity(0.5) : .white)
									.padding(10)
									.padding(.horizontal, 5)
									.padding(.vertical, 5)

								Spacer()
							}
							.background(!viewModel.meetingForm.urls.isEmpty && viewModel.meetingForm.urls.allSatisfy({
                                !$0.url.validateURL()
                            }) ? Color.DinotisDefault.lightPrimary : Color.DinotisDefault.primary)
							.clipShape(RoundedRectangle(cornerRadius: 8))
						})
                        .disabled(!viewModel.meetingForm.urls.isEmpty && viewModel.meetingForm.urls.allSatisfy({
                            !$0.url.validateURL()
                        }))
						.padding()
						.background(
							Color.white
								.edgesIgnoringSafeArea(.vertical)
						)

					}
					.alert(isPresented: $viewModel.isShowSuccess) {
						Alert(
							title: Text(LocaleText.successTitle),
							message: Text(LocaleText.editVideoCallSuccessSubtitle),
							dismissButton: .default(
								Text(LocaleText.returnText),
								action: {
									self.presentationMode.wrappedValue.dismiss()
								}
							)
						)
					}
				}

			}
			
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
		}
		.onAppear {
            Task {
                await viewModel.getUsers()
                viewModel.getMeetingDetail()
            }
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct EditTalentMeetingView_Previews: PreviewProvider {
	static var previews: some View {
		EditTalentMeetingView(
			viewModel: EditTalentMeetingViewModel(meetingID: "", backToRoot: {}, backToHome: {})
		)
	}
}
