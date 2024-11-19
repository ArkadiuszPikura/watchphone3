//
//  ContentView.swift
//  watchphone3 Watch App
//
//  Created by Arkadiusz Pikura on 05/11/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            //Spacer() // Pusty obszar na górze, aby przyciski były w środku

            VStack {
                Button("Przycisk 1") {
                    print("Przycisk 1 wciśnięty!")
                    triggerHaptic()
                }
                .buttonStyle(DefaultButtonStyle())
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(35)
                //.padding(.trailing, 8) // Odstęp między przyciskami
                
                Spacer()
                
                Button("Przycisk 3") {
                    print("Przycisk 3 wciśnięty!")
                    triggerHaptic()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 35)
                    .fill(Color.green))
                .foregroundColor(.white)
                //.cornerRadius(25)
            }
            //.padding(.vertical) // Opcjonalnie: dodatkowy odstęp po bokach

            //Spacer() // Pusty obszar na dole
        }
    }
    
    // Funkcja wywołująca haptykę
    private func triggerHaptic() {
        WKInterfaceDevice.current().play(.notification) // Typ haptyki
    }
}
