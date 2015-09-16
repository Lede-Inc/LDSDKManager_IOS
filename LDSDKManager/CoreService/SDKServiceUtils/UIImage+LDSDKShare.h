//
//  UIImage+LDSDKShare.h
//  Pods
//
//  Created by xuguoxing on 14-9-28.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (LDSDKShare)

- (UIImage *)LDSDKShare_resizedImage:(CGSize)newSize
                interpolationQuality:(CGInterpolationQuality)quality;

@end
