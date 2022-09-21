//
//  CoinHistoryView.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/22.
//

import SwiftUI
import Introspect

struct CoinHistoryView: View {

	@ObservedObject var viewModel: CoinHistoryViewModel

	var body: some View {
		GeometryReader { geo in
			VStack {
				NavigationBarTitle()
					.alert(isPresented: $viewModel.isError) {
						Alert(
							title: Text(LocaleText.attention),
							message: Text(viewModel.errorText()),
							dismissButton: .default(Text(LocaleText.returnText))
						)
					}
					.onChange(of: viewModel.tabSelection) { _ in
						self.viewModel.coinHistoryData = []
						self.viewModel.historyQuery.take = 10
						self.viewModel.historyQuery.skip = 0
						self.viewModel.getCoinHistory()
					}

				VStack(spacing: 0) {
					TabSelectionBar(viewModel: viewModel)
						.alert(isPresented: $viewModel.isRefreshFailed) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text(LocaleText.sessionExpireText),
								dismissButton: .default(Text(LocaleText.returnText), action: {
									self.viewModel.routeBack()
								})
							)
						}

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
											.font(.montserratSemiBold(size: 14))
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
											if item.id.orZero() == (viewModel.coinHistoryData.last?.id).orZero() {
												self.viewModel.historyQuery.skip = self.viewModel.historyQuery.take
												self.viewModel.historyQuery.take += 10
												self.viewModel.getCoinHistory()
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
											.font(.montserratSemiBold(size: 14))
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
											if item.id.orZero() == (viewModel.coinHistoryData.filter({ item in
												!(item.isOut ?? false)
											}).last?.id).orZero() {
												self.viewModel.historyQuery.skip = self.viewModel.historyQuery.take
												self.viewModel.historyQuery.take += 10
												self.viewModel.getCoinHistory()
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
											.font(.montserratSemiBold(size: 14))
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
											if item.id.orZero() == (viewModel.coinHistoryData.filter({ item in
												item.isOut ?? false
											}).last?.id).orZero() {
												self.viewModel.historyQuery.skip = self.viewModel.historyQuery.take
												self.viewModel.historyQuery.take += 10
												self.viewModel.getCoinHistory()
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
						.font(.montserratBold(size: 14))
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
								.montserratBold(size: 14) :
									.montserratRegular(size: 14))
							.foregroundColor(.black)
							.lineLimit(2)
							.minimumScaleFactor(0.8)

						Capsule()
							.frame(height: 2)
							.isHidden(!(self.viewModel.tabSelection == LocaleText.allText))
							.foregroundColor(.primaryViolet)
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
								.montserratBold(size: 14) :
									.montserratRegular(size: 14))
							.foregroundColor(.black)
							.lineLimit(2)
							.minimumScaleFactor(0.8)

						Capsule()
							.frame(height: 2)
							.isHidden(!(self.viewModel.tabSelection == LocaleText.coinHistoryCoinIn))
							.foregroundColor(.primaryViolet)
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
								.montserratBold(size: 14) :
									.montserratRegular(size: 14))
							.foregroundColor(.black)
							.lineLimit(2)
							.minimumScaleFactor(0.8)

						Capsule()
							.frame(height: 2)
							.isHidden(!(self.viewModel.tabSelection == LocaleText.coinHistoryCoinOut))
							.foregroundColor(.primaryViolet)
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
		CoinHistoryView(viewModel: CoinHistoryViewModel(backToHome: {}, backToRoot: {}))
	}
}
