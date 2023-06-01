//
//  AUIRoomMessageModel.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/7.
//

#import "AUIRoomMessageModel.h"

@implementation AUIRoomMessageModel

@end


@implementation AUIRoomGiftModel

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _giftId = [data objectForKey:@"id"];
        _name = [data objectForKey:@"name"];
        _desc = [data objectForKey:@"description"];
        _imageUrl = [data objectForKey:@"imageUrl"];
    }
    return self;
}

- (NSDictionary *)toData {
    return @{
        @"id":_giftId ?: @"",
        @"name":_name ?: @"",
        @"description":_desc ?: @"",
        @"imageUrl":_imageUrl ?: @"",
    };
}

@end
