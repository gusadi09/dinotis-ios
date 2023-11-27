//
//  CreatorStudioView.swift
//  DinotisApp
//
//  Created by Irham Naufal on 30/10/23.
//

import DinotisDesignSystem
import DinotisData
import SwiftUI
import SwiftUINavigation

struct CreatorStudioView: View {
    
    @EnvironmentObject var viewModel: CreatorStudioViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.sessionRecordingList,
                destination: { viewModel in
                    SessionRecordingListView()
                        .environmentObject(viewModel.wrappedValue)
                },
                onNavigate: {_ in},
                label: {
                    EmptyView()
                }
            )
            
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.detailVideo,
                destination: { viewModel in
                    DetailVideoView()
                        .environmentObject(viewModel.wrappedValue)
                },
                onNavigate: {_ in},
                label: {
                    EmptyView()
                }
            )
            
            HeaderView(
                type: .textHeader,
                title: "Dinotis \(LocalizableText.creatorStudioLabel)",
                headerColor: .clear,
                textColor: .DinotisDefault.black1,
                leadingButton:  {
                    Button {
                        viewModel.backToHome()
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
                VStack(spacing: 18) {
                    switch viewModel.uploadState {
                    case .initial, .select:
                        UploadContentButton()
                    default:
                        UploadProgressView()
                    }
                    
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.DinotisDefault.black3.opacity(0.2))
                        .frame(maxWidth: 270, maxHeight: 1)
                }
                .padding([.horizontal, .top])
                .padding(.bottom, -18)
                .listRowSeparator(.hidden)
                .listSectionSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                
                Section {
                    VideoListView()
                } header: {
                    ListHeaderView()
                }
                .listRowSeparator(.hidden)
                .listSectionSeparator(.hidden)
                .listRowBackground(Color.white)
                .listRowInsets(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                .background(Color.white)
            }
            .padding(.horizontal, -18)
            .listStyle(.plain)
            .background(
                RoundedCorner(radius: 20, corners: [.topLeft, .topRight])
                    .foregroundColor(.white)
                    .ignoresSafeArea(edges: .bottom)
            )
            .refreshable {
                if viewModel.currentSection != StudioVideoFilter.archive.rawValue {
                    viewModel.mineVideoRequest = MineVideoRequest()
                    viewModel.onLoadMineVideo()
                } else {
                    viewModel.skipArchived = 0
                    viewModel.takeArchived = 5
                    viewModel.onLoadArchivedVideo()
                }
            }
        }
        .background(Color.DinotisDefault.baseBackground)
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.isShowPicker, content: {
            VideoPickerView(videoURL: $viewModel.selectedVideo)
                .onDisappear {
                    viewModel.showEditorWhenPosting()
                }
        })
        .sheet(isPresented: $viewModel.isShowCancelUploadSheet, content: {
            if #available(iOS 16.0, *) {
                CancelUploadSheet()
                    .presentationDetents([.height(180)])
            } else {
                CancelUploadSheet()
            }
        })
        .fullScreenCover(isPresented: $viewModel.isShowPostEditor, content: {
            PostEditorView(isEdit: viewModel.isEdit)
        })
        .onAppear {
            viewModel.onLoadUser()
            viewModel.onLoadMineVideo()
        }
        .onChange(of: viewModel.currentSection) { newValue in
            viewModel.videos = []
            viewModel.mineVideoRequest.skip = 0
            viewModel.mineVideoRequest.take = 5
            viewModel.skipArchived = 0
            viewModel.takeArchived = 5
            
            if newValue != StudioVideoFilter.archive.rawValue {
                viewModel.archivedVideo = []
            }
            
            if newValue != StudioVideoFilter.archive.rawValue {
                if newValue == MineVideoSorting.asc.rawValue {
                    viewModel.mineVideoRequest.sort = MineVideoSorting.asc
                    viewModel.mineVideoRequest.videoType = nil
                } else if newValue == MineVideoSorting.desc.rawValue {
                    viewModel.mineVideoRequest.sort = MineVideoSorting.desc
                    viewModel.mineVideoRequest.videoType = nil
                } else if newValue == MineVideoVideoType.RECORD.rawValue {
                    viewModel.mineVideoRequest.sort = nil
                    viewModel.mineVideoRequest.videoType = MineVideoVideoType.RECORD
                }
                
                viewModel.onLoadMineVideo()
            } else {
                viewModel.onLoadArchivedVideo()
            }
            
        }
        .dinotisAlert(
            isPresent: $viewModel.isShowDelete,
            type: .general,
            title: LocalizableText.creatorStudioDeleteVideoAlertTitle,
            isError: false,
            message: LocalizableText.creatorStudioDeleteVideoAlertContent,
            primaryButton: .init(text: LocalizableText.cancelLabel, action: {}),
            secondaryButton: .init(text: LocalizableText.deleteLabel, action: {
                Task {
                    if let id = viewModel.selectedId {
                        await viewModel.deleteVideo(id: id)
                    }
                }
            })
        )
        .dinotisAlert(
            isPresent: $viewModel.isError,
            type: .general,
            title: LocalizableText.attentionText,
            isError: true,
            message: viewModel.isRefreshFailed ? LocalizableText.alertSessionExpired : viewModel.error,
            primaryButton: .init(text: LocalizableText.okText, action: {
                if viewModel.isRefreshFailed {
                    viewModel.routeToRoot()
                }
            })
        )
    }
}

extension CreatorStudioView {
    @ViewBuilder
    func ListHeaderView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollView in
                HStack(spacing: 8) {
                    ForEach(viewModel.sortSections, id: \.self) { section in
                        Button {
                            withAnimation {
                                viewModel.currentSection = section.rawValue
                                scrollView.scrollTo(section.rawValue, anchor: .center)
                            }
                        } label: {
                            Text(viewModel.chipText(section.rawValue))
                                .font(viewModel.currentSection == section.rawValue ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                .foregroundColor(viewModel.currentSection == section.rawValue ? .DinotisDefault.primary : .DinotisDefault.black1)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(viewModel.currentSection == section.rawValue ? Color.DinotisDefault.lightPrimary : .white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .inset(by: 0.5)
                                        .stroke(viewModel.currentSection == section.rawValue ? Color.DinotisDefault.primary : Color.DinotisDefault.brightPrimary, lineWidth: 1)
                                )
                        }
                        .id(section.rawValue)
                    }
                    
                    ForEach(viewModel.sections, id: \.self) { section in
                        Button {
                            withAnimation {
                                viewModel.currentSection = section.rawValue
                                scrollView.scrollTo(section.rawValue, anchor: .center)
                            }
                        } label: {
                            Text(viewModel.chipText(section.rawValue))
                                .font(viewModel.currentSection == section.rawValue ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                .foregroundColor(viewModel.currentSection == section.rawValue ? .DinotisDefault.primary : .DinotisDefault.black1)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(viewModel.currentSection == section.rawValue ? Color.DinotisDefault.lightPrimary : .white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .inset(by: 0.5)
                                        .stroke(viewModel.currentSection == section.rawValue ? Color.DinotisDefault.primary : Color.DinotisDefault.brightPrimary, lineWidth: 1)
                                )
                        }
                        .id(section.rawValue)
                    }
                    
                    ForEach(viewModel.archieveSections, id: \.self) { section in
                        Button {
                            withAnimation {
                                viewModel.currentSection = section.rawValue
                                scrollView.scrollTo(section.rawValue, anchor: .center)
                            }
                        } label: {
                            Text(viewModel.chipText(section.rawValue))
                                .font(viewModel.currentSection == section.rawValue ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                .foregroundColor(viewModel.currentSection == section.rawValue ? .DinotisDefault.primary : .DinotisDefault.black1)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(viewModel.currentSection == section.rawValue ? Color.DinotisDefault.lightPrimary : .white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .inset(by: 0.5)
                                        .stroke(viewModel.currentSection == section.rawValue ? Color.DinotisDefault.primary : Color.DinotisDefault.brightPrimary, lineWidth: 1)
                                )
                        }
                        .id(section.rawValue)
                    }
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    func VideoListView() -> some View {
        Group {
            switch viewModel.currentSection {
            case StudioVideoFilter.archive.rawValue:
                if viewModel.isLoading {
                    DinotisLoadingView(.small, hide: false)
                } else {
                    if viewModel.archivedVideo.isEmpty {
                        Text(LocalizableText.creatorStudioEmptyArchive)
                            .font(.robotoRegular(size: 14))
                            .foregroundColor(.DinotisDefault.black2)
                            .padding()
                    } else {
                        ForEach(viewModel.archivedVideo, id: \.id) { video in
                            if video.id == viewModel.archivedVideo.last?.id {
                                ArchivedVideoCard(video)
                                    .onAppear {
                                        Task {
                                            if video.id == viewModel.archivedVideo.last?.id {
                                                if viewModel.nextCursor != nil {
                                                    viewModel.skipArchived = viewModel.takeArchived
                                                    viewModel.takeArchived += 5
                                                    
                                                    await viewModel.getArchived(isMore: true)
                                                }
                                            }
                                        }
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 36, bottom: viewModel.isLoadingMore ? 0 : -15, trailing: 36))
                                
                                if viewModel.isLoadingMore {
                                    HStack {
                                        Spacer()
                                        
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                        
                                        Spacer()
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 36, bottom: -15, trailing: 36))
                                }
                            } else {
                                ArchivedVideoCard(video)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 36, bottom: -15, trailing: 36))
                            }
                            
                        }
                    }
                }
                
            default:
                if viewModel.isLoading {
                    DinotisLoadingView(.small, hide: false)
                } else {
                    if viewModel.videos.isEmpty {
                        Text(LocalizableText.creatorStudioEmptyUpload)
                            .font(.robotoRegular(size: 14))
                            .foregroundColor(.DinotisDefault.black2)
                            .padding()
                    } else {
                        ForEach(viewModel.videos, id: \.id) { video in
                            if video.id == viewModel.videos.last?.id {
                                VideoCard(video)
                                    .onAppear {
                                        Task {
                                            if video.id == viewModel.videos.last?.id {
                                                if viewModel.nextCursor != nil {
                                                    viewModel.mineVideoRequest.skip = viewModel.mineVideoRequest.take
                                                    viewModel.mineVideoRequest.take += 5
                                                    
                                                    await viewModel.getMineVideo(isMore: true)
                                                }
                                            }
                                        }
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 36, bottom: 0, trailing: 36))
                                
                                if viewModel.isLoadingMore {
                                    HStack {
                                        Spacer()
                                        
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                        
                                        Spacer()
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 36, bottom: 0, trailing: 36))
                                }
                            } else {
                                VideoCard(video)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 36, bottom: 0, trailing: 36))
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
    
    @ViewBuilder
    func VideoCard(_ video: MineVideoData) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            DinotisImageLoader(urlString: video.cover.orEmpty())
                .scaledToFill()
                .frame(width: 358, height: 202)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    viewModel.routeToDetailVideo(id: video.id.orEmpty())
                }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top) {
                    Text(video.title.orEmpty())
                        .font(.robotoBold(size: 16))
                        .foregroundColor(.DinotisDefault.black1)
                        .padding([.leading], 4)
                        .onTapGesture {
                            viewModel.routeToDetailVideo(id: video.id.orEmpty())
                        }
                    
                    Spacer()
                    
                    Menu {
                        Button {
                            viewModel.selectedId = video.id
                            viewModel.editVideo(video)
                        } label: {
                            Label(
                                title: { Text(LocalizableText.changeLabel) },
                                icon: { Image.studioPencilIcon }
                            )
                        }
                        
                        Button {
                            viewModel.selectedId = video.id
                            viewModel.isShowDelete = true
                        } label: {
                            Label(
                                title: { Text(LocalizableText.deleteLabel) },
                                icon: { Image.studioTrashIcon }
                            )
                        }
                        
//                        Button {
//                            
//                        } label: {
//                            Label(
//                                title: { Text(LocalizableText.downloadLabel) },
//                                icon: { Image.studioDocumentUploadIcon }
//                            )
//                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(.DinotisDefault.black2)
                            .padding([.trailing], 4)
                            .padding([.top, .leading])
                            .contentShape(Rectangle())
                    }
                    
                }
                
                HStack {
                    Text(viewModel.dateFormatter(video.createdAt.orCurrentDate()))
                        .font(.robotoMedium(size: 12))
                    
                    Circle()
                        .frame(width: 4, height: 4)
                    
                    Text((video.videoType?.rawValue).orEmpty().capitalized)
                        .font(.robotoMedium(size: 12))
                }
                .foregroundColor(.DinotisDefault.black3)
                .padding([.leading], 4)
                .onTapGesture {
                    viewModel.routeToDetailVideo(id: video.id.orEmpty())
                }
            }
            
            Divider()
        }
    }
    
    @ViewBuilder
    func PostEditorView(isEdit: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    viewModel.dismissEditor()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.DinotisDefault.black1)
                }
                
                Spacer()
                
                if isEdit && viewModel.isLoadingEdit {
                        LottieView(name: "regular-loading", loopMode: .loop)
                            .scaledToFit()
                            .frame(height: 25)
                            .padding(10)
                            .padding(.horizontal, 6)
                } else {
                    DinotisCapsuleButton(text: LocalizableText.postLabel, textColor: .white, bgColor: .DinotisDefault.primary) {
                        Task {
                            if isEdit {
                                guard let id = viewModel.selectedId else { return }
                                if viewModel.thumbnail != UIImage() {
                                    await viewModel.uploadCoverEdit(viewModel.thumbnail)
                                }
                                
                                await viewModel.editVideoItem(id: id, for: viewModel.currentVideo)
                            } else {
                                if viewModel.uploadState == .select {
                                    let backgroundQueue = DispatchQueue.global(qos: .background)
                                    
                                    backgroundQueue.async {
                                        Task {
                                            await viewModel.startUpload()
                                        }
                                    }
                                } else {
                                    viewModel.dismissEditor()
                                }
                            }
                        }
                    }
                    .opacity(viewModel.disablePostButton() ? 0.5 : 1)
                    .disabled(viewModel.disablePostButton())
                }
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        DinotisImageLoader(urlString: viewModel.profileImage)
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .clipShape(.circle)
                        
                        Button {
                            viewModel.isShowUploadSheet = true
                        } label: {
                            Text("\(viewModel.viewerTypeText(viewModel.currentVideo.audienceType)) \(Image(systemName: "chevron.down"))")
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.DinotisDefault.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.DinotisDefault.lightPrimary)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .inset(by: 0.5)
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                )
                        }
                    }
                    
                    Button {
                        viewModel.showHoverVideo()
                    } label: {
                        Group {
                            if viewModel.thumbnail == UIImage() {
                                DinotisImageLoader(urlString: viewModel.currentVideo.cover)
                            } else {
                                Image(uiImage: viewModel.thumbnail)
                                    .resizable()
                            }
                        }
                        .scaledToFill()
                        .frame(width: 358, height: 202)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(viewModel.isLoadingEdit)
                    .overlay(alignment: .bottomLeading) {
                        Button {
                            viewModel.isShowImagePicker = true
                        } label: {
                            Text(LocalizableText.editCoverLabel)
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .foregroundColor(.black.opacity(0.7))
                                )
                        }
                        .padding(8)
                        .disabled(viewModel.isLoadingEdit)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizableText.titleLabel)
                            .font(.robotoRegular(size: 14))
                            .foregroundColor(.DinotisDefault.black3)
                        
                        MultilineTextField(LocalizableText.creatorStudioArchiveTitlePlaceholder, text: $viewModel.currentVideo.title)
                            .tint(Color.DinotisDefault.primary)
                            .disabled(viewModel.isLoadingEdit)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizableText.descriptionLabel)
                            .font(.robotoRegular(size: 14))
                            .foregroundColor(.DinotisDefault.black3)
                        
                        MultilineTextField(LocalizableText.creatorStudioArchiveDescPlaceholder, text: $viewModel.currentVideo.description)
                            .tint(Color.DinotisDefault.primary)
                            .disabled(viewModel.isLoadingEdit)
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay {
            HoverVideoView(isEdit: isEdit, webVideoUrl: viewModel.currentVideo.videoUrl)
        }
        .sheet(isPresented: $viewModel.isShowUploadSheet, content: {
            if #available(iOS 16.0, *) {
                UploadBottomSheet()
                    .presentationDetents([.height(240)])
            } else {
                UploadBottomSheet()
            }
        })
        .sheet(isPresented: $viewModel.isShowImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.thumbnail)
                .dynamicTypeSize(.large)
        }
    }
    
    @ViewBuilder
    func HoverVideoView(isEdit: Bool = false, webVideoUrl: String) -> some View {
        if let url = viewModel.selectedVideo, viewModel.isShowHoverVideo && !isEdit {
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
                    .padding(.top, 100)
            }
        } else if let webUrl = URL(string: webVideoUrl), viewModel.isShowHoverVideo && isEdit {
            ZStack {
                Color.black.opacity(0.4).ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            viewModel.isShowHoverVideo = false
                        }
                    }
                
                DinotisVideoPlayer(url: webUrl)
                    .frame(maxHeight: 210)
                    .cornerRadius(9)
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .padding(.top, 100)
            }
        }
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
                    viewModel.isShowUploadSheet = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.DinotisDefault.black2)
                }
            }
            
            VStack(spacing: 8) {
                Button {
                    withAnimation {
                        viewModel.currentVideo.audienceType = ViewerType.publicly.type
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
                        .foregroundColor(viewModel.currentVideo.audienceType == ViewerType.publicly.type ? .white : .DinotisDefault.black1)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(viewModel.currentVideo.audienceType == ViewerType.publicly.type ? Color.DinotisDefault.primary : .clear)
                        )
                        .overlay {
                            if viewModel.currentVideo.audienceType != ViewerType.publicly.type {
                                RoundedRectangle(cornerRadius: 12)
                                    .inset(by: 0.5)
                                    .stroke(Color(red: 0.91, green: 0.91, blue: 0.91), lineWidth: 1)
                            }
                        }
                    }
                }
                
                Button {
                    withAnimation {
                        viewModel.currentVideo.audienceType = ViewerType.subscriber.type
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
                        .foregroundColor(viewModel.currentVideo.audienceType == ViewerType.subscriber.type ? .white : .DinotisDefault.black1)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(viewModel.currentVideo.audienceType == ViewerType.subscriber.type ? Color.DinotisDefault.primary : .clear)
                        )
                        .overlay {
                            if viewModel.currentVideo.audienceType != ViewerType.subscriber.type {
                                RoundedRectangle(cornerRadius: 12)
                                    .inset(by: 0.5)
                                    .stroke(Color(red: 0.91, green: 0.91, blue: 0.91), lineWidth: 1)
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding()
        .padding(.vertical)
    }
    
    @ViewBuilder
    func UploadContentButton() -> some View {
        Button {
            viewModel.showVideoPicker()
        } label: {
            HStack {
                Image(systemName: "plus.app")
                    .font(.title3)
                
                Text(LocalizableText.uploadContentLabel)
                    .font(.robotoBold(size: 14))
            }
            .foregroundColor(.DinotisDefault.primary)
            .frame(maxWidth: .infinity)
            .padding(18)
            .background(Color.DinotisDefault.lightPrimary)
            .cornerRadius(12)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.5)
                    .stroke(Color.DinotisDefault.primary, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    func UploadProgressView() -> some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 2) {
                    Text(viewModel.uploadStatusText)
                        .font(.robotoBold(size: 12))
                        .foregroundColor(.DinotisDefault.primary)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(.DinotisDefault.primary.opacity(0.7))
                        .isHidden(viewModel.uploadState != .success, remove: true)
                    
                    Spacer()
                    
                    Button {
                        let backgroundQueue = DispatchQueue.global(qos: .background)
                        
                        backgroundQueue.async {
                            Task {
                                await viewModel.startUpload()
                            }
                        }
                    } label: {
                        Text("\(Image(systemName: "arrow.clockwise")) \(LocalizableText.tryAgainLabel)")
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .foregroundColor(.DinotisDefault.primary)
                            )
                    }
                    .buttonStyle(.plain)
                    .isHidden(viewModel.uploadState != .failed, remove: true)
                }
                
                ProgressView(value: viewModel.uploadProgress)
                    .tint(.DinotisDefault.primary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.DinotisDefault.lightPrimary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .inset(by: 0.5)
                    .stroke(Color.DinotisDefault.primary, lineWidth: 1)
            )
            .onTapGesture {
                if viewModel.uploadState == .uploading {
                    viewModel.isShowCancelUploadSheet = true
                }
            }
            
            Button {
                withAnimation {
                    viewModel.uploadState = .initial
                    viewModel.uploadProgress = 0.0
                }
            } label: {
                Text(LocalizableText.cancelUploadLabel)
                    .font(.robotoBold(size: 12))
                    .foregroundColor(.DinotisDefault.red)
            }
            .buttonStyle(.plain)
            .isHidden(viewModel.uploadState != .failed, remove: true)
        }
    }
    
    @ViewBuilder
    func CancelUploadSheet() -> some View {
        VStack(spacing: 18) {
            HStack {
                Text(LocalizableText.uploadVideoLabel)
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button {
                    viewModel.isShowCancelUploadSheet = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.DinotisDefault.black2)
                }
            }
            
            VStack(spacing: 16) {
                DinotisPrimaryButton(
                    text: LocalizableText.generalContinueLabel,
                    type: .adaptiveScreen,
                    textColor: .white,
                    bgColor: .DinotisDefault.primary
                ) {
                    viewModel.isShowCancelUploadSheet = false
                }
                
                DinotisPrimaryButton(
                    text: LocalizableText.cancelUploadLabel,
                    type: .adaptiveScreen,
                    textColor: .DinotisDefault.primary,
                    bgColor: .DinotisDefault.lightPrimary
                ) {
                    viewModel.isShowCancelUploadSheet = false
                    withAnimation {
                        viewModel.uploadState = .initial
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .padding()
    }
    
    @ViewBuilder
    func ArchivedVideoCard(_ video: ArchivedData) -> some View {
        Button {
            viewModel.routeToSessionRecordingList(videos: video.recordings ?? [])
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(video.title.orEmpty())
                    .font(.robotoBold(size: 15))
                    .foregroundColor(.DinotisDefault.black2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 8) {
                    Text("\((video.recordings?.count).orZero()) Videos")
                    
                    Circle()
                        .frame(width: 3, height: 3)
                    
                    Text(viewModel.dateFormatter(video.endAt.orCurrentDate()))
                }
                .font(.robotoMedium(size: 12))
                .foregroundColor(.DinotisDefault.black3)
            }
            .padding(16)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.DinotisDefault.black3.opacity(0.5), lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CreatorStudioView()
        .environmentObject(CreatorStudioViewModel(backToHome: {}))
}
