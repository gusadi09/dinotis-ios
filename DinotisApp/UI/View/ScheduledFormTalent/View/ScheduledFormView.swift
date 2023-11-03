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
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    @ObservedObject var stateObservable = StateObservable.shared
    @ObservedObject var viewModel: ScheduledFormViewModel
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    init(viewModel: ScheduledFormViewModel) {
        self.viewModel = viewModel
        FontInjector.registerFonts()
        UISlider.appearance().maximumTrackTintColor = .white
    }
    
    var body: some View {
        ZStack {
            ZStack(alignment: .topLeading) {
                Color.DinotisDefault.baseBackground
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
                    .alert(isPresented: $viewModel.minimumPeopleError) {
                        Alert(
                            title: Text(LocaleText.attention),
                            message: Text(LocaleText.errorMinimumPeopleText),
                            dismissButton: .cancel(Text(LocaleText.returnText))
                        )
                    }
                    
                    ZStack(alignment: .bottomTrailing) {
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: 16) {
                                ScheduleSetupForm()
                                    .environmentObject(viewModel)
                                
                                PriceSetupForm()
                                    .environmentObject(viewModel)
                            }
                            .padding()
                        }
                        .alert(isPresented: $viewModel.isError) {
                            Alert(
                                title: Text(LocaleText.attention),
                                message: Text(viewModel.error.orEmpty()),
                                dismissButton: .cancel(Text(LocaleText.returnText)))
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
                                    .foregroundColor(!viewModel.meeting.urls.isEmpty && viewModel.meeting.urls.allSatisfy({
                                        !$0.url.validateURL()
                                    }) || viewModel.isTotalEstimationMinus() ? .DinotisDefault.primary.opacity(0.5) : .white)
                                    .padding(10)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 5)
                                
                                Spacer()
                            }
                            .background(
                                !viewModel.meeting.urls.isEmpty && viewModel.meeting.urls.allSatisfy({
                                    !$0.url.validateURL()
                                }) || viewModel.isTotalEstimationMinus() ? Color.DinotisDefault.lightPrimary : Color.DinotisDefault.primary
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        })
                        .disabled(!viewModel.meeting.urls.isEmpty && viewModel.meeting.urls.allSatisfy({
                            !$0.url.validateURL()
                        }) || viewModel.isTotalEstimationMinus())
                        .padding()
                        .background(Color.white.edgesIgnoringSafeArea(.vertical))
                        
                    }
                }
                .valueChanged(value: viewModel.success) { value in
                    if value {
                        dismiss()
                    }
                }
                
            }
            
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
        }
        .onAppear {
            viewModel.meeting.startAt = viewModel.startDate.orCurrentDate().toStringFormat(with: .utc)
            
            viewModel.meeting.endAt = viewModel.endDate.orCurrentDate().toStringFormat(with: .utc)
            
            viewModel.onAppear()
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.isShowAppCostsManagement) {
            if #available(iOS 16.0, *) {
                SetupAppUsageFaresSheetView()
                    .environmentObject(viewModel)
                    .presentationDetents([.height(viewModel.appUsageFareSheetHeight)])
                    .animation(.spring(), value: viewModel.appUsageFareSheetHeight)
                    .presentationDragIndicator(.visible)
            } else {
                SetupAppUsageFaresSheetView()
                    .environmentObject(viewModel)
            }
        }
        .sheet(isPresented: $viewModel.isShowSelectedTalent, content: {
            if #available(iOS 16.0, *) {
                SelectedCollabCreatorView(arrUsername: $viewModel.meeting.collaborations, arrTalent: $viewModel.talent) {
                    viewModel.isShowSelectedTalent = false
                }
                .presentationDetents([.medium, .large])
                .dynamicTypeSize(.large)
            } else {
                SelectedCollabCreatorView(arrUsername: $viewModel.meeting.collaborations, arrTalent: $viewModel.talent) {
                    viewModel.isShowSelectedTalent = false
                }
                .dynamicTypeSize(.large)
            }
        })
        .sheet(isPresented: $viewModel.presentTalentPicker, content: {
            CreatorPickerView(arrUsername: $viewModel.meeting.collaborations, arrTalent: $viewModel.talent) {
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
    }
}

struct ScheduledFormView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduledFormView(viewModel: ScheduledFormViewModel(backToHome: {}))
    }
}
