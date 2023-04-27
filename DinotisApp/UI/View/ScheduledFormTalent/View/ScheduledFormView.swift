//
//  ScheduledFormView.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/08/21.
//

import DinotisData
import DinotisDesignSystem
import OneSignal
import SwiftUI
import SwiftKeychainWrapper
import SwiftUITrackableScrollView

struct ScheduledFormView: View {
	@Environment(\.presentationMode) var presentationMode

	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder

	@ObservedObject var stateObservable = StateObservable.shared
	@ObservedObject var viewModel: ScheculedFormViewModel
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
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
								action: {
									viewModel.routeToRoot()
								}
							)
						)
					}
				
				VStack(spacing: 0) {
					ZStack {
						HStack {
							Spacer()
							Text(LocaleText.createScheduleTitleText)
								.font(.robotoBold(size: 14))
								.foregroundColor(.black)
							
							Spacer()
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
						viewModel.colorTab
							.edgesIgnoringSafeArea(.vertical)
					)
					.alert(isPresented: $viewModel.minimumPeopleError) {
						Alert(
							title: Text(LocaleText.attention),
							message: Text(LocaleText.errorMinimumPeopleText),
							dismissButton: .cancel(Text(LocaleText.returnText))
						)
					}

					ZStack(alignment: .bottomTrailing) {
						ScrollViews(axes: .vertical, showsIndicators: false) { value in
							DispatchQueue.main.async {
								if value.y < 0 {
									viewModel.colorTab = Color.white
								} else {
									viewModel.colorTab = Color.clear
								}
							}
						} content: {
							LazyVStack(spacing: 10) {
								ForEach($viewModel.meetingArr, id: \.id) { value in
									FormScheduleTalentCardView(
                                        collab: .constant([]),
                                        managements: $viewModel.managements,
                                        meetingForm: value,
										onTapRemove: {
											if let index = viewModel.meetingArr.firstIndex(where: { item in
												value.wrappedValue.id == item.id
											}) {
												viewModel.meetingArr.remove(at: index)
											}
										},
										isShowRemove: value.wrappedValue.id != viewModel.meetingArr.first?.id,
										isEdit: false
									)
								}
							}
							.padding(.vertical, 15)
						}
						.alert(isPresented: $viewModel.isError) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text(viewModel.error.orEmpty()),
								dismissButton: .cancel(Text(LocaleText.returnText)))
						}

						HStack {
							Button(action: {
                viewModel.meetingArr.append(MeetingForm(id: String.random(), title: "", description: "", price: 0, startAt: "", endAt: "", isPrivate: true, slots: 1, managementId: nil, urls: []))
							}, label: {
								Image.Dinotis.plusIcon
									.resizable()
									.scaledToFit()
									.frame(height: 24)
									.padding()
									.background(Color.DinotisDefault.primary)
									.clipShape(Circle())
							})
							.padding()
						}
					}

					VStack(spacing: 0) {
						Button(action: {
							viewModel.submitMeeting()
						}, label: {
							HStack {
								Spacer()
								Text(LocaleText.saveText)
									.font(.robotoMedium(size: 12))
									.foregroundColor(viewModel.meetingArr.contains(where: {
                                        !$0.urls.isEmpty && $0.urls.allSatisfy({
                                            !$0.url.validateURL()
                                        })
                                    }) ? .DinotisDefault.primary.opacity(0.5) : .white)
									.padding(10)
									.padding(.horizontal, 5)
									.padding(.vertical, 5)

								Spacer()
							}
							.background(
                                viewModel.meetingArr.contains(where: {
                                    !$0.urls.isEmpty && $0.urls.allSatisfy({
                                        !$0.url.validateURL()
                                    })
                                }) ? Color.DinotisDefault.lightPrimary : Color.DinotisDefault.primary
							)
							.clipShape(RoundedRectangle(cornerRadius: 8))
						})
                        .disabled(viewModel.meetingArr.contains(where: {
                            !$0.urls.isEmpty && $0.urls.allSatisfy({
                                !$0.url.validateURL()
                            })
                        }))
						.padding()
						.background(Color.white.edgesIgnoringSafeArea(.vertical))

					}
				}
				.valueChanged(value: viewModel.success) { value in
					if value {
						self.presentationMode.wrappedValue.dismiss()
					}
				}

			}
			
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
		}
        .onAppear {
            Task {
                await viewModel.getUsers()
            }
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
