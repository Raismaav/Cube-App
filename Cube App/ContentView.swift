import SwiftUI

// Define possible states for the stopwatch
enum StopwatchState {
    case idle     // Not started or has been reset
    case running  // Running
    case stopped  // Stopped with a recorded time
}

struct ContentView: View {
    @State private var startTime: Date? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var state: StopwatchState = .idle
    @State private var timer: Timer? = nil
    @State private var recordedTimes: [TimeInterval] = []
    
    // Variables to validate touch duration and display behavior
    @State private var tapStartTime: Date? = nil
    @State private var indicatorColor: Color = .primary  // Default color (when not interacting)
    
    // Computed property to define the dynamic background color
    var dynamicBackground: Color {
        if indicatorColor == .red {
            return Color.red.opacity(0.2)
        } else if indicatorColor == .green {
            return Color.green.opacity(0.2)
        } else {
            return Color.black.opacity(0.05)
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Display the elapsed time with the indicator color
            Text(formatTime(elapsedTime))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(indicatorColor)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(dynamicBackground)
        // Gesture to measure touch duration (to start/reset)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if state != .running {
                        // If this is the first touch event, record the time and set the color to red
                        if tapStartTime == nil {
                            tapStartTime = Date()
                            indicatorColor = .red
                        }
                        let duration = Date().timeIntervalSince(tapStartTime!)
                        // Update color: red if the duration is less than 0.5s, green if greater or equal
                        if duration >= 0.5 {
                            indicatorColor = .green // Visually reset the stopwatch
                            elapsedTime = 0  // Reset time to 0.000
                        } else {
                            indicatorColor = .red
                        }
                    }
                }
                .onEnded { _ in
                    if state != .running {
                        let duration = Date().timeIntervalSince(tapStartTime ?? Date())
                        // If the touch lasted at least 0.5s, start or reset the stopwatch
                        if duration >= 0.5 {
                            if state == .idle {
                                startTimer()
                            } else if state == .stopped {
                                resetTimer()
                            }
                        }
                        // Reset gesture variables and restore default color
                        tapStartTime = nil
                        indicatorColor = .primary
                    }
                }
        )
        // Single tap to stop the stopwatch when running
        .onTapGesture {
            if state == .running {
                stopTimer()
                recordedTimes.append(elapsedTime)
                print("Saved time: \(formatTime(elapsedTime))")
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // Starts the stopwatch timer
    private func startTimer() {
        guard state == .idle || state == .stopped else { return }
        startTime = Date()
        state = .running
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if let start = self.startTime {
                self.elapsedTime = Date().timeIntervalSince(start)
            }
        }
    }
    
    // Stops the stopwatch timer
    private func stopTimer() {
        guard state == .running else { return }
        timer?.invalidate()
        timer = nil
        state = .stopped
    }
    
    // Resets the stopwatch timer
    private func resetTimer() {
        stopTimer()  // Ensure timer is stopped before resetting
        elapsedTime = 0
        startTime = nil
        startTimer()
    }
    
    // Formats the elapsed time into a readable string
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time - Double(Int(time))) * 1000)
        
        return minutes > 0 ?
            String(format: "%d:%02d.%03d", minutes, seconds, milliseconds) :
            String(format: "%d.%03d", seconds, milliseconds)
    }
}

#Preview {
    ContentView()
}
