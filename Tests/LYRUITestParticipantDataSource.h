//
//  LYRUITestParticipantDataSource.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/29/14.
//
//

#import <Foundation/Foundation.h>
#import <LayerUIKit/LayerUIKit.h>

@interface LYRUITestParticipantDataSource : NSObject <LYRUIParticipantPickerDataSource>

+ (instancetype)dataSourceWithParticipants:(NSSet *)participants;

@end
