//
//  AUIRoomMessageService.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/2/24.
//

#import <Foundation/Foundation.h>
#import "AUIRoomMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AUIRoomMessageServiceObserver <NSObject>

/**
 * 消息所在的群
 */
- (NSString *)groupId;

/**
 * 收到自定义消息
 */
- (void)onCustomMessageReceived:(AUIRoomMessageModel *)message;

/**
 * 收到点赞消息
 */
- (void)onLikeReceived:(AUIRoomMessageModel *)message;

/**
 * 加入消息组
 */
- (void)onJoinGroup:(AUIRoomMessageModel *)message;

/**
 * 离开消息组
 */
- (void)onLeaveGroup:(AUIRoomMessageModel *)message;

/**
 * 禁言群组
 */
- (void)onMuteGroup:(AUIRoomMessageModel *)message;

/**
 * 取消禁言群组
 */
- (void)onCancelMuteGroup:(AUIRoomMessageModel *)message;

/**
 * 禁言用户
 */
- (void)onMuteUser:(AUIRoomMessageModel *)message;

/**
 * 取消禁言用户
 */
- (void)onCancelMuteUser:(AUIRoomMessageModel *)message;

@end


@protocol AUIRoomMessageServiceAction <NSObject>

- (void)joinGroup:(NSString *)groupID
        extension:(nullable NSString *)userExtension
        onSuccess:(void (^)(void))onSuccess
        onFailure:(void (^)(NSError *error))onFailure;

- (void)leaveGroup:(NSString *)groupID
          onSuccess:(void (^)(void))onSuccess
          onFailure:(void (^)(NSError *error))onFailure;

- (void)muteAll:(NSString *)groupID
      onSuccess:(void (^)(void))onSuccess
      onFailure:(void (^)(NSError* error))onFailure;

- (void)cancelMuteAll:(NSString *)groupID
            onSuccess:(void (^)(void))onSuccess
            onFailure:(void (^)(NSError* error))onFailure;

- (void)queryMuteAll:(NSString *)groupID
          onSuccess:(void (^)(BOOL isMuteAll))onSuccess
          onFailure:(void (^)(NSError * error))onFailure;

- (void)listMuteUsers:(NSString *)groupID
            onSuccess:(void (^)(NSArray<NSString *> *ids))onSuccess
            onFailure:(void (^)(NSError * error))onFailure;

-(void)sendLike:(NSString *)groupID
          count:(NSUInteger)count
      onSuccess:(void (^)(void))onSuccess
      onFailure:(void (^)(NSError * error))onFailure;


- (void)sendTextMessage:(NSString *)groupID
                userIDs:(NSArray *)userIDs
                message:(NSString *)message
                   type:(AUIRoomMessageType)type
          skipMuteCheck:(BOOL)skipMuteCheck
              skipAudit:(BOOL)skipAudit
              onSuccess:(void (^)(void))onSuccess
              onFailure:(void (^)(NSError * error))onFailure;

@end

@protocol AUIRoomMessageServiceProtocol <AUIRoomMessageServiceAction>

- (void)login:(void(^)(BOOL))completed;
- (void)logout;
- (void)addObserver:(id<AUIRoomMessageServiceObserver>)observer;
- (void)removeObserver:(id<AUIRoomMessageServiceObserver>)observer;

@end

@interface AUIRoomMessage : NSObject

@property (nonatomic, strong, readonly, class) id<AUIRoomMessageServiceProtocol> currentService;

@end

@interface AUIRoomMessageService : NSObject <AUIRoomMessageServiceProtocol>



@end

NS_ASSUME_NONNULL_END
