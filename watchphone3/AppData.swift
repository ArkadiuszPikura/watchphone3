//
//  Untitled.swift
//  watchphone3
//
//  Created by Arkadiusz Pikura on 08/11/2024.
//

import SwiftUI

class AppData: ObservableObject {
    @Published var setPointA: Int = 0
    @Published var setPointB: Int = 0
    @Published var matchPointA: Int = 0
    @Published var matchPointB: Int = 0
    
    @Published var side: Bool = true
    @Published var finished: Bool = false
    
    private var blinkDuration: TimeInterval = 10 // duration in seconds
    
    func incrementSetPointA() {
        if finished {
            return;
        }
        
        setPointA += 1
        if setPointA >= 25 && setPointA - setPointB > 1 {
            matchPointA += 1
            finished = true
        }
    }
    
    func incrementSetPointB() {
        if finished {
            return;
        }
        
        setPointB += 1
        if setPointB >= 25 && setPointB - setPointA > 1 {
            matchPointB += 1
            finished = true
        }
    }
    
    func startSet() {
        finished = false
        setPointA = 0
        setPointB = 0
    }
    
    func handleMessage(_ message: String) {
        if message == "Top" {
            incrementSetPointA()
        }
        else if message == "Bottom" {
            incrementSetPointB()
        }
    }
}
