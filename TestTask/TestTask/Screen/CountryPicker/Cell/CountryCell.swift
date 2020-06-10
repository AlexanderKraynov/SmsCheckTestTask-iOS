import UIKit

class CountryCell: UITableViewCell {
    @IBOutlet private var countryLabel: UILabel!

    func setup(with country: Country) {
        countryLabel.text = "\(country.flag ?? "")  \(country.name ?? "")  (+\(country.extensionCode ?? ""))"
    }
}
