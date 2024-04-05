//
//  SettingsScreen.swift
//  WriteGPT
//
//  Created by Priyanshu Nayan on 03/04/24.
//

import SwiftUI
import KeyboardShortcuts


enum OpenAIModels: String, CaseIterable {
    case gpt3Turbo = "gpt-3.5-turbo"
    case gpt4 = "gpt-4"
}

struct SettingsScreen: View {
    @AppStorage("openAIKey") private var openAIKey:String = "";
    @AppStorage("openAIModel") private var openAIModel:OpenAIModels = .gpt4 ;

    
    var body: some View {
        
        VStack {
            Text("Preferences").font(.title).padding(.top, 24)
            Text("Select your preferences").font(.subheadline)
            Form {
                Picker("AI Model", selection: $openAIModel) {
                    ForEach(OpenAIModels.allCases, id: \.self) { model in
                        Text(model.rawValue)
                    }
                }.pickerStyle(.segmented)
                
                SecureField("Enter your OpenAI Key", text: $openAIKey).textFieldStyle(.roundedBorder)
                
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            
            Button("Save and close") {
                NSApp.keyWindow?.close()
            }.padding(.top, 24).foregroundColor(.blue)
                .padding(.bottom, 24)
            
            
        }.padding(.bottom, 24)

    }
}

#Preview {
    SettingsScreen()
}
