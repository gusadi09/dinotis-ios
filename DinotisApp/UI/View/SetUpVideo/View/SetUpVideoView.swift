//
//  SetUpVideoView.swift
//  DinotisApp
//
//  Created by Irham Naufal on 27/10/23.
//
import SwiftUINavigation
import SwiftUI
import DinotisData
import DinotisDesignSystem

struct SetUpVideoView: View {
    
    @EnvironmentObject var viewModel: SetUpVideoViewModel
    
    var body: some View {
        ZStack {
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.creatorStudio,
                destination: { viewModel in
                    CreatorStudioView()
                        .environmentObject(viewModel.wrappedValue)
                },
                onNavigate: { _ in },
                label: {
                    EmptyView()
                }
            )
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 28) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 16) {
                                Image.archiveMediaIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 34, height: 34)
                                
                                Text(LocalizableText.archiveChooseVideo)
                                    .font(.robotoBold(size: 18))
                                    .foregroundColor(.DinotisDefault.black1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.top, .horizontal])
                            
                            if viewModel.isLoading {
                                HStack {
                                    Spacer()
                                    
                                    LottieView(name: "regular-loading", loopMode: .loop)
                                        .scaledToFit()
                                        .frame(height: 50)
                                    
                                    Spacer()
                                }
                                .frame(height: 200)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false, content: {
                                    HStack {
                                        
                                        ForEach(viewModel.videos.indices, id: \.self) { index in
                                            
                                            Group {
                                                Image(uiImage: viewModel.thumbnails[index])
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 340, height: 200)
                                                    .clipShape(RoundedRectangle(cornerRadius: 9))
                                            }
                                            .overlay {
                                                Image(systemName: "play.circle.fill")
                                                    .font(.system(size: 36))
                                                    .foregroundColor(.white.opacity(0.9))
                                            }
                                            .onTapGesture {
                                                viewModel.showHoverVideo(viewModel.videos[index].downloadUrl.orEmpty())
                                            }
                                            .overlay(alignment: .bottomLeading) {
                                                HStack(spacing: 6) {
                                                    Text("\(viewModel.formatSecondsToTimestamp(seconds: viewModel.videos[index].recordingDuration.orZero()))")
                                                        .font(.robotoBold(size: 12))
                                                        .foregroundColor(.white)
                                                        .padding(4)
                                                        .background(Color.black.opacity(0.5))
                                                        .cornerRadius(6)
                                                    
                                                    Button {
                                                        viewModel.isShowImagePicker[index] = true
                                                    } label: {
                                                        Text("\(Image(systemName: "pencil")) \(LocalizableText.editCoverLabel)")
                                                            .font(.robotoBold(size: 12))
                                                            .foregroundColor(.white)
                                                            .padding(4)
                                                            .padding(.horizontal, 4)
                                                            .background(Color.black.opacity(0.5))
                                                            .cornerRadius(6)
                                                    }
                                                    .isHidden(viewModel.videos[index].downloadUrl.orEmpty() != viewModel.currentVideo.videoUrl, remove: true)
                                                }
                                                .padding(8)
                                            }
                                            .overlay(alignment: .topTrailing) {
                                                Button {
                                                    withAnimation {
                                                        viewModel.currentVideo.videoUrl = viewModel.videos[index].downloadUrl.orEmpty()
                                                        print(viewModel.currentVideo)
                                                    }
                                                } label: {
                                                    (
                                                        viewModel.videos[index].downloadUrl.orEmpty() == viewModel.currentVideo.videoUrl ?
                                                        Image.archiveMagentaCheckmarkIcon :
                                                            Image.archiveInactiveCheckmarkIcon
                                                    )
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 28, height: 28)
                                                    .padding(8)
                                                }
                                            }
                                            .sheet(isPresented: $viewModel.isShowImagePicker[index]) {
                                                ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.thumbnails[index])
                                                    .dynamicTypeSize(.large)
                                            }
                                        }
                                        
                                    }
                                    .padding(.horizontal)
                                })
                            }
                        }
                        
                        Divider()
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizableText.titleLabel)
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.DinotisDefault.black3)
                            
                            Text((viewModel.data?.title).orEmpty())
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.DinotisDefault.black1)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizableText.descriptionLabel)
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.DinotisDefault.black3)
                            
                            Text((viewModel.data?.description).orEmpty())
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.DinotisDefault.black1)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }
                }
                .background(Color.DinotisDefault.baseBackground.ignoresSafeArea())
                
                HStack(spacing: 10) {
                    DinotisSecondaryButton(
                        text: LocalizableText.archiveLabel,
                        type: .adaptiveScreen,
                        textColor: .DinotisDefault.black1,
                        bgColor: .DinotisDefault.lightPrimary,
                        strokeColor: .DinotisDefault.primary
                    ) {
                        viewModel.isShowArchiveSheet = true
                    }
                    
                    DinotisPrimaryButton(
                        text: LocalizableText.uploadLabel,
                        type: .adaptiveScreen,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary
                    ) {
                        viewModel.isShowUploadeSheet = true
                    }
                }
                .padding()
                .background(Color.white.ignoresSafeArea())
            }
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .onAppear {
            viewModel.onGetRecordings()
        }
        .sheet(isPresented: $viewModel.isShowArchiveSheet, content: {
            if #available(iOS 16.0, *) {
                ArchiveBottomSheet()
                    .presentationDetents([.height(360)])
            } else {
                ArchiveBottomSheet()
            }
        })
        .sheet(isPresented: $viewModel.isShowUploadeSheet, content: {
            if #available(iOS 16.0, *) {
                UploadBottomSheet()
                    .presentationDetents([.height(360)])
            } else {
                UploadBottomSheet()
            }
        })
        .overlay {
            HoverVideoView()
        }
    }
}

extension SetUpVideoView {
    @ViewBuilder
    func ArchiveBottomSheet() -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(LocalizableText.archiveLabel)
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.DinotisDefault.black1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    viewModel.isShowArchiveSheet = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.DinotisDefault.black2)
                }
            }
            
            Spacer()
            
            Text(LocalizableText.archiveVideoTitle)
                .font(.robotoBold(size: 24))
                .foregroundColor(.DinotisDefault.black1)
                .multilineTextAlignment(.center)
            
            Text(LocalizableText.archiveVideoDesc)
                .font(.robotoRegular(size: 14))
                .foregroundColor(.DinotisDefault.black3)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            DinotisPrimaryButton(
                text: LocalizableText.goToArchiveLabel,
                type: .adaptiveScreen,
                textColor: .white,
                bgColor: .DinotisDefault.primary
            ) {
                viewModel.isShowArchiveSheet = false
                viewModel.routeToCreatorStudio()
            }
        }
        .padding()
        .padding(.vertical)
    }
    
    @ViewBuilder
    func UploadBottomSheet() -> some View {
        VStack(spacing: 18) {
            HStack {
                Text(LocalizableText.archiveChooseAudience)
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.DinotisDefault.black1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    viewModel.isShowUploadeSheet = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.DinotisDefault.black2)
                }
            }
            
            VStack(spacing: 8) {
                Button {
                    withAnimation {
                        viewModel.viewerType = .publicly
                    }
                } label: {
                    VStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizableText.publicLabel)
                                .font(.robotoBold(size: 14))
                            
                            Text(LocalizableText.archivePublicDesc)
                                .font(.robotoRegular(size: 12))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundColor(viewModel.viewerType == .publicly ? .white : .DinotisDefault.black1)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(viewModel.viewerType == .publicly ? Color.DinotisDefault.primary : .clear)
                        )
                        .overlay {
                            if viewModel.viewerType != .publicly {
                                RoundedRectangle(cornerRadius: 12)
                                    .inset(by: 0.5)
                                    .stroke(Color(red: 0.91, green: 0.91, blue: 0.91), lineWidth: 1)
                            }
                        }
                    }
                }
                
                Button {
                    withAnimation {
                        viewModel.viewerType = .subscriber
                    }
                } label: {
                    VStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizableText.subscriberLabel)
                                .font(.robotoBold(size: 14))
                            
                            Text(LocalizableText.archiveSubscriberDesc)
                                .font(.robotoRegular(size: 12))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundColor(viewModel.viewerType == .subscriber ? .white : .DinotisDefault.black1)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(viewModel.viewerType == .subscriber ? Color.DinotisDefault.primary : .clear)
                        )
                        .overlay {
                            if viewModel.viewerType != .subscriber {
                                RoundedRectangle(cornerRadius: 12)
                                    .inset(by: 0.5)
                                    .stroke(Color(red: 0.91, green: 0.91, blue: 0.91), lineWidth: 1)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            DinotisPrimaryButton(
                text: LocalizableText.goToUploadLabel,
                type: .adaptiveScreen,
                textColor: .white,
                bgColor: .DinotisDefault.primary
            ) {
                viewModel.isShowUploadeSheet = false
            }
        }
        .padding()
        .padding(.vertical)
    }
    
    @ViewBuilder
    func HoverVideoView() -> some View {
        if let url = URL(string: viewModel.currentVideo.videoUrl), viewModel.isShowHoverVideo {
            ZStack {
                Color.black.opacity(0.4).ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            viewModel.isShowHoverVideo = false
                        }
                    }
                
                DinotisVideoPlayer(url: url)
                    .frame(maxHeight: 210)
                    .cornerRadius(9)
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .padding(.top, 50)
            }
        }
    }
}

#Preview {
    SetUpVideoView()
        .environmentObject(SetUpVideoViewModel(data: nil, backToHome: {}, backToScheduleDetail: {}))
}
