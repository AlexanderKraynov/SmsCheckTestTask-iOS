import Kingfisher
import UIKit

class MainViewController: UIViewController {
    private var imagePlaceholderUrl = URL(string:"https://app.surprizeme.ru/media/store/1186_i1KaYnj_8DuYTzc.jpg")
    private var sightPlaceholderName = "Arc de Triomphe"
    private var extraInfoPlaceholder = "Sign in to have an easier access to your tours. No password needed — we'll send you authorization code 😼"
    
    enum CountryPickerState {
        case expanded
        case collapsed
    }
    var user = User(id: 1, name: "Anitta", phoneNumber: PhoneNumber(code: "+1",number: "720 505-50-00"), email: "")
    var pickerIsVisible = false
    var nextState: CountryPickerState {
        return pickerIsVisible ? .collapsed : .expanded
    }
    private var countryPickerViewController: CountryPickerViewController!
    private var visualEffectView: UIVisualEffectView!
    let countryPickerHeight: CGFloat = 600
    let countryPickerHandleAreaHeight: CGFloat = 20
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    @IBOutlet private var sightImageView: UIImageView!
    @IBOutlet private var sightNameLabel: UILabel!
    @IBOutlet private var greetingsLabel: UILabel!
    @IBOutlet private var extraInfoLabel: UILabel!
    @IBOutlet private var countryPickerButton: UIButton!
    @IBOutlet private var countryCodeLabel:UILabel!
    @IBOutlet private var phoneNumberTextField:UITextField!
    @IBOutlet private var confirmButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    var activeField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainView()
        setupCountryPickerButton()
        setUpCounrtyPicker()
        phoneNumberTextField.delegate = self
        setUpKeyboardGesture()
        registerForKeyboardNotifications()
    }
    
    func setUpKeyboardGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func setupCountryPickerButton() {
        countryPickerButton.setImage(UIImage(named: "Globe"), for: [])
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
    }
    
    func setUpCounrtyPicker() {
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        countryPickerViewController = CountryPickerViewController(nibName: "CountryPickerView", bundle: nil)
        self.addChild(countryPickerViewController)
        self.view.addSubview(countryPickerViewController.view)
        countryPickerViewController.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.bounds.width, height: countryPickerHeight)
        countryPickerViewController.view.clipsToBounds = true
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCountryPickerPan(recognizer:)))
        countryPickerViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
        visualEffectView.isUserInteractionEnabled = false
    }
    
    func disableCountryPicker() {
        self.visualEffectView.removeFromSuperview()
        self.countryPickerViewController.view.removeFromSuperview()
        self.countryPickerViewController.removeFromParent()
    }
    
    @objc func handleCountryPickerPan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            let translation = recognizer.translation(in: self.countryPickerViewController.handleArea)
            var fractionCompleted = translation.y / countryPickerHeight
            fractionCompleted = pickerIsVisible ? fractionCompleted: -fractionCompleted
            updateInterractiveTransition(fractionCompleted: fractionCompleted)
        case .ended:
            continueInterractiveTransition()
        default:
            break
        }
        
    }
    
    func animateTransitionIfNeeded(state: CountryPickerState, duration: TimeInterval) {
        if(runningAnimations.isEmpty) {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.countryPickerViewController.view.frame.origin.y = self.view.frame.height - self.countryPickerHeight
                case .collapsed:
                    self.countryPickerViewController.view.frame.origin.y =  self.view.frame.height
                }
            }
            frameAnimator.addCompletion {_ in
                self.pickerIsVisible = !self.pickerIsVisible
                self.runningAnimations.removeAll()
            }
            frameAnimator.startAnimation()
            let fadeAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    self.visualEffectView.effect = nil
                }

            }
            fadeAnimator.startAnimation()
            runningAnimations.append(fadeAnimator)
            runningAnimations.append(frameAnimator)
        }
    }
    
    func startInteractiveTransition(state: CountryPickerState, duration: TimeInterval) {
        if(runningAnimations.isEmpty) {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInterractiveTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInterractiveTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    func setupCountry(flag: String, code: String) {
        countryPickerButton.setTitle(flag, for: .normal)
        countryCodeLabel.text = "+\(code)"
    }

    @IBAction func CountryPickerButtonPressed(_ sender: UIButton) {
        dismissKeyboard()
        animateTransitionIfNeeded(state: nextState, duration: 0.9)
    }
    @IBAction func ConfirmButtonPressed(_ sender: UIButton) {
        dismissKeyboard()
        let vc = UIStoryboard(name: "SmsCodeViewController", bundle: nil).instantiateViewController(withIdentifier: "SmsCodeViewController") as! SmsCodeViewController
        vc.setup(with: user.phoneNumber.number)
        self.present(vc, animated: true, completion: nil)
    }
}

extension MainViewController: UITextFieldDelegate {
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func deregisterFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification){
        self.scrollView.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height + 100, right: 0.0)

        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets

        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }

    @objc func keyboardWillBeHidden(notification: NSNotification){
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height - 100, right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }

    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
