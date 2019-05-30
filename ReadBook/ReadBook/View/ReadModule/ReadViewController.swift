//
//  ReadViewController.swift
//  ReadBook
//
//  Created by 123 on 2019/5/15.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit
import SnapKit
import XSUtil
import AVFoundation
import MediaPlayer

class ReadViewController: UIViewController {
    
    /// 文字视图
    private lazy var textView: UITextView = {
        let v = UITextView()
        v.textColor = UIColor(hex: 0x546356)
        v.backgroundColor = UIColor.clear
        v.delegate = self
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textViewTap)))
        v.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return v
    }()
    
    /// 蒙层视图
    private lazy var maskView: MaskView = {
        let v = MaskView.viewFromNib() as! MaskView
        v.isHidden = true
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(maskViewTap)))
        v.monitorCompletion = {[weak self] type in
            guard let strongSelf = self else { return }
            switch type {
            case 100001: // 上一章
                strongSelf.loadPreviousData()
            case 100002: // 下一章
                strongSelf.loadNextData()
            case 100003:
                strongSelf.startPlay()
            case 100004:
                if let model = strongSelf.chapterModel {
                    strongSelf.fontSize -= 1
                    strongSelf.chapterModel = model
                }
            case 100005:
                if let model = strongSelf.chapterModel {
                    strongSelf.fontSize += 1
                    strongSelf.chapterModel = model
                }
            default:
                break
            }
        }
        return v
    }()
    
    /// 章节模型
    private var chapterModel: ReadModel? {
        didSet {
            guard let model = chapterModel else { return }
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 15
            self.textView.attributedText = NSAttributedString(string: model.chapter.content.replacingOccurrences(of: "<br/>", with: "\n"), attributes: [NSAttributedString.Key.paragraphStyle: paragraph,
                                                                                                                                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)])
            
            if speechSynthesizer != nil {
                self.startPlay()
            }
        }
    }
    
    /// 文字大小
    private var fontSize = SettingModel.textFontSize {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: kTextFontKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// 语音合成器
    private var speechSynthesizer: XSSpeechSynthesizer?
    
    /// 蒙层视图
    private lazy var playView: PlayView = {
        let v = PlayView.viewFromNib() as! PlayView
        v.isHidden = true
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playViewTap)))
        v.monitorCompletion = {[weak self] (view, type) in
            view.isHidden = true
            guard let strongSelf = self else { return }
            switch type {
            case 100001:
                strongSelf.speechSynthesizer?.stopSpeaking(at: .immediate)
                break
            case 100002:
                strongSelf.timing(delay: 1 * 60)
                break
            case 100003:
                strongSelf.timing(delay: 30 * 60)
                break
            case 100004:
                strongSelf.timing(delay: 60 * 60)
                break
            case 100005:
                strongSelf.timing(delay: 120 * 60)
                break
            default:
                break
            }
        }
        return v
    }()
    
    /// 阅读视图模型
    var viewModel: ReadViewModel!
    
    /// 图书封面图片
    var bookImage: UIImage!
    
    deinit {
        print("ReadViewController OUT")
        XSHUD.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0xCDDFD1)
        view.addSubview(textView)
        view.addSubview(maskView)
        view.addSubview(playView)
        
        loadData(offset: viewModel.bookInfo.offset)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        maskView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        playView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        speechSynthesizer?.stopSpeaking(at: .immediate)
        UIApplication.shared.endReceivingRemoteControlEvents()
        speechSynthesizer = nil
    }

    override func remoteControlReceived(with event: UIEvent?) {
        guard let event = event else { return }
        if event.type == UIEvent.EventType.remoteControl {
            switch event.subtype {
            case UIEvent.EventSubtype.remoteControlPlay://  播放
                fallthrough
            case UIEvent.EventSubtype.remoteControlPause:// 暂停
                fallthrough
            case UIEvent.EventSubtype.remoteControlTogglePlayPause:// 耳机暂停or播放
                speechSynthesizer?.pauseOrContinuePlay()
            case UIEvent.EventSubtype.remoteControlNextTrack:// 下一章
                loadNextData()
            case UIEvent.EventSubtype.remoteControlPreviousTrack:// 上一章
                loadPreviousData()
            default:
                break
            }
        }
    }
}

// MARK: - Net

extension ReadViewController {
    
    /// 上一章
    private func loadPreviousData() {
        textView.setContentOffset(CGPoint.zero, animated: false)
        loadData(offset: viewModel.bookInfo.offset - 1)
    }
    
    /// 下一章
    private func loadNextData() {
        textView.setContentOffset(CGPoint.zero, animated: false)
        if let model = chapterModel, model.next.offset > 0 {
            loadData(offset: viewModel.bookInfo.offset + 1)
        } else if speechSynthesizer != nil {
            speechSynthesizer?.stopSpeaking(at: .immediate)
        }
    }
    
    /// 加载数据
    ///
    /// - Parameter offset: 页码
    private func loadData(offset: Int) {
        textView.isUserInteractionEnabled = false
        viewModel.loadChapterInfo(offset: offset) {[weak self] (model) in
            self?.chapterModel = model
            self?.title = model.current.title
            self?.maskView.isHidden = true
            
            self?.maskView.chapterButtonEnable(previous: model.previous.offset > 0, next: model.next.offset > 0)
            self?.textView.isUserInteractionEnabled = true
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension ReadViewController: AVSpeechSynthesizerDelegate {

    /// 完成
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        loadNextData()
    }
}

// MARK: - Read

extension ReadViewController {
    
    /// 定时关闭
    private func timing(delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            self.speechSynthesizer?.stopSpeaking(at: .immediate)
        }
    }
    
    /// 锁屏信息
    private func nowPlayingInfo() {
        let artwork = MPMediaItemArtwork(boundsSize: bookImage.size) {[weak self]_ in
            guard let sf = self else { return UIImage(imageLiteralResourceName: "noData") }
            return sf.bookImage
        }
        let dic = [MPMediaItemPropertyTitle: viewModel.bookInfo.title,
                   MPMediaItemPropertyArtist: chapterModel?.current.title ?? "",
                   MPMediaItemPropertyArtwork: artwork] as [String : Any]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = dic
    }
    
    /// 开始播放
    private func startPlay() {
        maskView.isHidden = true
        
        if let content = chapterModel?.chapter.content {
            if speechSynthesizer == nil {
                speechSynthesizer = XSSpeechSynthesizer()
                speechSynthesizer?.delegate = self
                UIApplication.shared.beginReceivingRemoteControlEvents()
            }
            
            speechSynthesizer?.startPlay(utterance: content.replacingOccurrences(of: "<br/>", with: ""))
            nowPlayingInfo()
        }
    }
}

// MARK: - Monitor

extension ReadViewController {
    
    @objc private func playViewTap() {
        speechSynthesizer?.pauseOrContinuePlay()
        playView.isHidden = true
    }
    
    @objc private func maskViewTap() {
        maskView.isHidden = true
    }
    
    @objc private func textViewTap() {
        if speechSynthesizer != nil, speechSynthesizer!.isSpeaking {
            speechSynthesizer?.pauseOrContinuePlay()
            playView.isHidden = false
        } else {
            maskView.isHidden = false
        }
    }

}

// MARK: - UITextViewDelegate

extension ReadViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
}
