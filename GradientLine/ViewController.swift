//
//  ViewController.swift
//  GradientLine
//
//  Created by Michel Anderson Lutz Teixeira on 20/11/18.
//  Copyright © 2018 Michel Lutz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        makePath()
    }

    func makePath() {
        let mLCurveAlgorithm = MLCurveAlgorithm.shared
        var points: [CGPoint] = []
        points.append(CGPoint(x: 40, y: 40))
        points.append(CGPoint(x: 50, y: 50))
        points.append(CGPoint(x: 50, y: 70))
        points.append(CGPoint(x: 50, y: 80))
        points.append(CGPoint(x: 60, y: 100))
        points.append(CGPoint(x: 60, y: 130))
        points.append(CGPoint(x: 60, y: 150))
        points.append(CGPoint(x: 60, y: 160))
        points.append(CGPoint(x: 60, y: 180))
        if let path = mLCurveAlgorithm.createCurvedPath(points) {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.green.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.lineWidth = 4
            
            let gradient = CAGradientLayer()
            gradient.frame = CGRect(x: 40, y: 40, width: 300, height: 300)
//            gradient.frame = lineLayer.frame
            gradient.colors = [
                UIColor(hex: "3B8074").cgColor,
                UIColor(hex: "70A886").cgColor,
                UIColor(hex: "F3A634").cgColor,
                UIColor(hex: "F29D53").cgColor,
                UIColor(hex: "EB7F33").cgColor,
                UIColor(hex: "E74C32").cgColor,
                UIColor(hex: "AD504E").cgColor
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)
            
            
            gradient.mask = lineLayer
            
            view.layer.addSublayer(gradient)
        }
    }
    
    
}

struct MLCurvedSegment {
    var controlPoint1: CGPoint
    var controlPoint2: CGPoint
}

class MLCurveAlgorithm {
    static let shared = MLCurveAlgorithm()
    
    private func controlPointsFrom(points: [CGPoint]) -> [MLCurvedSegment] {
        var result: [MLCurvedSegment] = []
        
        let delta: CGFloat = 0.3 // The value that help to choose temporary control points.
        
        // Calculate temporary control points, these control points make Bezier segments look straight and not curving at all
        for i in 1..<points.count {
            let A = points[i-1]
            let B = points[i]
            let controlPoint1 = CGPoint(x: A.x + delta*(B.x-A.x), y: A.y + delta*(B.y - A.y))
            let controlPoint2 = CGPoint(x: B.x - delta*(B.x-A.x), y: B.y - delta*(B.y - A.y))
            let curvedSegment = MLCurvedSegment(controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            result.append(curvedSegment)
        }
        
        // Calculate good control points
        for i in 1..<points.count-1 {
            /// A temporary control point
            let M = result[i-1].controlPoint2
            
            /// A temporary control point
            let N = result[i].controlPoint1
            
            /// central point
            let A = points[i]
            
            /// Reflection of M over the point A
            let MM = CGPoint(x: 2 * A.x - M.x, y: 2 * A.y - M.y)
            
            /// Reflection of N over the point A
            let NN = CGPoint(x: 2 * A.x - N.x, y: 2 * A.y - N.y)
            
            result[i].controlPoint1 = CGPoint(x: (MM.x + N.x)/2, y: (MM.y + N.y)/2)
            result[i-1].controlPoint2 = CGPoint(x: (NN.x + M.x)/2, y: (NN.y + M.y)/2)
        }
        
        return result
    }
    
    /**
     Create a curved bezier path that connects all points in the dataset
     */
    func createCurvedPath(_ dataPoints: [CGPoint]) -> UIBezierPath? {
        let path = UIBezierPath()
        path.move(to: dataPoints[0])
        
        var curveSegments: [MLCurvedSegment] = []
        curveSegments = controlPointsFrom(points: dataPoints)
        
        for i in 1..<dataPoints.count {
            path.addCurve(to: dataPoints[i], controlPoint1: curveSegments[i-1].controlPoint1, controlPoint2: curveSegments[i-1].controlPoint2)
        }
        return path
    }
}
extension UIColor {
    convenience init(hex: String) {
        let hexN = hex.replacingOccurrences(of: "#", with: "", options: .literal, range: nil)
        let scanner = Scanner(string: hexN)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = (rgbValue & 0xff0000) >> 16
        let green = (rgbValue & 0xff00) >> 8
        let blue = rgbValue & 0xff
        self.init(
            red: CGFloat(red) / 0xff,
            green: CGFloat(green) / 0xff,
            blue: CGFloat(blue) / 0xff, alpha: 1
        )
    }
}
