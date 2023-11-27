//
//  SessionRecordingListViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 30/10/23.
//

import DinotisData
import Foundation
import Photos
import UIKit

struct DownloadVideo: Identifiable {
    var id: String?
    var title: String?
    var thumbnail: UIImage?
    var size: String?
    var isDownloading: Bool
    var downloadURL: String?
    var progress: Double
    var isError: Bool
    var filename: String
}

final class SessionRecordingListViewModel: ObservableObject {
    private let downloadUseCase: DownloadVideoUseCase
    
    @Published var videos: [RecordingData]
    
    @Published var processedVideos = [DownloadVideo]()
    @Published var selectedVideo = ""
    
    var backToHome: () -> Void
    
    init(videos: [RecordingData], backToHome: @escaping () -> Void, downloadUseCase: DownloadVideoUseCase = DownloadVideoDefaultUseCase()) {
        self.videos = videos
        self.backToHome = backToHome
        self.downloadUseCase = downloadUseCase
        
        self.processedVideos = self.videos.compactMap({
            DownloadVideo(id: $0.id, title: $0.outputFileName, thumbnail: createThumbnail(url: URL(string: $0.downloadUrl.orEmpty()) ?? (NSURL() as URL)), size: fileSizeString(from: $0.fileSize.orZero()), isDownloading: false, downloadURL: $0.downloadUrl, progress: 0.0, isError: false, filename: $0.outputFileName.orEmpty())
        })
    }
    
    func fileSizeString(from size: Int) -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB] // Define the units you want to use
        byteCountFormatter.countStyle = .file

        return byteCountFormatter.string(fromByteCount: Int64(size))
    }
    
    func createThumbnail(url: URL) -> UIImage {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
          print(error.localizedDescription)
            return UIImage()
        }
    }
    
    func onDownload(url: String, filename: String, index: Int, isCancel: Bool = false) {
        Task {
            await self.download(url: url, filename: filename, index: index, isCancel: isCancel)
        }
    }
    
    @MainActor
    func download(url: String, filename: String, index: Int, isCancel: Bool = false) async {
        self.processedVideos[index].isError = false
        self.processedVideos[index].isDownloading = !self.processedVideos[index].isDownloading
        self.processedVideos[index].progress = 0.0
        
        let result = await downloadUseCase.execute(url: url, filename: filename, isCancel: isCancel, progress: isCancel ? nil : { progress in
            self.processedVideos[index].progress = progress.progress
        })
        
        switch result {
        case .success(_):
            self.processedVideos[index].isDownloading = false
            self.processedVideos[index].isError = false
            self.processedVideos[index].progress = 0.0
        case .failure(let error):
            print("ERRORX: \(error.localizedDescription)")
            if !isCancel {
                if error.localizedDescription.contains("cancelled") {
                    self.processedVideos[index].isDownloading = false
                    self.processedVideos[index].isError = false
                    self.processedVideos[index].progress = 0.0
                } else {
                    self.processedVideos[index].isDownloading = false
                    self.processedVideos[index].isError = true
                    self.processedVideos[index].progress = 0.0
                }
            } else if error.localizedDescription.contains("cancelled") {
                self.processedVideos[index].isDownloading = false
                self.processedVideos[index].isError = false
                self.processedVideos[index].progress = 0.0
            }
        }
    }
}
