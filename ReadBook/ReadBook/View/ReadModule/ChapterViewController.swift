//
//  ChapterViewController.swift
//  ReadBook
//
//  Created by 123 on 2019/6/3.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit
import SnapKit
import XSUtil
import AVFoundation
import MediaPlayer

class ChapterViewController: UIViewController {
    
    //  MARK: - Properties Public
    /// 阅读视图模型
    var viewModel: ReadViewModel!
    /// 图书封面图片
    var bookImage: UIImage!
    
    /// 分页控制器
    private lazy var pageVC: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        vc.dataSource = self
        return vc
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
    
    /// 播放视图
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
//                strongSelf.setupTextViewText(unread: strongSelf.content)
                break
            case 100002:
                strongSelf.timing(delay: 15 * 60)
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
    
    /// 文字大小
    private var fontSize = SettingModel.textFontSize {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: kTextFontKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// 章节模型
    private var chapterModel: ReadModel? {
        didSet {
            guard let model = chapterModel else { return }
            self.content = model.chapter.content.replacingOccurrences(of: "<br/>", with: "\n")
//            self.setupTextViewText(unread: self.content)
            
            if speechSynthesizer != nil, speechSynthesizer!.isSpeaking {
                self.startPlay()
            }
        }
    }
    
    /// 分页内容
    private var pagingContents = [String]()
    /// 语音合成器
    private var speechSynthesizer: XSSpeechSynthesizer?
    /// 当前页
    private var currentPage: Int = 0
    /// 当前文本
    private var content = "" {
        didSet {
            getTotalPages(string: content)
            
            pageVC.setViewControllers([pagingvc(page: currentPage)], direction: .forward, animated: true, completion: nil)
        }
    }
    /// 当前分页控制器
    private var currentPagingVC: PagingViewController?
    
    //  MARK: - override
    deinit {
        print("ReadViewController OUT")
        XSHUD.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        loadData(offset: viewModel.bookInfo.offset)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pageVC.view.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.bottom.right.equalToSuperview()
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

extension ChapterViewController {
    
    /// 上一章
    private func loadPreviousData() {
        loadData(offset: viewModel.bookInfo.offset - 1)
    }
    
    /// 下一章
    private func loadNextData() {
        if let model = chapterModel, model.next.offset > 0 {
            loadData(offset: viewModel.bookInfo.offset + 1)
        } else if speechSynthesizer != nil {
//            setupTextViewText(unread: content)
            speechSynthesizer?.stopSpeaking(at: .immediate)
        }
    }
    
    /// 加载数据
    ///
    /// - Parameter offset: 页码
    private func loadData(offset: Int) {
        currentPage = 0
        pagingContents.removeAll()
        viewModel.loadChapterInfo(offset: offset) {[weak self] (model) in
            self?.chapterModel = model
            self?.title = model.current.title
            self?.maskView.isHidden = true
            
            self?.maskView.chapterButtonEnable(previous: model.previous.offset > 0, next: model.next.offset > 0)
        }
    }
}


// MARK: - Read

extension ChapterViewController {
    
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
        if speechSynthesizer == nil {
            speechSynthesizer = XSSpeechSynthesizer()
            speechSynthesizer?.delegate = self
            UIApplication.shared.beginReceivingRemoteControlEvents()
        }
        
        speechSynthesizer?.startPlay(utterance: pagingContents[currentPage])
        nowPlayingInfo()
    }
}

// MARK: - Monitor

extension ChapterViewController {
    
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
    
    @objc private func playViewTap() {
        speechSynthesizer?.pauseOrContinuePlay()
        playView.isHidden = true
    }
}

// MARK: - Data

extension ChapterViewController {
    
    private func getTotalPages(string: String) {
        let rect = CGRect(x: 0, y: 0, width: view.width - 30, height: view.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 15
        let attributedString = NSAttributedString(string: string,
                                                  attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: SettingModel.textFontSize), NSAttributedString.Key.paragraphStyle: paragraph])

        var rangeIndex = 0
        repeat{
            let length = min(240, attributedString.length - rangeIndex)
            let childString = attributedString.attributedSubstring(from: NSRange(location: rangeIndex, length: length))
            let childFramesetter = CTFramesetterCreateWithAttributedString(childString)
            let bezierPath = UIBezierPath(rect: rect)
            let frame = CTFramesetterCreateFrame(childFramesetter, CFRangeMake(0, 0), bezierPath.cgPath, nil)
            let range = CTFrameGetVisibleStringRange(frame)
            let r:NSRange = NSMakeRange(rangeIndex, range.length)
            if r.length > 0 {
                pagingContents.append((string as NSString).substring(with: r))
            }
            rangeIndex += r.length
            
        } while (rangeIndex < attributedString.length  && Int(attributedString.length) > 0 )
    }
}

// MARK: - UI

extension ChapterViewController {
    
    private func setup() {
        view.backgroundColor = UIColor(hex: 0xCDDFD1)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textViewTap)))
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        
        view.addSubview(maskView)
        view.addSubview(playView)
    }
    
    private func pagingvc(page: Int) -> PagingViewController {
        let vc = PagingViewController()
        vc.speechContent(unread: pagingContents[page], read: nil)
        currentPagingVC = vc
        return vc
    }
    
}

// MARK: - AVSpeechSynthesizerDelegate

extension ChapterViewController: AVSpeechSynthesizerDelegate {
    
    /// 即将朗读
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        
        let read = (utterance.speechString as NSString).substring(to: characterRange.location + characterRange.length)
        let unread = (utterance.speechString as NSString).substring(from: characterRange.location + characterRange.length)
        
        currentPagingVC?.speechContent(unread: unread, read: read)
    }
    
    /// 完成
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if currentPage <= pagingContents.count - 1 {
            currentPage += 1
            pageVC.setViewControllers([pagingvc(page: currentPage)], direction: .forward, animated: true) { (_) in
                self.startPlay()
            }
        } else {
            loadNextData()
        }
    }
}


// MARK: - UIPageViewControllerDataSource

extension ChapterViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentPage <= 0 {
            return nil
        }
        currentPage -= 1
        return pagingvc(page: currentPage)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentPage >= pagingContents.count - 1 {
            return nil
        }
        currentPage += 1
        return pagingvc(page: currentPage)
    }
}
