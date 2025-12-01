import SwiftUI

struct ContentView: View {
    @StateObject var session = PracticeSession()
    @StateObject var engine = GameEngine()
    @State private var showDebug = false
    @State private var bassClefOffset: CGFloat = -190
    
    var body: some View {
        switch session.appState {
        case .start:
            StartScreen(session: session)
        case .practice:
            PracticeView(session: session, engine: engine, showDebug: $showDebug, bassClefOffset: $bassClefOffset)
        case .summary:
            SummaryScreen(session: session, engine: engine)
        }
    }
}

struct PracticeView: View {
    @ObservedObject var session: PracticeSession
    @ObservedObject var engine: GameEngine
    @Binding var showDebug: Bool
    @Binding var bassClefOffset: CGFloat
    
    @State private var sessionTimer: Int = 30
    @State private var timerSubscription: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                // Header with Timer and Controls
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Session \(session.currentSession + 1)/\(session.selectedNoteCount)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Accuracy: \(session.totalSessions > 0 ? Int((Double(session.correctSessions) / Double(session.totalSessions)) * 100) : 0)%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Feedback Message
                    Text(engine.feedbackMessage)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(engine.feedbackColor)
                        .frame(minWidth: 150)
                    
                    Spacer()
                    
                    // Session Timer with Circle Progress
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(sessionTimer) / 30.0)
                            .stroke(
                                sessionTimer <= 10 ? Color.red : Color.blue,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: sessionTimer)
                        
                        VStack(spacing: 2) {
                            Text("\(sessionTimer)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(sessionTimer <= 10 ? .red : .primary)
                            Text("sec")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                if showDebug {
                    HStack {
                        Text("Bass Clef Offset: \(Int(bassClefOffset))")
                        Slider(value: $bassClefOffset, in: -200...200, step: 10)
                    }
                    .padding(.horizontal, 30)
                }
                
                Spacer()
                
                // Staff - Larger for iPad
                if let note = engine.currentNotes.first {
                    StaffView(note: note, showDebug: showDebug, bassClefOffset: bassClefOffset)
                        .frame(height: min(geometry.size.height * 0.35, 400))
                }
                
                Spacer()
                
                // Piano - Optimized for iPad landscape
                PianoView(engine: engine)
                    .frame(height: min(geometry.size.height * 0.25, 250))
                    .padding(.horizontal, 20)
                
                // Control Buttons - Touch-friendly sizing
                HStack(spacing: 30) {
                    Button(action: {
                        skipSession()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "forward.fill")
                            Text("Skip")
                                .fontWeight(.semibold)
                        }
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 150, height: 60)
                        .background(Color.orange)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                    }
                    
                    Button(action: {
                        timerSubscription?.invalidate()
                        session.endPractice()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "stop.fill")
                            Text("End Practice")
                                .fontWeight(.semibold)
                        }
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 60)
                        .background(Color.red)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                    }
                    
                    Toggle(isOn: $showDebug) {
                        Image(systemName: "ladybug.fill")
                            .font(.title2)
                    }
                    .toggleStyle(.button)
                    .tint(.gray)
                    .frame(width: 60, height: 60)
                    .background(showDebug ? Color.gray.opacity(0.3) : Color.clear)
                    .cornerRadius(15)
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            startSessionTimer()
        }
        .onDisappear {
            timerSubscription?.invalidate()
        }
        .onChange(of: engine.feedbackMessage) { newValue in
            if newValue.contains("Correct") {
                // User got it right - move to next session
                session.correctSessions += 1
                session.totalSessions += 1
                session.currentSession += 1
                
                if session.isPracticeComplete {
                    timerSubscription?.invalidate()
                    session.endPractice()
                } else {
                    // Reset timer after GameEngine generates new note
                    timerSubscription?.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        sessionTimer = 30
                        startSessionTimer()
                    }
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private func startSessionTimer() {
        timerSubscription = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if sessionTimer > 0 {
                sessionTimer -= 1
            } else {
                // Time's up - mark as incorrect and move to next
                timer.invalidate()
                session.totalSessions += 1
                session.currentSession += 1
                
                if session.isPracticeComplete {
                    session.endPractice()
                } else {
                    // Reset timer and generate new note
                    sessionTimer = 30
                    engine.generateNote()
                    startSessionTimer()
                }
            }
        }
    }
    
    private func skipSession() {
        timerSubscription?.invalidate()
        session.totalSessions += 1
        session.currentSession += 1
        
        if session.isPracticeComplete {
            session.endPractice()
        } else {
            sessionTimer = 30
            engine.generateNote()
            startSessionTimer()
        }
    }
}
