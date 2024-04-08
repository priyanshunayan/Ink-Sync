//
//  SettingsScreen.swift
//  WriteGPT
//
//  Created by Priyanshu Nayan on 03/04/24.
//

import SwiftUI
import OpenAIKit


enum OpenAIModels: String, CaseIterable {
    case gpt3Turbo = "gpt-3.5-turbo"
    case gpt4 = "gpt-4"
}

struct SettingsScreen: View {

    @AppStorage("openAIKey") private var openAIKey:String = "";
    @AppStorage("openAIModel") private var openAIModel:OpenAIModels = .gpt3Turbo ;

    @State private var isSecure = true
    
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
                
                
               
                
                VStack {
                    HStack {
                            
                            if isSecure {
                                SecureField("Enter your OpenAI Key", text: $openAIKey).textFieldStyle(.roundedBorder)
                            } else {
                                TextField("Enter your OpenAI Key", text: $openAIKey).textFieldStyle(.roundedBorder)
                            }
                        Button(action: {
                                    isSecure.toggle()
                                }) {
                                    Image(systemName: isSecure ? "eye.slash" : "eye")
                                }.buttonStyle(BorderlessButtonStyle())
                    }
                    HStack {
                        Link("Get your key here", destination: URL(string: "https://platform.openai.com/api-keys")!)
                        Spacer()
                    }.offset(x: 145)
                   
                    
                }


                
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            
            
            VStack {
                HStack {
                    
                    Button("Save and close") {
                        NSApp.keyWindow?.close()
                    }.foregroundColor(.blue)
                        .buttonStyle(.borderedProminent)
                        
                    
                    Link("Give Feedback", destination: URL(string: "https://pen-pal.canny.io/feature-requests")!)
                    
                }.padding(.bottom, 8)
                .padding(.top, 24)
                
            }
            
                
            
            
        }.padding(.bottom, 24)

    }
}

//#Preview {
//    var updaterViewModel = UpdaterViewModel()
//    SettingsScreen(updaterViewModel: updaterViewModel)
//}
