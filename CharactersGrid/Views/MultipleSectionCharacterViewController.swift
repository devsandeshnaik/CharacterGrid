//
//  MultipleSectionCharacterViewController.swift
//  CharactersGrid
//
//  Created by Sandesh Naik on 23/10/22.
//

import UIKit
import SwiftUI
class MultipleSectionCharacterViewController: UIViewController {

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var sectionStubs = Universe.ff7r.sectionedStubs {
        didSet {
            updatedCollectionView(oldSectionItems: oldValue, newSectionItems: sectionStubs)
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

    private func updatedCollectionView(oldSectionItems: [SectionCharacters], newSectionItems: [SectionCharacters]) {
        var sectionsToInsert = IndexSet()
        var sectionsToRemove = IndexSet()
        
        var indexPathToInsert = [IndexPath]()
        var indexPathToRemove = [IndexPath]()
        
        let sectionDiff = newSectionItems.difference(from: oldSectionItems)
        
        sectionDiff.forEach { change in
            switch change {
            case let .remove(offset, _, _):
                sectionsToRemove.insert(offset)
            case let .insert(offset, _, _):
                sectionsToInsert.insert(offset)
            }
        }
        
        (0 ..< newSectionItems.count).forEach { index in
            let newSectionCharacter = newSectionItems[index]
            if let oldSectionIndex = oldSectionItems.firstIndex(where: { $0 == newSectionCharacter }) {
                let oldSectionCharacter = oldSectionItems[oldSectionIndex]
                let diff = newSectionCharacter.characters.difference(from: oldSectionCharacter.characters)
                
                diff.forEach { change in
                    switch change {
                    case let .remove(offset, _, _):
                        indexPathToRemove.append(IndexPath(item: offset, section: oldSectionIndex))
                    case let .insert(offset, _, _):
                        indexPathToInsert.append(IndexPath(item: offset, section: index))
                    }
                }
            }
        }
        
        
        collectionView.performBatchUpdates {
            collectionView.deleteSections(sectionsToRemove)
            collectionView.deleteItems(at: indexPathToRemove)
            collectionView.insertSections(sectionsToInsert)
            collectionView.insertItems(at: indexPathToInsert)
        } completion: { _ in
            
            let headersIndexPath = self.collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader)
            headersIndexPath.forEach { indexPath in
                let headerView = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader,
                                                                  at: indexPath) as! HeaderView

                let section = self.sectionStubs[indexPath.section]
                headerView.setup(text: "\(section.category) \(section.characters.count)".uppercased())
            }
        }
        collectionView.collectionViewLayout.invalidateLayout()
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
        sectionStubs = sender.selectedUniverse.sectionedStubs
    }
    
    @objc func shuffleTapped() {
        sectionStubs = sectionStubs.shuffled().map {
            SectionCharacters(category: $0.category,
                              characters: $0.characters.shuffled())
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.collectionViewLayout.invalidateLayout()
    }

}

extension MultipleSectionCharacterViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionStubs.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionStubs[section].characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CharacterCell
        cell.setup(character: sectionStubs[indexPath.section].characters[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView
            .dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                         withReuseIdentifier: "Header",
                                                                         for: indexPath) as! HeaderView
        let section = sectionStubs[indexPath.section]
        headerView.setup(text: "\(section.category) \(section.characters.count)".uppercased())
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = HeaderView()
        let section = sectionStubs[section]
        headerView.setup(text: "\(section.category) \(section.characters.count)".uppercased())
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.bounds.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}



struct MultipleSectiionCharacterViewControllerRepresntable: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    

    func makeUIViewController(context: Context) -> UIViewController {
        return UINavigationController(rootViewController: MultipleSectionCharacterViewController())
    }
    
}

struct MultipleSectionCharacterViewController_Preview: PreviewProvider {
    static var previews: some View {
        MultipleSectiionCharacterViewControllerRepresntable()
            .edgesIgnoringSafeArea(.top)
            .environment(\.sizeCategory, ContentSizeCategory.small)
    }
}
