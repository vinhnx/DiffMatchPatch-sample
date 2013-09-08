//
//  CLinkingCoreTextLabel.m
//  CoreText
//
//  Created by Jonathan Wight on 1/18/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CLinkingCoreTextLabel.h"

#import "CMarkupValueTransformer.h"
#import "NSAttributedString_Extensions.h"

@interface CLinkingCoreTextLabel ()
@property (readwrite, nonatomic, strong) NSArray *linkRanges;
@end

#pragma mark -

@implementation CLinkingCoreTextLabel

- (id)initWithFrame:(CGRect)frame
    {
    if ((self = [super initWithFrame:frame]) != NULL)
        {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        _tapRecognizer.enabled = NO;
        [self addGestureRecognizer:_tapRecognizer];
        }
    return(self);
    }

- (id)initWithCoder:(NSCoder *)inCoder
    {
    if ((self = [super initWithCoder:inCoder]) != NULL)
        {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        _tapRecognizer.enabled = NO;
        [self addGestureRecognizer:_tapRecognizer];
        }
    return(self);
    }

- (void)setAttributedText:(NSAttributedString *)inText
    {
    if (self.attributedText != inText)
        {
        [super setAttributedText:inText];
        
        NSMutableArray *theRanges = [NSMutableArray array];
        [self.attributedText enumerateAttribute:kMarkupLinkAttributeName inRange:(NSRange){ .length = self.attributedText.length } options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value != NULL)
                {
                [theRanges addObject:[NSValue valueWithRange:range]];
                }
            }];
        self.linkRanges = [theRanges copy];

        self.tapRecognizer.enabled = self.linkRanges.count > 0;
        }
    }
    
- (void)setEnabled:(BOOL)inEnabled
    {
    [super setEnabled:inEnabled];
    
    self.tapRecognizer.enabled = inEnabled && self.linkRanges.count > 0;
    }
    
#pragma mark -

- (void)tap:(UITapGestureRecognizer *)inGestureRecognizer
    {
    CGPoint theLocation = [inGestureRecognizer locationInView:self];
    theLocation.x -= self.insets.left;
    theLocation.y -= self.insets.top;

    NSRange theRange;
    NSDictionary *theAttributes = [self attributesAtPoint:theLocation effectiveRange:&theRange];
    NSURL *theLink = theAttributes[kMarkupLinkAttributeName];
    if (theLink != NULL)
        {
        if (self.URLHandler != NULL)
            {
            self.URLHandler(theRange, theLink);
            }
        }
    }
    
@end
