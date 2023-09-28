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
	
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		ZStack {
			ZStack(alignment: .topLeading) {
				Image.Dinotis.linearGradientBackground
					.resizable()
					.edgesIgnoringSafeArea(.all)
				
				VStack(spacing: 0) {
					ZStack {
						HStack {
							Spacer()
							Text(LocaleText.editVideoCallSchedule)
								.font(.robotoBold(size: 14))
								.foregroundColor(.black)
							
							Spacer()
						}
						
						HStack {
							Button(action: {
								dismiss()
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
                            FormScheduleTalentCardView(
                                collab: $viewModel.talent,
                                managements: $viewModel.managements,
                                meetingForm: $viewModel.meetingForm,
                                onTapRemove: {},
                                isShowRemove: false,
                                isEdit: true,
                                disableEdit: viewModel.isDisableEdit,
                                maxEdit: $viewModel.maxEdit
                            )
						}
						.padding(.vertical, 15)
					}

					VStack(spacing: 0) {
						Button(action: {
                            Task {
                                UIApplication.shared.endEditing()
                                await viewModel.editMeeting()
                            }
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
                            .background(viewModel.disableSaveButton() ? Color.DinotisDefault.lightPrimary : Color.DinotisDefault.primary)
							.clipShape(RoundedRectangle(cornerRadius: 8))
						})
                        .disabled(viewModel.disableSaveButton())
						.padding()
						.background(
							Color.white
								.edgesIgnoringSafeArea(.vertical)
						)

					}
				}

			}
			
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
		}
		.onAppear {
            viewModel.onAppear()
		}
        .dinotisAlert(
            isPresent: $viewModel.isShowAlert,
            type: .general,
            title: viewModel.alertTitle(),
            isError: viewModel.isError || viewModel.isRefreshFailed,
            message: viewModel.alertText(),
            primaryButton: .init(text: LocalizableText.returnText, action: {
                if viewModel.isRefreshFailed && !viewModel.isShowSuccess && !viewModel.isError {
                    viewModel.routeToRoot()
                } else if !viewModel.isRefreshFailed && viewModel.isShowSuccess && !viewModel.isError {
                    dismiss()
                }
            })
        )
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct EditTalentMeetingView_Previews: PreviewProvider {
	static var previews: some View {
		EditTalentMeetingView(
			viewModel: EditTalentMeetingViewModel(meetingID: "", backToHome: {})
		)
	}
}
