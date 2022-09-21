//
//  SpeakerGridView.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import SwiftUI

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
			return gridItemCount < 4 ? 1 : 2
		} else {
			if isPortraitOrientation {
				return gridItemCount < 4 ? 1 : 2
			} else {
				return (gridItemCount + gridItemCount % rowCount) / rowCount
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
								if let indexPath = viewModel.pages.indexPathOfParticipant(identity: streamViewModel.spotlightUser), let dataUser = $viewModel.pages[indexPath.section].speakerPage[indexPath.item] {
									SpeakerVideoView(
										speaker: dataUser,
										showHostControls: role == "host",
										isOnSpotlight: true
									)
									.clipShape(RoundedRectangle(cornerRadius: 8))
									.padding(.top, 10)
									.padding([.horizontal, .bottom])
								}
							}

							if let data = $viewModel.pages {
								if data.isEmpty {
									VStack {
										Spacer()

										Text(LocaleText.onlyYouOnRoom)
											.font(.montserratBold(size: 14))
											.foregroundColor(.white)

										Spacer()
									}
								} else {
									ForEach(data, id: \.identifier) { page in
										LazyVGrid(columns: columns, spacing: spacing) {
											ForEach(page.speakerPage, id: \.identity) { $participant in
													SpeakerVideoView(
														speaker: $participant,
														showHostControls: role == "host",
														isOnSpotlight: false
													)
													.frame(height: geometry.size.height / CGFloat(rowCount) - spacing)
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
							
							ForEach($viewModel.pages, id: \.identifier) { $page in
								LazyVGrid(columns: columns, spacing: spacing) {
									ForEach($page.speakerPage, id: \.identity) { $participant in
										SpeakerVideoView(
											speaker: $participant,
											showHostControls: role == "host",
											isOnSpotlight: false
										)
										.frame(height: geometry.size.height / CGFloat(rowCount) - spacing)
										.clipShape(RoundedRectangle(cornerRadius: 8))
									}
								}
								.padding(.top)
								.padding([.horizontal, .bottom])
								.padding(.bottom)
							}
						}
						.tabViewStyle(PageTabViewStyle())
					}
				}
			}
		}
	}
}


struct SpeakerGridView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			ForEach((1...6), id: \.self) { index in
				SpeakerGridView(speaker: SpeakerVideoViewModel(), spacing: 6, role: "speaker")
			}
			.frame(width: 400, height: 700)
			
			ForEach((1...6), id: \.self) { index in
				SpeakerGridView(speaker: SpeakerVideoViewModel(), spacing: 6, role: "speaker")
			}
		}
	}
}
