//
//  LYRUIAddresBarView.m
//  Pods
//
//  Created by Kevin Coleman on 10/27/14.
//
//

#import "LYRUIAddressBarTextView.h"
#import "LYRUIConstants.h"

NSString *const LYRUIPlaceHolder = @"Enter Name";

@interface LYRUIAddressBarTextView ()

@property (nonatomic) UILabel *toLabel;

@end

@implementation LYRUIAddressBarTextView

- (id)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setFirstLineHeadIndent:28.0f];
        [paragraphStyle setHeadIndent:0];
        [paragraphStyle setLineSpacing:6];
        self.attributedText = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSParagraphStyleAttributeName : paragraphStyle,
                                                                                           NSFontAttributeName : [UIFont systemFontOfSize:14],
                                                                                           NSForegroundColorAttributeName: [UIColor blackColor],
                                                                                           }];

        self.toLabel = [[UILabel alloc] init];
        self.toLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.toLabel.text = @"To:";
        self.toLabel.font = [UIFont systemFontOfSize:14];
        self.toLabel.textColor = LSGrayColor();
        [self.toLabel sizeToFit];
        [self addSubview:self.toLabel];
        
        [self updateConstraints];
        
    }
    return self;
}

- (void)updateConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.toLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:0 constant:12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.toLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:0 constant:8]];
    
    [super updateConstraints];
}

@end
