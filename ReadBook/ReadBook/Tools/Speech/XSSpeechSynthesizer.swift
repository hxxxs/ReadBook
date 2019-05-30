//
//  XSSpeechSynthesizer.swift
//  ReadBook
//
//  Created by 123 on 2019/5/30.
//  Copyright © 2019 hxs. All rights reserved.
//

import AVFoundation

class XSSpeechSynthesizer: AVSpeechSynthesizer {
    
    /// 开始播放
    ///
    /// - Parameters:
    ///   - utterance: 话语字符串
    ///   - rate: 语速，默认0.55
    ///   - volume: 音量，默认1
    ///   - pitchMutiplier: 音调，默认0.9
    ///   - postUtteranceDelay: 播放下一句时有短暂的停顿，默认1s
    ///   - language: 语言，默认中文
    func startPlay(utterance: String,
               rate: Float = 0.55,
               volume: Float = 1,
               pitchMutiplier: Float = 0.9,
               postUtteranceDelay: TimeInterval = 1,
               language: String = "zh-CN") {
        let u = AVSpeechUtterance(string: utterance)
        u.rate = rate
        u.volume = volume
        u.pitchMultiplier = pitchMutiplier
        u.postUtteranceDelay = postUtteranceDelay
        u.voice = AVSpeechSynthesisVoice(language: language)
        if isSpeaking {
            stopSpeaking(at: .immediate)
        }
        speak(u)
    }
    
    /// 暂停or继续播放
    func pauseOrContinuePlay() {
        if isPaused {
            continueSpeaking()
        } else {
            pauseSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
}
