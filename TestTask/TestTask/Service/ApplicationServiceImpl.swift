import Foundation

class ApplicationServiceImpl: ApplicationService {
    private var serverUrl = "https://webhook.site/4e88daa3-ddc5-436e-9659-993660603103"

    func getFlags() -> [Country] {
        var countryList = [Country]()
        for code in NSLocale.isoCountryCodes {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id)
            let locale = NSLocale(localeIdentifier: id)
            let countryCode = locale.object(forKey: NSLocale.Key.countryCode)
            if name != nil {
                let model = Country(
                    countryCode: countryCode as? String,
                    extensionCode: NSLocale().extensionCode(countryCode: countryCode as? String),
                    name: name,
                    flag: String.flag(for: code)
                )
                countryList.append(model)
            }
        }
        return countryList
    }

    func sendPhoneNumberAndId(phoneNumber: String, id: Int) {
        guard let url = URL(string: serverUrl) else {
            return
        }
        let data: [String: Any] = ["id": id, "phone": phoneNumber]
        var request = URLRequest(url: url)
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
}
