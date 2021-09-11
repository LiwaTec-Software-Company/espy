//
//  UIImage+Extensions.swift
//  Espy
//
//  Created by Willie Johnson on 9/3/21.
//

import Foundation
import UIKit

public extension UIImage {
  convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }

  func blurredImage(radius: CGFloat) -> UIImage? {
    let context = CIContext(options: nil)

      guard let ciImg = CIImage(image: self) else { return nil }

      let blur = CIFilter(name: "CIGaussianBlur")
      blur?.setValue(ciImg, forKey: kCIInputImageKey)
      blur?.setValue(radius, forKey: kCIInputRadiusKey)

      if let ciImgWithBlurredRect = blur?.outputImage?.composited(over: ciImg),
         let outputImg = context.createCGImage(ciImgWithBlurredRect, from: ciImgWithBlurredRect.extent) {
          return UIImage(cgImage: outputImg)
      }
      return nil
  }
}


