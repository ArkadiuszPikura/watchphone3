//
//  WatchSessionManager.swift
//  watchphone3 Watch App
//
//  Created by Arkadiusz Pikura on 06/11/2024.
//

import WatchConnectivity
import SwiftUI

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    
    @Published var receivedMessage: String = "Waiting for message from iPhone"
    @Published var teamA: Int = 0
    @Published var teamB: Int = 0
    @Published var team: String = ""
    
    @Published var isBlinkingA: Bool = false
    @Published var isBlinkingB: Bool = false
    @Published var blocked: Bool = false
    @Published var finish: Bool = false
    
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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.handleMessage(message)
        }
    }
    
    // Wysyłanie wiadomości do iPhone
    func sendMessageToPhone(_ message: [String: Any]) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message to iPhone: \(error.localizedDescription)")
            }
        }
    }
    
    func handleMessage(_ message: [String: Any]) {
        if let receivedMessage = message["message"] as? String {
            self.receivedMessage = receivedMessage
            
            if receivedMessage == "Confirmation" {
                blocked = true
                
                if let text2 = message["teamA"] as? String {
                    self.teamA = Int(text2) ?? 0
                    print("Received message from iPhone: \(text2)")
                }
                
                if let text3 = message["teamB"] as? String {
                    self.teamB = Int(text3) ?? 0
                    print("Received message from iPhone: \(text3)")
                }
                
                if let text4 = message["team"] as? String {
                    self.team = text4
                    print("Received message from iPhone: \(text4)")
                    if team == "A" {
                        startBlinkingA()
                    }
                    else if team == "B" {
                        startBlinkingB()
                    }
                }
            }
            else if receivedMessage == "Unblock" {
                blocked = false
                isBlinkingA = false
                isBlinkingB = false
                
                if let text2 = message["teamA"] as? String {
                    self.teamA = Int(text2) ?? 0
                    print("Received message from iPhone: \(text2)")
                }
                
                if let text3 = message["teamB"] as? String {
                    self.teamB = Int(text3) ?? 0
                    print("Received message from iPhone: \(text3)")
                }
            }
            else if receivedMessage == "Finish" {
                blocked = false
                isBlinkingA = false
                isBlinkingB = false
                finish = true
                
                if let text2 = message["teamA"] as? String {
                    self.teamA = Int(text2) ?? 0
                    print("Received message from iPhone: \(text2)")
                }
                
                if let text3 = message["teamB"] as? String {
                    self.teamB = Int(text3) ?? 0
                    print("Received message from iPhone: \(text3)")
                }
            }
            else if receivedMessage == "StartSet" {
                blocked = false
                isBlinkingA = false
                isBlinkingB = false
                finish = false
                
                if let text2 = message["teamA"] as? String {
                    self.teamA = Int(text2) ?? 0
                    print("Received message from iPhone: \(text2)")
                }
                
                if let text3 = message["teamB"] as? String {
                    self.teamB = Int(text3) ?? 0
                    print("Received message from iPhone: \(text3)")
                }
            }
        }
    }
    
    // Method to start blinking
    func startBlinkingA() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            self.isBlinkingA = true
        }
    }
    
    // Method to start blinking
    func startBlinkingB() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            self.isBlinkingB = true
        }
    }
    
    func cancelTeamA() {
        sendMessageToPhone(["message" : "cancelTeamA"])
    }
    
    func cancelTeamB() {
        sendMessageToPhone(["message" : "cancelTeamB"])
    }
}
