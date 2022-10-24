//
//  CharacterCell.swift
//  CharactersGrid
//
//  Created by Sandesh Naik on 22/10/22.
//

import UIKit
import SwiftUI

class CharacterCell: UICollectionViewCell {
    
    let imageView = RoundedImageView()
    let textLabel = UILabel()
    let vStack = UIStackView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Storyboard/Xib is not supported")
    }
    
    private func setupLayout() {
        imageView.contentMode = .scaleAspectFit
        textLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        textLabel.adjustsFontForContentSizeCategory = true
        textLabel.textAlignment = .center
        
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 8
        
        vStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(vStack)
        vStack.addArrangedSubview(imageView)
        vStack.addArrangedSubview(textLabel)
        
        
        
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }
    
    func setup(character: Character) {
        textLabel.text = character.name
        imageView.image = UIImage(named: character.imageName)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let padding: CGFloat = 8
        let noOfItems: CGFloat  = traitCollection.horizontalSizeClass == .compact ? 4 : 8
        let itemWidth = floor((UIScreen.main.bounds.width - (padding * 2)) /  noOfItems)
        return super.systemLayoutSizeFitting(
            CGSize(width: itemWidth, height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
    }
}

class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = true
        layer.cornerRadius = bounds.width / 2
    }
}

struct CharacterCellViewRepresentable: UIViewRepresentable {
    
    let character: Character
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> some UIView {
        let cell = CharacterCell()
        cell.setup(character: character)
        return cell
    }
}


struct CharacterCell_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            CharacterCellViewRepresentable(
                character: Universe.ff7r.stubs[0]
            )
            .frame(width: 120, height: 150)
            
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()),
                                        GridItem(.flexible()),
                                        GridItem(.flexible())]) {
                        ForEach(Universe.ff7r.stubs) {
                            CharacterCellViewRepresentable(character: $0)
                                .frame(width: 120, height: 150)
                        }
                    }
                                        .navigationTitle(Universe.ff7r.title)
                }
            }
        }
        
    }
}
