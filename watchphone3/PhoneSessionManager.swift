//
//  PhoneSessionManager.swift
//  watchphone3
//
//  Created by Arkadiusz Pikura on 06/11/2024.
//

import WatchConnectivity
import SwiftUI

class PhoneSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = PhoneSessionManager()
    private var audioPlayer = AudioPlayer()
    
    @Published var receivedMessage: String = "Waiting for message from Apple Watch"
    //@Published var appData = AppData()
    
    @Published var setPointA: Int = 0
    @Published var setPointB: Int = 0
    @Published var matchPointA: Int = 0
    @Published var matchPointB: Int = 0
    
    @Published var side: Bool = true
    @Published var finished: Bool = false
    
    @Published var isBlinkingA: Bool = false
    @Published var isBlinkingB: Bool = false
    @Published var blocked: Bool = false
    
    @State private var timerA: Timer?
    @State private var timerB: Timer?
    
    private var blinkDuration: TimeInterval = 10 // duration in seconds
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    // Metody delegata WCSession
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Obsługa aktywacji
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) { }
    
    // Odbieranie wiadomości z Apple Watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let text = message["message"] as? String {
                self.receivedMessage = text
                print("Received message from Apple Watch: \(text)")
                self.handleMessage(text, message["sound"] as? String)
            }
        }
    }
    
    // Wysyłanie wiadomości do Apple Watch
    func sendMessageToWatch(_ message: [String: Any]) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message to Apple Watch: \(error.localizedDescription)")
            }
        }
    }
    
    func incrementSetPointA() {
        if finished || blocked {
            return;
        }
        
        setPointA += 1
        startBlinkingA()
        
        if setPointA >= 25 && setPointA - setPointB > 1 {
            matchPointA += 1
            setFinished()
        }
    }
    
    func incrementSetPointB() {
        if finished || blocked {
            return;
        }
        
        setPointB += 1
        startBlinkingB()
        
        if setPointB >= 25 && setPointB - setPointA > 1 {
            matchPointB += 1
            setFinished()
        }
    }
    
    func startSet() {
        finished = false
        setPointA = 0
        setPointB = 0
        side = !side
        sendMessageToWatch(["message": "StartSet", "teamA": "\(setPointA)", "teamB": "\(setPointB)"])
    }
    
    func setFinished() {
        finished = true
        sendMessageToWatch(["message": "Finish", "teamA": "\(setPointA)", "teamB": "\(setPointB)"])
    }
    
    func handleMessage(_ message: String, _ sound: String?) {
        if message == "Top" {
            incrementSetPointA()
        }
        else if message == "Bottom" {
            incrementSetPointB()
        }
        else if message == "cancelTeamA" {
            cancelTeamA()
        }
        else if message == "cancelTeamB" {
            cancelTeamB()
        }
        else if message == "NextSet" {
            startSet()
        }
        else if message == "Play" {
            audioPlayer.playSound(named: sound ?? "none")
        }
        
    }
    
    func cancelTeamA() {
        setPointA -= 1
        unblockDevice("A", false)
    }
    
    func cancelTeamB() {
        setPointB -= 1
        unblockDevice("B", false)
    }
    
    // Method to start blinking
    func startBlinkingA() {
        blocked = true
        sendConfirmation("A")
        
        timerA = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            self.isBlinkingA = true
        }

        // Automatically stop blinking after `blinkDuration`
        DispatchQueue.main.asyncAfter(deadline: .now() + blinkDuration) {
            self.unblockDevice("A", true)
        }
    }
    
    // Method to start blinking
    func startBlinkingB() {
        blocked = true
        sendConfirmation("B")
        
        self.timerB = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            self.isBlinkingB = true
        }

        // Automatically stop blinking after `blinkDuration`
        DispatchQueue.main.asyncAfter(deadline: .now() + blinkDuration) {
            self.unblockDevice("B", true)
        }
    }
    
    // Unblock
    func unblockDevice(_ team: String, _ fromTimer: Bool) {
        self.blocked = false
        if team == "A" {
            isBlinkingA = false
            print("invalidate timerA")
            timerA?.invalidate()
            timerA = nil
        }
        
        else if team == "B" {
            isBlinkingB = false
            print("invalidate timerB")
            timerB?.invalidate()
            timerB = nil
        }
        
        print("unblockDevice: \(team) \(fromTimer)")
        sendMessageToWatch(["message": "Unblock", "teamA": "\(setPointA)", "teamB": "\(setPointB)"])
    }
    
    // Send confirmation
    func sendConfirmation(_ team: String) {
        sendMessageToWatch(["message": "Confirmation", "teamA": "\(setPointA)", "teamB": "\(setPointB)", "team": team])
    }
}
