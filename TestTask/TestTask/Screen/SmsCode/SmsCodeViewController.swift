import KKPinCodeTextField
import UIKit

class SmsCodeViewController: UIViewController {
    private var phoneNumber = ""

    @IBOutlet private var phoneNumberLabel: UILabel!
    @IBOutlet private var codeView: KKPinCodeTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberLabel.text = phoneNumber
        codeView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    @IBAction private func sendAgainButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func setup(with phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count == 4 {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
