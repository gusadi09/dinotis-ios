//
//  File.swift
//  
//
//  Created by Garry on 28/01/23.
//

import Foundation

public enum DateFormat: String {
    case utc = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    case utcV2 = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case ddMMMyyyy = "dd MMM yyyy"
    case yyyyMMdd = "yyyy-MM-dd"
    case ddMMMMyyyy = "dd MMMM yyyy"
    case ddMMMyyyyHHmm = "dd MMM yyyy, HH:mm"
    case EEEEddMMMMyyyy = "EEEE, dd MMMM yyyy"
    case HHmm = "HH.mm"
    case HHmmss = "HH:mm:ss"
    case slashddMMyyyy = "dd / MM / yyyy"
    case ddMMyyyyHHmm = "dd/MM/yyyy HH:mm"
    case negotiationBubbleChat = "HH:mm - dd MMMM yyyy"
    case EEEEddMMMyyyHHmm = "EEEE, dd MMM yyyy HH:mm"
}
