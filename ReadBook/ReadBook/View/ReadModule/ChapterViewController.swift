//
//  ChapterViewController.swift
//  ReadBook
//
//  Created by 123 on 2019/6/3.
//  Copyright © 2019 hxs. All rights reserved.
//  章节控制器

import UIKit

class ChapterViewController: UIViewController {
    
    //  MARK: - Properties Public
    /// 阅读视图模型
    var viewModel: ReadViewModel!
    /// 朗读视图模型
    var speechViewModel: SpeechViewModel!
    
    //  MARK: - Properties Private
    /// 分页控制器
    private lazy var pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    /// 蒙层视图
    private lazy var maskView: MaskView = {
        let v  = MaskView.viewFromNib() as! MaskView // swiftlint:disable:this force_cast
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
                    strongSelf.resetTextView()
                }
            case 100005:
                if let model = strongSelf.chapterModel, strongSelf.fontSize < 36 {
                    strongSelf.fontSize += 2
                    strongSelf.resetTextView()
                }
            default:
                break
            }
        }
        return v
    }()
    
    /// 播放视图
    private lazy var playView: PlayView = {
        let v  = PlayView.viewFromNib() as! PlayView // swiftlint:disable:this force_cast
        v.isHidden = true
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playViewTap)))
        v.monitorCompletion = {[weak self] (view, type) in
            view.isHidden = true
            guard let strongSelf = self else { return }
            switch type {
            case 100001:
                strongSelf.stopPlay()
            case 100002:
                strongSelf.timing(delay: 15 * 60)
            case 100003:
                strongSelf.timing(delay: 30 * 60)
            case 100004:
                strongSelf.timing(delay: 60 * 60)
            case 100005:
                strongSelf.timing(delay: 120 * 60)
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
        willSet {
            if newValue != nil {
                newValue?.content = newValue!.content
                    .replacingOccurrences(of: "?", with: "？")
            }
        }
    }
    
    /// 分页内容
    private var pagingContents = [String]()
    
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
        print("ChapterViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupSpeechViewModel()
        setupGesture()
        RBSQlite.shared.delete(id: viewModel.bookInfo.gid, url: viewModel.bookInfo.url)
        loadData(cid: viewModel.bookInfo.cid, url: viewModel.bookInfo.url, false)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(jump))
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
            case .remoteControlPlay, .remoteControlPause, .remoteControlTogglePlayPause://  播放,暂停,耳机暂停or播放
                speechViewModel.pauseOrContinuePlay()
            case .remoteControlNextTrack:// 下一章
                loadNextData()
            case .remoteControlPreviousTrack:// 上一章
                loadPreviousData()
            default:
                break
            }
        }
    }
    
    @objc func jump() {
        let vc = UIAlertController(title: "跳转", message: nil, preferredStyle: .alert)
        vc.addTextField { (textField) in
            textField.placeholder = "请输入章节地址"
            textField.font = UIFont.systemFont(ofSize: 20)
            textField.keyboardType = .URL
        }
        vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        vc.addAction(UIAlertAction(title: "跳转", style: .default, handler: {[weak self] (_) in
            if let tf = vc.textFields?.first,
                let url = tf.text,
                let params = url.urlParameters,
                let book = BookInfoModel(JSON: params) {
                self?.loadData(cid: book.cid, url: book.url, false)
            }
        }))
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - Net

extension ChapterViewController: NVActivityIndicatorViewable {
    
    /// 上一章
    private func loadPreviousData(_ isShowLastPage: Bool = false) {
        direction = .reverse
        if let model = chapterModel, model.pre_url.count > 0 {
            loadData(cid: model.pre_cid, url: model.pre_url, isShowLastPage)
        }
    }
    
    /// 下一章
    private func loadNextData() {
        direction = .forward
        if let model = chapterModel, model.next_url.count > 0 {
            loadData(cid: model.next_cid, url: model.next_url, false)
        } else {
            stopPlay()
        }
    }
    
    /// 加载数据
    private func loadData(cid: String, url: String, _ isShowLastPage: Bool) {
        startAnimating(CGSize(width: 30, height: 30), type: .ballRotateChase)
        viewModel.loadChapterInfo(cid: cid, url: url) {[weak self] (model, error) in
            self?.stopAnimating()
            if let model = model {
                self?.chapterModel = model
                self?.title = model.title
                self?.maskView.isHidden = true
                
                self?.maskView.chapterButtonEnable(previous: model.pre_cid.count > 0, next: model.next_cid.count > 0)
                
                self?.setupPageVC(isShowLastPage)
            } else {
                XSHUD.show(text: error ?? "")
            }
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
        
        var utterances = [String]()
        for i in currentPage..<pagingContents.count {
            utterances.append(pagingContents[i])
        }

        speechViewModel.startPlay(title: viewModel.bookInfo.title, artist: chapterModel?.title ?? "", utterances: utterances)
    }
}

// MARK: - Monitor

extension ChapterViewController {
    
    /// 上翻页
    @objc private func pageUpTap() {
        if currentPage > 0 {
            currentPage -= 1
            pageVC.setViewControllers([pagingvc(page: currentPage)], direction: .reverse, animated: true, completion: nil)
        } else {
            loadPreviousData(true)
        }
    }
    
    /// 下翻页
    @objc private func pageDownTap() {
        if currentPage < pagingContents.count - 1 {
            currentPage += 1
            if isOpenSpeechPattern {
                currentPagingVC?.speechContent(unread: pagingContents[currentPage])
            } else {
                pageVC.setViewControllers([pagingvc(page: currentPage)], direction: .forward, animated: true, completion: nil)
            }
        } else {
            loadNextData()
        }
    }
    
    /// 文本视图点击
    private func textViewTap() {
        if isOpenSpeechPattern {
            speechViewModel.pauseOrContinuePlay()
            playView.isHidden = false
        } else {
            maskView.isHidden = false
        }
    }
    
    /// 蒙版视图点击
    @objc private func maskViewTap() {
        maskView.isHidden = true
    }
    
    /// 播放视图点击
    @objc private func playViewTap() {
        speechViewModel.pauseOrContinuePlay()
        playView.isHidden = true
    }
}

// MARK: - Data

extension ChapterViewController {
    
    /// 获取总页数
    private func getTotalPages(string: String) {
        currentPage = 0
        pagingContents.removeAll()
        
        let rect = CGRect(x: 0, y: 0, width: pageVC.view.width - 30 - fontSize / 2, height: pageVC.view.height - 2 * fontSize)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 15
        let attributedString = NSAttributedString(string: string,
                                                  attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: SettingModel.textFontSize), NSAttributedString.Key.paragraphStyle: paragraph])
        
        var rangeIndex = 0
        repeat {
            let length = min(750, attributedString.length - rangeIndex)
            let childString = attributedString.attributedSubstring(from: NSRange(location: rangeIndex, length: length))
            let childFramesetter = CTFramesetterCreateWithAttributedString(childString)
            let bezierPath = UIBezierPath(rect: rect)
            let frame = CTFramesetterCreateFrame(childFramesetter, CFRangeMake(0, 0), bezierPath.cgPath, nil)
            let range = CTFrameGetVisibleStringRange(frame)
            let r = NSRange(location: rangeIndex, length: range.length)
            if r.length > 0 {
                pagingContents.append((string as NSString).substring(with: r))
            }
            rangeIndex += r.length
        } while (rangeIndex < attributedString.length  && Int(attributedString.length) > 0 )
    }
}

// MARK: - UI

extension ChapterViewController {
    
    /// 设置
    private func setup() {
        view.backgroundColor = UIColor(hex: 0xCDDFD1)
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        
        view.addSubview(maskView)
        view.addSubview(playView)
    }
    
    /// 配置手势
    private func setupGesture() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(pageDownTap))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(pageUpTap))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }
    
    /// 配置朗读视图模型
    private func setupSpeechViewModel() {
        speechViewModel.speechDidFinishCompletion = {[weak self] in
            self?.pageDownTap()
        }
        
        speechViewModel.speechProgressCompletion = {[weak self] (read, unread) in
            self?.currentPagingVC?.speechContent(unread: unread, read: read)
        }
    }
    
    /// 设置分页控制器
    private func setupPageVC(_ isShowLastPage: Bool) {
        guard let model = chapterModel else { return }
        
        getTotalPages(string: model.content)
        if isShowLastPage {
            currentPage = pagingContents.count - 1
        }
        
        if isOpenSpeechPattern {
            startPlay()
            currentPagingVC?.speechContent(unread: pagingContents[0])
        } else {
            pageVC.setViewControllers([pagingvc(page: currentPage)], direction: direction, animated: true, completion: nil)
        }
    }
    
    /// 重新设置文本视图
    private func resetTextView() {
        if let model = chapterModel {
            getTotalPages(string: model.content)
        }
        currentPagingVC?.speechContent(unread: pagingContents[currentPage])
    }
    
    /// 分页控制器
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
