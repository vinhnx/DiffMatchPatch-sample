//
//  NXVDiffViewController.m
//  Test_Diff
//
//  Created by Nguyen Xuan Vinh on 07/09/2013.
//  Copyright (c) 2013 Nguyen Xuan Vinh. All rights reserved.
//

#import "NXVDiffViewController.h"

@interface NXVDiffViewController ()
@property (strong, nonatomic) UITextView *fuzzyTextView;
@end

@implementation NXVDiffViewController


#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"diff, match, patch test";
    }
    return self;
}


#pragma mark - view lifecyle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.945 green:0.942 blue:0.992 alpha:1.000];
    
    // uncomment to test
    [self getDiff];
//    [self fuzzySearch];
//    [self getPatch];
}


#pragma mark - diff

- (void)getDiff
{
    // testing...
    NSString *oldString = @"Hey, Luke! May the Force be you";
    NSString *newString = @"Luke! May the Force be with you";
    NSString *htmlDiff = diff_prettyHTMLFromDiffs([self diffFromOldString:oldString
                                                             andNewString:newString]);

    // -- other stuffs, read "DiffMatchPatch.h" for details
    //    NSString *deltaFromDiff = diff_deltaFromDiffs(diff);
    //    NSError *error = nil;
    //    NSArray *diffFromOriginalTextAndDelta = diff_diffsFromOriginalTextAndDelta(oldString, deltaFromDiff, &error);
    
    //    NSString *textOneFromDiff = diff_text1(diff);
    //    NSString *textTwoFromDiff = diff_text2(diff);
    
    // -- test log output
    //    NSLog(@"deltaFromDiff: %@", deltaFromDiff);
    //    NSLog(@"diffFromOriginalTextAndDelta: %@", diffFromOriginalTextAndDelta);
    
    //    NSLog(@"textOneFromDiff: %@", textOneFromDiff);
    //    NSLog(@"textTwoFromDiff: %@", textTwoFromDiff);
    
    //    NSLog(@"htmlDiff: %@", htmlDiff);
    
    //-- set diffview to output html
    UILabel *sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                                     5,
                                                                     CGRectGetWidth(self.view.bounds) - 10,
                                                                     200)];
    sourceLabel.backgroundColor = [UIColor colorWithRed:0.072 green:0.280 blue:0.400 alpha:1.000];
    sourceLabel.textColor = [UIColor whiteColor];
    sourceLabel.font = [UIFont fontWithName:@"Futura" size:16];
    sourceLabel.text = [NSString stringWithFormat:@"// oldString:\n%@\n\n// newString:\n%@", oldString, newString];
    sourceLabel.numberOfLines = 0;
    [self.view addSubview:sourceLabel];
    
    CCoreTextLabel *diffLabel = [[CCoreTextLabel alloc] initWithFrame:CGRectMake(5,
                                                                                 280,
                                                                                 CGRectGetWidth(self.view.bounds) - 10,
                                                                                 CGRectGetHeight(self.view.bounds))];
    diffLabel.markup          = htmlDiff;
    diffLabel.lineBreakMode   = NSLineBreakByWordWrapping;
    diffLabel.backgroundColor = [UIColor clearColor];
    diffLabel.textColor       = [UIColor darkGrayColor];
    diffLabel.font            = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    [self.view addSubview:diffLabel];
    
}

- (NSArray *)diffFromOldString:(NSString *)oldString
                  andNewString:(NSString *)newString
{
    
    NSArray *diff = diff_diffsBetweenTextsWithOptions(oldString,
                                                      newString,
                                                      FALSE,
                                                      0.0);
    
    return diff;
}


#pragma mark - fuzzy match

- (void)fuzzySearch
{
    
    _fuzzyTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _fuzzyTextView.text = @"yolo - you only live once";
    _fuzzyTextView.font = [UIFont fontWithName:@"AvenirNext-Medium" size:24];
    [self.view addSubview:_fuzzyTextView];
    
    [_fuzzyTextView becomeFirstResponder];
    
    NSString *pattern = @"love";
    
    // calculate fuzzy match
    double delayInSeconds = .5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSUInteger index = match_locationOfMatchInTextWithOptions(_fuzzyTextView.text,
                                                                  pattern,
                                                                  30,
                                                                  0.8,
                                                                  1000);
        NSLog(@"index of '%@' from text '%@' is %i", pattern, _fuzzyTextView.text ,index);
        [_fuzzyTextView setSelectedRange:NSMakeRange(index, 0)];
    });
}


- (NSUInteger)indexForFuzzySearchForPattern:(NSString *)patternString
                                     fromText:(NSString *)text
{
    
    NSUInteger index = match_locationOfMatchInText(text, patternString, 30);
    
    return index;
}


#pragma mark - patch

- (void)getPatch
{
    //
    NSString *textOne = @"Hello world";
    NSString *textTwo = @"Halo mundo";
    
    //
    NSArray *patchFromTwoText = patch_patchesFromTexts(textOne, textTwo);
    NSLog(@"patch from textOne: %@\n...and textTwo: %@\n... is: %@", textOne, textTwo, patchFromTwoText);
    
    //
    NSString *text = @"bye";
    NSString *appliedText = patch_applyPatchesToText(patchFromTwoText, text, NULL);
    NSLog(@"applied: %@", appliedText);
    
    
    UILabel *sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                                     5,
                                                                     CGRectGetWidth(self.view.bounds) - 10,
                                                                     CGRectGetHeight(self.view.bounds) - 10)];
    sourceLabel.backgroundColor = [UIColor colorWithRed:0.072 green:0.280 blue:0.400 alpha:1.000];
    sourceLabel.textColor = [UIColor whiteColor];
    sourceLabel.font = [UIFont fontWithName:@"Futura" size:16];
    sourceLabel.text = [NSString stringWithFormat:@"patch from textOne: %@\n...and textTwo: %@\n... is: %@", textOne, textTwo, patchFromTwoText];
    sourceLabel.numberOfLines = 0;
    [self.view addSubview:sourceLabel];
}


@end
