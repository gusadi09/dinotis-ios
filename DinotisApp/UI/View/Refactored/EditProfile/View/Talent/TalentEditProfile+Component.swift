//
//  TalentEditProfile+Component.swift
//  DinotisApp
//
//  Created by hilmy ghozy on 22/04/22.
//

import Foundation
import SwiftUINavigation
import SwiftUI

extension TalentEditProfile {

	struct HighlightSection: View {

		var geo: GeometryProxy

		@ObservedObject var viewModel: EditProfileViewModel

		var body: some View {
			VStack(spacing: 30) {
				Text(LocaleText.highlightTitle)
					.font(.montserratMedium(size: 12))
					.foregroundColor(.black)
					.multilineTextAlignment(.center)

				HStack(alignment: .center, spacing: 15) {

					Spacer()

					ForEach((viewModel.userHighlightsImage).indices, id: \.self) { item in
						VStack {
							Button(action: {
								viewModel.isShowPhotoLibraryHG[item].toggle()
							}, label: {
								ZStack(alignment: .bottomTrailing) {
									if viewModel.userHighlightsImage[item] == UIImage() {
										HStack {
											Spacer()
										Image(systemName: "plus")
											.resizable()
											.scaledToFit()
											.frame(height: 20)
											.foregroundColor(.primaryViolet)
											.padding()

											Spacer()
										}
										.scaledToFit()
										.frame(height: (geo.size.width/2)/3)
											.background(
												Circle()
													.frame(height: (geo.size.width/2)/3)
													.foregroundColor(.secondaryViolet)
											)
											.overlay(
												Circle()
													.stroke(Color.primaryViolet, lineWidth: 1)
													.frame(height: (geo.size.width/2)/3)
											)

									} else {
										Image(uiImage: viewModel.userHighlightsImage[item])
											.resizable()
											.scaledToFill()
											.frame(width: (geo.size.width/2)/3, height: (geo.size.width/2)/3)
											.clipShape(Circle())
									}

									if viewModel.userHighlightsImage[item] != UIImage() {
										Image.Dinotis.editPhotoIcon
											.resizable()
											.scaledToFit()
											.frame(height: 24)
											.clipShape(Circle())
									}
								}
							})
							.sheet(isPresented: $viewModel.isShowPhotoLibraryHG[item]) {
								ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.userHighlightsImage[item])
							}
							.alert(isPresented: $viewModel.isError) {
								Alert(
									title: Text(LocaleText.attention),
									message: Text((viewModel.error?.errorDescription).orEmpty()),
									dismissButton: .default(Text(LocaleText.returnText))
								)
							}

							Text("\(LocaleText.photo) \(item+1)")
								.font(.montserratRegular(size: 12))
								.foregroundColor(.black)
						}
					}

					Spacer()
				}

				Text(LocaleText.highlightNote)
					.multilineTextAlignment(.center)
					.font(.montserratRegular(size: 12))
					.foregroundColor(.black)

			}
			.padding()
			.overlay(
				RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
			)
		}
	}

	struct TitleHeader: View {

		@ObservedObject var viewModel: EditProfileViewModel
		@Environment(\.presentationMode) var presentationMode
		
		var body: some View {
			HStack {
				Spacer()
				Text(LocaleText.editProfileTitle)
					.font(Font.custom(FontManager.Montserrat.bold, size: 14))
					.foregroundColor(.black)
					.alert(isPresented: $viewModel.isSuccessUpdate) {
						Alert(
							title: Text(LocaleText.successTitle),
							message: Text(LocaleText.successUpdateAccount),
							dismissButton: .default(Text(LocaleText.returnText), action: {

								presentationMode.wrappedValue.dismiss()
							}))
					}

				Spacer()
			}
			.padding(.top)
			.padding()
		}
	}
	
	struct ProfilePicture: View {
		
		@ObservedObject var viewModel: EditProfileViewModel
		
		var body: some View {
			
			HStack(alignment: .center) {
				VStack {
					Text(LocaleText.photoProfile)
						.font(.montserratSemiBold(size: 12))
						.foregroundColor(.black)
					
					Button(action: {
						viewModel.isShowPhotoLibrary.toggle()
					}, label: {
						ZStack(alignment: .bottomTrailing) {
							if viewModel.image == UIImage() {
								ProfileImageContainer(
									profilePhoto: $viewModel.userPhoto,
									name: $viewModel.name,
									width: 75,
									height: 75
								)
								
							} else {
								Image(uiImage: viewModel.image)
									.resizable()
									.scaledToFill()
									.frame(width: 75, height: 75)
									.clipShape(Circle())
							}
							
							Image.Dinotis.editPhotoIcon
								.resizable()
								.scaledToFit()
								.frame(height: 24)
								.clipShape(Circle())
						}
					})
					.sheet(isPresented: $viewModel.isShowPhotoLibrary) {
						ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.image)
					}
					.alert(isPresented: $viewModel.isError) {
						Alert(
							title: Text(LocaleText.attention),
							message: Text((viewModel.error?.errorDescription).orEmpty()),
							dismissButton: .default(Text(LocaleText.returnText))
						)
					}
					Spacer()
				}
			}
		}
	}
	
	struct ChipsProfession: View {
		
		@ObservedObject var viewModel: EditProfileViewModel
		@Binding var profesionSelect: [ProfessionElement]
		var item: ProfessionElement
		
		var body: some View {
			HStack {
				Text(item.profession.name)
					.font(.montserratRegular(size: 12))
				
				Image(systemName: "xmark")
					.resizable()
					.scaledToFit()
					.frame(height: 10)
			}
			.minimumScaleFactor(0.6)
			.padding(5)
			.background(Color(.systemGray5))
			.cornerRadius(5)
			.onTapGesture {
				profesionSelect.removeAll(where: { value in
					return value.professionID == item.professionID
				})
				
				self.viewModel.professionSelectID = []
				for item in profesionSelect {
					self.viewModel.professionSelectID.append(item.profession.id)
				}
			}
		}
	}
	
	struct ChipsContentView: View {
		
		@ObservedObject var viewModel: EditProfileViewModel
		@Binding var profesionSelect: [ProfessionElement]
		var geo: GeometryProxy
		
		var body: some View {
			var width = CGFloat.zero
			var height = CGFloat.zero
			return ZStack(alignment: .topLeading, content: {
				ForEach(profesionSelect, id:\.professionID) { item in
					ChipsProfession(viewModel: viewModel, profesionSelect: $profesionSelect, item: item)
						.padding(.all, 5)
						.alignmentGuide(.leading) { dimension in
							if (abs(width - dimension.width) >= geo.size.width/1.5) {
								width = 0
								height -= dimension.height
							}
							
							let result = width
							if let last = profesionSelect.last?.professionID {
								if item.professionID == last {
									width = 0
								} else {
									width -= dimension.width
								}
							}
							
							return result
						}
						.alignmentGuide(.top) { _ in
							
							let result = height
							if let last = profesionSelect.last?.professionID {
								if item.professionID == last {
									height = 0
								}
							}
							
							return result
						}
				}
				
			})
			.padding(.all, 8)
			.frame(width: geo.size.width/2, alignment: .leading)
			.fixedSize()
		}
	}
}
