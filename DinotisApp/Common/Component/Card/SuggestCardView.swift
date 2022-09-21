//
//  SuggestCardView.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/08/21.
//

import SwiftUI

struct SuggestCardView: View {
	@State var title: String
	@State var selected: Bool
	var body: some View {
		Button(action: {
			selected.toggle()
		}, label: {
			Text(title)
				.font(Font.custom(FontManager.Montserrat.regular, size: 14))
				.foregroundColor(.black)
				.padding(.horizontal)
				.padding(.vertical, 15)
				.background(selected ? Color("btn-color-1") : Color.gray.opacity(0.2))
				.cornerRadius(8)
		})
		.overlay(
			RoundedRectangle(cornerRadius: 8)
				.stroke(selected ? Color("btn-stroke-1") : Color.gray.opacity(0.5), lineWidth: 1.0)
		)
	}
}

struct SuggestCardView_Previews: PreviewProvider {
	static var previews: some View {
		SuggestCardView(title: "TEst", selected: false)
	}
}
