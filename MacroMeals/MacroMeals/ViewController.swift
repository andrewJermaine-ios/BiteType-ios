//
//  ViewController.swift
//  MacroMeals
//
//  Created by Andrew on 8/11/23.
//

import UIKit
import OpenAISwift
import CoreHaptics

class ViewController: UIViewController, UITextViewDelegate {
    private var observer: NSObjectProtocol?
    var attributedQuote = NSAttributedString()
    let feedback = UIFeedbackGenerator()
    var gen: UIImpactFeedbackGenerator?
    var res = String()
    private var hapticManager: HapticManager?
    private var textFieldBottomConstraint: NSLayoutConstraint?
    var openAI: OpenAISwift = OpenAISwift(config:
        OpenAISwift
        .Config
        .makeDefaultOpenAI(apiKey: APIKeys().openAIKey))
    let imageGenerator = ViewModel()
    var image: UIImage?
    var text = ""
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var mainTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapToHidKeyboard = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        iconImage.layer.cornerRadius = iconImage.frame.size.height/2
        mainTextField.layer.cornerRadius = 14
        textView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        textView.layer.borderWidth = 2
        textView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        imageView.layer.cornerRadius = 8
        self.textView.delegate = self
        self.mainTextField.delegate = self
        view.addGestureRecognizer(tapToHidKeyboard)
        hapticManager = HapticManager()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //mainTextField.typingAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        mainTextField.attributedPlaceholder = NSAttributedString(string: "What sounds good to eat?", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        mainTextField.textAlignment = .center
        mainTextField.font = UIFont(name: "AvenirNext-Medium", size: 20.0)
        textFieldBottomConstraint = mainTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        textFieldBottomConstraint?.isActive = true
        imageGenerator.setup()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        saveButton.isEnabled = false

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)


    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        
        if mainTextField.isEditing {
            updateViewWithKeyboard(notification: notification, bottomConstraint: self.textFieldBottomConstraint!, keyboardWillShow: true)
        }
        
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        
        updateViewWithKeyboard(notification: notification, bottomConstraint: self.textFieldBottomConstraint!, keyboardWillShow: false)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
    }
        
    func updateViewWithKeyboard(notification: NSNotification, bottomConstraint: NSLayoutConstraint, keyboardWillShow: Bool) {
        
        guard let userInfo = notification.userInfo,
              let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        guard let keybaordDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        guard let keybaordCurve = UIView.AnimationCurve(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int) else {
            return
        }
        let keyboardHeight = keyboardSize.cgRectValue.height
        
        if keyboardWillShow {
            bottomConstraint.constant = -(keyboardHeight + 5)
        } else {
            bottomConstraint.constant = -30
            
        }
        
        let animator = UIViewPropertyAnimator(duration: keybaordDuration, curve: keybaordCurve) {
            [weak self] in self?.view.layoutIfNeeded()
        }
        animator.startAnimation()
        
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("text view is changing")
    }
    
    func genHapticFeedBack() {
        print("feedback func")
        hapticManager?.playSlice()
    }
    
    func askAi() {
        print("Got tapped")
        print(self.mainTextField.text!)
        textView.text = ""
        openAI.sendCompletion(with: mainTextField.text!, maxTokens: 500) { result in
            switch result {
            case .success(let success):
              
                print("we made it", success.choices?.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                self.res = success.choices?.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                self.sendToView(message: self.res)
                
                
//                DispatchQueue.main.async {
//                    //self.textView.text = success.choices?.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//                    for i in res {
//                        self.gen.prepare()
//
//                        self.textView.text += "\(i)"
//                        self.textViewDidChange(self.textView)
//
//
//                        self.gen.impactOccurred(intensity: 0.1)
//                        RunLoop.current.run(until: Date()+0.01)
//
//                    }
//                }
                
            case .failure(let failure):
                print("we aint make it", failure.localizedDescription)
            }
            
            print(result, "--------result----")
        }
        
        Task{
            print("button pressed")
            if text.trimmingCharacters(in: .whitespaces).isEmpty {
                let res = await imageGenerator.generateImage(withPrompt: mainTextField.text!)
                if res == nil {
                    print("somehow its nil breven")
                }
                self.imageView.image = res
                print("reached!")

            }
        }
        saveButton.isEnabled = true
    }
    
    
    func sendToView(message: String) {
        DispatchQueue.main.async {
            for i in self.res {
                self.textView.text += "\(i)"
                self.textViewDidChange(self.textView)
                self.genHapticFeedBack()
               RunLoop.current.run(until: Date()+0.005)
            }
           
        }
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        print("Got tapped", sender)
        dismissKeyboard()
        askAi()
    }
    @IBAction func didDblTap(_ sender: UITapGestureRecognizer) {
        
    }
    
    @IBAction func savePressed(_ sender: Any) {
        print("save pressed")
    }
    

}
//PRAGMA MARK: Move all this to separate class! but this works so well and feels great!!!

//https://www.kodeco.com/10608020-getting-started-with-core-haptics
class HapticManager {
    let engine: CHHapticEngine!
    
    init?() {
        let capability = CHHapticEngine.capabilitiesForHardware()
        guard capability.supportsHaptics else {
            return nil
        }
        do {
            engine = try CHHapticEngine()
        } catch let error {
            print("Haptic engine creation error: \(error)")
            return nil
        }
        
        do {
          try engine.start()
        } catch let error {
          print("Haptic failed to start Error: \(error)")
        }
        
        engine.isAutoShutdownEnabled = true

    }
    
    func playSlice() {
      do {
        // 1
        let pattern = try slicePattern()
        // 2
        try engine.start()
        // 3
        let player = try engine.makePlayer(with: pattern)
        // 4
        try player.start(atTime: CHHapticTimeImmediate)
        // 5
          
      } catch {
        print("Failed to play slice: \(error)")
      }
    }
}

extension HapticManager {
 
    private func slicePattern() throws -> CHHapticPattern {
    let slice = CHHapticEvent(
        eventType: .hapticTransient,
      parameters: [
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.15),
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
      ],
      relativeTime: 0,
      duration: 0.02)

    let snip = CHHapticEvent(
      eventType: .hapticTransient,
      parameters: [
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.15),
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
      ],
      relativeTime: 0.08)

    return try CHHapticPattern(events: [slice, snip], parameters: [])
  }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        askAi()
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    
    
}
