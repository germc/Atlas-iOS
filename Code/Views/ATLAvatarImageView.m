//
//  ATLUIAvatarImageView.m
//  Atlas
//
//  Created by Kevin Coleman on 10/22/14.
//  Copyright (c) 2015 Layer. All rights reserved.
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
#import "ATLAvatarImageView.h"
#import "ATLConstants.h"

@interface ATLAvatarImageView ()

@property (nonatomic) UILabel *initialsLabel;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;

@end

@implementation ATLAvatarImageView

NSString *const ATLAvatarImageViewAccessibilityLabel = @"ATLAvatarImageViewAccessibilityLabel";


+ (NSCache *)sharedImageCache
{
    static NSCache *_sharedImageCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedImageCache = [NSCache new];
    });
    return _sharedImageCache;
}

+ (void)initialize
{
    ATLAvatarImageView *proxy = [self appearance];
    proxy.backgroundColor = ATLLightGrayColor();
}

- (id)init
{
    self = [super init];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (void)lyr_commonInit
{
    // Default UI Appearance
    _initialsFont = [UIFont systemFontOfSize:14];
    _initialsColor = [UIColor blackColor];
    _avatarImageViewDiameter = 27;
    
    self.clipsToBounds = YES;
    self.layer.cornerRadius = _avatarImageViewDiameter / 2;
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.accessibilityLabel = ATLAvatarImageViewAccessibilityLabel;
    
    _initialsLabel = [[UILabel alloc] init];
    _initialsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _initialsLabel.textAlignment = NSTextAlignmentCenter;
    _initialsLabel.adjustsFontSizeToFitWidth = YES;
    _initialsLabel.minimumScaleFactor = 0.75;
    _initialsLabel.textColor = _initialsColor;
    _initialsLabel.font = _initialsFont;
    [self addSubview:_initialsLabel];
    [self configureInitialsLabelConstraint];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(self.avatarImageViewDiameter, self.avatarImageViewDiameter);
}

- (void)resetView
{
    self.avatarItem = nil;
    self.image = nil;
    self.initialsLabel.text = nil;
    [self.downloadTask cancel];
}

- (void)dealloc
{
    [self.downloadTask cancel];
}

- (void)setAvatarItem:(id<ATLAvatarItem>)avatarItem
{
    if ([avatarItem avatarImageURL]) {
        self.initialsLabel.text = nil;
        [self loadAvatarImageWithURL:[avatarItem avatarImageURL]];
    } else if (avatarItem.avatarImage) {
        self.initialsLabel.text = nil;
        self.image = avatarItem.avatarImage;
    } else if (avatarItem.avatarInitials) {
        self.image = nil;
        self.initialsLabel.text = avatarItem.avatarInitials;
    }
    _avatarItem = avatarItem;
}

- (void)setInitialsColor:(UIColor *)initialsColor
{
    self.initialsLabel.textColor = initialsColor;
    _initialsColor = initialsColor;
}

- (void)setInitialsFont:(UIFont *)initialsFont
{
    self.initialsLabel.font = initialsFont;
    _initialsFont = initialsFont;
}

- (void)setAvatarImageViewDiameter:(CGFloat)avatarImageViewDiameter
{
    self.layer.cornerRadius = avatarImageViewDiameter / 2;
    _avatarImageViewDiameter = avatarImageViewDiameter;
    [self invalidateIntrinsicContentSize];
}

- (void)setImageViewBackgroundColor:(UIColor *)imageViewBackgroundColor
{
    self.backgroundColor = imageViewBackgroundColor;
    _imageViewBackgroundColor = imageViewBackgroundColor;
}
         
- (void)loadAvatarImageWithURL:(NSURL *)imageURL
{
    if (![imageURL isKindOfClass:[NSURL class]] || imageURL.absoluteString.length == 0) {
        NSLog(@"Cannot fetch image without URL");
        return;
    }
    
    // Check if image is in cache
    __block NSString *stringURL = imageURL.absoluteString;
    UIImage *image = [[[self class] sharedImageCache] objectForKey:stringURL];
    if (image) {
        self.image = image;
        return;
    }
    
    // If not, fetch the image and add to the cache
    [self fetchImageFromRemoteImageURL:imageURL];
}

- (void)fetchImageFromRemoteImageURL:(NSURL *)remoteImageURL
{
    self.downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:remoteImageURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (!error && location) {
            __block UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
            if (image) {
                [[[self class] sharedImageCache] setObject:image forKey:remoteImageURL.absoluteString cost:0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateWithImage:image forRemoteImageURL:remoteImageURL];
                });
            }
        }
    }];
    [self.downloadTask resume];
}

- (void)updateWithImage:(UIImage *)image forRemoteImageURL:(NSURL *)remoteImageURL;
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.image = image;
            self.alpha = 1.0;
        }];
    }];
}

- (void)configureInitialsLabelConstraint
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:3]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-3]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:3]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-3]];
}
    
@end
