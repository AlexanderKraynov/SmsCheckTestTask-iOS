import UIKit

class CountryPickerViewController: UIViewController {
    private var countryList = [Country]()
    private var filteredCountryList = [Country]()
    private var countryDictionary = [String: [Country]]()
    private var countrySectionTitles = [String]()
    private var applicationService: ApplicationService = ApplicationServiceImpl()
    @IBOutlet private var handleArea: UIView!
    @IBOutlet private var handleStrip: UIView!
    @IBOutlet private var mainView: UIView!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupData()
        setUpSearchBar()
        roundCorners(view: mainView, cornerRadius: 20)
        roundCorners(view: handleStrip, cornerRadius: 2, onlyTop: false)
    }

    @IBAction private func backButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func roundCorners(view: UIView, cornerRadius: Double, onlyTop: Bool = true) {
        view.layer.cornerRadius = CGFloat(cornerRadius)
        view.clipsToBounds = true
        if onlyTop {
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }

    func setUpSearchBar() {
        searchBar.delegate = self
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionIndexColor = .black
    }

    func updateSections() {
        countryDictionary.removeAll()
        countrySectionTitles.removeAll()
        for country in filteredCountryList {
            let countryKey = String(country.name?.prefix(1) ?? "")
            if var countryValues = countryDictionary[countryKey] {
                countryValues.append(country)
                countryDictionary[countryKey] = countryValues
            } else {
                countryDictionary[countryKey] = [country]
            }
        }
        countrySectionTitles = [String](countryDictionary.keys)
        countrySectionTitles = countrySectionTitles.sorted { $0 < $1 }
    }

    func setupData() {
        countryList = applicationService.getFlags()
        filteredCountryList = countryList
        updateSections()
        self.tableView.reloadData()
    }
}
// MARK: - UITableViewDelegate
extension CountryPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateSections()
        let countryKey = countrySectionTitles[section]
        if let countryValues = countryDictionary[countryKey] {
            return countryValues.count
        }
        return 0
    }

    //swiftlint:disable:next discouraged_optional_collection
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        countrySectionTitles
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .white
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        countrySectionTitles.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let main = presentingViewController as? MainViewController else {
            return
        }
        guard let country = countryDictionary[countrySectionTitles[indexPath.section]]?[indexPath.row] else {
            return
        }
        main.setupCountry(flag: country.flag ?? "", code: country.extensionCode ?? "")
        tableView.deselectRow(at: indexPath, animated: true)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension CountryPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Bundle.main.loadNibNamed("CountryCell", owner: self, options: nil)?.first as? CountryCell else {
            return UITableViewCell()
        }
        let countryKey = countrySectionTitles[indexPath.section]
        if let countryValues = countryDictionary[countryKey] {
            cell.setup(with: countryValues[indexPath.row])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        countrySectionTitles[section]
    }
}

// MARK: - UISearchBarDelegate

extension CountryPickerViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text =  ""
        searchBar.endEditing(true)
        self.filteredCountryList = self.countryList
        self.updateSections()
        self.tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredCountryList = searchText.isEmpty ? countryList : countryList.filter { model -> Bool in
            guard let name = model.name, let phoneCode = model.extensionCode else {
                return false
            }
            return (name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil) || phoneCode.contains(searchText)
        }
        self.updateSections()
        self.tableView.reloadData()
    }
}
