//
//  BlinkingTextView.swift
//  watchphone3
//
//  Created by Arkadiusz Pikura on 08/11/2024.
//

import SwiftUI

struct BlinkingTextView: View {
    @State private var isBlinking = false
    @State private var isVisible = true
    private var blinkDuration: TimeInterval = 10 // duration in seconds

    var body: some View {
        VStack {
            Text("Blinking Text")
                .opacity(isVisible ? 1 : 0)
                .onAppear {
                    startBlinking()
                }

            Button("Start Blinking") {
                startBlinking()
            }
            .padding()

            Button("Stop Blinking") {
                stopBlinking()
            }
            .padding()
        }
    }

    // Method to start blinking
    public func startBlinking() {
        isBlinking = true
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if isBlinking {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isVisible.toggle()
                }
            } else {
                timer.invalidate() // Stop the timer
                isVisible = true // Ensure text is visible when blinking ends
            }
        }

        // Automatically stop blinking after `blinkDuration`
        DispatchQueue.main.asyncAfter(deadline: .now() + blinkDuration) {
            stopBlinking()
        }
    }

    // Method to stop blinking
    private func stopBlinking() {
        isBlinking = false
    }
}
