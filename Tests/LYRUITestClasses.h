//
//  LYRUITestClasses.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 1/19/15.
//
//

#import <Foundation/Foundation.h>
#import <LayerUIKit/LayerUIKit.h>

@interface LYRUITestClasses : NSObject

@end

@interface LYRUITestConversationCell : LYRUIConversationTableViewCell <LYRUIConversationPresenting>

@end

@interface LYRUITestMessageCollectionViewCell : LYRUIMessageCollectionViewCell <LYRUIMessagePresenting>

@end

@interface LYRUITestParticipantCell : LYRUIParticipantTableViewCell

@end

@interface LYRUITestParticipantDataSource : NSObject <LYRUIParticipantPickerDataSource>

@property (nonatomic, readonly) NSSet *participants;

+ (instancetype)dataSourceWithParticipants:(NSSet *)participants;

@end
