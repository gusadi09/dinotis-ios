//
//  ChipsView.swift
//  EmontirApps
//
//  Created by Gus Adi on 16/12/21.
//

import SwiftUI

struct ChipsView: View {
	@Binding var categoryList: [Categories]
	let geo: GeometryProxy
	var onTapped: ((String, Int) -> Void)
	
	var body: some View {
		var width = CGFloat.zero
		var height = CGFloat.zero
		
		GeometryReader { geo in
			ZStack(alignment: .topLeading, content: {
				ForEach(categoryList.indices, id: \.self) { idx in
					
					Button(action: {
						onTapped(categoryList[idx].name.orEmpty(), categoryList[idx].id.orZero())
					}, label: {
						Chips(titleKey: (categoryList[idx].name).orEmpty(), geo: geo)
							.foregroundColor(.white)
							.cornerRadius(12)
							.padding(5)
					})
					.alignmentGuide(.leading) { dimension in
						if abs(width - dimension.width) > geo.size.width {
							width = 0
							height -= dimension.height
						}
						
						let result = width
						if categoryList[idx].id == categoryList.last?.id {
							width = 0
						} else {
							width -= dimension.width
						}
						return result
					}
					.alignmentGuide(.top) { _ in
						let result = height
						if categoryList[idx].id == categoryList.last?.id {
							height = 0
						}
						return result
					}
				}
			})
			.scaledToFit()
			.frame(height: geo.size.width/4)
		}
	}
}

struct Chips: View {
	let titleKey: String
	let geo: GeometryProxy
	
	var body: some View {
		
		HStack {
			Text(titleKey)
				.font(.montserratSemiBold(size: UIDevice.current.userInterfaceIdiom == .pad ? 14 : 10))
		}
		.padding(5)
		.background(
			Image.Dinotis.categoryCardBackground
				.resizable()
				.frame(
					width: UIDevice.current.userInterfaceIdiom == .pad ? geo.size.height/8 : geo.size.height/10,
					height: UIDevice.current.userInterfaceIdiom == .pad ? geo.size.height/8 : geo.size.height/10
				)
		)
		.frame(
			width: UIDevice.current.userInterfaceIdiom == .pad ? geo.size.height/8 : geo.size.height/10,
			height: UIDevice.current.userInterfaceIdiom == .pad ? geo.size.height/8 : geo.size.height/10
		)
	}
}
