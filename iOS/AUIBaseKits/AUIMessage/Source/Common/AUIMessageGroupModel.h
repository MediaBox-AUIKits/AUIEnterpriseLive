//
//  AUIMessageGroupModel.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import <Foundation/Foundation.h>
#import "AUIMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIMessageCreateGroupRequest : NSObject

/**
 * 群组id，在Alivc无效，一般情况下无需传入
 */
@property (nonatomic, copy, nullable) NSString *groupId;

/**
 * 群组名称
 */
@property (nonatomic, copy, nullable) NSString *groupName;

/**
 * 扩展信息
 */
@property (nonatomic, copy, nullable) NSString *groupExtension;

@end


@interface AUIMessageCreateGroupResponse : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

@end


@interface AUIMessageJoinGroupRequest : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

@end

@interface AUIMessageLeaveGroupRequest : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

@end

@interface AUIMessageSendMessageToGroupRequest : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

/**
 * 消息类型
 */
@property (nonatomic, assign) NSInteger msgType;

/**
 * 消息级别
 */
@property (nonatomic, assign) AUIMessageLevel msgLevel;

/**
 * 消息体内容
 */
@property (nonatomic, strong) id<AUIMessageDataProtocol> data;

/**
 * 是否跳过审核
 */
@property (nonatomic, assign) BOOL skipAudit;

/**
 * 跳过禁言检测，true:忽略被禁言用户，还可发消息；false：当被禁言时，消息无法发送，默认为false，即为不跳过禁言检测。
 */
@property (nonatomic, assign) BOOL skipMuteCheck;

@end


@interface AUIMessageSendMessageToGroupResponse : NSObject

/**
 * 消息id
 */
@property (nonatomic, copy) NSString *messageId;

@end


@interface AUIMessageSendMessageToGroupUserRequest : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy, nullable) NSString *groupId;

/**
 * 消息类型
 */
@property (nonatomic, assign) NSInteger msgType;

/**
 * 消息级别
 */
@property (nonatomic, assign) AUIMessageLevel msgLevel;

/**
 * 消息体内容
 */
@property (nonatomic, strong) id<AUIMessageDataProtocol> data;

/**
 * 接收用户ID
 */
@property (nonatomic, copy) NSString *receiverId;

/**
 * 是否跳过审核
 */
@property (nonatomic, assign) BOOL skipAudit;


@end

@interface AUIMessageSendMessageToGroupUserResponse : NSObject

/**
 * 消息id
 */
@property (nonatomic, copy) NSString *messageId;

@end


@interface AUIMessageMuteAllRequest : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

@end


@interface AUIMessageCancelMuteAllRequest : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

@end


@interface AUIMessageQueryMuteAllRequest : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

@end


@interface AUIMessageQueryMuteAllResponse : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

/**
 * 是否全员禁言
 */
@property (nonatomic, assign) NSInteger isMuteAll;


@end

@interface AUIMessageSendLikeRequest : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;
/**
 * 点赞数
 */
@property (nonatomic, assign) NSInteger count;

@end

@interface AUIMessageGetGroupInfoRequest : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

@end


@interface AUIMessageGetGroupInfoResponse : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

/**
 * PV，当实现不支持获取PV时，返回-1
 */
@property (nonatomic, assign) NSInteger pv;

/**
 * 在线人数，当实现不支持获取在线人数时，返回-1
 */
@property (nonatomic, assign) NSInteger onlineCount;


@end


NS_ASSUME_NONNULL_END
