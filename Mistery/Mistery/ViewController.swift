//
//  ViewController.swift
//  Mistery
//
//  Created by Joje on 30/07/25.
//

import UIKit

class ViewController: UIViewController {

    private let customView = MyCustomView()
    
    override func loadView() {
        super.loadView()
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customView.onButtonDownPress = navigateToSecondViewController
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

final class MyCustomView: UIView {
    
    var onButtonDownPress: () -> Void = {}
    
    // MARK: - Subviews
    
    private(set) lazy var myButton: UIButton = {
        // cria um botao e retorna ele
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Tap me", for: .normal)
        button.setTitle("Im being tapped", for: .highlighted)
        button.setTitleColor(.green, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        
        button.addTarget(self, action: #selector(didPressButtonUpInside), for: .touchUpInside)
        button.addTarget(self, action: #selector(didPressButtonDown), for: .touchDown)
        
        button.backgroundColor = .gray
        
        button.layer.cornerRadius = 8
        
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Button actions
    
    @objc private func didPressButtonDown() {
        onButtonDownPress()
    }
    
    @objc private func didPressButtonUpInside() {
        print("Soltado!!!!")
    }
    
    // MARK: - Setup methods
    private func addSubviews() {
        self.addSubview(myButton)
    }
    
    private func setupConstraints() {
        myButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        myButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        myButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        myButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}


#Preview {
    ViewController()
}
