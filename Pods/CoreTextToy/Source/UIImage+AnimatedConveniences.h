//
//  UIImage+AnimatedConveniences.h
//  CoreText
//
//  Created by Jonathan Wight on 10/23/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AnimatedConveniences)

+ (UIImage *)animatedImageWithURL:(NSURL *)inURL duration:(NSTimeInterval)inDuration;

@end
