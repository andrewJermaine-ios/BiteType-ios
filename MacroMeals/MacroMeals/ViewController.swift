//
//  ViewController.swift
//  MacroMeals
//
//  Created by Andrew on 8/11/23.
//

import UIKit
import OpenAISwift


class ViewController: UIViewController, UITextViewDelegate {
    
    let feedback = UIFeedbackGenerator()
    var gen = UIImpactFeedbackGenerator(style: .light)
    var res = String()

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

        view.addGestureRecognizer(tapToHidKeyboard)
        
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
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    func sendToView(message: String) {
        DispatchQueue.main.async {
            
            for i in self.res {
                self.gen.prepare()
                self.textView.text += "\(i)"
                self.textViewDidChange(self.textView)
                
                
                self.gen.impactOccurred(intensity: 0.1)
                RunLoop.current.run(until: Date()+0.01)
                
            }
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

