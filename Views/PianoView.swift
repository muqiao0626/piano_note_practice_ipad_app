import SwiftUI

struct PianoView: View {
    @ObservedObject var engine: GameEngine
    @State private var pressedKey: Note?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Render White Keys
                ForEach(0..<whiteKeys.count, id: \.self) { index in
                    let note = whiteKeys[index]
                    let width = geometry.size.width / CGFloat(whiteKeys.count)
                    let height = geometry.size.height
                    let x = CGFloat(index) * width
                    
                    PianoKey(note: note, isBlack: false, isPressed: pressedKey == note) {
                        pressKey(note)
                    }
                    .frame(width: width, height: height)
                    .position(x: x + width / 2, y: height / 2)
                    .zIndex(0)
                }
                
                // Render Black Keys
                ForEach(blackKeys, id: \.self) { note in
                    let whiteKeyWidth = geometry.size.width / CGFloat(whiteKeys.count)
                    let width = whiteKeyWidth * 0.65
                    let height = geometry.size.height * 0.6
                    let xPos = calculateBlackKeyXPosition(for: note, whiteKeyWidth: whiteKeyWidth)
                    
                    PianoKey(note: note, isBlack: true, isPressed: pressedKey == note) {
                        pressKey(note)
                    }
                    .frame(width: width, height: height)
                    .position(x: xPos, y: height / 2)
                    .zIndex(1)
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    func pressKey(_ note: Note) {
        pressedKey = note
        AudioManager.shared.play(note: note)
        engine.check(note: note)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            pressedKey = nil
        }
    }
    
    var whiteKeys: [Note] {
        var keys: [Note] = []
        keys.append(Note(name: .B, octave: 2, accidental: .natural, clef: .bass, duration: .quarter))
        
        for octave in 3...4 {
            for name in NoteName.allCases {
                keys.append(Note(name: name, octave: octave, accidental: .natural, clef: .treble, duration: .quarter))
            }
        }
        keys.append(Note(name: .C, octave: 5, accidental: .natural, clef: .treble, duration: .quarter))
        return keys
    }
    
    var blackKeys: [Note] {
        var keys: [Note] = []
        for octave in 3...4 {
            keys.append(Note(name: .C, octave: octave, accidental: .sharp, clef: .treble, duration: .quarter))
            keys.append(Note(name: .D, octave: octave, accidental: .sharp, clef: .treble, duration: .quarter))
            keys.append(Note(name: .F, octave: octave, accidental: .sharp, clef: .treble, duration: .quarter))
            keys.append(Note(name: .G, octave: octave, accidental: .sharp, clef: .treble, duration: .quarter))
            keys.append(Note(name: .A, octave: octave, accidental: .sharp, clef: .treble, duration: .quarter))
        }
        return keys
    }
    
    func calculateBlackKeyXPosition(for note: Note, whiteKeyWidth: CGFloat) -> CGFloat {
        var baseIndex = 0
        switch note.name {
        case .C: baseIndex = 0
        case .D: baseIndex = 1
        case .F: baseIndex = 3
        case .G: baseIndex = 4
        case .A: baseIndex = 5
        default: break
        }
        
        baseIndex += (note.octave - 3) * 7 + 1
        return CGFloat(baseIndex + 1) * whiteKeyWidth
    }
}

struct PianoKey: View {
    let note: Note
    let isBlack: Bool
    let isPressed: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(isBlack ? 
                          (isPressed ? Color.gray : Color.black) :
                          (isPressed ? Color.blue.opacity(0.3) : Color.white)
                    )
                    .overlay(
                        Rectangle()
                            .stroke(Color.black.opacity(0.3), lineWidth: isBlack ? 0 : 2)
                    )
                    .shadow(color: isPressed ? Color.blue.opacity(0.5) : Color.clear, radius: 5)
                
                if !isBlack {
                    Text(note.name.rawValue)
                        .foregroundColor(.black.opacity(0.5))
                        .padding(.bottom, 10)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}
