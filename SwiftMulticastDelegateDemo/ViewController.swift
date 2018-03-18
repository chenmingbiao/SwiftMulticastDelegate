//
//  ViewController.swift
//  SwiftMulticastDelegate
//
//  Created by billchan on 05/03/2018.
//  Copyright © 2018 billchan. All rights reserved.
//

import UIKit

// MARK: - MyButtonDelegate
protocol MyButtonDelegate: class {
    func didTap()
}

// MARK: - MyButton
class MyButton: UIButton {
    
    var delegates = SwiftMulticastDelegate<MyButtonDelegate>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTitle("Action", for: .normal)
        self.setTitleColor(UIColor.blue, for: .normal)
        self.addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTap() {
        delegates => {
            $0.didTap()
        }
    }
    
}

// MARK: - SubView
class SubView: UIView {
    var name = ""
}

extension SubView: MyButtonDelegate {
    func didTap() {
        print("\(name) did tap")
    }
}

// MARK: - ViewController
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = MyButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        button.center = self.view.center
        self.view.addSubview(button)
        
        let subview1 = SubView()
        subview1.name = "subview@1"
        button.delegates += subview1
        self.view.addSubview(subview1)
        
        let subview2 = SubView()
        subview2.name = "subview@2"
        button.delegates += subview2
        self.view.addSubview(subview2)
    }

}
