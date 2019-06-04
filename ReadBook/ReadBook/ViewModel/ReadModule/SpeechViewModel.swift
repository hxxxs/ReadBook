//
//  SpeechViewModel.swift
//  ReadBook
//
//  Created by 123 on 2019/6/4.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class SpeechViewModel: NSObject {
    
    deinit {
        XSSpeechSynthesizer.shared.stopSpeaking(at: .immediate)
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    init(with image: UIImage) {
        super.init()
        
        XSSpeechSynthesizer.shared.delegate = self
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        speechImage = image
    }
    
    var speechImage: UIImage?
    
    var speechProgressCompletion: ((_ readString: String, _ unreadString: String) -> ())?
    
    var speechDidFinishCompletion: (() -> ())?
    
    /// 暂停恢复
    func pauseOrContinuePlay() {
        XSSpeechSynthesizer.shared.pauseOrContinuePlay()
    }
    
    /// 停止播放
    func stopPlay() {
        XSSpeechSynthesizer.shared.stopSpeaking(at: .immediate)
    }
    
    /// 开始播放
    func startPlay(title: String, artist: String, utterance: String) {
        XSSpeechSynthesizer.shared.startPlay(utterance: utterance)
        nowPlayingInfo(title: title, artist: artist)
    }
    
    /// 锁屏信息
    private func nowPlayingInfo(title: String, artist: String) {
        let noDataImage = UIImage(imageLiteralResourceName: "noData")
        let artwork = MPMediaItemArtwork(boundsSize: noDataImage.size) {[weak self] _ in
            return self?.speechImage ?? noDataImage
        }
        let dic = [MPMediaItemPropertyTitle: title,
                   MPMediaItemPropertyArtist: artist,
                   MPMediaItemPropertyArtwork: artwork] as [String : Any]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = dic
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechViewModel: AVSpeechSynthesizerDelegate {
    
    /// 即将朗读
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        
        let read = (utterance.speechString as NSString).substring(to: characterRange.location + characterRange.length)
        let unread = (utterance.speechString as NSString).substring(from: characterRange.location + characterRange.length)
        
        speechProgressCompletion?(read, unread)
    }
    
    /// 完成
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speechDidFinishCompletion?()
    }
}
