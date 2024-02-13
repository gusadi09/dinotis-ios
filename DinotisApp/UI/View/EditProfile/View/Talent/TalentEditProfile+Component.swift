//
//  TalentEditProfile+Component.swift
//  DinotisApp
//
//  Created by hilmy ghozy on 22/04/22.
//

import Foundation
import SwiftUINavigation
import SwiftUI
import DinotisData
import DinotisDesignSystem

extension TalentEditProfile {

	struct HighlightSection: View {

		var geo: GeometryProxy
        var cardWidth: CGFloat {
            (geo.size.width - 80) / 3 - 14
        }
        var cardHeight: CGFloat {
            cardWidth * 20 / 23
        }
        var grid: [GridItem] {
            Array(repeating: GridItem(.flexible(minimum: cardWidth)), count: 3)
        }

		@ObservedObject var viewModel: EditProfileViewModel

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizableText.galleryWithCounter(with: viewModel.userHighlightImageCount))
                    .font(.robotoMedium(size: 12))
                    .foregroundColor(.DinotisDefault.black1)
                
                LazyVGrid(columns: grid, spacing: 8) {
                    ForEach(viewModel.userHighlightsImage.indices, id: \.self) { index in
                        ImagePlaceholder(at: index)
                            .onDrag {
                                viewModel.draggedImage = viewModel.userHighlightsImage[index]
                                return NSItemProvider()
                            }
                            .onDrop(of: [.image], delegate: DropViewDelegate(destinationItem: viewModel.userHighlightsImage[index], viewModel: viewModel))
                            .sheet(isPresented: $viewModel.isShowPhotoLibraryHG[index]) {
                                ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.userHighlightsImage[index])
                                    .dynamicTypeSize(.large)
                            }
                    }
                    
                    if viewModel.userHighlightImageCount < 3 {
                        AddPhotoButton()
                    }
                }
                
                Text(LocalizableText.profileImageLimitationDesc)
                    .font(.robotoRegular(size: 12))
                    .foregroundColor(.DinotisDefault.primary)
            }
		}
        
        func ImagePlaceholder(at index: Int) -> some View {
            Group {
                if viewModel.userHighlightsImage[index] != UIImage() {
                    Button {
                        viewModel.isShowPhotoLibraryHG[index] = true
                    } label: {
                        Image(uiImage: viewModel.userHighlightsImage[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: cardWidth, height: cardHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .overlay(alignment: .topTrailing) {
                        Button {
                            viewModel.deleteHighlightImage(at: index)
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.DinotisDefault.black1)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(Color.DinotisDefault.lightPrimary)
                                )
                        }
                        .buttonStyle(.plain)
                        .offset(x: 14)
                    }
                }
            }
        }
        
        func AddPhotoButton() -> some View {
            Button {
                viewModel.isShowPhotoLibraryHG[viewModel.userHighlightImageCount] = true
            } label: {
                VStack(spacing: 8) {
                    Image.profileAddPhotoIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text(LocalizableText.addPhotoLabel)
                        .font(.robotoRegular(size: 14))
                        .foregroundColor(.DinotisDefault.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }
                .frame(width: cardWidth, height: cardHeight)
                .background(Color.DinotisDefault.lightPrimary)
                .cornerRadius(12)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .inset(by: 0.5)
                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $viewModel.isShowPhotoLibraryHG[viewModel.userHighlightImageCount]) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.userHighlightsImage[viewModel.userHighlightImageCount])
                    .dynamicTypeSize(.large)
            }
        }
	}
    
    struct DropViewDelegate: DropDelegate {
        let destinationItem: UIImage
        @ObservedObject var viewModel: EditProfileViewModel
        
        func dropUpdated(info: DropInfo) -> DropProposal? {
            return DropProposal(operation: .move)
        }
        
        func performDrop(info: DropInfo) -> Bool {
            viewModel.draggedImage = nil
            return true
        }
        
        func dropEntered(info: DropInfo) {
            if let draggedItem = viewModel.draggedImage {
                let fromIndex = viewModel.userHighlightsImage.firstIndex(of: draggedItem)
                if let fromIndex {
                    let toIndex = viewModel.userHighlightsImage.firstIndex(of: destinationItem)
                    if let toIndex, fromIndex != toIndex {
                        withAnimation {
                            self.viewModel.userHighlightsImage.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))
                        }
                    }
                }
            }
        }
    }
	
	struct ProfilePicture: View {
		
		@ObservedObject var viewModel: EditProfileViewModel
		
		var body: some View {
            Button(action: {
                viewModel.isShowPhotoLibrary.toggle()
            }, label: {
                ZStack(alignment: .bottomTrailing) {
                    if viewModel.image == UIImage() {
                        ProfileImageContainer(
                            profilePhoto: $viewModel.userPhoto,
                            name: $viewModel.name,
                            width: 86,
                            height: 86,
                            shape: RoundedRectangle(cornerRadius: 12)
                        )
                    } else {
                        Image(uiImage: viewModel.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 86, height: 86)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Image.studioPencilIcon
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .padding(6)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.DinotisDefault.primary)
                            )
                        .overlay {
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                        }
                        .offset(y: 8)
                }
            })
            .sheet(isPresented: $viewModel.isShowPhotoLibrary) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.image)
                    .dynamicTypeSize(.large)
            }
		}
	}
	
	struct ChipsProfession: View {
		
		@ObservedObject var viewModel: EditProfileViewModel
		@Binding var profesionSelect: [ProfessionData]
		var item: ProfessionData
		
		var body: some View {
			HStack {
				Text((item.profession?.name).orEmpty())
					.font(.robotoRegular(size: 12))
                    .foregroundColor(.DinotisDefault.primary)
				
				Image(systemName: "xmark.circle.fill")
					.resizable()
					.scaledToFit()
					.frame(height: 23)
                    .foregroundColor(.DinotisDefault.primary)
			}
			.minimumScaleFactor(0.6)
			.padding(4)
            .padding(.horizontal, 4)
			.background(Capsule().fill(Color.DinotisDefault.lightPrimary))
			.onTapGesture {
				profesionSelect.removeAll(where: { value in
					return value.professionId == item.professionId
				})
				
				self.viewModel.professionSelectID = []
				for item in profesionSelect {
					self.viewModel.professionSelectID.append((item.profession?.id).orZero())
				}
			}
		}
	}
	
	struct ChipsContentView: View {
		
		@ObservedObject var viewModel: EditProfileViewModel
		@Binding var profesionSelect: [ProfessionData]
		var geo: GeometryProxy
		
		var body: some View {
			var width = CGFloat.zero
			var height = CGFloat.zero
			return ZStack(alignment: .topLeading, content: {
				ForEach(profesionSelect, id:\.professionId) { item in
					ChipsProfession(viewModel: viewModel, profesionSelect: $profesionSelect, item: item)
						.padding(.all, 5)
						.alignmentGuide(.leading) { dimension in
							if (abs(width - dimension.width) >= geo.size.width/1.5) {
								width = 0
								height -= dimension.height
							}
							
							let result = width
							if let last = profesionSelect.last?.professionId {
								if item.professionId == last {
									width = 0
								} else {
									width -= dimension.width
								}
							}
							
							return result
						}
						.alignmentGuide(.top) { _ in
							
							let result = height
							if let last = profesionSelect.last?.professionId {
								if item.professionId == last {
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
