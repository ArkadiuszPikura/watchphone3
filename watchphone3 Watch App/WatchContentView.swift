//
//  WatchContentView.swift
//  watchphone3 Watch App
//
//  Created by Arkadiusz Pikura on 06/11/2024.
//

import SwiftUI
import CoreMotion

struct WatchContentView: View {
    @State private var motionManager = CMMotionManager()
    @StateObject private var watchSessionManager = WatchSessionManager.shared
    @State private var messageToSend = ""
    @State private var top = "Top"
    @State private var bottom = "Bottom"
    
    @State private var crownValue: Double = 50
    
    @FocusState private var focusedField: Field?
    
    enum Field: Equatable {
        case top, middle, bottom
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            if (!watchSessionManager.finish)
            {
                if watchSessionManager.blocked && watchSessionManager.team == "B" {
                    Button(action: {
                        watchSessionManager.cancelTeamB()
                    }) {
                        Text("Cancel B")
                    }
                    .background(RoundedRectangle(cornerRadius: 25).fill(.red))
                }
                else {
                    Button(action: {
                        // Akcja dla górnego przycisku
                        print("Top button pressed")
                        watchSessionManager.sendMessageToPhone(["message": top])
                        //triggerHaptic()
                    }) {
                        Text("Team A - \(watchSessionManager.teamA)")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .focusable()
                    .focused($focusedField, equals: .top)
                    .background(RoundedRectangle(cornerRadius: 25).fill(watchSessionManager.isBlinkingA ? .gray : .blue))
                    .animation(watchSessionManager.isBlinkingA ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: watchSessionManager.isBlinkingA)
                }
            }
            
            if (watchSessionManager.finish)
            {
                Button(action: {
                    print("Next Set")
                    watchSessionManager.sendMessageToPhone(["message": "NextSet"])
                    triggerHaptic()
                }) {
                    Text("Next Set")
                }
                .focusable()
                .focused($focusedField, equals: .middle)
            }
            else if watchSessionManager.blocked {
                HStack() {
                    Button(action: {
                        watchSessionManager.sendMessageToPhone(["message" : "Play", "sound": "ostatni"])
                        triggerHaptic()
                    }) {
                        Text("O")
                    }
                    
                    Button(action: {
                        watchSessionManager.sendMessageToPhone(["message" : "Play", "sound": "boom"])
                        triggerHaptic()
                    }) {
                        Text("B")
                    }
                    
                    Button(action: {
                        watchSessionManager.sendMessageToPhone(["message" : "Play", "sound": "ace"])
                        triggerHaptic()
                    }) {
                        Text("A")
                    }
                }
            }
            
            if !watchSessionManager.finish {
                if watchSessionManager.blocked && watchSessionManager.team == "A" {
                    Button(action: {
                        watchSessionManager.cancelTeamA()
                    }) {
                        Text("Cancel A")
                    }
                    .background(RoundedRectangle(cornerRadius: 25).fill(.red))
                }
                else {
                    Button(action: {
                        // Akcja dla dolnego przycisku
                        print("Bottom button pressed")
                        watchSessionManager.sendMessageToPhone(["message": bottom])
                        //triggerHaptic()
                    }) {
                        Text("Team B - \(watchSessionManager.teamB)")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .focusable()
                    .focused($focusedField, equals: .bottom)
                    .background(RoundedRectangle(cornerRadius: 25).fill(watchSessionManager.isBlinkingB ? .gray : .green))
                    .animation(watchSessionManager.isBlinkingB ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: watchSessionManager.isBlinkingB)
                }
            }
        }
        //.focusable()
        .focusable(!watchSessionManager.blocked)
        .digitalCrownRotation($crownValue, from: 0, through: 100, by: 50)
        /*).onChange(of: crownValue) { newValue, _ in
            print("Nowa wartość korony: \(newValue)")
            if newValue > 90 {
                watchSessionManager.sendMessageToPhone(["message": top] )
                crownValue = 50
            }
            else if newValue < 10 {
                watchSessionManager.sendMessageToPhone(["message": bottom] )
                crownValue = 50
            }
        }*/
        .onChange(of: watchSessionManager.receivedMessage) { oldMssage, newMessage in
            print("receivedMessage watch changed: '\(newMessage)'")
            if newMessage == "Confirmation" {
                triggerHaptic()
            }
            
            // clear status
            watchSessionManager.receivedMessage = ""
        }
        .onChange(of: focusedField) { old, new in
            print("focusedField changed: '\(new)'")
        }
        .onAppear() {
            //startMotionUpdates()
            //self.focused(<#T##condition: FocusState<Bool>.Binding##FocusState<Bool>.Binding#>)
            focusedField = .middle
        }
    }
    
    // Funkcja do akcelerometru
    func startMotionUpdates() {
        guard motionManager.isAccelerometerAvailable else { return }
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            guard let data = data else { return }
            
            // wykrywanie potrząśnieęcia
            if abs(data.acceleration.x) > 1.5 || abs(data.acceleration.y) > 1.5 || abs(data.acceleration.z) > 1.5 {
                print("X: \(data.acceleration.x) Y: \(data.acceleration.y) Z: \(data.acceleration.z)")
            }
        }
        
        motionManager.deviceMotionUpdateInterval = 1
        motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
            guard let motion = motion, error == nil else { return }
            
            //print("Roll: \(motion.attitude.roll) Pitch: \(motion.attitude.pitch) Yaw: \(motion.attitude.yaw)")
            if abs(motion.rotationRate.x) > 5 {
                print("Rx: \(motion.rotationRate.x) Ry: \(motion.rotationRate.y) Rz: \(motion.rotationRate.z)")
            }
        }
    }
    
    // Funkcja wywołująca haptykę
    private func triggerHaptic() {
        WKInterfaceDevice.current().play(.notification) // Typ haptyki
    }
}
