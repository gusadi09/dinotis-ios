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
            
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.videos.isEmpty {
                        Text(LocalizableText.emptyRecordingDesc)
                            .font(.robotoRegular(size: 14))
                            .foregroundColor(.DinotisDefault.black2)
                            .multilineTextAlignment(.center)
                            .padding(.top)
                    } else {
                        ForEach(viewModel.videos.indices, id: \.self) { index in
                            let video = viewModel.videos[index]
                            HStack(alignment: .top, spacing: 8) {
                                ZStack {
                                    DinotisImageLoader(urlString: video.thumbnail)
                                    
                                    Color.black.opacity(0.4)
                                    
                                    Image(systemName: "play.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                                .scaledToFill()
                                .frame(width: 155, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(video.title)
                                        .font(.robotoBold(size: 16))
                                        .foregroundColor(.DinotisDefault.black1)
                                    
                                    Text(video.size)
                                        .font(.robotoBold(size: 12))
                                        .foregroundColor(.DinotisDefault.black3)
                                    
                                    Text("\(LocalizableText.downloadingLabel) 46%")
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.DinotisDefault.primary)
                                        .isHidden(!video.isDownloading, remove: true)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button {
                                    withAnimation {
                                        viewModel.videos[index].isDownloading = true
                                    }
                                } label: {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.DinotisDefault.primary)
                                }
                                .isHidden(video.isDownloading, remove: true)
                            }
                        }
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.DinotisDefault.baseBackground)
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
    }
}

#Preview {
    SessionRecordingListView()
        .environmentObject(SessionRecordingListViewModel(backToHome: {}))
}
