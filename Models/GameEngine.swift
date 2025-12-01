import Foundation
import SwiftUI
internal import Combine

class GameEngine: ObservableObject {
    @Published var currentNotes: [Note] = []
    @Published var score: Int = 0
    @Published var feedbackMessage: String = "Press the key!"
    @Published var feedbackColor: Color = .primary
    
    init() {
        generateNote()
    }
    
    func generateNote() {
        var newNote: Note
        repeat {
            // Reduce C5 bias by making it a separate low-probability event
            let includeC5 = Double.random(in: 0...1) < 0.05 // 5% chance of C5
            let octave = includeC5 ? 5 : Int.random(in: 3...4)
            let name = NoteName.allCases.randomElement()!
            let accidental = Accidental.allCases.randomElement()!
            
            // Constraint check
            if octave == 5 {
                newNote = Note(name: .C, octave: 5, accidental: .natural, clef: .treble, duration: .quarter)
            } else {
                let clef: Clef = octave < 4 ? .bass : .treble
                let duration = NoteDuration.allCases.randomElement()!
                newNote = Note(name: name, octave: octave, accidental: accidental, clef: clef, duration: duration)
            }
        } while currentNotes.contains(newNote)
        
        currentNotes = [newNote]
        
        feedbackMessage = "Press the key!"
        feedbackColor = .primary
    }
    
    func check(note: Note) {
        guard let targetNote = currentNotes.first else { return }
        
        // Compare MIDI values to handle enharmonics
        let isCorrect = note.midiValue == targetNote.midiValue
        
        if isCorrect {
            score += 1
            feedbackMessage = "Correct! ✓"
            feedbackColor = .green
            
            // Add haptic feedback on iPad
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.generateNote()
            }
        } else {
            score = max(0, score - 1)
            feedbackMessage = "Try again! ✗"
            feedbackColor = .red
            
            // Light haptic feedback for incorrect
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}
