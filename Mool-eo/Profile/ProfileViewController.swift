//
//  ProfileViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

enum CellType {
    case info
    case myPost
}

struct MyPost {
    let title: String
    let content: String
    let likeCount: Int
    let commentCount: Int
    let image: String?
}

enum SectionItem {
    case infoItem(ProfileModel)
    case myPostItem(MyPost)
}

// 섹션에 대한 데이터 모델
struct SectionModel {
    let title: String?
    var items: [SectionItem]
}

// SectionModelType 프로토콜 준수
extension SectionModel: SectionModelType {
    typealias Item = SectionItem
    
    init(original: SectionModel, items: [SectionItem]) {
        self = original
        self.items = items
    }
}

class ProfileViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = ProfileViewModel()
    let profileView = ProfileView()
    
    lazy var dataSource = configureDataSource()
    
    var showProfileUpdateAlert: Bool = false
    
    override func loadView() {
        self.view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if showProfileUpdateAlert {
            profileView.makeToast("프로필 수정 성공", duration: 2, position: .top)
            showProfileUpdateAlert = false
        }
    }
    
    override func bind() {
        profileView.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        let viewDidLoadTrigger = Observable.just(())
        let input = ProfileViewModel.Input(viewDidLoadTrigger: viewDidLoadTrigger)
        
        let output = viewModel.transform(input: input)
        output.profile.bind(with: self) { owner, value in
            let sections: [SectionModel] = [SectionModel(title: nil, 
                                                         items: [.infoItem(value)]),
                                            SectionModel(title: "내 게시물", 
                                                         items: [.myPostItem(MyPost(title: "제목 테스트", content: "내용 테스트", likeCount: 10, commentCount: 10, image: "star")),
                                                                 .myPostItem(MyPost(title: "제목 테스트", content: "내용 테스트", likeCount: 10, commentCount: 10, image: nil)),
                                                                 .myPostItem(MyPost(title: "제목 테스트", content: "내용 테스트", likeCount: 10, commentCount: 10, image: "heart")),
                                                                 .myPostItem(MyPost(title: "제목 테스트", content: "내용 테스트", likeCount: 10, commentCount: 10, image: nil))])]
            Observable.just(sections).bind(to: owner.profileView.tableView.rx.items(dataSource: owner.dataSource)).disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel>(
            configureCell: { dataSource, tableView, indexPath, item in
                switch item {
                case .infoItem(let info):
                    let cell = tableView.dequeueReusableCell(withIdentifier: ProfileInfoTableViewCell.identifier, for: indexPath) as! ProfileInfoTableViewCell
                    cell.configureCell(info)
                    cell.profileEditButton.rx.tap.bind(with: self) { owner, _ in
                        let vc = ProfileEditViewController()
                        vc.profileImageData = cell.profileImageView.image?.pngData()
                        vc.profileImage = info.profileImage
                        vc.nickname = info.nick
                        vc.introduction = info.introduction
                        owner.navigationController?.pushViewController(vc, animated: true)
                    }.disposed(by: cell.disposeBag)
                    return cell
                case .myPostItem(let myPost):
                    if myPost.image == nil {
                        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMyPostWithoutImageTableViewCell.identifier, for: indexPath) as! ProfileMyPostWithoutImageTableViewCell
                        cell.postTitleLabel.text = myPost.title
                        cell.postContentLabel.text = myPost.content
                        cell.likeCountLabel.text = "\(myPost.likeCount)"
                        cell.commentCountLabel.text = "\(myPost.commentCount)"
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMyPostTableViewCell.identifier, for: indexPath) as! ProfileMyPostTableViewCell
                        cell.postTitleLabel.text = myPost.title
                        cell.postContentLabel.text = myPost.content
                        cell.likeCountLabel.text = "\(myPost.likeCount)"
                        cell.commentCountLabel.text = "\(myPost.commentCount)"
                        return cell
                    }
                }
            },
            titleForHeaderInSection: { dataSource, index in
                return dataSource.sectionModels[index].title
            }
        )
        return dataSource
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            let title = dataSource[section].title
            let headerView = ProfileMyPostHeaderView()
            headerView.myPostLabel.text = title
            return headerView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1: return UITableView.automaticDimension
        default: return 0
        }
    }
}
