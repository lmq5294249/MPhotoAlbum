//
//  UIImage+Zoom.h
//  SvImageEdit
//
//  Created by  maple on 5/22/13.
//  Copyright (c) 2013 maple. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    enSvResizeScale,            // image scaled to fill
    enSvResizeAspectFit,        // image scaled to fit with fixed aspect. remainder is transparent
    enSvResizeAspectFill,       // image scaled to fill with fixed aspect. some portion of content may be cliped
};
typedef NSInteger SvResizeMode;



@interface UIImage (Zoom)

/*
 * @brief resizeImage
 * @param newsize the dimensions（pixel） of the output image
 * 缩放后的图片,img.CIImage = nil,未缩放的图片 [[CIImage alloc] initWithImage:img] = nil;
 */

- (UIImage*)resizeImageToSize:(CGSize)newSize resizeMode:(SvResizeMode)resizeMode;

@end
