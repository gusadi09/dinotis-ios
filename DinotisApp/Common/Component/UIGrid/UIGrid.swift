//
//  UIGrid.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/03/22.
//

import SwiftUI

struct UIGrid<Content: View>: View {
	
	private let columns: Int
	
	private var list: [[Categories]] = []
	
	private let content: (Categories) -> Content
	
	init(columns: Int, list: [Categories], @ViewBuilder content:@escaping (Categories) -> Content) {
		self.columns = columns
		self.content = content
		self.setupList(list)
	}
	
	var body: some View {
		GeometryReader { geo in
			VStack {
				ForEach(self.list.indices, id: \.self) { i  in
					HStack {
						ForEach(self.list[i], id: \.id) { object in
							
							self.content(object)
								.frame(width: abs((geo.size.width - 40)/CGFloat(columns)))
						}
					}
					.padding(.horizontal)
				}
			}
			.frame(width: geo.size.width)
		}
		
	}
	
	private mutating func setupList(_ list: [Categories]) {
		var column = 0
		var columnIndex = 0
		
		for object in list {
			if columnIndex < self.columns {
				if columnIndex == 0 {
					self.list.insert([object], at: column)
					columnIndex += 1
				} else {
					self.list[column].append(object)
					columnIndex += 1
				}
			} else {
				column += 1
				self.list.insert([object], at: column)
				columnIndex = 1
			}
		}
	}
}
