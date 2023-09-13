//
//  AUIRoomBeautyQueenController.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/4.
//


#import "AUIRoomBeautyControllerProtocol.h"

#ifndef DISABLE_QUEEN

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomBeautyQueenController : NSObject <AUIRoomBeautyControllerProtocol>

+ (void)setupMotionManager;
+ (void)destroyMotionManager;

@end

NS_ASSUME_NONNULL_END

#endif
