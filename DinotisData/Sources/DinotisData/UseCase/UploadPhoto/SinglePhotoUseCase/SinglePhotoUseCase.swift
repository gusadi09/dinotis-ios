//
//  File.swift
//  
//
//  Created by Gus Adi on 29/03/23.
//

import Foundation
import UIKit

public protocol SinglePhotoUseCase {
    func execute(with image: UIImage) async -> Result<String, Error>
}
