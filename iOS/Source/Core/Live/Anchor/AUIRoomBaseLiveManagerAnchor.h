//
//  AUIRoomBaseLiveManagerAnchor.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/4.
//

#import <Foundation/Foundation.h>
#import "AUIRoomDisplayView.h"
#import "AUIRoomUser.h"
#import "AUIRoomLiveModel.h"
#import "AUIRoomLiveService.h"

NS_ASSUME_NONNULL_BEGIN


@protocol AUIRoomLiveManagerAnchorProtocol <NSObject>

@property (strong, nonatomic, readonly) AUIRoomLiveInfoModel *liveInfoModel;
@property (strong, nonatomic) AUIRoomDisplayLayoutView *displayLayoutView;
@property (assign, nonatomic, readonly) BOOL isLiving;
@property (weak, nonatomic) UIViewController *roomVC;


@property (copy, nonatomic) void(^onStartedBlock)(void);
@property (copy, nonatomic) void(^onPausedBlock)(void);
@property (copy, nonatomic) void(^onResumedBlock)(void);
@property (copy, nonatomic) void(^onRestartBlock)(void);
@property (copy, nonatomic) void(^onConnectionPoorBlock)(void);
@property (copy, nonatomic) void(^onConnectionLostBlock)(void);
@property (copy, nonatomic) void(^onConnectionRecoveryBlock)(void);
@property (copy, nonatomic) void(^onConnectErrorBlock)(void);
@property (copy, nonatomic) void(^onReconnectStartBlock)(void);
@property (copy, nonatomic) void(^onReconnectSuccessBlock)(void);
@property (copy, nonatomic) void(^onReconnectErrorBlock)(void);
- (void)setupLivePusher;

- (void)enterRoom:(nullable void(^)(BOOL))completed;
- (void)leaveRoom:(nullable void (^)(BOOL))completed;

- (void)startLive:(nullable void(^)(BOOL))completed;
- (void)finishLive:(nullable void(^)(BOOL))completed;


// 全局禁言
@property (copy, nonatomic) void (^onReceivedMuteAll)(BOOL isMuteAll);
@property (assign, nonatomic, readonly) BOOL isMuteAll;
- (void)muteAll:(nullable void(^)(BOOL))completed;
- (void)cancelMuteAll:(nullable void(^)(BOOL))completed;

// 弹幕
@property (copy, nonatomic) void (^onReceivedComment)(AUIRoomUser *sender, NSString *content);
- (void)sendComment:(NSString *)comment completed:(nullable void(^)(BOOL))completed;

// 点赞
@property (copy, nonatomic) void (^onReceivedLike)(AUIRoomUser *sender, NSInteger likeCount);

// PV
@property (copy, nonatomic) void (^onReceivedPV)(NSInteger pv);
@property (assign, nonatomic, readonly) NSInteger pv;

// 公告
@property (copy, nonatomic, readonly) NSString *notice;
- (void)updateNotice:(NSString *)notice completed:(nullable void(^)(BOOL))completed;

// Gift
@property (copy, nonatomic) void (^onReceivedGift)(AUIRoomUser *sender, AUIRoomGiftModel *gift);


@property (assign, nonatomic, readonly) BOOL isMicOpened;
@property (assign, nonatomic, readonly) BOOL isCameraOpened;
@property (assign, nonatomic, readonly) BOOL isBackCamera;
@property (assign, nonatomic, readonly) BOOL isMirror;
- (void)openLivePusherMic:(BOOL)open;
- (void)openLivePusherCamera:(BOOL)open;
- (void)switchLivePusherCamera;
- (void)openLivePusherMirror:(BOOL)mirror;

- (void)openBeautyPanel;

@end



@interface AUIRoomBaseLiveManagerAnchor : NSObject<AUIRoomLiveManagerAnchorProtocol>

- (instancetype)initWithModel:(AUIRoomLiveInfoModel *)liveInfoModel;

@end

NS_ASSUME_NONNULL_END
