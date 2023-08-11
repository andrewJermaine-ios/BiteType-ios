//
//  ViewController.swift
//  MacroMeals
//
//  Created by Andrew on 8/11/23.
//

import UIKit
import OpenAISwift


class ViewController: UIViewController {
    
    
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
        textView.layer.borderColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        textView.layer.borderWidth = 4
        textView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        imageView.layer.cornerRadius = 8
      
        
    }
    override func viewWillAppear(_ animated: Bool) {
        imageGenerator.setup()
    }
    
    @IBAction func didDblTap(_ sender: UITapGestureRecognizer) {
        print("Got tapped", sender)
        print(self.textField.text!)
        textView.text = ""

        openAI.sendCompletion(with: textField.text!, maxTokens: 500) { result in
            switch result {
            case .success(let success):
              
                print("we made it", success.choices?.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                DispatchQueue.main.async {
                    self.textView.text = success.choices?.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                }
                
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

