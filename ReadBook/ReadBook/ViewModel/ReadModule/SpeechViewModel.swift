//
//  SpeechViewModel.swift
//  ReadBook
//
//  Created by 123 on 2019/6/4.
//  Copyright © 2019 hxs. All rights reserved.
//  朗读视图模型

import UIKit
import MediaPlayer
import AVFoundation

class SpeechViewModel: NSObject {
    
    deinit {
        RBSpeechSynthesizer.shared.stopSpeaking(at: .immediate)
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    init(with image: UIImage) {
        super.init()
        
        RBSpeechSynthesizer.shared.delegate = self
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        speechImage = image
    }
    
    /// 书封面
    var speechImage: UIImage?
    
    /// 朗读进度回调
    var speechProgressCompletion: ((_ readString: String, _ unreadString: String) -> Void)?
    
    /// 朗读结束回调
    var speechDidFinishCompletion: (() -> Void)?
    
    /// 暂停恢复
    func pauseOrContinuePlay() {
        RBSpeechSynthesizer.shared.pauseOrContinuePlay()
    }
    
    /// 停止播放
    func stopPlay() {
        RBSpeechSynthesizer.shared.stopSpeaking(at: .immediate)
    }
    
    /// 开始播放
    func startPlay(title: String, artist: String, utterances: [String]) {
        RBSpeechSynthesizer.shared.startPlay(utterances: utterances)
        nowPlayingInfo(title: title, artist: artist)
    }
    func startPlay(title: String, artist: String, utterance: String) {
        RBSpeechSynthesizer.shared.startPlay(utterance: utterance)
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
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
//        let read = (utterance.speechString as NSString).substring(with: NSRange(location: 0, length: characterRange.location + characterRange.length))
//        let unread = (utterance.speechString as NSString).substring(from: characterRange.location + characterRange.length)
//        speechProgressCompletion?(read, unread)
//    }
    
    /// 完成
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speechDidFinishCompletion?()
    }
}
