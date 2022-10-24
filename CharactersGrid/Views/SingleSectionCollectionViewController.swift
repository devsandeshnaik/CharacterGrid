//
//  SingleSectionCollectionViewController.swift
//  CharactersGrid
//
//  Created by Sandesh Naik on 23/10/22.
//

import UIKit
import SwiftUI

class SingleSectionCharacterViewController: UIViewController {

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var characters = Universe.ff7r.stubs {
        didSet {
            updatedCollectionView(oldItems: oldValue, newItems: characters)
        }
    }
    let segmentedControl = UISegmentedControl(items: Universe.allCases.map { $0.title })
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupLayout()
        setupSegmentedControl()
        setupNavigationItem()
    }
    
    private func setupCollectionView() {
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .systemBackground
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(CharacterCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(HeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "Header")
        view.addSubview(collectionView)
    }

    private func updatedCollectionView(oldItems: [Character], newItems: [Character]) {
        collectionView.performBatchUpdates {
            let diff  = newItems.difference(from: oldItems)
            diff.forEach { change in
                switch change {
                case .insert(offset: let offset, _, _):
                    self.collectionView.insertItems(at: [IndexPath(item: offset, section: 0)])
                case .remove(offset: let offset, _, _):
                    self.collectionView.deleteItems(at: [IndexPath(item: offset, section: 0)])

                }
            }
        } completion: { _ in
            let headersIndexPath = self.collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader)
            headersIndexPath.forEach { indexPath in
                let headerView = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader,
                                                                  at: indexPath) as! HeaderView
                headerView.setup(text: "Characters \(self.characters.count)")
            }
        }
        self.collectionView.collectionViewLayout.invalidateLayout()
        
    }
    
    private func setupLayout() {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    
    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self,
                                   action: #selector(segmentChanged(_:)),
                                   for: .valueChanged)
        navigationItem.titleView = segmentedControl
    }
    
    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "shuffle"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(shuffleTapped))
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        characters = sender.selectedUniverse.stubs
    }
    
    @objc func shuffleTapped() {
        characters.shuffle()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension SingleSectionCharacterViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CharacterCell
        cell.setup(character: characters[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView
            .dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                         withReuseIdentifier: "Header",
                                                                         for: indexPath) as! HeaderView
        headerView.setup(text: "Characters \(characters.count)")
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = HeaderView()
        headerView.setup(text: "Characters \(characters.count)")
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.bounds.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}

struct SingleSectiionCharacterViewControllerRepresntable: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    

    func makeUIViewController(context: Context) -> UIViewController {
        return UINavigationController(rootViewController: SingleSectionCharacterViewController())
    }
    
}

struct SingleSectionCharacterViewController_Preview: PreviewProvider {
    static var previews: some View {
        SingleSectiionCharacterViewControllerRepresntable()
            .edgesIgnoringSafeArea(.top)
            .environment(\.sizeCategory, ContentSizeCategory.small)
    }
}
