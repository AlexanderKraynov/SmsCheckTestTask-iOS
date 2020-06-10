import Kingfisher
import UIKit

class MainViewController: UIViewController {
    private let imagePlaceholderUrl = URL(string: "https://app.surprizeme.ru/media/store/1186_i1KaYnj_8DuYTzc.jpg")
    private let sightPlaceholderName = "Arc de Triomphe"
    private let extraInfoPlaceholder = "Sign in to have an easier access to your tours. No password needed — we'll send you authorization code 😼"
    private var user = User(id: 1, name: "Anitta", phoneNumber: PhoneNumber(code: "+1", number: "720 505-50-00"), email: "")
    private let applicationService: ApplicationService = ApplicationServiceImpl()
    private var expanded = false
    private var activeField: UITextField?

    @IBOutlet private var sightImageView: UIImageView!
    @IBOutlet private var sightNameLabel: UILabel!
    @IBOutlet private var greetingsLabel: UILabel!
    @IBOutlet private var extraInfoLabel: UILabel!
    @IBOutlet private var countryPickerButton: UIButton!
    @IBOutlet private var countryCodeLabel: UILabel!
    @IBOutlet private var phoneNumberTextField: UITextField!
    @IBOutlet private var confirmButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var signInStackView: UIStackView!
    @IBOutlet private var signInButton: UIButton!
    @IBOutlet private var signInAnnotationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainView()
        setupCountryPickerButton()
        phoneNumberTextField.delegate = self
        setUpKeyboardGesture()
        registerForKeyboardNotifications()
    }

    @IBAction private func countryPickerButtonPressed(_ sender: UIButton) {
        dismissKeyboard()
        let viewController = CountryPickerViewController(nibName: "CountryPickerView", bundle: nil)
        self.present(viewController, animated: true, completion: nil)
    }

    @IBAction private func confirmButtonPressed(_ sender: UIButton) {
        dismissKeyboard()
        if !expanded {
            user.phoneNumber.number = phoneNumberTextField.text ?? ""
            user.phoneNumber.code = countryCodeLabel.text ?? ""
            applicationService.sendPhoneNumberAndId(phoneNumber: "\(user.phoneNumber.code)\(user.phoneNumber.number)", id: user.id)
            guard let viewController = UIStoryboard(
                name: String(describing: SmsCodeViewController.self),
                bundle: nil
            ).instantiateViewController(withIdentifier: String(describing: SmsCodeViewController.self)) as? SmsCodeViewController else {
                return
            }
            viewController.setup(with: user.phoneNumber.number)
            self.present(viewController, animated: true, completion: nil)
        }
    }

    @IBAction private func signInButtonPressed(_ sender: UIButton) {
        expanded = true
        signInStackView.isHidden = false
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 40 + signInStackView.frame.height)
        scrollView.setContentOffset(CGPoint(x: 0, y: 40 + signInStackView.frame.height), animated: true)
        signInAnnotationLabel.text = "or use another way to sign in"
        signInButton.setTitle("", for: .normal)
        confirmButton.setTitle("Confirm and get link", for: .normal)
        dismissKeyboard()
        phoneNumberTextField.textAlignment = .center
        phoneNumberTextField.text = ""
        phoneNumberTextField.placeholder = "your email"
        countryPickerButton.removeFromSuperview()
        countryCodeLabel.removeFromSuperview()
        phoneNumberTextField.keyboardType = .emailAddress
        phoneNumberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    }

    func setUpKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    func setupCountryPickerButton() {
        countryPickerButton.backgroundColor = .white
        countryPickerButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        countryPickerButton.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        countryPickerButton.layer.shadowOpacity = 1.0
        countryPickerButton.layer.shadowRadius = 2.0
        countryPickerButton.layer.masksToBounds = false
        countryPickerButton.layer.cornerRadius = 4.0
    }

    func setUpMainView() {
        phoneNumberTextField.text = "\(user.phoneNumber.number)"
        countryCodeLabel.text = "\(user.phoneNumber.code)"
        sightImageView.layer.cornerRadius = 15
        sightImageView.clipsToBounds = true
        sightImageView.kf.setImage(with: imagePlaceholderUrl)
        sightNameLabel.text = "\(sightPlaceholderName):\n Fast-Track and Audio Tour"
        greetingsLabel.text = "Hi, \(user.name)!"
        extraInfoLabel.text = extraInfoPlaceholder
        confirmButton.layer.cornerRadius = 10
        confirmButton.clipsToBounds = true
        signInStackView.isHidden = true
    }

    func setupCountry(flag: String, code: String) {
        countryPickerButton.setTitle(flag, for: .normal)
        countryCodeLabel.text = "+\(code)"
    }
}

// MARK: - UITextFieldDelegate

extension MainViewController: UITextFieldDelegate {
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification) {
        self.scrollView.isScrollEnabled = true
        let info = notification.userInfo
        let keyboardSize = (info?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize?.height ?? 0 + 200, right: 0.0)

        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets

        var aRect = self.view.frame
        aRect.size.height -= keyboardSize?.height ?? 0
        if let activeField = self.activeField {
            if !aRect.contains(activeField.frame.origin) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }

    @objc func keyboardWillBeHidden(notification: NSNotification) {
        let info = notification.userInfo
        let keyboardSize = (info?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -(keyboardSize?.height ?? 0) - 200, right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        textField.text = ""
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
