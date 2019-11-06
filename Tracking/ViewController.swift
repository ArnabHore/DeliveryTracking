//
//  ViewController.swift
//  Tracking
//
//  Created by Arnab Hore on 31/10/19.
//  Copyright © 2019 Arnab Hore. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var labelStackView: UIStackView!
    
    var count = -1
    var appSecColor = UIColor.init(red: 255/255.0, green: 133/255.0, blue: 0, alpha: 1.0)
    var completeResponse: TrackResponse!
    var trackData: [TrackData]!
    var buttonsData: [ButtonsData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //        self.btns = [btn1, btn2, btn3]
        
        let json = """
        {
          "data": [
            {
              "text": "Ready for dispatch",
              "isComplete": true,
              "isStarted": true
            },
            {
              "text": "Dispatched",
              "isComplete": true,
              "isStarted": true
            },
            {
              "text": "Out for delivery",
              "isComplete": false,
              "isStarted": true
            },
            {
              "text": "Delivered",
              "isComplete": false,
              "isStarted": false
            }
          ]
        }
        """
        
        let receivedData = json.data(using: .utf8)
        let decoder = JSONDecoder()
        do {
            if let responseData = receivedData {
                completeResponse = try decoder.decode(TrackResponse.self, from: responseData)
                trackData = completeResponse.data ?? []
            }
        } catch let error as NSError {
            print(error)
        }
        
        self.buttonsData.removeAll()
        createUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.fillButton()
    }
    
    @IBAction func btn1Tapped(_ sender: UIButton) {
        sender.setImage(UIImage.init(named: "TickCircle.png"), for: .normal)
        startAnimation()
    }
    
    func createUI() {
        for stackSubView in labelStackView.arrangedSubviews {
            stackSubView.removeFromSuperview()
        }
        
        for track in trackData {
            let label = UILabel()
            label.text = track.text
            labelStackView.addArrangedSubview(label)
            
            let button = UIButton()
            button.setImage(UIImage(named: "EmptyCircle"), for: .normal)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(button)
            
            self.buttonsData.append(ButtonsData(btn: button, isComplete: track.isComplete ?? false, isStarted: track.isStarted ?? false))
            
            self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 30.0))
            self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: labelStackView, attribute: .leading, multiplier: 1.0, constant: -20.0))
            self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: label, attribute: .centerY, multiplier: 1.0, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25.0))
            self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25.0))
        }
    }
    
    func startAnimation() {
        if count + 1 < buttonsData.count, buttonsData[count+1].isStarted {
            self.createPath(firstButton: buttonsData[count].btn, secondButton: buttonsData[count+1].btn)
        }
    }
    func createPath(firstButton: UIButton, secondButton: UIButton) {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.fillButton()
        })
        
        let firstPoint: CGPoint = CGPoint(x: firstButton.center.x, y: firstButton.center.y + 3)
        let secPoint: CGPoint = CGPoint(x: secondButton.center.x, y: secondButton.center.y - 2)
        
        let path = UIBezierPath()
        path.move(to: firstPoint)
        path.addLine(to: secPoint)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = appSecColor.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "line"
        
        view.layer.addSublayer(shapeLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 1
        shapeLayer.add(animation, forKey: "MyAnimation")
        
        CATransaction.commit()
    }
    
    func fillButton() {
        self.count += 1
        var timeCount = 1
        if self.buttonsData[self.count].isStarted && !self.buttonsData[self.count].isComplete {
            self.createCircle(currentButton: self.buttonsData[self.count].btn, radius: CGFloat(3.0))
        } else {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
                self.createCircle(currentButton: self.buttonsData[self.count].btn, radius: CGFloat(timeCount))
                timeCount += 1
                if timeCount == Int(self.buttonsData[self.count].btn.bounds.size.width) / 2 {
                    timer.invalidate()
                    
                    if let sublayers = self.view.layer.sublayers {
                        for layer in sublayers {
                            if layer.name == "circle" {
                                layer.removeFromSuperlayer()
                            }
                        }
                    }
                    
                    if self.buttonsData[self.count].isComplete {
                        self.buttonsData[self.count].btn.setImage(UIImage.init(named: "TickCircle.png"), for: .normal)
                    }
                    self.startAnimation()
                }
            }
        }
    }
    
    func createCircle(currentButton: UIButton, radius: CGFloat) {
        let circlePath = UIBezierPath(arcCenter: currentButton.center, radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = appSecColor.cgColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "circle"
        
        view.layer.addSublayer(shapeLayer)
    }
}

struct TrackResponse: Codable {
    let data: [TrackData]?
}
struct TrackData: Codable {
    let text: String?
    let isComplete: Bool?
    let isStarted: Bool?
}
struct ButtonsData {
    let btn: UIButton
    let isComplete: Bool
    let isStarted: Bool
    init(btn: UIButton, isComplete: Bool, isStarted: Bool) {
        self.btn = btn
        self.isComplete = isComplete
        self.isStarted = isStarted
    }
}
