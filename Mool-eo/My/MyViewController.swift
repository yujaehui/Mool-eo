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

protocol MyScrollDelegate: AnyObject {
    func didScroll(scrollView: UIScrollView)
}

class MyViewController: BaseViewController {
    
    let viewModel = MyViewModel()
    let myView = MyView()
    
    let reload = BehaviorSubject<Void>(value: ())
    
    var pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var pageCollection = PageCollection()
    
    override func loadView() {
        self.view = myView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupTabbarCollectionView()
        setupPagingViewController()
        populateBottomView()
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
    
    func setupScrollView() {
        myView.scrollView.delegate = self
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
        postVC.myScrollDelegate = self
        let postPage = Page(with: "게시글", _vc: postVC)
        pageCollection.pages.append(postPage)
        
        let productVC = MyProductViewController()
        productVC.myScrollDelegate = self
        let productPage = Page(with: "상품", _vc: productVC)
        pageCollection.pages.append(productPage)
        
        let paymentVC = MyPaymentViewController()
        paymentVC.myScrollDelegate = self
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
    
    func setBottomPagingView(toPageWithAtIndex index: Int, andNavigationDirection navigationDirection: UIPageViewController.NavigationDirection) {
        pageViewController.setViewControllers([pageCollection.pages[index].vc], direction: navigationDirection, animated: true, completion: nil)
    }
    
    func scrollSelectedTabView(toIndexPath indexPath: IndexPath, shouldAnimate: Bool = true) {
        UIView.animate(withDuration: 0.2) {
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
        print(#function)
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
        print(#function)
        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.vc == viewController }) {
            if (1..<pageCollection.pages.count).contains(currentViewControllerIndex) {
                pageCollection.selectedPageIndex = currentViewControllerIndex - 1
                return pageCollection.pages[currentViewControllerIndex - 1].vc
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print(#function)
        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.vc == viewController }) {
            if (0..<(pageCollection.pages.count - 1)).contains(currentViewControllerIndex) {
                pageCollection.selectedPageIndex = currentViewControllerIndex + 1
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

extension MyViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tabbarCollectionViewFrame = myView.tabbarCollectionView.convert(myView.tabbarCollectionView.bounds, to: self.view)
        let topLimit = myView.safeAreaInsets.top
        
        if tabbarCollectionViewFrame.origin.y <= topLimit {
            scrollView.contentOffset.y = myView.stickyHeaderView.frame.height
            myView.scrollView.isScrollEnabled = false
            if let postVC = pageCollection.pages[0].vc as? MyPostViewController {
                postVC.myPostView.collectionView.isScrollEnabled = true
            }
            if let productVC = pageCollection.pages[1].vc as? MyProductViewController {
                productVC.myProductView.collectionView.isScrollEnabled = true
            }
            if let paymentVC = pageCollection.pages[2].vc as? MyPaymentViewController {
                paymentVC.myPaymentView.collectionView.isScrollEnabled = true
            }
        } else {
            myView.scrollView.isScrollEnabled = true
            if let postVC = pageCollection.pages[0].vc as? MyPostViewController {
                postVC.myPostView.collectionView.isScrollEnabled = false
            }
            if let productVC = pageCollection.pages[1].vc as? MyProductViewController {
                productVC.myProductView.collectionView.isScrollEnabled = false
            }
            if let paymentVC = pageCollection.pages[2].vc as? MyPaymentViewController {
                paymentVC.myPaymentView.collectionView.isScrollEnabled = false
            }
        }
    }
}


extension MyViewController: MyScrollDelegate {
    func didScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY <= 0 {
            scrollView.contentOffset.y = 0
            myView.scrollView.isScrollEnabled = true
            if let postVC = pageCollection.pages[0].vc as? MyPostViewController {
                postVC.myPostView.collectionView.contentOffset.y = 0
                postVC.myPostView.collectionView.isScrollEnabled = false
            }
            if let productVC = pageCollection.pages[1].vc as? MyProductViewController {
                productVC.myProductView.collectionView.contentOffset.y = 0
                productVC.myProductView.collectionView.isScrollEnabled = false
            }
            if let paymentVC = pageCollection.pages[2].vc as? MyPaymentViewController {
                paymentVC.myPaymentView.collectionView.contentOffset.y = 0
                paymentVC.myPaymentView.collectionView.isScrollEnabled = false
            }
        }
    }
}

