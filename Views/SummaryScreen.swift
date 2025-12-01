import SwiftUI

struct SummaryScreen: View {
    @ObservedObject var session: PracticeSession
    @ObservedObject var engine: GameEngine
    
    var accuracy: Double {
        session.totalSessions > 0 ?
            (Double(session.correctSessions) / Double(session.totalSessions)) * 100 : 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(0.2),
                        Color.blue.opacity(0.2),
                        Color.purple.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Trophy icon
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 140, height: 140)
                            .shadow(radius: 10)
                        
                        Text(accuracy >= 80 ? "🏆" : accuracy >= 60 ? "🎯" : "📚")
                            .font(.system(size: 70))
                    }
                    
                    // Title
                    VStack(spacing: 10) {
                        Text("Practice Complete!")
                            .font(.system(size: 45, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(accuracy >= 80 ? "Excellent Work!" :
                             accuracy >= 60 ? "Good Job!" : "Keep Practicing!")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Results Cards
                    HStack(spacing: 30) {
                        // Accuracy Card
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                    .frame(width: 180, height: 180)
                                
                                Circle()
                                    .trim(from: 0, to: accuracy / 100)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.green, Color.blue]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                    )
                                    .frame(width: 180, height: 180)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack(spacing: 5) {
                                    Text(String(format: "%.0f%%", accuracy))
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text("Accuracy")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                }
                            }
                        }
                        .padding(30)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(25)
                        .shadow(radius: 5)
                        
                        VStack(spacing: 20) {
                            // Correct Sessions Card
                            HStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.2))
                                        .frame(width: 70, height: 70)
                                    Text("✓")
                                        .font(.system(size: 35, weight: .bold))
                                        .foregroundColor(.green)
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("\(session.correctSessions)")
                                        .font(.system(size: 44, weight: .bold))
                                        .foregroundColor(.green)
                                    Text("Correct")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(25)
                            .frame(width: 280)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(20)
                            .shadow(radius: 3)
                            
                            // Total Sessions Card
                            HStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 70, height: 70)
                                    Text("Σ")
                                        .font(.system(size: 35, weight: .bold))
                                        .foregroundColor(.blue)
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("\(session.totalSessions)")
                                        .font(.system(size: 44, weight: .bold))
                                        .foregroundColor(.blue)
                                    Text("Total")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(25)
                            .frame(width: 280)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(20)
                            .shadow(radius: 3)
                        }
                    }
                    
                    // Action Button
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        session.resetForNewPractice()
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title)
                            Text("Practice Again")
                                .font(.system(size: 28, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(width: 350, height: 80)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
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
