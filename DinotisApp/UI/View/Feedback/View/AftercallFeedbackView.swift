//
//  VideoCallViewFeedback.swift
//  DinotisApp
//
//  Created by mora hakim on 14/08/23.
//

import SwiftUI
import DinotisDesignSystem
import SwiftUINavigation
import WaterfallGrid

struct AftercallFeedbackView: View {
    
    @ObservedObject var viewModel: FeedbackViewModel
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var hasRegularSize: Bool {
        horizontalSizeClass == .regular
    }
    
    init(viewModel: FeedbackViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.setUpVideo,
                destination: { viewModel in
                    SetUpVideoView()
                        .environmentObject(viewModel.wrappedValue)
                },
                onNavigate: {_ in},
                label: {
                    EmptyView()
                }
            )
            
            Color.DinotisDefault.baseBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Text(LocalizableText.videoCallRateUs)
                        .font(.robotoBold(size: 16))
                        .foregroundColor(.DinotisDefault.black3)
                        .frame(maxWidth: .infinity)
                    
                    Image.feedbackSmileImage
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 260)
                    
                    Text(LocalizableText.videoCallRateText)
                        .font(.robotoBold(size: 16))
                        .foregroundColor(.DinotisDefault.black1)
                        .multilineTextAlignment(.center)
                    
                    VStack {
                        HStack {
                            ForEach(1...5, id: \.self) { rate in
                                Button {
                                    withAnimation {
                                        viewModel.rating = rate
                                    }
                                    
                                    viewModel.reasons = []
                                } label: {
                                    (viewModel.rating >= rate ?
                                        Image.feedbackStarYellow : Image.feedbackStarGray
                                    )
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 42, height: 42)
                                }
                                
                                Spacer()
                                    .isHidden(rate == 5, remove: rate == 5)
                            }
                        }
                        
                        HStack {
                            Text(LocalizableText.feedbackVeryBad)
                            Spacer()
                            Text(LocalizableText.feedbackVeryGood)
                        }
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.DinotisDefault.black3.opacity(0.7))
                    }
                    .padding(.horizontal)
                    
                    if viewModel.rating != 0 {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 14) {
                            
                            HStack {
                                Text(LocalizableText.feedbackWeaknessTitle)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.DinotisDefault.black1)
                                
                                Spacer()
                            }
                            
                            Group {
                                switch viewModel.rating {
                                case 2:
                                    ChipContainerView(chips: viewModel.chips2)
                                case 3:
                                    ChipContainerView(chips: viewModel.chips3)
                                case 4:
                                    ChipContainerView(chips: viewModel.chips4)
                                case 5:
                                    ChipContainerView(chips: viewModel.chips5)
                                default:
                                    ChipContainerView(chips: viewModel.chips0)
                                }
                            }
                            .frame(height: hasRegularSize ? 75 : 150)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            
                            HStack(spacing: 0) {
                                Text(LocalizableText.feedbackProblemTitle)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.DinotisDefault.black1)
                                
                                Text("*")
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.DinotisDefault.red)
                                    .isHidden(viewModel.rating > 3, remove: viewModel.rating > 3)
                                
                                Spacer()
                            }
                            
                            DinotisTextEditor(LocalizableText.yourCommentPlaceholder, label: nil, text: $viewModel.feedback, errorText: .constant(nil))
                        }
                    }
                }
                .padding()
                .background(
                    Color.white
                        .shadow(color: Color(red: 0.22, green: 0.29, blue: 0.41).opacity(0.06), radius: 20, x: 0, y: 0)
                )
                .cornerRadius(12)
                .padding()
            }
            .padding(.bottom, 80)
            
            DinotisPrimaryButton(
                text: LocalizableText.videoCallSendFeedback,
                type: .adaptiveScreen,
                textColor: viewModel.disableButton() ? .DinotisDefault.black3 : .white,
                bgColor: viewModel.disableButton() ? .DinotisDefault.smokeWhite : .DinotisDefault.primary) {
                    Task {
                        await viewModel.giveReview()
                    }
                }
                .padding()
                .background(
                    Color.white
                        .ignoresSafeArea()
                        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                )
                .disabled(viewModel.disableButton())
            
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .onAppear {
            viewModel.onGetDetail()
            
            viewModel.onGetReason(for: 0)
            viewModel.onGetReason(for: 1)
            viewModel.onGetReason(for: 2)
            viewModel.onGetReason(for: 3)
            viewModel.onGetReason(for: 4)
            viewModel.onGetReason(for: 5)
        }
        .fullScreenCover(isPresented: $viewModel.isSuccess) {
            ZStack(alignment: .bottom) {
                Color.DinotisDefault.primary
                    .ignoresSafeArea()
                
                Circle()
                    .fill(Color.black.opacity(0.2))
                    .scaleEffect(2)
                    .offset(y: 200)
                
                VStack {
                    Image.logoFullWhite
                        .resizable()
                        .scaledToFit()
                        .frame(width: 135)
                        .padding(36)
                    
                    Image.feedbackSuccessImage
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .padding([.bottom, .horizontal], 36)
                    
                    Text(LocalizableText.feedbackSuccessTitle)
                        .font(.robotoBold(size: 32))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .onTapGesture {
                self.viewModel.isSuccess = false
                
                if viewModel.showArchived() {
                    self.viewModel.routeToSetUpVideo()
                } else {
                    self.viewModel.backToScheduleDetail()
                }
            }
        }
    }
}

struct VideoCallViewFeedback_Previews: PreviewProvider {
    static var previews: some View {
        AftercallFeedbackView(viewModel: FeedbackViewModel(meetingId: "", backToHome: {}, backToScheduleDetail: {}))
            .onAppear {
                FontInjector.registerFonts()
            }
    }
}
