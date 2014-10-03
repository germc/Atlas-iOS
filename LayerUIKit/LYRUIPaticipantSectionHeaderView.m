//
//  LYRUIPaticipantSectionHeaderView.m
//  Pods
//
//  Created by Kevin Coleman on 8/31/14.
//
//

#import "LYRUIPaticipantSectionHeaderView.h"
#import "LYRUIConstants.h"

@interface LYRUIPaticipantSectionHeaderView ()

@property (nonatomic) UIView *bottomBar;
@property (nonatomic) UILabel *keyLabel;

@end

@implementation LYRUIPaticipantSectionHeaderView
\
- (id)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(10, 30, 300, 0.5)];
        self.bottomBar.backgroundColor = LSGrayColor();
        [self addSubview:self.bottomBar];
        self.keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 50, 20)];
        self.keyLabel.font = [UIFont systemFontOfSize:12];
        self.keyLabel.text = key;
        self.keyLabel.textColor = LSGrayColor();
        [self addSubview:self.keyLabel];
    }
    return self;
}

@end
