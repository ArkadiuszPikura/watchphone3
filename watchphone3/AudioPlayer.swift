//
//  AudioPlayer.swift
//  watchphone3
//
//  Created by Arkadiusz Pikura on 14/11/2024.
//

import Foundation
import AVFoundation

class AudioPlayer: ObservableObject {
    var player: AVAudioPlayer?

    func playSound(named soundName: String) {
        if let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                print("Zaczynam odtwarzać pliku dźwiękowy o nazwie \(soundName).mp3")
                player?.play()
            } catch {
                print("Błąd podczas odtwarzania dźwięku: \(error.localizedDescription)")
            }
        } else {
            print("Nie znaleziono pliku dźwiękowego o nazwie \(soundName).mp3")
        }
    }
}

