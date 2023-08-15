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
    
    let feedback = UIFeedbackGenerator()
    var gen: UIImpactFeedbackGenerator?
    var res = String()
    
    private var hapticManager: HapticManager?


    var openAI: OpenAISwift = OpenAISwift(config:
        OpenAISwift
        .Config
        .makeDefaultOpenAI(apiKey: "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"))
    let imageGenerator = ViewModel()
    var image: UIImage?
    var text = ""
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapToHidKeyboard = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        textView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        textView.layer.borderWidth = 2
        textView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        imageView.layer.cornerRadius = 8
        self.textView.delegate = self
        gen = UIImpactFeedbackGenerator(style: .rigid)
        gen?.impactOccurred(intensity: 1.0)
        gen?.prepare()

        view.addGestureRecognizer(tapToHidKeyboard)
        
        genHapticFeedBack()
        genHapticFeedBack()
        genHapticFeedBack()
        
        hapticManager = HapticManager()

        
    }
    override func viewWillAppear(_ animated: Bool) {
        imageGenerator.setup()
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

//        gen?.impactOccurred(intensity: 1.0)
//        gen?.prepare()
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    func sendToView(message: String) {
        DispatchQueue.main.async {
            self.gen?.prepare()
            for i in self.res {
                self.textView.text += "\(i)"
                self.textViewDidChange(self.textView)
                self.genHapticFeedBack()
               RunLoop.current.run(until: Date()+0.03)
            }
            self.textView.isEditable = true
        }
    }
    
    @IBAction func didDblTap(_ sender: UITapGestureRecognizer) {
        print("Got tapped", sender)
        print(self.textField.text!)
        textView.text = ""

        openAI.sendCompletion(with: textField.text!, maxTokens: 500) { result in
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
                let res = await imageGenerator.generateImage(withPrompt: textField.text!)
                if res == nil {
                    print("somehow its nil breven")
                }
                self.imageView.image = res
                print("reached!")

            }
        }
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
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
      ],
      relativeTime: 0,
      duration: 0.05)

    let snip = CHHapticEvent(
      eventType: .hapticTransient,
      parameters: [
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
      ],
      relativeTime: 0.08)

    return try CHHapticPattern(events: [slice, snip], parameters: [])
  }
}
