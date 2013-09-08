//
//  NSAttributedString_Extensions.m
//  CoreText
//
//  Created by Jonathan Wight on 1/18/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "NSAttributedString_Extensions.h"

#import "CMarkupValueTransformer.h"
#import "UIFont_CoreTextExtensions.h"

NSString *const kMarkupLinkAttributeName = @"com.touchcode.link";
NSString *const kMarkupBoldAttributeName = @"com.touchcode.bold";
NSString *const kMarkupItalicAttributeName = @"com.touchcode.italic";
NSString *const kMarkupSizeAdjustmentAttributeName = @"com.touchcode.sizeAdjustment";
NSString *const kMarkupFontNameAttributeName = @"com.touchcode.fontName";
NSString *const kShadowColorAttributeName = @"com.touchcode.shadowColor";
NSString *const kShadowOffsetAttributeName = @"com.touchcode.shadowOffset";
NSString *const kShadowBlurRadiusAttributeName = @"com.touchcode.shadowBlurRadius";
NSString *const kMarkupAttachmentAttributeName = @"com.touchcode.attachment";
NSString *const kMarkupBackgroundColorAttributeName = @"com.touchcode.backgroundColor";
NSString *const kMarkupStrikeColorAttributeName = @"com.touchcode.strikeColor";
NSString *const kMarkupOutlineAttributeName = @"com.touchcode.outline";

@implementation NSAttributedString (NSAttributedString_Extensions)

+ (NSAttributedString *)normalizedAttributedStringForAttributedString:(NSAttributedString *)inAttributedString baseFont:(UIFont *)inBaseFont
    {
    NSMutableAttributedString *theString = [inAttributedString mutableCopy];
    
    [theString enumerateAttributesInRange:(NSRange){ .length = theString.length } options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        UIFont *theFont = inBaseFont;
        CTFontRef theCTFont = (__bridge CTFontRef)attrs[(__bridge NSString *)kCTFontAttributeName];
        if (theCTFont != NULL)
            {
            theFont = [UIFont fontWithCTFont:theCTFont];
            }
        
        attrs = [self normalizeAttributes:attrs baseFont:theFont];
        [theString setAttributes:attrs range:range];
        }];
    return(theString);
    }

+ (NSDictionary *)normalizeAttributes:(NSDictionary *)inAttributes baseFont:(UIFont *)inBaseFont
    {
    NSMutableDictionary *theAttributes = [inAttributes mutableCopy];
        
    // NORMALIZE ATTRIBUTES
    UIFont *theBaseFont = inBaseFont;
    NSString *theFontName = theAttributes[kMarkupFontNameAttributeName];
    if (theFontName != NULL)
        {
        theBaseFont = [UIFont fontWithName:theFontName size:inBaseFont.pointSize];
        [theAttributes removeObjectForKey:kMarkupFontNameAttributeName];
        }
    
    UIFont *theFont = theBaseFont;
    
    BOOL theBoldFlag = [theAttributes[kMarkupBoldAttributeName] boolValue];
    if (theAttributes[kMarkupBoldAttributeName] != NULL)
        {
        [theAttributes removeObjectForKey:kMarkupBoldAttributeName];
        }

    BOOL theItalicFlag = [theAttributes[kMarkupItalicAttributeName] boolValue];
    if (theAttributes[kMarkupItalicAttributeName] != NULL)
        {
        [theAttributes removeObjectForKey:kMarkupItalicAttributeName];
        }
    
    if (theBoldFlag == YES && theItalicFlag == YES)
        {
        theFont = theBaseFont.boldItalicFont;
        }
    else if (theBoldFlag == YES)
        {
        theFont = theBaseFont.boldFont;
        }
    else if (theItalicFlag == YES)
        {
        theFont = theBaseFont.italicFont;
        }

    if (theAttributes[kMarkupOutlineAttributeName] != NULL)
        {
        [theAttributes removeObjectForKey:kMarkupOutlineAttributeName];
		theAttributes[(__bridge NSString *)kCTStrokeWidthAttributeName] = @(3.0);
        }

    NSNumber *theSizeValue = theAttributes[kMarkupSizeAdjustmentAttributeName];
    if (theSizeValue != NULL)
        {
        CGFloat theSize = [theSizeValue floatValue];
        theFont = [theFont fontWithSize:theFont.pointSize + theSize];
        
        [theAttributes removeObjectForKey:kMarkupSizeAdjustmentAttributeName];
        }

    if (theFont != NULL)
        {
        theAttributes[(__bridge NSString *)kCTFontAttributeName] = (__bridge id)theFont.CTFont;
        }
        
    return(theAttributes);
    }
    
@end
