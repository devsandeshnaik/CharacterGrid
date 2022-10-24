//
//  HeaderView.swift
//  CharactersGrid
//
//  Created by Sandesh Naik on 22/10/22.
//

import UIKit
import SwiftUI

class HeaderView: UICollectionReusableView {
    let textLable = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("XIB/Storyboard is not supported")
    }
    
    private func setupLayout() {
        textLable.font = UIFont.preferredFont(forTextStyle: .headline)
        textLable.adjustsFontForContentSizeCategory = true
        textLable.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textLable)
        
        NSLayoutConstraint.activate([
            textLable.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textLable.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            textLable.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textLable.topAnchor.constraint(equalTo: topAnchor, constant: 16),
        ])
    }
    
    func setup(text: String) {
        textLable.text = text
    }
}


struct HeaderViewRepresnetable: UIViewRepresentable {
    
    let text: String
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> some UIView {
        let headerView = HeaderView()
        headerView.setup(text: text)
        return headerView
    }
}

struct HeaderView_Preview: PreviewProvider {
    static var previews: some View {
        return HeaderViewRepresnetable(text: "Hero's")
    }
}
