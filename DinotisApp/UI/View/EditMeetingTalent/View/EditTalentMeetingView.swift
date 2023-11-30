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
                Color.DinotisDefault.baseBackground
                    .edgesIgnoringSafeArea(.all)
				
				VStack(spacing: 0) {
                    ZStack {
                        HStack {
                            Spacer()
                            Text(LocaleText.editVideoCallScheduleTitle)
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
                    .padding(.bottom)
                    .background(
                        Color.DinotisDefault.baseBackground
                            .edgesIgnoringSafeArea(.vertical)
                    )
					
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            if let attr = try? AttributedString(markdown: LocalizableText.creatorRescheduleWarning(viewModel.maxEdit)) {
                                Text(attr)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.DinotisDefault.darkPrimary)
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 11)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundColor(.DinotisDefault.lightPrimary)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .inset(by: 0.5)
                                            .stroke(Color.DinotisDefault.darkPrimary, lineWidth: 1)
                                    )
                            }
                            
                            ScheduleSetupForm()
                                .environmentObject(viewModel)
                            
                            PriceSetupForm()
                                .environmentObject(viewModel)
                        }
                        .padding()
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
        .sheet(isPresented: $viewModel.presentTalentPicker, content: {
            CreatorPickerView(arrUsername: $viewModel.meetingForm.collaborations, arrTalent: $viewModel.talent) {
                viewModel.presentTalentPicker = false
            }
            .dynamicTypeSize(.large)
        })
        .sheet(isPresented: $viewModel.showsDatePicker) {
            if #available(iOS 16.0, *) {
                StartDatePicker()
                    .environmentObject(viewModel)
                    .presentationDetents([.height(560)])
                    .dynamicTypeSize(.large)
            } else {
                StartDatePicker()
                    .environmentObject(viewModel)
                    .dynamicTypeSize(.large)
            }
        }
        .sheet(isPresented: $viewModel.showsTimePicker) {
            if #available(iOS 16.0, *) {
                StartTimePicker()
                    .environmentObject(viewModel)
                    .presentationDetents([.medium])
                    .dynamicTypeSize(.large)
            } else {
                StartTimePicker()
                    .environmentObject(viewModel)
                    .dynamicTypeSize(.large)
            }
            
        }
        .sheet(isPresented: $viewModel.showsTimeUntilPicker) {
            if #available(iOS 16.0, *) {
                EndTimePicker()
                    .environmentObject(viewModel)
                .presentationDetents([.medium])
                .dynamicTypeSize(.large)
            } else {
                EndTimePicker()
                    .environmentObject(viewModel)
                .dynamicTypeSize(.large)
            }
            
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
