//
//  AUILiveRoomInteractionView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/6.
//

#import <UIKit/UIKit.h>
#import "AUIRoomBaseLiveManagerAudience.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomInteractionView : UIView

- (instancetype)initWithFrame:(CGRect)frame withLiveManager:(id<AUIRoomLiveManagerAudienceProtocol>)liveManager;

@end

NS_ASSUME_NONNULL_END
