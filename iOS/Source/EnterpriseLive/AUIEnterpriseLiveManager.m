//
//  AUIEnterpriseLiveManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/6.
//

#import "AUIEnterpriseLiveManager.h"
#import "AUIRoomAccount.h"
#import "AUIRoomAppServer.h"
#import "AUIRoomMessageService.h"

#import "AUIEnterpriseLiveAudienceViewController.h"

#import "AUIRoomTheme.h"
#import "AUIFoundation.h"
#import "AUIRoomSDKHeader.h"

static NSString * const kLiveServiceDomainString = @"你的AppServer域名";

@interface AUIEnterpriseLiveManager ()

@property (nonatomic, copy) void (^loginCompleted)(BOOL success);

@end

@implementation AUIEnterpriseLiveManager

+ (instancetype)defaultManager {
    static AUIEnterpriseLiveManager *_instance = nil;
    if (!_instance) {
        _instance = [AUIEnterpriseLiveManager new];
    }
    return _instance;
}

- (void)setup {
    // 设置bundle资源名称
    AUIRoomTheme.resourceName = @"AUIEnterpriseLive";
    
    // 设置AppServer地址
    [AUIRoomAppServer setServiceUrl:kLiveServiceDomainString];
    
    //初始化IM
    [AUIRoomMessage useAlivcIMWhenCompatMode:NO];
    [AUIRoomAppServer setIMServers:AUIRoomMessage.currentIMServers];
    
    // 初始化SDK
    [AlivcBase setIntegrationWay:@"aui-live-enterprise"];
    [AlivcLiveBase registerSDK];

    [AliPlayer setEnableLog:NO];
    [AliPlayer setLogCallbackInfo:LOG_LEVEL_NONE callbackBlock:nil];
    
#if DEBUG
    [AlivcLiveBase setLogLevel:AlivcLivePushLogLevelDebug];
    [AlivcLiveBase setLogPath:NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject maxPartFileSizeInKB:1024*100];
#endif
}

- (void)setCurrentUser:(AUIRoomUser *)user {
    AUIRoomAccount.me.userId = user.userId ?: @"";
    AUIRoomAccount.me.avatar = user.avatar ?: @"";
    AUIRoomAccount.me.nickName = user.nickName ?: @"";
    AUIRoomAccount.me.token = user.token ?: @"";
}

- (AUIRoomUser *)currentUser {
    return AUIRoomAccount.me;
}

- (void)login:(void(^)(BOOL success))completedBlock {
    [AUIRoomMessage.currentService login:completedBlock];
}

- (void)logout {
    [AUIRoomMessage.currentService logout];
}

- (void)joinLiveWithLiveId:(NSString *)liveId currentVC:(UIViewController *)currentVC completed:(void(^)(BOOL success))completedBlock {
    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:currentVC.view animated:YES];
    loading.labelText = @"正在加入直播间，请等待";
    // 登录IM
    [AUIRoomMessage.currentService login:^(BOOL success) {
        if (!success) {
            [loading hideAnimated:YES];
            [AVAlertController show:@"直播间登入失败" vc:currentVC];
            if (completedBlock) {
                completedBlock(NO);
            }
            return;
        }
        
        // 获取最新直播信息
        [AUIRoomAppServer fetchLive:liveId userId:nil completed:^(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error) {
            if (error) {
                [loading hideAnimated:YES];
                [AVAlertController show:@"直播间刷新失败" vc:currentVC];
                if (completedBlock) {
                    completedBlock(NO);
                }
                return;
            }
            
            [loading hideAnimated:YES];
            if ([model.anchor_id isEqualToString:AUIRoomAccount.me.userId]) {
                // 自己创建的直播间，这里不支持
                [AVAlertController show:@"不能加入自己创建的直播间" vc:currentVC];
                if (completedBlock) {
                    completedBlock(NO);
                }
                return;
            }
            AUIEnterpriseLiveAudienceViewController *vc = [[AUIEnterpriseLiveAudienceViewController alloc] initWithModel:model];
            [currentVC.navigationController pushViewController:vc animated:YES];
            if (completedBlock) {
                completedBlock(YES);
            }
        }];
    }];
}

- (void)joinLive:(AUIRoomLiveInfoModel *)model currentVC:(UIViewController *)currentVC completed:(void(^)(BOOL success))completedBlock {
    [self joinLiveWithLiveId:model.live_id currentVC:currentVC completed:completedBlock];
}

@end
