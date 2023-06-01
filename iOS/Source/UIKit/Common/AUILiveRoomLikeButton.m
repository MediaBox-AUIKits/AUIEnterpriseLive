//
//  AUILiveRoomLikeButton.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomLikeButton.h"
#import "AUIRoomMacro.h"

@interface AUILiveRoomLikeButton ()

@property (nonatomic, assign) BOOL isRepeatLikeAnimation;
@property (nonatomic, strong) NSTimer *animationTimer;

@end

@implementation AUILiveRoomLikeButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"like_button:touchesBegan");
    self.isRepeatLikeAnimation = YES;
    [self likeAnimation];
    [self startLikeTimer];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSLog(@"like_button:touchesEnded");
    self.isRepeatLikeAnimation = NO;
    [self stopLikeTimer];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"like_button:touchesCancelled");
    self.isRepeatLikeAnimation = NO;
    [self stopLikeTimer];
}

- (void)startLikeTimer {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(likeAnimation) userInfo:nil repeats:YES];
}

- (void)stopLikeTimer {
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

- (void)likeAnimation {
    NSLog(@"like_button:timer to animation");

    if (!self.isRepeatLikeAnimation) {
        [self stopLikeTimer];
        return;
    }
    
    UIImageView *imageView = [[UIImageView alloc] init];
    CGRect frame = self.superview.superview.frame;
    // 初始frame，即设置了动画的起点
    imageView.frame = CGRectMake(self.frame.origin.x + self.superview.frame.origin.x, self.frame.origin.y + self.superview.frame.origin.y, 30,30);
    // 初始化imageView透明度为0
    imageView.alpha =0;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.clipsToBounds = YES;
    // 用0.2秒的时间将imageView的透明度变成1.0，同时将其放大1.3倍，再缩放至1.1倍，这里参数根据需求设置
    [UIView animateWithDuration:0.2 animations:^{
        imageView.alpha =1.0;
//        imageView.frame = CGRectMake(frame.size.width -40, frame.size.height -90,30,30);
        CGAffineTransform transfrom = CGAffineTransformMakeScale(1.3,1.3);
        imageView.transform = CGAffineTransformScale(transfrom,1,1);
    }];
    [self.superview.superview addSubview:imageView];
    // 随机产生一个动画结束点的X值
    CGFloat finishX = frame.size.width - round(random() % 120);
    // 动画结束点的Y值
    CGFloat finishY = imageView.frame.origin.y - 214;
    // imageView在运动过程中的缩放比例
    CGFloat scale = round(random() %2) +0.7;
    // 生成一个作为速度参数的随机数
    CGFloat speed =1/ round(random() %900) +0.6;
    // 动画执行时间
    NSTimeInterval duration =4* speed;
    // 如果得到的时间是无穷大，就重新附一个值（这里要特别注意，请看下面的特别提醒）
    if(duration == INFINITY) duration =2.412346;
    // 开始动画
    [UIView beginAnimations:nil context:(__bridge void *_Nullable)(imageView)];
    // 设置动画时间
    [UIView setAnimationDuration:duration];
    // 拼接图片名字
    NSString *ic_like = [NSString stringWithFormat:@"ic_like_%u", arc4random() % 6 + 1];
    imageView.image = AUIRoomGetCommonImage(ic_like);
    // 设置imageView的结束frame
    imageView.frame =CGRectMake( finishX, finishY,30* scale,30* scale);
    // 设置渐渐消失的效果，这里的时间最好和动画时间一致
    [UIView animateWithDuration:duration animations:^{
        imageView.alpha =0;
    }];
    // 结束动画，调用onAnimationComplete:finished:context:函数
    [UIView setAnimationDidStopSelector:@selector(onAnimationComplete:finished:context:)];
    // 设置动画代理
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    UIImageView *imageView = (__bridge UIImageView*)(context);
    [imageView removeFromSuperview];
    imageView = nil;
}


@end
