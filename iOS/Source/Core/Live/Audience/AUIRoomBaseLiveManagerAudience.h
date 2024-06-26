//
//  AUIRoomBaseLiveManagerAudience.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/28.
//

#import <Foundation/Foundation.h>
#import "AUIRoomDisplayView.h"
#import "AUIRoomUser.h"
#import "AUIRoomLiveModel.h"
#import "AUIRoomLiveService.h"

NS_ASSUME_NONNULL_BEGIN


@protocol AUIRoomLiveManagerAudienceProtocol <NSObject>

@property (strong, nonatomic, readonly) AUIRoomLiveInfoModel *liveInfoModel;
@property (strong, nonatomic) AUIRoomDisplayLayoutView *displayLayoutView;
@property (assign, nonatomic, readonly) BOOL isLiving;
@property (weak, nonatomic) UIViewController *roomVC;

- (void)setupPullPlayer:(BOOL)scaleAspectFit;
- (BOOL)pause:(BOOL)pause;

- (void)enterRoom:(nullable void(^)(BOOL))completed;
- (void)leaveRoom:(nullable void (^)(BOOL))completed;
@property (nonatomic, copy) void (^onReceivedLeaveRoom)(void);  // 被动离开房间

@property (nonatomic, copy) void (^onReceivedStartLive)(void);
@property (nonatomic, copy) void (^onReceivedStopLive)(void);

// 全局禁言
@property (copy, nonatomic) void (^onReceivedMuteAll)(BOOL isMuteAll);
@property (assign, nonatomic, readonly) BOOL isMuteAll;

// 弹幕
@property (copy, nonatomic) void (^onReceivedComment)(AUIRoomUser *sender, NSString *content);
- (void)sendComment:(NSString *)comment completed:(nullable void(^)(BOOL))completed;

// 点赞
@property (copy, nonatomic) void (^onReceivedLike)(AUIRoomUser *sender, NSInteger likeCount);
- (void)sendLike;

// PV
@property (copy, nonatomic) void (^onReceivedPV)(NSInteger pv);
@property (assign, nonatomic, readonly) NSInteger pv;

// 公告
@property (nonatomic, copy) void (^onReceivedNoticeUpdate)(NSString *notice);
@property (copy, nonatomic, readonly) NSString *notice;

// 礼物
@property (copy, nonatomic) void (^onReceivedGift)(AUIRoomUser *sender, AUIRoomGiftModel *gift, NSInteger count);
- (void)sendGift:(AUIRoomGiftModel *)gift completed:(void(^)(BOOL))completed;

// 商品
@property (copy, nonatomic) void (^onReceivedProduct)(AUIRoomUser *sender, AUIRoomProductModel *product);

@end


@interface AUIRoomBaseLiveManagerAudience : NSObject<AUIRoomLiveManagerAudienceProtocol>

- (instancetype)initWithModel:(AUIRoomLiveInfoModel *)liveInfoModel;

@end

NS_ASSUME_NONNULL_END
