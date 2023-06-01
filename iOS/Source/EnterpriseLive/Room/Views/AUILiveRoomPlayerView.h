//
//  AUILiveRoomPlayerView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/6.
//

#import <UIKit/UIKit.h>
#import "AUIRoomBaseLiveManagerAudience.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomPlayerView : UIView

@property (assign, nonatomic, readonly) BOOL isFullScreen;
@property (copy, nonatomic) void (^onPlayFullScreenBlock)(AUILiveRoomPlayerView *sender, BOOL fullScreen);

- (instancetype)initWithFrame:(CGRect)frame withLiveManager:(id<AUIRoomLiveManagerAudienceProtocol>)liveManager;

@end

NS_ASSUME_NONNULL_END
