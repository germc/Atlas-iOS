 //
//  UIMessageComposeTextView.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIMessageComposeTextView.h"
#import "LYRUIMediaAttachment.h"
#import "LYRUIConstants.h"

@interface LYRUIMessageComposeTextView () <UITextViewDelegate>

@property (nonatomic) CGFloat contentHeight;

@end

@implementation LYRUIMessageComposeTextView

static NSString *const LYRUIPlaceHolderText = @"Enter Message";

- (id)init
{
    self = [super init];
    if (self) {
        self.textContainerInset = UIEdgeInsetsMake(6, 0, 6, 0);
        self.font = [UIFont systemFontOfSize:14];
        self.text = @"Enter Message";
        self.textColor = [UIColor lightGrayColor];
        [self layoutIfNeeded];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textViewBeganEditing)
                                                     name:UITextViewTextDidBeginEditingNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textViewDidChange)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    CGFloat width = self.contentSize.width;
    CGFloat height = self.contentSize.height;
    return CGSizeMake(width, height);
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    // Don'd do anything here to prevent autoscrolling.
    // Unless you plan on using this method in another fashion.
}

- (void)insertImage:(UIImage *)image
{
    // Check for place holder text and remove if present
    [self displayPlaceHolderText:NO];
    // Create a text attachement with the image
    LYRUIMediaAttachment *textAttachment = [[LYRUIMediaAttachment alloc] init];
    textAttachment.image = image;
    // Make an Mutable attributed copy of the current attributed string
    NSMutableAttributedString *attributedString = [self.attributedText mutableCopy];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, self.attributedText.length)];
    // If we have text, add a line break
    if (attributedString.length > 0) {
        [self insertLineBreak:attributedString];
    }
    // Add the attachemtn as an attribtued string
    [attributedString replaceCharactersInRange:NSMakeRange(attributedString.length, 0)
                          withAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
    self.attributedText = attributedString;
    [self layoutIfNeeded];
}

- (void)insertVideoAtPath:(NSString *)videoPath
{
    [self layoutIfNeeded];
}

- (void)insertLocation:(CLLocationCoordinate2D)location
{
    [self layoutIfNeeded];
}

- (void)removeAttachements
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}];
    self.attributedText = attributedString;
    [self layoutIfNeeded];
}

- (void)insertLineBreak:(NSMutableAttributedString *)mutableAttributedString
{
    [mutableAttributedString insertAttributedString:[[NSMutableAttributedString alloc] initWithString:@" \n "] atIndex:mutableAttributedString.length];
    [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, mutableAttributedString.length)];
    self.attributedText = mutableAttributedString;
}

- (BOOL)previousIndexIsAttachement
{
    if (!self.attributedText.length > 0) return FALSE;
    NSDictionary *theAttributes = [self.attributedText attributesAtIndex:self.attributedText.length - 1
                                                   longestEffectiveRange:nil
                                                                 inRange:NSMakeRange(0, self.attributedText.length)];
    NSTextAttachment *theAttachment = [theAttributes objectForKey:NSAttachmentAttributeName];
    if (theAttachment != NULL) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (void)displayPlaceHolderText:(BOOL)displayPlaceHolderText
{
    if ([self.text isEqualToString:LYRUIPlaceHolderText]) {
        if (displayPlaceHolderText) {
            self.text = @"Enter Message";
        } else {
            self.text = @"";
        }
    }
}

- (void)textViewBeganEditing
{
    [self displayPlaceHolderText:NO];
    if ([self previousIndexIsAttachement]) {
        [self insertLineBreak:[self.attributedText mutableCopy]];
    }
    self.textColor = [UIColor blackColor];
    [self layoutIfNeeded];
}

- (void)textViewDidChange
{
    [self layoutIfNeeded];
}
@end
