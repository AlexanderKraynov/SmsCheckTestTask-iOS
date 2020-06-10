import Foundation

protocol ApplicationService {
    func getFlags() -> [Country]

    func sendPhoneNumberAndId(phoneNumber: String, id: Int)
}
