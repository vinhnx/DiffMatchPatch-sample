//
//  CMarkupValueTransformer.m
//  TouchCode
//
//  Created by Jonathan Wight on 07/15/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY TOXICSOFTWARE.COM ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL TOXICSOFTWARE.COM OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of toxicsoftware.com.

#import "CMarkupValueTransformer.h"

#import <CoreText/CoreText.h>

#import "UIFont_CoreTextExtensions.h"
#import "CMarkupValueTransformer.h"
#import "CSimpleHTMLParser.h"
#import "CCoreTextAttachment.h"
#import "CCoreTextRenderer.h"
#import "NSAttributedString_Extensions.h"
#import "UIColor+Hex.h"

@interface CMarkupValueTransformer ()
@property (readwrite, nonatomic, strong) NSMutableDictionary *tagHandlers;

- (NSDictionary *)attributesForTagStack:(NSArray *)inTagStack;
@end

#pragma mark -

@implementation CMarkupValueTransformer

+ (Class)transformedValueClass
    {
    return([NSAttributedString class]);
    }

+ (BOOL)allowsReverseTransformation
    {
    return(NO);
    }

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
        _tagHandlers = [NSMutableDictionary dictionary];

        [self resetStyles];

        [self addStandardStyles];
		}
	return(self);
	}
    
- (id)transformedValue:(id)value
    {
    return([self transformedValue:value error:NULL]);
    }

- (id)transformedValue:(id)value error:(NSError **)outError
    {
    NSString *theMarkup = value;

    NSMutableAttributedString *theAttributedString = [[NSMutableAttributedString alloc] init];

    __block NSMutableDictionary *theTextAttributes = NULL;
    __block NSURL *theCurrentLink = NULL;

    CSimpleHTMLParser *theParser = [[CSimpleHTMLParser alloc] init];
    if (self.whitespaceCharacterSet != NULL)
        {
        theParser.whitespaceCharacterSet = self.whitespaceCharacterSet;
        }

    theParser.openTagHandler = ^(CSimpleHTMLTag *inTag, NSArray *tagStack) {
        if ([inTag.name isEqualToString:@"a"] == YES)
            {
            NSString *theURLString = (inTag.attributes)[@"href"];
            if ((id)theURLString != [NSNull null] && theURLString.length > 0)
                {
                theCurrentLink = [NSURL URLWithString:theURLString];
                }
            }
		else if ([inTag.name isEqualToString:@"p"] == YES)
			{
			NSAttributedString *as = [[NSAttributedString alloc] initWithString:@"\n"];
			[theAttributedString appendAttributedString:as];
			}
        else if ([inTag.name isEqualToString:@"img"] == YES)
            {
            NSString *theImageSource = (inTag.attributes)[@"src"];
            if (theImageSource == (id)[NSNull null])
                {
                theImageSource = NULL;
                }
        
            UIImage *theImage = NULL;
            if ([theImageSource length] > 0)
                {
                theImage = [UIImage imageNamed:theImageSource];
                }
            else
                {
                theImage = [UIImage imageNamed:@"MissingImage.png"];
                }

            CoreTextAttachmentRenderer theRenderer = ^(CCoreTextAttachment *inAttachment, CGContextRef inContext, CGRect inRect) {
                [theImage drawInRect:inRect];
                };
            CCoreTextAttachment *theAttachment = [[CCoreTextAttachment alloc] initWithType:kCoreTextAttachmentType_Renderer ascent:theImage.size.height descent:0.0 width:theImage.size.width representedObject:[theRenderer copy]];

            NSMutableDictionary *theImageAttributes = [[theAttachment createAttributes] mutableCopy];
            if (theCurrentLink != NULL)
                {
                theImageAttributes[kMarkupLinkAttributeName] = theCurrentLink;
                }

            // U+FFFC "Object Replacment Character" (thanks to Jens Ayton for the pointer)
            NSAttributedString *theImageString = [[NSAttributedString alloc] initWithString:@"\uFFFC" attributes:theImageAttributes];
            [theAttributedString appendAttributedString:theImageString];
            }
        };

    theParser.closeTagHandler = ^(CSimpleHTMLTag *inTag, NSArray *tagStack) {
        if ([inTag.name isEqualToString:@"a"] == YES)
            {
            theCurrentLink = NULL;
            }
    };

    theParser.textHandler = ^(NSString *inString, NSArray *tagStack) {
        NSDictionary *theAttributes = [self attributesForTagStack:tagStack];
        theTextAttributes = [theAttributes mutableCopy];

        if (theCurrentLink != NULL)
            {
            theTextAttributes[kMarkupLinkAttributeName] = theCurrentLink;
            }
        
        [theAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:inString attributes:theTextAttributes]];
        };

        // In this section we use the NSScanner method
        // - (BOOL)scanCharactersFromSet:(NSCharacterSet *)scanSet intoString:(NSString **)stringValue
        // Apparently `stringValue` is autoreleased and ARC does not handle that properly.
        // Therefore we need this autorelease pool.
        @autoreleasepool
        {
            
        if ([theParser parseString:theMarkup error:outError] == NO)
            {
            return(NULL);
            }

        }
        
    return(theAttributedString);
    }

- (void)resetStyles
    {
    self.tagHandlers = [NSMutableDictionary dictionary];
    }

- (void)addStandardStyles
    {
    BTagHandler theTagHandler = NULL;

    // ### b
    theTagHandler = ^(CSimpleHTMLTag *inTag) {
        return(@{kMarkupBoldAttributeName: @YES});
        };
    [self addHandler:theTagHandler forTag:@"b"];
    [self addHandler:theTagHandler forTag:@"strong"];

    // ### i
    theTagHandler = ^(CSimpleHTMLTag *inTag) {
        return(@{kMarkupItalicAttributeName: @YES});
        };
    [self addHandler:theTagHandler forTag:@"i"];
    [self addHandler:theTagHandler forTag:@"em"];

    // ### a
    theTagHandler = ^(CSimpleHTMLTag *inTag) {
        return(@{
			(__bridge NSString *)kCTForegroundColorAttributeName: (__bridge id)[UIColor blueColor].CGColor,
            (__bridge id)kCTUnderlineStyleAttributeName: @(kCTUnderlineStyleSingle),
			});
        };
    [self addHandler:theTagHandler forTag:@"a"];

    // ### mark
    theTagHandler = ^(CSimpleHTMLTag *inTag) {
        return(@{kMarkupBackgroundColorAttributeName: (__bridge id)[UIColor yellowColor].CGColor});
        };
    [self addHandler:theTagHandler forTag:@"mark"];

    // ### strike
    theTagHandler = ^(CSimpleHTMLTag *inTag) {
        return(@{kMarkupStrikeColorAttributeName: (__bridge id)[UIColor blackColor].CGColor});
        };
    [self addHandler:theTagHandler forTag:@"strike"];

    // ### outline
    theTagHandler = ^(CSimpleHTMLTag *inTag) {
        return(@{kMarkupOutlineAttributeName: @YES});
        };
    [self addHandler:theTagHandler forTag:@"outline"];


    // ### small
    theTagHandler = ^(CSimpleHTMLTag *inTag) {
        return(@{kMarkupSizeAdjustmentAttributeName: @-4.0f});
        };
    [self addHandler:theTagHandler forTag:@"small"];

    // ### font
    theTagHandler = ^(CSimpleHTMLTag *inTag) {
        NSString *theColorString = (inTag.attributes)[@"color"];
        UIColor *theColor = [UIColor colorWithHexString:theColorString];
        return(@{
			(__bridge NSString *)kCTForegroundColorAttributeName: (__bridge id)theColor.CGColor,
            (__bridge id)kCTUnderlineStyleAttributeName: @(kCTUnderlineStyleSingle),
			});
        };
    [self addHandler:theTagHandler forTag:@"font"];
    }

- (void)addHandler:(BTagHandler)inHandler forTag:(NSString *)inTag
    {
    (self.tagHandlers)[inTag] = [inHandler copy];
    }

- (void)removeHandlerForTag:(NSString *)inTag
    {
    [self.tagHandlers removeObjectForKey:inTag];
    }

#pragma mark -

- (NSDictionary *)attributesForTagStack:(NSArray *)inTagStack
    {
    NSMutableDictionary *theCumulativeAttributes = [NSMutableDictionary dictionary];

    for (CSimpleHTMLTag *theTag in inTagStack)
        {
        BTagHandler theHandler = (self.tagHandlers)[theTag.name]; 
        if (theHandler)
            {
            NSDictionary *theAttributes = theHandler(theTag);
            [theCumulativeAttributes addEntriesFromDictionary:theAttributes];
            }
        }

    return(theCumulativeAttributes);
    }

@end

#pragma mark -

@implementation CMarkupValueTransformer (CMarkupValueTransformer_ConvenienceExtensions)

- (void)addStyleHandlerWithAttributes:(NSDictionary *)inDictionary forTag:(NSString *)inTag
    {
    BTagHandler theHandler = ^(CSimpleHTMLTag *tag) {
        return(inDictionary);
        };
    [self addHandler:theHandler forTag:inTag];
    }

@end

#pragma mark -

@implementation NSAttributedString (NSAttributedString_MarkupExtensions)

+ (NSAttributedString *)attributedStringWithMarkup:(NSString *)inMarkup error:(NSError **)outError
    {
    CMarkupValueTransformer *theTransformer = [[CMarkupValueTransformer alloc] init];

    NSAttributedString *theAttributedString = [theTransformer transformedValue:inMarkup error:outError];

    return(theAttributedString);
    }

@end
