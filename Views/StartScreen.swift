import SwiftUI

struct StartScreen: View {
    @ObservedObject var session: PracticeSession
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.3),
                        Color.purple.opacity(0.3),
                        Color.pink.opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // App Icon/Logo
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 140, height: 140)
                            .shadow(radius: 10)
                        
                        VStack(spacing: 5) {
                            Text("🎹")
                                .font(.system(size: 60))
                            Text("♪")
                                .font(.system(size: 30))
                        }
                    }
                    
                    // Title
                    VStack(spacing: 10) {
                        Text("Piano Practice")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Master Note Reading")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Session Configuration
                    VStack(spacing: 25) {
                        Text("Select Practice Length")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        // Custom segmented picker for iPad
                        HStack(spacing: 15) {
                            ForEach(session.noteCountOptions, id: \.self) { count in
                                Button(action: {
                                    session.selectedNoteCount = count
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                }) {
                                    VStack(spacing: 8) {
                                        Text("\(count)")
                                            .font(.system(size: 32, weight: .bold))
                                        Text("notes")
                                            .font(.caption)
                                            .textCase(.uppercase)
                                    }
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(session.selectedNoteCount == count ? .white : .primary)
                                    .background(
                                        session.selectedNoteCount == count ?
                                        Color.blue : Color.white.opacity(0.7)
                                    )
                                    .cornerRadius(20)
                                    .shadow(radius: session.selectedNoteCount == count ? 8 : 3)
                                    .scaleEffect(session.selectedNoteCount == count ? 1.05 : 1.0)
                                    .animation(.spring(response: 0.3), value: session.selectedNoteCount)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(30)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(25)
                    .shadow(radius: 5)
                    
                    // Start Button
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        session.startPractice()
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "play.fill")
                                .font(.title)
                            Text("Start Practice")
                                .font(.system(size: 28, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(width: 350, height: 80)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    
                    Spacer()
                }
                .padding(40)
            }
        }
    }
}
