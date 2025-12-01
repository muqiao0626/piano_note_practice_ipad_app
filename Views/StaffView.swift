import SwiftUI

struct StaffView: View {
    let note: Note
    var showDebug: Bool = false
    var bassClefOffset: CGFloat = -190
    
    let lineSpacing: CGFloat = 25  // Increased for iPad
    let staffSpacing: CGFloat = 70  // Increased spacing between staves
    
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let staffHeight = 4 * lineSpacing
            
            // Treble Clef Position
            let trebleX = centerX - 150
            let trebleY = centerY - (staffSpacing / 2) - (staffHeight / 2)
            
            // Bass Clef Position
            let bassX = centerX - 150
            let bassY = centerY + (staffSpacing / 2) + (staffHeight / 2) + bassClefOffset
            
            ZStack {
                // White background card
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(radius: 5)
                    .padding(20)
                
                // Draw Grand Staff
                Path { path in
                    // Treble Staff
                    let trebleCenterY = centerY - (staffSpacing / 2) - (staffHeight / 2)
                    drawStaff(path: &path, centerX: centerX, centerY: trebleCenterY, width: 350)
                    
                    // Bass Staff
                    let bassCenterY = centerY + (staffSpacing / 2) + (staffHeight / 2)
                    drawStaff(path: &path, centerX: centerX, centerY: bassCenterY, width: 350)
                    
                    // Vertical bar connecting staves
                    let topY = trebleCenterY - (staffHeight / 2)
                    let bottomY = bassCenterY + (staffHeight / 2)
                    path.move(to: CGPoint(x: centerX - 175, y: topY))
                    path.addLine(to: CGPoint(x: centerX - 175, y: bottomY))
                }
                .stroke(Color.black, lineWidth: 2)
                
                // Clefs with larger size for iPad
                VStack(spacing: 0) {
                    Text("𝄞").font(.system(size: 80))
                        .position(x: trebleX, y: trebleY)
                    
                    Text("𝄢").font(.system(size: 80))
                        .position(x: bassX, y: bassY)
                }
                .frame(height: geometry.size.height)

                // Note
                NoteHeadView(note: note, lineSpacing: lineSpacing)
                    .position(x: centerX, y: calculateNoteYPosition(for: note, in: geometry.size.height))
                
                // Debug Lines
                if showDebug {
                    Path { path in
                        let y = calculateNoteYPosition(for: note, in: geometry.size.height)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 1, dash: [5]))
                }
            }
        }
        .padding()
    }
    
    func drawStaff(path: inout Path, centerX: CGFloat, centerY: CGFloat, width: CGFloat) {
        let startX = centerX - (width / 2)
        let endX = centerX + (width / 2)
        
        for i in -2...2 {
            let y = centerY + CGFloat(i) * lineSpacing
            path.move(to: CGPoint(x: startX, y: y))
            path.addLine(to: CGPoint(x: endX, y: y))
        }
    }
    
    func calculateNoteYPosition(for note: Note, in totalHeight: CGFloat) -> CGFloat {
        let staffHeight = 4 * lineSpacing
        let centerY = totalHeight / 2
        
        // Treble Center (B4)
        let trebleCenterY = centerY - (staffSpacing / 2) - (staffHeight / 2)
        
        // Bass Center (D3)
        let bassCenterY = centerY + (staffSpacing / 2) + (staffHeight / 2)
        
        if note.clef == .treble {
            let b4Offset = 6 + (4 - 4) * 7
            let currentOffset = note.staffOffset
            let diff = currentOffset - b4Offset
            
            return trebleCenterY - (CGFloat(diff) * (lineSpacing / 2))
        } else {
            let d3Offset = 1 + (3 - 4) * 7
            let currentOffset = note.staffOffset
            let diff = currentOffset - d3Offset
            
            return bassCenterY - (CGFloat(diff) * (lineSpacing / 2))
        }
    }
}

struct NoteHeadView: View {
    let note: Note
    let lineSpacing: CGFloat
    
    var body: some View {
        ZStack {
            // Ledger Lines
            if needsLedgerLine(note: note) {
                VStack(spacing: lineSpacing) {
                    ForEach(0..<numberOfLedgerLines(note: note), id: \.self) { _ in
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 50, height: 2)
                    }
                }
                .offset(y: ledgerLineOffset(note: note))
            }
            
            // Note Head - Larger for iPad
            let headHeight = lineSpacing * 1.1
            let headWidth = headHeight * 1.3
            
            if note.duration == .whole {
                Ellipse()
                    .stroke(Color.black, lineWidth: 3)
                    .frame(width: headWidth, height: headHeight)
                    .rotationEffect(.degrees(-20))
            } else {
                Ellipse()
                    .fill(note.duration == .half ? Color.clear : Color.black)
                    .overlay(
                        Ellipse()
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .frame(width: headWidth, height: headHeight)
                    .rotationEffect(.degrees(-20))
            }
            
            // Stem
            if note.duration != .whole {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 2.5, height: 45)
                    .offset(x: (headWidth / 2) - 1.5, y: -20)
            }
            
            // Accidental - Larger for iPad
            if note.accidental != .natural {
                Text(note.accidental.rawValue)
                    .font(.system(size: 36))
                    .offset(x: -35)
            }
        }
    }
    
    func needsLedgerLine(note: Note) -> Bool {
        if note.clef == .treble {
            if note.octave == 4 && note.name == .C { return true }
            if note.octave == 5 && (note.name == .A || note.name == .B) { return true }
        } else {
            if note.octave == 4 && note.name == .C { return true }
            if note.octave == 2 { return true }
            if note.octave == 3 && note.name == .C { return false }
        }
        return false
    }
    
    func numberOfLedgerLines(note: Note) -> Int {
        return 1
    }
    
    func ledgerLineOffset(note: Note) -> CGFloat {
        return 0
    }
}
