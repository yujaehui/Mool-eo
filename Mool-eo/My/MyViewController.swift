//
//  MyViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum DragDirection {
    case Up
    case Down
}

protocol InnerScrollDelegate: AnyObject {
    var currentHeaderHeight: CGFloat { get }
    func innerDidScroll(withDistance scrollDistance: CGFloat)
    func innerScrollEnded(withScrollDirection scrollDirection: DragDirection)
}

var topViewInitialHeight : CGFloat = 140
let topViewFinalHeight : CGFloat = 0
var topViewHeightConstraintRange = topViewFinalHeight..<topViewInitialHeight

class MyViewController: BaseViewController {
    
    let viewModel = MyViewModel()
    let myView = MyView()
    
    let reload = BehaviorSubject<Void>(value: ())
    
    var pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var pageCollection = PageCollection()
    
    var dragInitialY: CGFloat = 0
    var dragPreviousY: CGFloat = 0
    var dragDirection: DragDirection = .Up
    
    override func loadView() {
        self.view = myView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabbarCollectionView()
        setupPagingViewController()
        populateBottomView()
        addPanGestureToTopViewAndCollectionView()
    }
    
    override func bind() {
        let profileEditButtonTap = myView.stickyHeaderView.profileEditButton.rx.tap.asObservable()
        let input = MyViewModel.Input(reload: reload, profileEditButtonTap: profileEditButtonTap)
        
        let output = viewModel.transform(input: input)
        
        output.profile.bind(with: self) { owner, profile in
            URLImageSettingManager.shared.setImageWithUrl(owner.myView.stickyHeaderView.profileImageView, urlString: profile.profileImage)
            owner.myView.stickyHeaderView.nicknameLabel.text = profile.nick
            owner.myView.stickyHeaderView.followLabel.text = "팔로워 \(profile.followers.count) | 팔로잉 \(profile.following.count)"
        }.disposed(by: disposeBag)
        
        output.profileEditButtonTap.bind(with: self) { owner, profile in
            let vc = ProfileEditViewController()
            vc.profileImageData = owner.myView.stickyHeaderView.profileImageView.image?.pngData()
            vc.profileImage = profile.profileImage
            vc.nickname = profile.nick
            vc.introduction = profile.introduction
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
    
    func setupTabbarCollectionView() {
        myView.tabbarCollectionView.dataSource = self
        myView.tabbarCollectionView.delegate = self
    }
    
    func setupPagingViewController() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
    
    func populateBottomView() {
        let postVC = MyPostViewController()
        postVC.innerScrollDelegate = self
        let postPage = Page(with: "게시글", _vc: postVC)
        pageCollection.pages.append(postPage)
        
        let productVC = MyProductViewController()
        productVC.innerScrollDelegate = self
        let productPage = Page(with: "상품", _vc: productVC)
        pageCollection.pages.append(productPage)
        
        let paymentVC = MyPaymentViewController()
        paymentVC.innerScrollDelegate = self
        let paymentPage = Page(with: "결제", _vc: paymentVC)
        pageCollection.pages.append(paymentPage)
        
        pageViewController.setViewControllers([pageCollection.pages[0].vc], direction: .forward, animated: true, completion: nil)
        addChild(pageViewController)
        pageViewController.willMove(toParent: self)
        myView.bottomView.addSubview(pageViewController.view)
        pinPagingViewControllerToBottomView()
    }
    
    func pinPagingViewControllerToBottomView() {
        pageViewController.view.snp.makeConstraints { make in
            make.edges.equalTo(myView.bottomView)
        }
    }
    
    func addPanGestureToTopViewAndCollectionView() {
        let topViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(topViewMoved))
        myView.stickyHeaderView.addGestureRecognizer(topViewPanGesture)
    }
    
    @objc func topViewMoved(_ gesture: UIPanGestureRecognizer) {
        var dragYDiff: CGFloat
        
        switch gesture.state {
        case .began:
            dragInitialY = gesture.location(in: self.view).y
            dragPreviousY = dragInitialY
        case .changed:
            let dragCurrentY = gesture.location(in: self.view).y
            dragYDiff = dragPreviousY - dragCurrentY
            dragPreviousY = dragCurrentY
            dragDirection = dragYDiff < 0 ? .Down : .Up
            innerDidScroll(withDistance: dragYDiff)
        case .ended:
            innerScrollEnded(withScrollDirection: dragDirection)
        default: return
        }
    }
    
    func setBottomPagingView(toPageWithAtIndex index: Int, andNavigationDirection navigationDirection: UIPageViewController.NavigationDirection) {
        pageViewController.setViewControllers([pageCollection.pages[index].vc], direction: navigationDirection, animated: true, completion: nil)
    }
    
    func scrollSelectedTabView(toIndexPath indexPath: IndexPath, shouldAnimate: Bool = true) {
        UIView.animate(withDuration: 0.3) {
            if let cell = self.myView.tabbarCollectionView.cellForItem(at: indexPath) {
                self.myView.selectedTabView.frame.size.width = cell.frame.width
                self.myView.selectedTabView.frame.origin.x = cell.frame.origin.x
            }
        }
    }
}

extension MyViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageCollection.pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabbarCollectionViewCell.identifier, for: indexPath) as! TabbarCollectionViewCell
        cell.tabLabel.text = pageCollection.pages[indexPath.row].name
        return cell
    }
}

extension MyViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == pageCollection.selectedPageIndex {
            return
        }
        
        var direction: UIPageViewController.NavigationDirection
        
        if indexPath.item > pageCollection.selectedPageIndex {
            direction = .forward
        } else {
            direction = .reverse
        }
        
        pageCollection.selectedPageIndex = indexPath.item
        
        myView.tabbarCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        scrollSelectedTabView(toIndexPath: indexPath)
        setBottomPagingView(toPageWithAtIndex: indexPath.item, andNavigationDirection: direction)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}

extension MyViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.vc == viewController }) {
            if (1..<pageCollection.pages.count).contains(currentViewControllerIndex) {
                return pageCollection.pages[currentViewControllerIndex - 1].vc
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.vc == viewController }) {
            if (0..<(pageCollection.pages.count - 1)).contains(currentViewControllerIndex) {
                return pageCollection.pages[currentViewControllerIndex + 1].vc
            }
        }
        return nil
    }
}

extension MyViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        guard let currentVC = pageViewController.viewControllers?.first else { return }
        guard let currentVCIndex = pageCollection.pages.firstIndex(where: { $0.vc == currentVC }) else { return }
        
        let indexPathAtCollectionView = IndexPath(item: currentVCIndex, section: 0)
        scrollSelectedTabView(toIndexPath: indexPathAtCollectionView)
        myView.tabbarCollectionView.scrollToItem(at: indexPathAtCollectionView, at: .centeredHorizontally, animated: true)
    }
}

extension MyViewController: InnerScrollDelegate {
    var currentHeaderHeight: CGFloat {
        return myView.headerViewHeightConstraint.layoutConstraints[0].constant
    }
    
    func innerDidScroll(withDistance scrollDistance: CGFloat) {
        myView.headerViewHeightConstraint.update(offset: myView.headerViewHeightConstraint.layoutConstraints[0].constant - scrollDistance)
        
        if myView.headerViewHeightConstraint.layoutConstraints[0].constant < topViewFinalHeight {
            myView.headerViewHeightConstraint.update(offset: topViewFinalHeight)
        }
    }
    
    func innerScrollEnded(withScrollDirection scrollDirection: DragDirection) {
        let topViewHeight = myView.headerViewHeightConstraint.layoutConstraints[0].constant
        
        if topViewHeight <= topViewFinalHeight + 20 {
            scrollToFinalView()
        } else if topViewHeight <= topViewInitialHeight - 20 {
            switch scrollDirection {
            case .Down: scrollToInitialView()
            case .Up: scrollToFinalView()
            }
        } else {
            scrollToInitialView()
        }
    }
    
    func scrollToInitialView() {
        let topViewCurrentHeight = myView.stickyHeaderView.frame.height
        let distanceToBeMoved = abs(topViewCurrentHeight - topViewInitialHeight)
        var time = distanceToBeMoved / 500
        if time < 0.25 {
            time = 0.25
        }
        
        myView.headerViewHeightConstraint.update(offset: topViewInitialHeight)
        UIView.animate(withDuration: TimeInterval(time), animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func scrollToFinalView() {
        let topViewCurrentHeight = myView.stickyHeaderView.frame.height
        let distanceToBeMoved = abs(topViewCurrentHeight - topViewFinalHeight)
        var time = distanceToBeMoved / 500
        if time < 0.25 {
            time = 0.25
        }
        
        myView.headerViewHeightConstraint.update(offset: topViewFinalHeight)
        
        UIView.animate(withDuration: TimeInterval(time), animations: {
            self.view.layoutIfNeeded()
        })
    }
}

