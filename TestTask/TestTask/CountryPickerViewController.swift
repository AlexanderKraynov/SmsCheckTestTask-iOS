import UIKit

class CountryPickerViewController: UIViewController {
    var countryList = [Country]()
    var filteredCountryList = [Country]()
    var countryDictionary = [String: [Country]]()
    var countrySectionTitles = [String]()
    @IBOutlet var handleArea: UIView!
    @IBOutlet private var handleStrip: UIView!
    @IBOutlet private var mainView: UIView!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupData()
        searchBar.delegate = self
        roundCorners(view: mainView, cornerRadius: 20)
        roundCorners(view: handleStrip, cornerRadius: 2, onlyTop: false)
    }
    
    func roundCorners(view: UIView, cornerRadius: Double, onlyTop: Bool = true) {
        view.layer.cornerRadius = CGFloat(cornerRadius)
        view.clipsToBounds = true
        if onlyTop {
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
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
        countrySectionTitles = countrySectionTitles.sorted(by: {$0 < $1})
    }
    
    func setupData() {
        for code in NSLocale.isoCountryCodes {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id)
            let locale = NSLocale.init(localeIdentifier: id)
            let countryCode = locale.object(forKey: NSLocale.Key.countryCode)
            
            if name != nil {
                let model = Country()
                model.name = name
                model.countryCode = countryCode as? String
                model.flag = String.flag(for: code)
                model.extensionCode = NSLocale().extensionCode(countryCode: model.countryCode)
                countryList.append(model)
            }
        }
        filteredCountryList = countryList
        updateSections()
        self.tableView.reloadData()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        let main =  self.parent as! MainViewController
        main.animateTransitionIfNeeded(state: main.nextState, duration: 0.9)
    }
}

extension CountryPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateSections()
        let countryKey = countrySectionTitles[section]
        if let countryValues = countryDictionary[countryKey] {
            return countryValues.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return countrySectionTitles[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return countrySectionTitles
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("CountryCell", owner: self, options: nil)?.first as! CountryCell
        let countryKey = countrySectionTitles[indexPath.section]
        if let countryValues = countryDictionary[countryKey] {
            cell.setup(with: countryValues[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .white
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        countrySectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let main =  self.parent as! MainViewController
        guard let country = countryDictionary[countrySectionTitles[indexPath.section]]?[indexPath.row] else {
            return
        }
        main.setupCountry(flag: country.flag ?? "", code: country.extensionCode ?? "")
        tableView.deselectRow(at: indexPath, animated: true)
        main.animateTransitionIfNeeded(state: main.nextState, duration: 0.9)
    }
}

extension CountryPickerViewController : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text =  ""
        searchBar.endEditing(true)
        self.filteredCountryList = self.countryList
        self.updateSections()
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredCountryList = searchText.isEmpty ? countryList : countryList.filter({ (model) -> Bool in
            return model.name!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        self.updateSections()
        self.tableView.reloadData()
    }
}
