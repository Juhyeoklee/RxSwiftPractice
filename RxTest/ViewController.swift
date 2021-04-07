//
//  ViewController.swift
//  RxTest
//
//  Created by juhyeok.lee on 2021/04/02.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture


class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var swipeView: UIView!
    
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var requestMoreButton: UIButton!
    @IBOutlet weak var remainCountLabel: UILabel!
    
    @IBOutlet weak var button2: UIButton!
    let disposeBag = DisposeBag()

    let panGestureRecognizer = UIPanGestureRecognizer()
    var topConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let networkRequsetAPI = Observable.of(100).debug("NetworkRequstAPI")
        swipeView.addGestureRecognizer(panGestureRecognizer)
        let result = requestMoreButton.rx.tap
            .flatMap{ networkRequsetAPI }
            .share()
        
        result
            .map{ $0 > 0 }
            .bind(to: requestMoreButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        result
            .map { "Count:\($0)" }
            .bind(to: remainCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        txtField.rx.text.orEmpty.subscribe{ print($0) }
        .disposed(by: disposeBag)
        
//        swipeView
//            .rx
//            .swipeGesture(.up, .down)
//            .when(.recognized)
//            .subscribe{ [weak self] gesture in
//                print(gesture)
//            }.disposed(by: disposeBag)
        
//        swipeView
//            .rx
//            .panGesture()
//            .when(.began, .changed, .ended)
//            .subscribe { (gesture) in
//
//                print(gesture)
//            }.disposed(by: disposeBag)
        
        swipeView.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = swipeView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 5 / 6)
        topConstraint.isActive = true
        NSLayoutConstraint.activate([
            swipeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            swipeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            swipeView.heightAnchor.constraint(equalToConstant: view.frame.height * 5 / 6)
        ])
        
        panGestureRecognizer.rx.event.bind { (gesture) in
            
            let transition = gesture.translation(in: self.swipeView)
            let velocity = gesture.velocity(in: self.swipeView)
            
            if abs(velocity.y) > abs(velocity.x) {
                let isUp = velocity.y < 0
                
                if isUp {
                    self.moveUp(constant: transition.y, state: gesture.state)
                }
                else {
                    self.moveDown(constant: transition.y, state: gesture.state)
                }
            }
            gesture.setTranslation(CGPoint.zero, in: self.swipeView)
        }.disposed(by: disposeBag)
    }
    
    private func moveUp(constant: CGFloat, state: UIPanGestureRecognizer.State) {
        
        print(state.rawValue)
        switch state {
        case .cancelled, .ended, .failed:
            topConstraint.constant = view.frame.height / 6
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            
        default:
            
            let changedY = swipeView.center.y + constant
            swipeView.center.y = changedY
        }
    }
    
    private func moveDown(constant: CGFloat, state: UIPanGestureRecognizer.State) {
        print(state.rawValue)
        switch state {
        case .cancelled, .ended, .failed:
            topConstraint.constant = view.frame.height * 5 / 6
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            
        default:
            
            let changedY = swipeView.center.y + constant
            swipeView.center.y = changedY
        }
    }
    
    
    @IBAction func touchUpBtn2(_ sender: Any) {
        
    }
    
    
}

