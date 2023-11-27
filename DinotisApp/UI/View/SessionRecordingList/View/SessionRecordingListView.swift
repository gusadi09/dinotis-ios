//
//  SessionRecordingListView.swift
//  DinotisApp
//
//  Created by Irham Naufal on 30/10/23.
//

import DinotisDesignSystem
import SwiftUI

struct SessionRecordingListView: View {
    
    @EnvironmentObject var viewModel: SessionRecordingListViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    HeaderView(
                        type: .textHeader,
                        title: LocalizableText.seeSessionRecordingLabel,
                        headerColor: .clear,
                        textColor: .DinotisDefault.black1,
                        leadingButton:  {
                            Button {
                                dismiss()
                            } label: {
                                Image.generalBackIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding(12)
                                    .background(
                                        Circle()
                                            .fill(.white)
                                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 0)
                                    )
                            }
                        })
                    
                    List {
                        if viewModel.videos.isEmpty {
                            Text(LocalizableText.emptyRecordingDesc)
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.DinotisDefault.black2)
                                .multilineTextAlignment(.center)
                                .padding(.top)
                        } else {
                            ForEach(viewModel.processedVideos.indices, id: \.self) { index in
                                
                                HStack(alignment: .top, spacing: 8) {
                                    ZStack {
                                        Image(uiImage: viewModel.processedVideos[index].thumbnail ?? UIImage())
                                        
                                        Color.black.opacity(0.4)
                                        
                                        Image(systemName: "play.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                        
                                    }
                                    .scaledToFill()
                                    .frame(width: 155, height: 90)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.selectedVideo = viewModel.processedVideos[index].downloadURL.orEmpty()
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Recording \(index)")
                                            .font(.robotoBold(size: 16))
                                            .foregroundColor(.DinotisDefault.black1)
                                        
                                        Text(viewModel.processedVideos[index].size.orEmpty())
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.black3)
                                        
                                        if !viewModel.processedVideos[index].isDownloading && viewModel.processedVideos[index].isError {
                                            Text("Download failed, please try again")
                                                .font(.robotoRegular(size: 12))
                                                .foregroundColor(.DinotisDefault.red)
                                        } else {
                                            Text("\(LocalizableText.downloadingLabel) \(Int(viewModel.processedVideos[index].progress*100))%")
                                                .font(.robotoRegular(size: 12))
                                                .foregroundColor(.DinotisDefault.primary)
                                                .isHidden(!viewModel.processedVideos[index].isDownloading, remove: true)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    if !viewModel.processedVideos[index].isDownloading && viewModel.processedVideos[index].isError {
                                        Button {
                                            withAnimation {
                                                viewModel.processedVideos[index].isDownloading = false
                                                viewModel.processedVideos[index].isError = false
                                            }
                                            
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title)
                                                .foregroundColor(.DinotisDefault.red)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    
                                    Button {
                                        let backgroundQueue = DispatchQueue.global(qos: .background)
                                        
                                        backgroundQueue.async {
                                            if viewModel.processedVideos[index].isDownloading {
                                                viewModel.onDownload(url: viewModel.processedVideos[index].downloadURL.orEmpty(), filename: $viewModel.processedVideos[index].filename.wrappedValue, index: index, isCancel: true)
                                                
                                            } else if !viewModel.processedVideos[index].isDownloading && viewModel.processedVideos[index].isError {
                                                viewModel.onDownload(url: viewModel.processedVideos[index].downloadURL.orEmpty(), filename: $viewModel.processedVideos[index].filename.wrappedValue, index: index)
                                            } else {
                                                viewModel.onDownload(url: viewModel.processedVideos[index].downloadURL.orEmpty(), filename: $viewModel.processedVideos[index].filename.wrappedValue, index: index)
                                            }
                                        }
                                        
                                    } label: {
                                        if viewModel.processedVideos[index].isDownloading && !viewModel.processedVideos[index].isError {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title)
                                                .foregroundColor(.DinotisDefault.primary)
                                        } else if !viewModel.processedVideos[index].isDownloading && viewModel.processedVideos[index].isError {
                                            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                                .font(.title)
                                                .foregroundColor(.DinotisDefault.primary)
                                        } else {
                                            Image(systemName: "arrow.down.circle.fill")
                                                .font(.title)
                                                .foregroundColor(.DinotisDefault.primary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                
                Color.black.opacity(0.3)
                    .ignoresSafeArea(.all)
                    .isHidden(viewModel.selectedVideo.isEmpty, remove: viewModel.selectedVideo.isEmpty)
                    .onTapGesture {
                        withAnimation {
                            viewModel.selectedVideo = ""
                        }
                    }
                    .buttonStyle(.plain)
                
                DinotisVideoPlayer(url: URL(string: viewModel.selectedVideo) ?? (NSURL() as URL), isAutoPlay: true)
                    .frame(width: geo.size.width-40, height: geo.size.width * 9 / 16)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                    .isHidden(viewModel.selectedVideo.isEmpty, remove: viewModel.selectedVideo.isEmpty)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.DinotisDefault.baseBackground)
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
    }
}

#Preview {
    SessionRecordingListView()
        .environmentObject(SessionRecordingListViewModel(videos: [], backToHome: {}))
}
