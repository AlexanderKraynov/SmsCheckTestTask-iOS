import KKPinCodeTextField
import UIKit

class SmsCodeViewController: UIViewController {
    private var phoneNumber = ""
    @IBOutlet private var phoneNumberLabel: UILabel!
    @IBOutlet private var codeView: KKPinCodeTextField!
    @IBAction func SendAgainButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }

    func setup(with phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }

    override func viewDidLoad() {
        phoneNumberLabel.text = phoneNumber
        codeView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count == 4 {
            self.presentingViewController?.dismiss(animated: true, completion:nil)
        }
    }
}

