//
//  AUIRoomAccount.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/10/6.
//

#import <UIKit/UIKit.h>
#import "AUIRoomAccount.h"

@implementation AUIRoomAccount

+ (AUIRoomUser *)me {
    static AUIRoomUser *_instance = nil;
    if (!_instance) {
        _instance = [AUIRoomUser new];
    }
    return _instance;
}

+ (NSString *)deviceId {
    static NSString * _deviceId = nil;
    if (!_deviceId) {
        _deviceId = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    }
    return _deviceId;
}

@end
