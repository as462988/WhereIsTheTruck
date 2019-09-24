//
//  SettingViewController.swift
//  RunRunTruck
//
//  Created by yueh on 2019/9/9.
//  Copyright © 2019 yueh. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    ///標題
    var titleLabel: UILabel!
    
//    var contentScrollerView: UIScrollView!
    var contentView: UIView!
//    var blockRow: SettingRow!
    var blockRow: SettingRow = {
        let row = SettingRow(
            title: "封鎖名單",
            subTitle: nil,
            withRightArrow: true,
            associatedContentViewController: BlockListViewController())
        return row
    }()
    var privateCheckRow: SettingRow = {
        let row = SettingRow(
            title: "隱私權政策",
            subTitle: nil,
            withRightArrow: true,
            associatedContentViewController: nil)
        return row
    }()
    var feebackRow: SettingRow = {
        let row = SettingRow(
            title: "意見回饋",
            subTitle: nil,
            withRightArrow: true,
            associatedContentViewController: nil)
        return row
    }()
    var versionRow: SettingRow = {
        let row = SettingRow(
            title: "版本",
            subTitle: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            withRightArrow: false,
            associatedContentViewController: nil)
        return row
    }()
    var logoutRow: SettingRow = {
        let row = SettingRow(
            title: "登出",
            subTitle: nil,
            withRightArrow: true,
            associatedContentViewController: nil)
        return row
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        setupViews()
    }
}
// MARK: - 建置導航欄
extension SettingViewController {
    func setupNavBar() {
        self.navigationController?.navigationBar.barTintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.asset(.Icon_back),
            style: .plain,
            target: self,
            action: #selector(backToRoot))
        let image = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationController?.navigationBar.shadowImage = image
    }
    
    @objc func backToRoot() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - 建置頁面
extension SettingViewController {
    func setupViews() {
        //配置ScrollView
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.backgroundColor = .white
        //配置ScrollView的ContentView
        contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: view.bounds.size.width).isActive = true
        
        titleLabel = UILabel()
        titleLabel.text = "設定"
        titleLabel.font = .boldSystemFont(ofSize: 30)
        contentView.addSubview(titleLabel)
        titleLabel.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            bottom: nil,
            trailing: nil,
            padding: .init(top: 15, left: 20, bottom: 0, right: 0), size: .zero)
        //Rows
        contentView.addSubview(blockRow)
        contentView.addSubview(privateCheckRow)
        contentView.addSubview(feebackRow)
        contentView.addSubview(versionRow)
        contentView.addSubview(logoutRow)
        blockRow.delegate = self
        privateCheckRow.delegate = self
        feebackRow.delegate = self
//        versionRow.delegate = self
        logoutRow.delegate = self
        blockRow.setupViews()
        privateCheckRow.setupViews()
        feebackRow.setupViews()
        versionRow.setupViews()
        logoutRow.setupViews()
        blockRow.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        privateCheckRow.topAnchor.constraint(equalTo: blockRow.bottomAnchor, constant: 0).isActive = true
        feebackRow.topAnchor.constraint(equalTo: privateCheckRow.bottomAnchor, constant: 0).isActive = true
        versionRow.topAnchor.constraint(equalTo: feebackRow.bottomAnchor, constant: 0).isActive = true
        logoutRow.topAnchor.constraint(equalTo: versionRow.bottomAnchor, constant: 0).isActive = true
        logoutRow.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
    }
}

extension SettingViewController: SettingRowDelegate {
    func settingRowDidTap(settingRow: SettingRow) {
        switch settingRow {
        case blockRow:
            blockRow.toggleContent()
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0,
                options: [.curveEaseOut],
                animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            return
        case privateCheckRow:
            return
        case feebackRow:
            return
        case logoutRow:
            FirebaseManager.shared.signOut()
        
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
            let root = appDelegate?.window?.rootViewController as? TabBarViewController
        
            root?.selectedIndex = 0
        default:
            return
        }
    }
}
