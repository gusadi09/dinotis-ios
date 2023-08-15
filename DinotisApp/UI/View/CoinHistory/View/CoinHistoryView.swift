//
//  CoinHistoryView.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/22.
//

import DinotisDesignSystem
import Introspect
import SwiftUI

struct CoinHistoryView: View {

	@ObservedObject var viewModel: CoinHistoryViewModel

	var body: some View {
		GeometryReader { geo in
			VStack {
				NavigationBarTitle()
					.onChange(of: viewModel.tabSelection) { _ in
						Task {
							self.viewModel.coinHistoryData = []
							self.viewModel.historyQuery.take = 10
							self.viewModel.historyQuery.skip = 0
							await self.viewModel.getCoinHistory()
						}
					}

				VStack(spacing: 0) {
					TabSelectionBar(viewModel: viewModel)

					TabView(selection: $viewModel.tabSelection) {
						DinotisList { view in
							view.separatorStyle = viewModel.coinHistoryData.isEmpty ? .none : .singleLine
							viewModel.use(for: view) { refresh in
								DispatchQueue.main.async {
									refresh.endRefreshing()
								}

							}
						} content: {
							if viewModel.coinHistoryData.isEmpty {
								HStack {

									Spacer()

									VStack(spacing: 15) {

										if viewModel.isLoading {
											HStack {
												Spacer()

												ProgressView()
													.progressViewStyle(.circular)

												Spacer()
											}
										}

										Image.Dinotis.emptyCoinIllustration
											.resizable()
											.scaledToFit()
											.frame(height: geo.size.width/3)

										Text(LocaleText.coinHistoryEmptyText)
											.font(.robotoMedium(size: 14))
											.multilineTextAlignment(.center)
											.foregroundColor(.black)
									}

									Spacer()

								}
								.padding()
							} else {
								ForEach(viewModel.coinHistoryData, id: \.id) { item in
									CoinHistoryCard(item: item)
										.padding(.vertical, 10)
										.onAppear {
											Task {
												if item.id.orZero() == (viewModel.coinHistoryData.last?.id).orZero() {
													self.viewModel.historyQuery.skip = self.viewModel.historyQuery.take
													self.viewModel.historyQuery.take += 10
													await self.viewModel.getCoinHistory()
												}
											}
										}
								}

								if viewModel.isLoading {
									HStack {
										Spacer()

										ProgressView()
											.progressViewStyle(.circular)

										Spacer()
									}
								}
							}
						}
						.tag(LocaleText.allText)
						.navigationBarTitle(Text(""))
						.navigationBarHidden(true)

						DinotisList { view in
							view.separatorStyle = viewModel.coinHistoryData.filter({ item in
								!(item.isOut ?? false)
							}).isEmpty ? .none : .singleLine
							viewModel.use(for: view) { refresh in
								DispatchQueue.main.async {
									refresh.endRefreshing()
								}

							}
						} content: {
							if viewModel.coinHistoryData.filter({ item in
								!(item.isOut ?? false)
							}).isEmpty {
								HStack {

									Spacer()

									VStack(spacing: 15) {
										if viewModel.isLoading {
											HStack {
												Spacer()

												ProgressView()
													.progressViewStyle(.circular)

												Spacer()
											}
										}

										Image.Dinotis.emptyCoinIllustration
											.resizable()
											.scaledToFit()
											.frame(height: geo.size.width/3)

										Text(LocaleText.coinHistoryEmptyText)
											.font(.robotoMedium(size: 14))
											.multilineTextAlignment(.center)
											.foregroundColor(.black)
									}

									Spacer()

								}
								.padding()
							} else {
								ForEach(viewModel.coinHistoryData.filter({ item in
									!(item.isOut ?? false)
								}), id: \.id) { item in
									CoinHistoryCard(item: item)
										.padding(.vertical, 10)
										.onAppear {
											Task {
												if item.id.orZero() == (viewModel.coinHistoryData.filter({ item in
													!(item.isOut ?? false)
												}).last?.id).orZero() {
													self.viewModel.historyQuery.skip = self.viewModel.historyQuery.take
													self.viewModel.historyQuery.take += 10
													await self.viewModel.getCoinHistory()
												}
											}
										}
								}

								if viewModel.isLoading {
									HStack {
										Spacer()

										ProgressView()
											.progressViewStyle(.circular)

										Spacer()
									}
								}
							}
						}
						.tag(LocaleText.coinHistoryCoinIn)
						.navigationBarTitle(Text(""))
						.navigationBarHidden(true)

						DinotisList { view in
							view.separatorStyle = viewModel.coinHistoryData.filter({ item in
								item.isOut ?? false
							}).isEmpty ? .none : .singleLine
							viewModel.use(for: view) { refresh in
								DispatchQueue.main.async {
									refresh.endRefreshing()
								}

							}
						} content: {
							if viewModel.coinHistoryData.filter({ item in
								item.isOut ?? false
							}).isEmpty {
								HStack {

									Spacer()

									VStack(spacing: 15) {
										if viewModel.isLoading {
											HStack {
												Spacer()

												ProgressView()
													.progressViewStyle(.circular)

												Spacer()
											}
										}

										Image.Dinotis.emptyCoinIllustration
											.resizable()
											.scaledToFit()
											.frame(height: geo.size.width/3)

										Text(LocaleText.coinHistoryEmptyText)
											.font(.robotoMedium(size: 14))
											.multilineTextAlignment(.center)
											.foregroundColor(.black)
									}

									Spacer()

								}
								.padding()
							} else {
								ForEach(viewModel.coinHistoryData.filter({ item in
									item.isOut ?? false
								}), id: \.id) { item in
									CoinHistoryCard(item: item)
										.padding(.vertical, 10)
										.onAppear {
											Task {
												if item.id.orZero() == (viewModel.coinHistoryData.filter({ item in
													item.isOut ?? false
												}).last?.id).orZero() {
													self.viewModel.historyQuery.skip = self.viewModel.historyQuery.take
													self.viewModel.historyQuery.take += 10
													await self.viewModel.getCoinHistory()
												}
											}
										}
								}

								if viewModel.isLoading {
									HStack {
										Spacer()

										ProgressView()
											.progressViewStyle(.circular)

										Spacer()
									}
								}
							}
						}
						.tag(LocaleText.coinHistoryCoinOut)
						.navigationBarTitle(Text(""))
						.navigationBarHidden(true)
					}
					.tabViewStyle(.page(indexDisplayMode: .never))
					.edgesIgnoringSafeArea(.bottom)
				}
				.padding(.top, 10)
			}
			.navigationBarTitle(Text(""))
			.navigationBarHidden(true)
			.onAppear {
				self.viewModel.onAppeared()
			}
			.onDisappear {
				self.viewModel.historyQuery.take = 10
				self.viewModel.historyQuery.skip = 0
			}
		}
    .dinotisAlert(
      isPresent: $viewModel.isShowAlert,
      title: viewModel.alert.title,
      isError: viewModel.alert.isError,
      message: viewModel.alert.message,
      primaryButton: viewModel.alert.primaryButton,
      secondaryButton: viewModel.alert.secondaryButton
    )
	}
}

extension CoinHistoryView {
	struct NavigationBarTitle: View {

		@Environment(\.presentationMode) var presentationMode

		var body: some View {
			ZStack {
				HStack {
					Spacer()

					Text(LocaleText.coinHistoryTitle)
						.font(.robotoBold(size: 14))
						.foregroundColor(.black)

					Spacer()
				}

				HStack {
					Button(action: {
						self.presentationMode.wrappedValue.dismiss()

					}, label: {
						Image.Dinotis.arrowBackIcon
							.padding()
					})
					.background(Color.white)
					.clipShape(Circle())
					.shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 0)

					Spacer()
				}
			}
			.padding([.horizontal, .bottom])
		}
	}

	struct TabSelectionBar: View {

		@ObservedObject var viewModel: CoinHistoryViewModel

		var body: some View {
			HStack(alignment: .bottom, spacing: 0) {

				Button(action: {
					self.viewModel.tabSelection = LocaleText.allText
				}) {

					VStack {
						Text(LocaleText.allText)
							.padding(.top, 10)
							.padding(.bottom, 6)
							.padding(.horizontal)
							.font(self.viewModel.tabSelection == LocaleText.allText ?
								.robotoBold(size: 14) :
									.robotoRegular(size: 14))
							.foregroundColor(.black)
							.lineLimit(2)
							.minimumScaleFactor(0.8)

						Capsule()
							.frame(height: 2)
							.isHidden(!(self.viewModel.tabSelection == LocaleText.allText))
							.foregroundColor(.DinotisDefault.primary)
							.padding(.horizontal)

					}
					.background(Color(.white))
					.clipShape(Rectangle())

				}

				Button(action: {
					self.viewModel.tabSelection = LocaleText.coinHistoryCoinIn
				}) {

					VStack {
						Text(LocaleText.coinHistoryCoinIn)
							.padding(.top, 10)
							.padding(.bottom, 6)
							.padding(.horizontal)
							.font(self.viewModel.tabSelection == LocaleText.coinHistoryCoinIn ?
								.robotoBold(size: 14) :
									.robotoRegular(size: 14))
							.foregroundColor(.black)
							.lineLimit(2)
							.minimumScaleFactor(0.8)

						Capsule()
							.frame(height: 2)
							.isHidden(!(self.viewModel.tabSelection == LocaleText.coinHistoryCoinIn))
							.foregroundColor(.DinotisDefault.primary)
							.padding(.horizontal)

					}
					.background(Color(.white))
					.clipShape(Rectangle())

				}

				Button(action: {
					self.viewModel.tabSelection = LocaleText.coinHistoryCoinOut
				}) {

					VStack {
						Text(LocaleText.coinHistoryCoinOut)
							.padding(.top, 10)
							.padding(.bottom, 6)
							.padding(.horizontal)
							.font(self.viewModel.tabSelection == LocaleText.coinHistoryCoinOut ?
								.robotoBold(size: 14) :
									.robotoRegular(size: 14))
							.foregroundColor(.black)
							.lineLimit(2)
							.minimumScaleFactor(0.8)

						Capsule()
							.frame(height: 2)
							.isHidden(!(self.viewModel.tabSelection == LocaleText.coinHistoryCoinOut))
							.foregroundColor(.DinotisDefault.primary)
							.padding(.horizontal)

					}
					.background(Color(.white))
					.clipShape(Rectangle())

				}

			}
			.padding(.top, 5)
			.background(Color.white.shadow(color: Color.dinotisShadow.opacity(0.08), radius: 30, x: 0.0, y: 0.0))
		}
	}
}

struct CoinHistoryView_Previews: PreviewProvider {
	static var previews: some View {
		CoinHistoryView(viewModel: CoinHistoryViewModel(backToHome: {}))
	}
}
