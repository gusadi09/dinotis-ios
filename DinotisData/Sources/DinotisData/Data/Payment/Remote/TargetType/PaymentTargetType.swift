//
//  File.swift
//  
//
//  Created by Garry on 02/02/23.
//

import Foundation
import Moya

public enum PaymentsTargetType {
	case getPaymentMethod
	case bookingPayment(BookingPaymentRequest)
	case coinPayment(CoinPaymentRequest)
	case promoCodeChecking(PromoCodeRequest)
    case extraFee(PaymentExtraFeeRequest)
}

extension PaymentsTargetType: DinotisTargetType, AccessTokenAuthorizable {
    var parameters: [String : Any] {
        switch self {
        case .extraFee(let body):
            return body.toJSON()
		case .getPaymentMethod:
			return [:]
		case .bookingPayment(let body):
			return body.toJSON()
		case .coinPayment(let body):
			return body.toJSON()
		case .promoCodeChecking(let body):
			return body.toJSON()
		}
    }
    
    public var headers: [String : String]? {
        return [:]
    }
    
    public var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .extraFee:
            return JSONEncoding.default
		case .getPaymentMethod:
			return URLEncoding.default
		case .bookingPayment(_):
			return JSONEncoding.default
		case .coinPayment(_):
			return JSONEncoding.default
		case .promoCodeChecking(_):
			return JSONEncoding.default
		}
    }
    
    public var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }
    
    public var path: String {
        switch self {
        case .extraFee:
            return "/bookings/extra-fee"
		case .getPaymentMethod:
			return "/payment-methods"
		case .bookingPayment(_):
			return "/bookings"
		case .coinPayment(_):
			return "/bookings/coin"
		case .promoCodeChecking(_):
			return "/voucher/check"
		}
    }
    
    public var method: Moya.Method {
        switch self {
        case .extraFee:
            return .post
		case .getPaymentMethod:
			return .get
		case .bookingPayment(_):
			return .post
		case .coinPayment(_):
			return .post
		case .promoCodeChecking(_):
			return .post
		}
    }
    
    public var sampleData: Data {
        switch self {
        case .extraFee(_):
            return PaymentExtraFeeResponse.sampleData
		case .getPaymentMethod:
			return PaymentMethodResponse.sampleData
		case .bookingPayment(_):
			return UserBookingData.sampleData
		case .coinPayment(_):
			return UserBookingData.sampleData
		case .promoCodeChecking(_):
			return PromoCodeResponse.sampleData
		}
    }
}

