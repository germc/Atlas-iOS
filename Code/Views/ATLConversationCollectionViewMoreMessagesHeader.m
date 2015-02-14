//
//  ATLUIConversationCollectionViewMoreMessagesHeader.m
//  Atlas
//
//  Created by Ben Blakley on 1/15/15.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ATLConversationCollectionViewMoreMessagesHeader.h"

@interface ATLConversationCollectionViewMoreMessagesHeader ()

@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ATLConversationCollectionViewMoreMessagesHeader

NSString *const ATLMoreMessagesHeaderIdentifier = @"ATLMoreMessagesHeaderIdentifier";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)  {
        [self lyr_commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (void)lyr_commonInit
{
    _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_activityIndicatorView startAnimating];
    [self addSubview:_activityIndicatorView];
    
    [self configureActivityIndicatorViewConstraints];
}

- (void)configureActivityIndicatorViewConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

@end
