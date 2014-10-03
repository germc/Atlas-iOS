//
//  LSUIConstants.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/17/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

static NSString *const LSFontMedium = @"HelveticaNeue";
static NSString *const LSFontBold = @"HelveticaNeue-Bold";
static NSString *const LSFontLight = @"HelveticaNeue-Light";

UIColor *LSBlueColor()
{
    return [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0];
}

UIColor *LSGrayColor()
{
    return [UIColor colorWithRed:216.0/255.0 green:223.0/255.0 blue:229.0/255.0 alpha:1.0];
}

UIColor *LSLighGrayColor()
{
    return [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0];
}

UIFont *LSMediumFont(CGFloat size)
{
    return [UIFont fontWithName:LSFontMedium size:size];
}

UIFont *LSBoldFont(CGFloat size)
{
    return [UIFont fontWithName:LSFontBold size:size];
}

UIFont *LSLightFont(CGFloat size)
{
    return [UIFont fontWithName:LSFontLight size:size];
}
