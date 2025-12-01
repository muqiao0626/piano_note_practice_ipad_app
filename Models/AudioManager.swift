import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var engine: AVAudioEngine?
    private var player: AVAudioPlayerNode?
    private var format: AVAudioFormat?
    private let audioQueue = DispatchQueue(label: "com.pianolearn.audio", qos: .userInitiated)
    
    init() {
        audioQueue.async { [weak self] in
            self?.setupAudio()
        }
    }
    
    private func setupAudio() {
        engine = AVAudioEngine()
        player = AVAudioPlayerNode()
        
        // Configure Audio Session for iOS
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
        
        guard let engine = engine, let player = player else { return }
        
        engine.attach(player)
        
        let outputFormat = engine.outputNode.inputFormat(forBus: 0)
        format = AVAudioFormat(
            standardFormatWithSampleRate: 44100.0,
            channels: outputFormat.channelCount
        )
        
        guard let format = format else { return }
        
        engine.connect(player, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("Audio Engine failed to start: \(error)")
        }
    }
    
    func play(note: Note) {
        audioQueue.async { [weak self] in
            self?.playSync(note: note)
        }
    }
    
    private func playSync(note: Note) {
        guard let player = player,
              let engine = engine,
              let format = format,
              engine.isRunning else {
            return
        }
        
        let frequency = frequencyFor(note: note)
        let sampleRate = format.sampleRate
        let duration = 1.0
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return
        }
        
        buffer.frameLength = frameCount
        guard let channels = buffer.floatChannelData else { return }
        
        let channelCount = Int(format.channelCount)
        
        // Piano-like harmonics
        let harmonics: [(frequency: Double, amplitude: Float)] = [
            (1.0, 1.0),
            (2.0, 0.5),
            (3.0, 0.3),
            (4.0, 0.2),
            (5.0, 0.15),
            (6.0, 0.1),
        ]
        
        for i in 0..<Int(frameCount) {
            let t = Float(i) / Float(sampleRate)
            
            // ADSR Envelope
            let attack: Float = 0.01
            let decay: Float = 0.1
            let sustain: Float = 0.1
            let release: Float = 0.1
            
            var envelope: Float = 1.0
            if t < attack {
                envelope = t / attack
            } else if t < attack + decay {
                let decayProgress = (t - attack) / decay
                envelope = 1.0 - (1.0 - sustain) * decayProgress
            } else if t < Float(duration) - release {
                envelope = sustain
            } else {
                let releaseProgress = (t - (Float(duration) - release)) / release
                envelope = sustain * (1.0 - releaseProgress)
            }
            
            // Generate sample with harmonics
            var sample: Float = 0.0
            for harmonic in harmonics {
                let harmonicFreq = frequency * harmonic.frequency
                let theta = Float(i) / Float(sampleRate) * Float(harmonicFreq) * 2.0 * Float.pi
                sample += sin(theta) * harmonic.amplitude
            }
            
            sample = sample / Float(harmonics.count) * 0.3 * envelope
            
            for channel in 0..<channelCount {
                channels[channel][i] = sample
            }
        }
        
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }
    
    private func frequencyFor(note: Note) -> Double {
        let midiNote = note.midiValue
        let semitones = midiNote - 69
        return 440.0 * pow(2.0, Double(semitones) / 12.0)
    }
}
