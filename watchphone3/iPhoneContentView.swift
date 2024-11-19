//
//  iPhoneContentView.swift
//  watchphone3
//
//  Created by Arkadiusz Pikura on 06/11/2024.
//

import SwiftUI

struct iPhoneContentView: View {
    @StateObject private var phoneSessionManager = PhoneSessionManager.shared
    @State private var isPortrait = true
    @State private var orientation = UIDevice.current.orientation

    var body: some View {
        GeometryReader { geometry in
            VStack {                
                if phoneSessionManager.side {
                    Text("Team A  -  Team B")
                    
                    Text("\(phoneSessionManager.matchPointA) : \(phoneSessionManager.matchPointB)")
                        .foregroundColor(.red)
                        .font(.system(size: orientation != UIDeviceOrientation.portrait ? 60 : 30))
                        .padding(.bottom, -50)
                    
                    HStack {
                        Text("\(phoneSessionManager.setPointA, specifier: "%02d")")
                            .background(phoneSessionManager.isBlinkingA ? .gray : .clear)
                            .animation(phoneSessionManager.isBlinkingA ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: phoneSessionManager.isBlinkingA)
                            .font(.system(size: orientation != UIDeviceOrientation.portrait ? 220 : 100))
                            .padding()
                        
                        Text(":")
                            .font(.system(size: orientation != UIDeviceOrientation.portrait ? 220 : 100))
                            .padding()
                        
                        Text("\(phoneSessionManager.setPointB, specifier: "%02d")")
                            .background(phoneSessionManager.isBlinkingB ? .gray : .clear)
                            .animation(phoneSessionManager.isBlinkingB ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: phoneSessionManager.isBlinkingB)
                            .font(.system(size: orientation != UIDeviceOrientation.portrait ? 220 : 100))
                            .padding()
                    }
                    
                }
                else {
                    Text("Team B  -  Team A")
                    
                    Text("\(phoneSessionManager.matchPointB) : \(phoneSessionManager.matchPointA)")
                        .foregroundColor(.red)
                        .font(.system(size: orientation != UIDeviceOrientation.portrait ? 60 : 30))
                        .padding(.bottom, -50)
                    
                    HStack {
                        Text("\(phoneSessionManager.setPointB, specifier: "%02d")")
                            .background(phoneSessionManager.isBlinkingB ? .gray : .clear)
                            .animation(phoneSessionManager.isBlinkingB ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: phoneSessionManager.isBlinkingB)
                            .font(.system(size: orientation != UIDeviceOrientation.portrait ? 220 : 100))
                            .padding()
                        
                        Text(":")
                            .font(.system(size: orientation != UIDeviceOrientation.portrait ? 220 : 100))
                            .padding()
                        
                        Text("\(phoneSessionManager.setPointA, specifier: "%02d")")
                            .background(phoneSessionManager.isBlinkingA ? .gray : .clear)
                            .animation(phoneSessionManager.isBlinkingA ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: phoneSessionManager.isBlinkingA)
                            .font(.system(size: orientation != UIDeviceOrientation.portrait ? 220 : 100))
                            .padding()
                    }
                }
                
                if phoneSessionManager.finished {
                    Button(action: {
                        if phoneSessionManager.finished {
                            phoneSessionManager.startSet()
                        }
                    }) {
                        Text("Finished")
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                    self.orientation = UIDevice.current.orientation
                }
                keepScreenAwake(true)
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
                keepScreenAwake(false)
            }
        }
    }
    
    // Funkcja zarządzająca trybem "always on"
    private func keepScreenAwake(_ shouldStayAwake: Bool) {
        UIApplication.shared.isIdleTimerDisabled = shouldStayAwake
    }
}
