//
//  ImageGenerator.swift
//  MacroMeals
//
//  Created by Andrew on 8/11/23.
//

import Foundation
import UIKit
import OpenAIKit

final class ViewModel: ObservableObject {
    private var openAi: OpenAI?
        func setup() {
                openAi = OpenAI(Configuration(
                    organizationId: "Personal",
                    apiKey: "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"
                ))
            }

    func generateImage(withPrompt: String) async -> UIImage? {
        guard let openAi = openAi else {
            return nil
        }

        do {
            let params = ImageParameters(
                prompt: withPrompt,
                resolution: .large,
                responseFormat: .base64Json
            )
            
            let result = try await openAi.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openAi.decodeBase64Image(data)
            return image
        }
        catch {
            print(String(describing: error))
            return nil
        }
    }
}
