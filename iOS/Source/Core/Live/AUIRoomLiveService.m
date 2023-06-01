//
//  AUIRoomLiveService.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/2/25.
//

#import "AUIRoomLiveService.h"
#import "AUIRoomAppServer.h"
#import "AUIRoomAccount.h"
#import "AUIRoomMessageService.h"

@interface AUIRoomLiveService () <AUIRoomMessageServiceObserver>

@property (strong, nonatomic) AUIRoomLiveInfoModel *liveInfoModel;
@property (strong, nonatomic) AUIRoomMessageService *messageService;

@property (assign, nonatomic) NSInteger pv;
@property (assign, nonatomic) BOOL isJoined;

@property (assign, nonatomic) BOOL isMuteAll;
@property (assign, nonatomic) BOOL isMuteByAuchor;

@property (nonatomic, strong) NSTimer *sendLikeTimer;
@property (assign, nonatomic) NSInteger allLikeCount;
@property (assign, nonatomic) NSInteger likeCountWillSend;
@property (assign, nonatomic) NSInteger likeCountToSend;

@property (copy, nonatomic) NSString *notice;

@end

@implementation AUIRoomLiveService


- (BOOL)isAnchor {
    return [self.liveInfoModel.anchor_id isEqualToString:AUIRoomAccount.me.userId];
}

- (NSString *)jsonStringWithDict:(NSDictionary *)dict {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - Room

- (void)enterRoom:(void(^)(BOOL))completed {
    __weak typeof(self) weakSelf = self;
    [self.messageService joinGroup:self.liveInfoModel.chat_id extension:nil onSuccess:^{
        weakSelf.isJoined = YES;
        if (completed) {
            completed(YES);
        }
    } onFailure:^(NSError * _Nonnull error) {
        if (completed) {
            completed(NO);
        }
    }];
}

- (void)leaveRoom:(void(^)(BOOL))completed {
    __weak typeof(self) weakSelf = self;
    [self.messageService leaveGroup:self.liveInfoModel.chat_id onSuccess:^{
        weakSelf.isJoined = NO;
        if (completed) {
            completed(YES);
        }
    } onFailure:^(NSError * _Nonnull error) {
        if (completed) {
            completed(NO);
        }
    }];
}

#pragma mark - Live

- (void)startLive:(void(^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [AUIRoomAppServer startLive:self.liveInfoModel.live_id ?: @"" completed:^(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error) {
        if (error) {
            if (completed) {
                completed(NO);
            }
        }
        [self.liveInfoModel updateStatus:model.status];
        NSDictionary *msg = @{};
        [self sendMessage:msg type:AUIRoomMessageTypeStartLive uids:nil skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
            if (completed) {
                completed(success);
            }
        }];
    }];
}

- (void)finishLive:(void(^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    if (self.liveInfoModel.status == AUIRoomLiveStatusFinished) {
        if (completed) {
            completed(YES);
        }
    }
    
    [AUIRoomAppServer stopLive:self.liveInfoModel.live_id ?: @"" completed:^(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error) {
        if (error) {
            if (completed) {
                completed(NO);
            }
        }
        [self.liveInfoModel updateStatus:model.status];
        NSDictionary *msg = @{};
        [self sendMessage:msg type:AUIRoomMessageTypeStopLive uids:nil skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
            if (completed) {
                completed(success);
            }
        }];
    }];
}

#pragma mark - Mute

- (void)queryMuteAll:(void (^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.messageService queryMuteAll:self.liveInfoModel.chat_id onSuccess:^(BOOL isMuteAll) {
        weakSelf.isMuteAll = isMuteAll;
        if (completed) {
            completed(YES);
        }
    } onFailure:^(NSError * _Nonnull error) {
        if (completed) {
            completed(NO);
        }
    }];
}

- (void)queryMuteByAnchor:(void (^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.messageService listMuteUsers:self.liveInfoModel.chat_id onSuccess:^(NSArray<NSString *> * _Nonnull ids) {
        weakSelf.isMuteByAuchor = NO;
        [ids enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([AUIRoomAccount.me.userId isEqualToString:obj]) {
                weakSelf.isMuteByAuchor = YES;
                *stop = YES;
            }
        }];
        if (completed) {
            completed(YES);
        }
    } onFailure:^(NSError * _Nonnull error) {
        if (completed) {
            completed(NO);
        }
    }];
}

- (void)muteAll:(void (^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.messageService muteAll:self.liveInfoModel.chat_id onSuccess:^{
        weakSelf.isMuteAll = YES;
        if (completed) {
            completed(YES);
        }
    } onFailure:^(NSError * _Nonnull error) {
        if (completed) {
            completed(NO);
        }
    }];
}

- (void)cancelMuteAll:(void (^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.messageService cancelMuteAll:self.liveInfoModel.chat_id onSuccess:^{
        weakSelf.isMuteAll = NO;
        if (completed) {
            completed(YES);
        }
    } onFailure:^(NSError * _Nonnull error) {
        if (completed) {
            completed(NO);
        }
    }];
}

#pragma mark - Notice

- (void)updateNotice:(NSString *)notice completed:(void (^)(BOOL))completed {
    if (!self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [AUIRoomAppServer updateLive:self.liveInfoModel.live_id title:nil notice:notice extend:nil completed:^(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error) {
        if (!error) {
            self.notice = notice;
            NSDictionary *msg = @{@"notice":notice?:@""};
            [self sendMessage:msg type:AUIRoomMessageTypeNotice uids:nil skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
                if (completed) {
                    completed(success);
                }
            }];
        }
        if (completed) {
            completed(!error);
        }
    }];
}


#pragma mark - Like

- (void)sendLike {
    self.likeCountWillSend++;
    NSLog(@"like_button:will send:%zd", self.likeCountWillSend);
    if (!self.sendLikeTimer) {
        [self startSendLikeTimer];
    }
}

- (void)sendLike:(NSInteger)count completed:(void(^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [self.messageService sendLike:self.liveInfoModel.chat_id count:count onSuccess:^{
        if (completed) {
            completed(YES);
        }
    } onFailure:^(NSError * _Nonnull error) {
        if (completed) {
            completed(NO);
        }
    }];
}

- (void)startSendLikeTimer {
    if (self.isJoined) {
        self.sendLikeTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timeToSendLike) userInfo:nil repeats:NO];
    }
}

- (void)stopSendLikeTimer {
    [self.sendLikeTimer invalidate];
    self.sendLikeTimer = nil;
}

- (void)timeToSendLike {
    [self stopSendLikeTimer];
    
    if (self.likeCountWillSend > 0) {
        self.likeCountToSend = self.likeCountWillSend;
        self.likeCountWillSend = 0;
        NSLog(@"like_button:sending:%zd", self.likeCountToSend);
        __weak typeof(self) weakSelf = self;
        [self sendLike:self.likeCountToSend completed:^(BOOL success) {
            if (!success) {
                weakSelf.likeCountWillSend += weakSelf.likeCountToSend;
                NSLog(@"like_button:send failed:%zd", weakSelf.likeCountToSend);
            }
            else {
                NSLog(@"like_button:send completed:%zd", weakSelf.likeCountToSend);
            }
            if (weakSelf.likeCountWillSend > 0) {
                [weakSelf startSendLikeTimer];
                NSLog(@"like_button:next 2 second to send:%zd", weakSelf.likeCountWillSend);
            }
        }];
    }
}

#pragma mark - Gift

- (void)sendGift:(AUIRoomGiftModel *)gift completed:(void(^)(BOOL))completed {
    if (!self.isJoined || self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [self sendData:gift type:AUIRoomMessageTypeGift uids:@[self.liveInfoModel.anchor_id] skipMuteCheck:YES skipAudit:YES completed:completed];
}

#pragma mark - Pusher state

- (void)sendCameraOpened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{@"cameraOpened":@(opened)};
    [self sendMessage:msg type:AUIRoomMessageTypeCameraOpened uids:nil skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendMicOpened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{@"micOpened":@(opened)};
    [self sendMessage:msg type:AUIRoomMessageTypeMicOpened uids:nil skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendOpenCamera:(NSString *)userId needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor || userId.length == 0 || [userId isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    NSDictionary *msg = @{@"needOpenCamera":@(needOpen)};
    [self sendMessage:msg type:AUIRoomMessageTypeNeedOpenCamera uids:@[userId] skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendOpenMic:(NSString *)userId needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor || userId.length == 0 || [userId isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    NSDictionary *msg = @{@"needOpenMic":@(needOpen)};
    [self sendMessage:msg type:AUIRoomMessageTypeNeedOpenMic uids:@[userId] skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

#pragma mark - Comment

- (void)sendComment:(NSString *)comment completed:(void(^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    if (comment.length == 0) {
        if (completed) {
            completed(NO);
        }
    }
    NSDictionary *msg = @{
        @"content":comment,
    };
    [self sendMessage:msg type:AUIRoomMessageTypeComment uids:nil skipMuteCheck:NO skipAudit:NO completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

#pragma mark - Message

- (void)sendMessage:(NSDictionary *)content type:(AUIRoomMessageType)type uids:(NSArray<NSString *> *)uids skipMuteCheck:(BOOL)skipMuteCheck skipAudit:(BOOL)skipAudit completed:(void (^)(BOOL))completed {
    if (content == nil) {
        content = @{};
    }
    NSString *json = [self jsonStringWithDict:content];

    [self.messageService sendTextMessage:self.liveInfoModel.chat_id userIDs:uids message:json type:type skipMuteCheck:skipMuteCheck skipAudit:skipAudit onSuccess:^{
        if (completed) {
            completed(YES);
        }
    } onFailure:^(NSError * _Nonnull error) {
        if (completed) {
            completed(NO);
        }
    }];
}

- (void)sendData:(id<AUIRoomCustomMessageData>)data type:(AUIRoomMessageType)type uids:(NSArray<NSString *> *)uids skipMuteCheck:(BOOL)skipMuteCheck skipAudit:(BOOL)skipAudit completed:(void (^)(BOOL))completed {
    NSDictionary *content = [data toData];
    [self sendMessage:content type:type uids:uids skipMuteCheck:skipMuteCheck skipAudit:skipAudit completed:completed];
}

#pragma mark - link mic

- (void)sendApplyLinkMic:(NSString *)uid completed:(void (^)(BOOL))completed {
    if (!self.isJoined || uid.length == 0 || [uid isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    // 观众只能申请跟主播连麦
    if (self.isAnchor || ![uid isEqualToString:self.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{
    };
    [self sendMessage:msg type:AUIRoomMessageTypeApplyLinkMic uids:@[uid] skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendCancelApplyLinkMic:(NSString *)uid completed:(void (^)(BOOL))completed {
    if (!self.isJoined || uid.length == 0 || [uid isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    // 观众只能跟主播取消申请连麦
    if (self.isAnchor || ![uid isEqualToString:self.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{
    };
    [self sendMessage:msg type:AUIRoomMessageTypeCancelApplyLinkMic uids:@[uid] skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendResponseLinkMic:(NSString *)uid agree:(BOOL)agree pullUrl:(NSString *)pullUrl completed:(void (^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor || uid.length == 0 || [uid isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    [msg setObject:@(agree) forKey:@"agree"];
    if (agree) {
        [msg setObject:pullUrl?:@"" forKey:@"rtcPullUrl"];
    }
    [self sendMessage:msg type:AUIRoomMessageTypeResponseLinkMic uids:@[uid] skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendJoinLinkMic:(NSString *)pullUrl completed:(void (^)(BOOL))completed {
    if (!self.isJoined || pullUrl.length == 0 || self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{
        @"rtcPullUrl":pullUrl?:@"",
    };
    [self sendMessage:msg type:AUIRoomMessageTypeJoinLinkMic uids:nil skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendLeaveLinkMic:(BOOL)byKickout completed:(void (^)(BOOL))completed {
    if (!self.isJoined || self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{
        @"reason":byKickout ? @"byKickout" : @"bySelf"
    };
    [self sendMessage:msg type:AUIRoomMessageTypeLeaveLinkMic uids:nil skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendKickoutLinkMic:(NSString *)uid completed:(void (^)(BOOL))completed {
    if (!self.isAnchor || !self.isJoined || uid.length == 0 || [uid isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{
    };
    [self sendMessage:msg type:AUIRoomMessageTypeKickoutLinkMic uids:@[uid] skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

static NSUInteger g_maxLinkMicCount = 6;
+ (NSUInteger)maxLinkMicCount {
    return g_maxLinkMicCount;
}

+ (void)setMaxLinkMicCount:(NSUInteger)maxLinkMicCount {
    g_maxLinkMicCount = maxLinkMicCount;
}

- (void)queryLinkMicJoinList:(void (^)(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *))completed {
    
    if (self.liveInfoModel.mode == AUIRoomLiveModeBase) {
        if (completed) {
            completed(nil);
        }
        return;
    }
    
    [AUIRoomAppServer queryLinkMicJoinList:self.liveInfoModel.live_id completed:^(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> * _Nullable models, NSError * _Nullable error) {
        if (completed) {
            completed(models);
        }
    }];
}

- (void)updateLinkMicJoinList:(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList completed:(nullable void (^)(BOOL))completed {
    if (!self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [AUIRoomAppServer updateLinkMicJoinList:self.liveInfoModel.live_id joinList:joinList completed:^(NSError * _Nullable error) {
        if (completed) {
            completed(error == nil);
        }
    }];
}

#pragma mark - Life Cycle

- (void)dealloc {
    [_messageService removeObserver:self];
}

- (instancetype)initWithModel:(AUIRoomLiveInfoModel *)model
                 withJoinList:(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList {
    self = [super init];
    if (self) {
        _liveInfoModel = model;
        _joinList = joinList;
        
        _messageService = AUIRoomMessage.currentService;
        [_messageService addObserver:self];
        
        _allLikeCount = _liveInfoModel.metrics.like_count;
        _pv = _liveInfoModel.metrics.pv;
        _notice = _liveInfoModel.notice;
    }
    return self;
}

#pragma mark - AUIRoomMessageServiceObserver

- (NSString *)groupId {
    return self.liveInfoModel.chat_id;
}

- (void)onCustomMessageReceived:(AUIRoomMessageModel *)message {
    
    AUIRoomUser *sender = message.sender;
    NSDictionary *data = message.data;

    if (message.msgType == AUIRoomMessageTypeComment) {
        if (self.onReceivedComment) {
            NSString *comment = [data objectForKey:@"content"];
            self.onReceivedComment(sender, comment);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeStartLive) {
        if (self.onReceivedStartLive) {
            self.onReceivedStartLive(sender);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeStopLive) {
        if (self.onReceivedStopLive) {
            self.onReceivedStopLive(sender);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeNotice) {
        NSString *notice = [data objectForKey:@"notice"];
        self.notice = notice;
        if (self.onReceivedNoticeUpdate) {
            self.onReceivedNoticeUpdate(notice);
        }
        return;
    }
    
    if (message.msgType == AUIRoomMessageTypeJoinLinkMic) {
        AUIRoomLiveLinkMicJoinInfoModel *joinInfo = [[AUIRoomLiveLinkMicJoinInfoModel alloc] init:sender.userId userNick:sender.nickName userAvatar:sender.avatar rtcPullUrl:[data objectForKey:@"rtcPullUrl"]];
        if (self.onReceivedJoinLinkMic) {
            self.onReceivedJoinLinkMic(sender, joinInfo);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeLeaveLinkMic) {
        if (self.onReceivedLeaveLinkMic) {
            self.onReceivedLeaveLinkMic(sender, sender.userId);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeApplyLinkMic) {
        if (self.onReceivedApplyLinkMic) {
            self.onReceivedApplyLinkMic(sender);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeCancelApplyLinkMic) {
        if (self.onReceivedCancelApplyLinkMic) {
            self.onReceivedCancelApplyLinkMic(sender);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeResponseLinkMic) {
        if (self.onReceivedResponseApplyLinkMic) {
            self.onReceivedResponseApplyLinkMic(sender, [[data objectForKey:@"agree"] boolValue], [data objectForKey:@"rtcPullUrl"]);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeKickoutLinkMic) {
        if (self.onReceivedLeaveLinkMic) {
            self.onReceivedLeaveLinkMic(sender, AUIRoomAccount.me.userId);
        }
        return;
    }
    
    if (message.msgType == AUIRoomMessageTypeMicOpened) {
        if (self.onReceivedMicOpened) {
            self.onReceivedMicOpened(sender, [[data objectForKey:@"micOpened"] boolValue]);
        }
        return;
    }
    
    if (message.msgType == AUIRoomMessageTypeCameraOpened) {
        if (self.onReceivedCameraOpened) {
            self.onReceivedCameraOpened(sender, [[data objectForKey:@"cameraOpened"] boolValue]);
        }
        return;
    }
    
    if (message.msgType == AUIRoomMessageTypeNeedOpenMic) {
        if (self.onReceivedOpenMic) {
            self.onReceivedOpenMic(sender, [[data objectForKey:@"needOpenMic"] boolValue]);
        }
        return;
    }
    
    if (message.msgType == AUIRoomMessageTypeNeedOpenCamera) {
        if (self.onReceivedOpenCamera) {
            self.onReceivedOpenCamera(sender, [[data objectForKey:@"needOpenCamera"] boolValue]);
        }
        return;
    }
    
    if (message.msgType == AUIRoomMessageTypeGift) {
        if (self.onReceivedGift) {
            self.onReceivedGift(sender, [[AUIRoomGiftModel alloc] initWithData:data]);
        }
        return;
    }
    
    if (self.onReceivedCustomMessage) {
        self.onReceivedCustomMessage(message);
    }
}

- (void)onLikeReceived:(AUIRoomMessageModel *)message {
    NSInteger likeCount = [[message.data objectForKey:@"likeCount"] integerValue];
    if (likeCount > self.allLikeCount) {
        self.allLikeCount = likeCount;
        if (self.onReceivedLike) {
            self.onReceivedLike(message.sender, self.allLikeCount);
        }
    }
}

- (void)onJoinGroup:(AUIRoomMessageModel *)message {
    AUIRoomUser *sender = message.sender;
    NSDictionary *data = message.data;
    NSDictionary *stat = [data objectForKey:@"statistics"];
    
    NSInteger likeCount = [[data objectForKey:@"likeCount"] integerValue];
    if (likeCount > self.allLikeCount) {
        self.allLikeCount = likeCount;
        if (self.onReceivedLike) {
            self.onReceivedLike(sender, self.allLikeCount);
        }
    }
    
    NSInteger pv = [[stat objectForKey:@"pv"] integerValue];
    if (pv > self.pv) {
        self.pv = pv;
        if (self.onReceivedPV) {
            self.onReceivedPV(sender, self.pv);
        }
    }
    
    if (self.onReceivedJoinGroup) {
        self.onReceivedJoinGroup(sender, stat);
    }
}

- (void)onLeaveGroup:(AUIRoomMessageModel *)message {
    
}

- (void)onMuteGroup:(AUIRoomMessageModel *)message {
    self.isMuteAll = YES;
    if (self.onReceivedMuteAll) {
        self.onReceivedMuteAll(self.isMuteAll);
    }
}

- (void)onCancelMuteGroup:(AUIRoomMessageModel *)message {
    self.isMuteAll = NO;
    if (self.onReceivedMuteAll) {
        self.onReceivedMuteAll(self.isMuteAll);
    }
}

- (void)onMuteUser:(AUIRoomMessageModel *)message {
    ;
}

- (void)onCancelMuteUser:(AUIRoomMessageModel *)message {
    ;
}

@end
