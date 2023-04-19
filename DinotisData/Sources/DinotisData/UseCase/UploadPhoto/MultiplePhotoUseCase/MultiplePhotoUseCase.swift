//
//  File.swift
//  
//
//  Created by Gus Adi on 29/03/23.
//

import Foundation
import UIKit

public protocol MultiplePhotoUseCase {
    func execute(with images: [UIImage]) async -> Result<[String], Error>
}
