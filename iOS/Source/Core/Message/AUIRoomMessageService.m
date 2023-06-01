//
//  AUIRoomMessageService.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/2/24.
//

#import "AUIRoomMessageService.h"
#import "AUIRoomSDKHeader.h"
#import "AUIRoomAccount.h"
#import "AUIRoomAppServer.h"

@implementation AUIRoomMessage

+ (id<AUIRoomMessageServiceProtocol>)currentService {
    static AUIRoomMessageService *_instance = nil;
    if (!_instance) {
        _instance = [AUIRoomMessageService new];
    }
    return _instance;
}

@end



@interface AUIRoomMessageService () <AVCIInteractionEngineDelegate, AVCIInteractionServiceDelegate>

@property (nonatomic, strong) NSHashTable<id<AUIRoomMessageServiceObserver>> *observerList;
@property (nonatomic, copy) void (^loginCompleted)(BOOL success);

@end


@implementation AUIRoomMessageService

#pragma mark - Observer

- (NSHashTable<id<AUIRoomMessageServiceObserver>> *)observerList {
    if (!_observerList) {
        _observerList = [NSHashTable weakObjectsHashTable];
    }
    return _observerList;
}

- (void)addObserver:(id<AUIRoomMessageServiceObserver>)observer {
    if ([self.observerList containsObject:observer])
    {
        return;
    }
    [self.observerList addObject:observer];
}

- (void)removeObserver:(id<AUIRoomMessageServiceObserver>)observer {
    [self.observerList removeObject:observer];
}

#pragma mark - IM

- (AVCIInteractionEngine *)interactionEngine {
    static AVCIInteractionEngine *_instance = nil;
    if (!_instance) {
        AVCIInteractionEngineConfig *interactionEngineConfig = [[AVCIInteractionEngineConfig alloc] init];
        interactionEngineConfig.deviceID = AUIRoomAccount.deviceId;
        interactionEngineConfig.requestToken = ^(void (^ _Nonnull onRequestedToken)(NSString * _Nonnull, NSString * _Nonnull)) {
            [AUIRoomAppServer fetchToken:^(NSString * _Nullable accessToken, NSString * _Nullable refreshToken, NSError * _Nullable error) {
                NSLog(@"accessToken:%@\nrefreshToken:%@", accessToken, refreshToken);
                if (onRequestedToken) {
                    onRequestedToken(refreshToken ?: @"", accessToken ?: @"");
                }
            }];
        };
        _instance = [[AVCIInteractionEngine alloc] initWithConfig:interactionEngineConfig];
        _instance.delegate = self;
    }
    return _instance;
}

- (void)login:(void(^)(BOOL))completed {
    if (self.interactionEngine.isLogin) {
        if (completed) {
            completed(YES);
        }
        return;
    }
    if (AUIRoomAccount.me.userId.length == 0) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    if (self.loginCompleted) {
        // 上次调用login，此时返回失败
        self.loginCompleted(NO);
    }
    self.loginCompleted = completed;
    [self.interactionEngine loginWithUserID:AUIRoomAccount.me.userId];
}

- (void)logout {
    if (!self.interactionEngine.isLogin) {
        return;
    }
    [self.interactionEngine logoutOnSuccess:^{
        ;
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        NSAssert(NO, @"Logout failure");
    }];
}

#pragma mark - AUIRoomMessageServiceAction

static NSError *s_error(AVCIInteractionError *error) {
    return [NSError errorWithDomain:@"" code:error.code userInfo:@{NSLocalizedDescriptionKey:error.message?:@""}];
}

- (void)joinGroup:(NSString *)groupID
        extension:(NSString *)userExtension
        onSuccess:(void (^)(void))onSuccess
        onFailure:(void (^)(NSError *error))onFailure {
    [self.interactionEngine.interactionService joinGroup:groupID userNick:AUIRoomAccount.me.nickName userAvatar:AUIRoomAccount.me.avatar userExtension:userExtension ?: @"{}" broadCastType:2 broadCastStatistics:YES onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onSuccess) {
                onSuccess();
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        NSLog(@"IM Error:joinGroup(%d,%@)", error.code, error.message);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onFailure) {
                onFailure(s_error(error));
            }
        });
    }];
}

- (void)leaveGroup:(NSString *)groupID
          onSuccess:(void (^)(void))onSuccess
         onFailure:(void (^)(NSError *error))onFailure {
    [self.interactionEngine.interactionService leaveGroup:groupID broadCastType:0 onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onSuccess) {
                onSuccess();
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        NSLog(@"IM Error:leaveGroup(%d,%@)", error.code, error.message);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onFailure) {
                onFailure(s_error(error));
            }
        });
    }];
}

- (void)muteAll:(NSString *)groupID
      onSuccess:(void (^)(void))onSuccess
      onFailure:(void (^)(NSError* error))onFailure {
    [self.interactionEngine.interactionService muteAll:groupID broadCastType:2 onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onSuccess) {
                onSuccess();
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onFailure) {
                onFailure(s_error(error));
            }
        });
    }];
}

- (void)cancelMuteAll:(NSString *)groupID
            onSuccess:(void (^)(void))onSuccess
            onFailure:(void (^)(NSError* error))onFailure {
    [self.interactionEngine.interactionService cancelMuteAll:groupID broadCastType:2 onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onSuccess) {
                onSuccess();
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onFailure) {
                onFailure(s_error(error));
            }
        });
    }];
}

- (void)queryMuteAll:(NSString *)groupID
          onSuccess:(void (^)(BOOL isMuteAll))onSuccess
           onFailure:(void (^)(NSError * error))onFailure {
    [self.interactionEngine.interactionService getGroup:groupID onSuccess:^(AVCIInteractionGroupDetail * _Nonnull groupDetail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onSuccess) {
                onSuccess(groupDetail.isMuteAll);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onFailure) {
                onFailure(s_error(error));
            }
        });
    }];
}

- (void)listMuteUsers:(NSString *)groupID
            onSuccess:(void (^)(NSArray<NSString *> *ids))onSuccess
            onFailure:(void (^)(NSError * error))onFailure {
    [self.interactionEngine.interactionService listMuteUsersWithGroupID:groupID onSuccess:^(NSArray<AVCIInteractionMuteUser *> * _Nonnull users) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *ids = [NSMutableArray array];
            [users enumerateObjectsUsingBlock:^(AVCIInteractionMuteUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [ids addObject:obj.userId];
            }];
            if (onSuccess) {
                onSuccess(ids);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onFailure) {
                onFailure(s_error(error));
            }
        });
    }];
}

-(void)sendLike:(NSString *)groupID
          count:(NSUInteger)count
      onSuccess:(void (^)(void))onSuccess
      onFailure:(void (^)(NSError * error))onFailure {
    [self.interactionEngine.interactionService sendLikeWithGroupID:groupID count:(int32_t)count broadCastType:2 onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onSuccess) {
                onSuccess();
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onFailure) {
                onFailure(s_error(error));
            }
        });
    }];
}


- (void)sendTextMessage:(NSString *)groupID
                userIDs:(NSArray *)userIDs
                message:(NSString *)message
                   type:(AUIRoomMessageType)type
          skipMuteCheck:(BOOL)skipMuteCheck
              skipAudit:(BOOL)skipAudit
              onSuccess:(nonnull void (^)(void))onSuccess
              onFailure:(nonnull void (^)(NSError * error))onFailure {
    if (userIDs.count > 0) {
        [self.interactionEngine.interactionService sendTextMessageToGroupUsers:message groupID:groupID type:(int32_t)type userIDs:userIDs skipMuteCheck:skipMuteCheck skipAudit:skipAudit onSuccess:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (onSuccess) {
                    onSuccess();
                }
            });
        } onFailure:^(AVCIInteractionError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (onFailure) {
                    onFailure(s_error(error));
                }
            });
        }];
    }
    else {
        [self.interactionEngine.interactionService sendTextMessage:message groupID:groupID type:(int32_t)type skipMuteCheck:skipMuteCheck skipAudit:skipAudit onSuccess:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (onSuccess) {
                    onSuccess();
                }
            });
        } onFailure:^(AVCIInteractionError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (onFailure) {
                    onFailure(s_error(error));
                }
            });
        }];
    }
}
                 
#pragma mark - AVCIInteractionEngineDelegate

- (void)onKickout:(NSString *)info {
    ;
}

- (void)onError:(AVCIInteractionError *)error {
    NSLog(@"onConnectiononError:%d, message:%@", error.code, error.message);
}

- (void)onConnectionStatusChanged:(int32_t)status {
    NSLog(@"onConnectionStatusChanged:%d", status);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == 4) {
            self.interactionEngine.interactionService.delegate = self;
            if (self.loginCompleted) {
                self.loginCompleted(YES);
            }
            self.loginCompleted = nil;
        }
    });
}

- (void)onLog:(NSString *)log level:(AliInteractionLogLevel)level {
    NSLog(@"[IMSDK]:%@", log);
}

#pragma mark - AVCIInteractionServiceDelegate

- (void)onCustomMessageReceived:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onCustomMessageReceived:)];
}

- (void)onLikeReceived:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onLikeReceived:)];
}

- (void)onJoinGroup:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onJoinGroup:)];
}

- (void)onLeaveGroup:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onLeaveGroup:)];
}

- (void)onMuteGroup:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onMuteGroup:)];
}

- (void)onCancelMuteGroup:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onCancelMuteGroup:)];
}

- (void)onMuteUser:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onMuteUser:)];
}

- (void)onCancelMuteUser:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onCancelMuteUser:)];
}

- (void)onMessageReceived:(AVCIInteractionGroupMessage *)message selector:(SEL)selector {
    NSLog(@"onMessageReceived:%@, type:%d, gid:%@, uid:%@, nick_name:%@", message.data, message.type, message.groupId, message.senderInfo.userID, message.senderInfo.userNick);
    
    AUIRoomMessageModel *model = [AUIRoomMessageModel new];
    model.msgId = message.messageId;
    model.msgType = message.type;
    model.data = [self dictFromMessage:message];
    model.sender = [self senderFromMessage:message];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSEnumerator<id<AUIRoomMessageServiceObserver>>* enumerator = [self.observerList objectEnumerator];
        id<AUIRoomMessageServiceObserver> observer = nil;
        while ((observer = [enumerator nextObject])) {
            if ([observer.groupId isEqualToString:message.groupId]) {
                [observer performSelector:selector withObject:model];
            }
        }
    });
}

- (AUIRoomUser *)senderFromMessage:(AVCIInteractionGroupMessage *)message {
    AUIRoomUser *sender = [AUIRoomUser new];
    sender.userId = message.senderInfo.userID ?: message.senderId;
    sender.nickName = message.senderInfo.userNick;
    sender.avatar = message.senderInfo.userAvatar;
    return sender;
}

- (NSDictionary *)dictFromMessage:(AVCIInteractionGroupMessage *)message {
    NSDictionary *dict = nil;
    if ([message.data isKindOfClass:NSDictionary.class]) {
        dict = message.data;
    }
    else if ([message.data isKindOfClass:NSString.class]) {
        dict = [NSJSONSerialization JSONObjectWithData:[message.data dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    }
    return dict;
}

@end
