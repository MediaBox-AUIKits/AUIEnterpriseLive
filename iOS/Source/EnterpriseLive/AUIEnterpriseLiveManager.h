//
//  AUIEnterpriseLiveManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/6.
//

#import <UIKit/UIKit.h>
#import "AUIRoomLiveModel.h"
#import "AUIRoomUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIEnterpriseLiveManager : NSObject

+ (instancetype)defaultManager;

- (void)setup;

- (void)setCurrentUser:(AUIRoomUser * _Nullable)user;
- (AUIRoomUser *)currentUser;
- (void)login:(void(^)(BOOL success))completedBlock;
- (void)logout;

// 加入直播间
- (void)joinLiveWithLiveId:(NSString *)liveId currentVC:(UIViewController *)currentVC completed:(nullable void(^)(BOOL success))completedBlock;
- (void)joinLive:(AUIRoomLiveInfoModel *)model currentVC:(UIViewController *)currentVC completed:(nullable void(^)(BOOL success))completedBlock;


@end

NS_ASSUME_NONNULL_END
