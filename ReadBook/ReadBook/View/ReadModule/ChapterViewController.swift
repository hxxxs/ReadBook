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

class ChapterViewController: UIViewController {
    
    //  MARK: - Properties Public
    /// 阅读视图模型
    var viewModel: ReadViewModel!
    /// 朗读视图模型
    var speechViewModel: SpeechViewModel!
    
    /// 分页控制器
    private lazy var pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
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
                if let model = strongSelf.chapterModel, strongSelf.fontSize > 20 {
                    strongSelf.fontSize -= 2
                    strongSelf.setupTextView()
                }
            case 100005:
                if let model = strongSelf.chapterModel, strongSelf.fontSize < 36 {
                    strongSelf.fontSize += 2
                    strongSelf.setupTextView()
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
                strongSelf.stopPlay()
                break
            case 100002:
                strongSelf.timing(delay: 15)
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
            
            getTotalPages(string: model.chapter.content.replacingOccurrences(of: "<br/>", with: "\n"))
            pageVC.setViewControllers([pagingvc(page: currentPage)], direction: direction, animated: true, completion: nil)
            
            if isOpenSpeechPattern {
                self.startPlay()
            }
        }
    }
    
    private lazy var changeItem = UIBarButtonItem(title: "换源", style: .done, target: self, action: #selector(changeItemClick))
    
    /// 分页内容
    private var pagingContents = [String]()
    
    /// 分页范围
    private var ranges = [NSRange]()
    
    /// 当前页
    private var currentPage: Int = 0
    
    /// 当前分页控制器
    private var currentPagingVC: PagingViewController?
    
    /// 翻页方向
    private var direction = UIPageViewController.NavigationDirection.forward
    
    /// 是否开启朗读模式
    private var isOpenSpeechPattern: Bool = false
    
    //  MARK: - override
    deinit {
        print("ReadViewController OUT")
        XSHUD.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        loadData(offset: viewModel.bookInfo.offset)
        
        speechViewModel.speechDidFinishCompletion = {[weak self] in
            self?.loadNextData()
        }
        
        speechViewModel.speechProgressCompletion = {[weak self] (read, unread, isPageDown) in
            self?.currentPagingVC?.speechContent(unread: unread, read: read)
            if isPageDown {
                self?.pageDownTap()
            }
        }
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(pageDownTap))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(pageUpTap))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pageVC.view.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
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
        
        stopPlay()
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
                speechViewModel.pauseOrContinuePlay()
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
        direction = .reverse
        loadData(offset: viewModel.bookInfo.offset - 1)
    }
    
    /// 下一章
    private func loadNextData() {
        direction = .forward
        if let model = chapterModel, model.next.offset > 0 {
            loadData(offset: viewModel.bookInfo.offset + 1)
        } else {
            stopPlay()
        }
    }
    
    /// 加载数据
    ///
    /// - Parameter offset: 页码
    private func loadData(offset: Int) {
        currentPage = 0
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
        speechViewModel.pauseOrContinuePlay()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            self.stopPlay()
        }
    }
    
    /// 停止播放
    private func stopPlay() {
        speechViewModel.stopPlay()
        isOpenSpeechPattern = false
        currentPagingVC?.speechContent(unread: pagingContents[currentPage])
    }
    
    /// 开始播放
    private func startPlay() {
        maskView.isHidden = true
        isOpenSpeechPattern = true
        
        var utterance = ""
        for i in currentPage..<pagingContents.count {
            utterance.append(pagingContents[i])
        }
        speechViewModel.startPlay(title: viewModel.bookInfo.title, artist: chapterModel?.current.title ?? "", utterance: utterance)
        if currentPage == ranges.count - 1 {
            speechViewModel.nextPageLocation = ranges[currentPage].length
        } else {
            speechViewModel.nextPageLocation = ranges[currentPage + 1].location - ranges[currentPage].location
        }
    }
}

// MARK: - Monitor

extension ChapterViewController {
    
    @objc private func changeItemClick() {
        let vc = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        vc.addTextField { (textField) in
            textField.placeholder = "请输入章节地址"
        }
        vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
        }))
        
        vc.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak self] (_) in
            guard let sself = self else { return }
            if let tf = vc.textFields?.first,
                let url = tf.text,
                let params = url.urlParameters,
                let id = params["id"] as? String {
                
                if sself.viewModel.bookInfo.id == id {
                    sself.viewModel.bookInfo.md = params["md"] as! String
                    sself.viewModel.bookInfo.cmd = params["cmd"] as! String
                    sself.viewModel.bookInfo.encodeUrl = params["url"] as! String
                    sself.loadData(offset: sself.viewModel.bookInfo.offset)
                }
            }
        }))
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func pageUpTap() {
        if currentPage > 0 {
            currentPage -= 1
            pageVC.setViewControllers([pagingvc(page: currentPage)], direction: .reverse, animated: true, completion: nil)
        } else {
            loadPreviousData()
        }
    }
    
    @objc private func pageDownTap() {
        if currentPage < pagingContents.count - 1 {
            currentPage += 1
            if isOpenSpeechPattern {
                if currentPage == ranges.count - 1 {
                    speechViewModel.nextPageLocation = 99999999
                } else {
                    speechViewModel.nextPageLocation = ranges[currentPage + 1].location
                }
            }
            pageVC.setViewControllers([pagingvc(page: currentPage)], direction: .forward, animated: true, completion: nil)
        } else {
            loadNextData()
        }
    }
    
    private func textViewTap() {
        if isOpenSpeechPattern  {
            speechViewModel.pauseOrContinuePlay()
            playView.isHidden = false
        } else {
            maskView.isHidden = false
        }
    }
    
    @objc private func maskViewTap() {
        maskView.isHidden = true
    }
    
    @objc private func playViewTap() {
        speechViewModel.pauseOrContinuePlay()
    }
}

// MARK: - Data

extension ChapterViewController {
    
    private func setupTextView() {
        if let model = chapterModel {
            getTotalPages(string: model.chapter.content.replacingOccurrences(of: "<br/>", with: "\n"))
        }
        currentPagingVC?.speechContent(unread: pagingContents[currentPage])
    }
    
    private func getTotalPages(string: String) {
        pagingContents.removeAll()
        ranges.removeAll()
        let rect = CGRect(x: 0, y: 0, width: pageVC.view.width - 30 - fontSize / 2, height: pageVC.view.height - 2 * fontSize)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 15
        let attributedString = NSAttributedString(string: string,
                                                  attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: SettingModel.textFontSize), NSAttributedString.Key.paragraphStyle: paragraph])
        
        var rangeIndex = 0
        repeat{
            let length = min(400, attributedString.length - rangeIndex)
            let childString = attributedString.attributedSubstring(from: NSRange(location: rangeIndex, length: length))
            let childFramesetter = CTFramesetterCreateWithAttributedString(childString)
            let bezierPath = UIBezierPath(rect: rect)
            let frame = CTFramesetterCreateFrame(childFramesetter, CFRangeMake(0, 0), bezierPath.cgPath, nil)
            let range = CTFrameGetVisibleStringRange(frame)
            let r:NSRange = NSMakeRange(rangeIndex, range.length)
            if r.length > 0 {
                ranges.append(r)
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
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        
        view.addSubview(maskView)
        view.addSubview(playView)
        
        navigationItem.rightBarButtonItem = changeItem
    }
    
    private func pagingvc(page: Int) -> PagingViewController {
        let vc = PagingViewController()
        vc.speechContent(unread: pagingContents[page])
        vc.monitorCompletion = {[weak self] type in
            switch type {
            case 100001:
                self?.pageUpTap()
            case 100002:
                self?.pageDownTap()
            case 100003:
                self?.textViewTap()
            default:
                break
            }
        }
        currentPagingVC = vc
        return vc
    }
    
}
