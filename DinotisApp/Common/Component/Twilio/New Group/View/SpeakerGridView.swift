//
//  SpeakerGridView.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import SwiftUI
import DinotisData
import DinotisDesignSystem

struct SpeakerGridView: View {
	@EnvironmentObject var viewModel: SpeakerGridViewModel
	@EnvironmentObject var streamViewModel: StreamViewModel
	@EnvironmentObject var streamManager: StreamManager
	@EnvironmentObject var presentationLayoutViewModel: PresentationLayoutViewModel
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass
	var speaker: SpeakerVideoViewModel
	let spacing: CGFloat
	let role: String
    let isShowName: Bool
	
	private var isPortraitOrientation: Bool {
		verticalSizeClass == .regular && horizontalSizeClass == .compact
	}
	
	private var gridItemCount: Int {
		viewModel.pages[0].speakerPage.count
	}

	private var rowCount: Int {
		if UIDevice.current.userInterfaceIdiom == .pad {
			return (gridItemCount + gridItemCount % columnCount) / columnCount
		} else {
			if isPortraitOrientation {
				return (gridItemCount + gridItemCount % columnCount) / columnCount
			} else {
				return gridItemCount < 5 ? 1 : 2
			}
		}
	}

	private var columnCount: Int {
		if UIDevice.current.userInterfaceIdiom == .pad {
			return viewModel.onscreenSpeakers.count >= 4 ? 4 : viewModel.onscreenSpeakers.count
		} else {
			if isPortraitOrientation {
				return 2
			} else {
				return viewModel.onscreenSpeakers.count >= 4 ? 4 : viewModel.onscreenSpeakers.count
			}
		}
	}

	private var columns: [GridItem] {
		[GridItem](
			repeating: GridItem(.flexible(), spacing: spacing),
			count: columnCount
		)
	}
	
	var body: some View {
		VStack {
			if viewModel.pages.isEmpty {
				Spacer()
			} else {
				GeometryReader { geometry in
					if !streamViewModel.spotlightUser.isEmpty && !presentationLayoutViewModel.isPresenting && !viewModel.isEnd {
						TabView {
							
							VStack {
								if let indexPath = viewModel.pages.indexPathOfParticipant(identity: streamViewModel.spotlightUser)  {
									SpeakerVideoView(
										speaker: $viewModel.pages[indexPath.section].speakerPage[indexPath.item],
										firebaseSpeaker: $streamManager.speakerArrayRealtime,
										showHostControls: role == "host",
										isOnSpotlight: true,
                                        isShowName: isShowName
									)
									.clipShape(RoundedRectangle(cornerRadius: 8))
									.padding(.top, 10)
									.padding([.horizontal, .bottom])
								}
                            }
                            
                            VStack {
                                if $viewModel.onscreenSpeakers.isEmpty {
                                    VStack {
                                        Spacer()
                                        
                                        Text(LocaleText.onlyYouOnRoom)
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                } else {
                                    
                                    ScrollView {
                                        LazyVGrid(columns: columns, spacing: spacing) {
                                            ForEach($viewModel.onscreenSpeakers, id: \.identity) { $participant in
                                                SpeakerVideoView(
                                                    speaker: $participant,
                                                    firebaseSpeaker: $streamManager.speakerArrayRealtime,
                                                    showHostControls: role == "host",
                                                    isOnSpotlight: false,
                                                    isShowName: isShowName
                                                )
                                                .frame(
                                                    height: UIDevice.current.userInterfaceIdiom == .pad ? 400 : 200
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                
                                            }
                                        }
                                        .padding([.horizontal, .bottom])
                                        .padding(.bottom)
                                        .padding(.top)
                                    }
                                    
                                }
                            }

						}
						.tabViewStyle(.page)

					} else {
                        TabView {
                            if presentationLayoutViewModel.isPresenting {
                                PresentationLayoutView(
                                    spacing: spacing,
                                    role: StateObservable.shared.twilioRole
                                )
                                .padding([.top, .horizontal])
                            }
                            
                            VStack {
                                if $viewModel.onscreenSpeakers.count <= 1 {
                                    VStack {
                                        ForEach($viewModel.onscreenSpeakers, id: \.identity) { $participant in
                                            SpeakerVideoView(
                                                speaker: $participant,
                                                firebaseSpeaker: $streamManager.speakerArrayRealtime,
                                                showHostControls: role == "host",
                                                isOnSpotlight: false,
                                                isShowName: isShowName
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                        }
                                    }
                                    .padding([.horizontal, .bottom])
                                    .padding(.bottom)
                                    .padding(.top)
                                } else {
                                    ScrollView {
                                        LazyVGrid(columns: columns, spacing: spacing) {
                                            ForEach($viewModel.onscreenSpeakers, id: \.identity) { $participant in
                                                SpeakerVideoView(
                                                    speaker: $participant,
                                                    firebaseSpeaker: $streamManager.speakerArrayRealtime,
                                                    showHostControls: role == "host",
                                                    isOnSpotlight: false,
                                                    isShowName: isShowName
                                                )
                                                .frame(
                                                    height: UIDevice.current.userInterfaceIdiom == .pad ? 400 : 200
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                
                                            }
                                        }
                                        .padding([.horizontal, .bottom])
                                        .padding(.bottom)
                                        .padding(.top)
                                    }
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                    }
				}
			}
		}
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.blue)
            UIPageControl.appearance().pageIndicatorTintColor = UIColor(.gray)

            let configuration = UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 32), scale: .small)
            UIPageControl.appearance().preferredIndicatorImage = UIImage(systemName: "minus", withConfiguration: configuration)
        }
        .onDisappear {
            UIPageControl.appearance().preferredIndicatorImage = nil
        }
	}
}


struct SpeakerGridView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			ForEach((1...6), id: \.self) { index in
                SpeakerGridView(speaker: SpeakerVideoViewModel(), spacing: 6, role: "speaker", isShowName: true)
			}
			.frame(width: 400, height: 700)
			
			ForEach((1...6), id: \.self) { index in
				SpeakerGridView(speaker: SpeakerVideoViewModel(), spacing: 6, role: "speaker", isShowName: true)
			}
		}
	}
}
