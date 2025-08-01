//
//  ViewController.swift
//  Mistery
//
//  Created by Joje on 30/07/25.
//

import UIKit

class ViewController: UIViewController {
    
    private var currentTextIndex = 0
    
    private let story = StoryModel()
    
    private let customView = MyCustomView()
    private let tvView = TVView()
    
    override func loadView() {
        super.loadView()
        view = tvView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtonAction()
        //customView.onButtonDownPress = navigateToSecondViewController
    }
    
    private func setupButtonAction() {
        
        tvView.onNextButtonTap = { [weak self] in
            guard let self,
            self.currentTextIndex < self.story.storyTexts.count - 1
            else { return }
            self.currentTextIndex += 1
            
            self.tvView.storyLabel.text = self.story.storyTexts[self.currentTextIndex]
        }
        
    }
    
    func navigateToSecondViewController() {
        let secondViewController = OtherViewController()
        navigationController?.pushViewController(secondViewController, animated: true)
    }
}

class OtherViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
}


#Preview {
    ViewController()
}
