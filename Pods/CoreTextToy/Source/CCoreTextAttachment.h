//
//  CCoreTextAttachment.h
//  CoreText
//
//  Created by Jonathan Wight on 10/31/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreText/CoreText.h>

typedef enum {
	kCoreTextAttachmentType_Unknown,
	kCoreTextAttachmentType_Renderer,
	kCoreTextAttachmentType_View,
	} ECoreTextAttachmentType;

@class CCoreTextAttachment;
typedef void (^CoreTextAttachmentRenderer)(CCoreTextAttachment *, CGContextRef,CGRect);

@interface CCoreTextAttachment : NSObject

@property (readonly, nonatomic, assign) ECoreTextAttachmentType type;
@property (readonly, nonatomic, assign) CGFloat ascent;
@property (readonly, nonatomic, assign) CGFloat descent;
@property (readonly, nonatomic, assign) CGFloat width;
@property (readonly, nonatomic, assign) UIEdgeInsets insets;
@property (readonly, nonatomic, strong) id representedObject;

- (id)initWithType:(ECoreTextAttachmentType)inType ascent:(CGFloat)inAscent descent:(CGFloat)inDescent width:(CGFloat)inWidth insets:(UIEdgeInsets)inInsets representedObject:(id)inRepresentedObject;
- (id)initWithType:(ECoreTextAttachmentType)inType ascent:(CGFloat)inAscent descent:(CGFloat)inDescent width:(CGFloat)inWidth representedObject:(id)inRepresentedObject;

- (CTRunDelegateRef)createRunDelegate;
- (NSDictionary *)createAttributes;
- (NSAttributedString *)createAttributedString;

@end

#pragma mark -

@interface CCoreTextAttachment (Conveniences)
+ (CCoreTextAttachment *)coreTextAttachmentWithView:(UIView *)inView;
@end
