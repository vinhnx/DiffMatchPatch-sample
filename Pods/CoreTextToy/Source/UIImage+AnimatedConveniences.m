//
//  UIImage+AnimatedConveniences.m
//  CoreText
//
//  Created by Jonathan Wight on 10/23/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "UIImage+AnimatedConveniences.h"

#import <ImageIO/ImageIO.h>

@implementation UIImage (AnimatedConveniences)

+ (UIImage *)animatedImageWithURL:(NSURL *)inURL duration:(NSTimeInterval)inDuration
	{
	UIImage *theImage = NULL;

	NSData *theData = [NSData dataWithContentsOfURL:inURL];
	CGImageSourceRef theImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)theData, NULL);
	if (theImageSource != NULL)
		{
		if (CGImageSourceGetCount(theImageSource) == 1)
			{
			CGImageRef theCGImage = CGImageSourceCreateImageAtIndex(theImageSource, 0, NULL);
			if (theCGImage != NULL)
				{
				theImage = [UIImage imageWithCGImage:theCGImage scale:0 orientation:UIImageOrientationUp];
				CFRelease(theCGImage);
				}
			}
		else
			{
			NSMutableArray *theImages = [NSMutableArray array];
			for (size_t N = 0; N != CGImageSourceGetCount(theImageSource); ++N)
				{
				CGImageRef theCGImage = CGImageSourceCreateImageAtIndex(theImageSource, N, NULL);
				if (theCGImage != NULL)
					{
					theImage = [UIImage imageWithCGImage:theCGImage scale:0 orientation:UIImageOrientationUp];
					CFRelease(theCGImage);
					
					[theImages addObject:theImage];
					}
				}
				
			theImage = [UIImage animatedImageWithImages:theImages duration:inDuration];
			}

		CFRelease(theImageSource);
		}

	return(theImage);
	}

@end
