//
//  AUIEnterpriseLiveAudienceViewController.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/6.
//

#import "AUIEnterpriseLiveAudienceViewController.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"

#import "AUILiveRoomInteractionView.h"
#import "AUILiveRoomPlayerView.h"

#import "AUIRoomBaseLiveManagerAudience.h"


@interface AUIEnterpriseLiveAudienceViewController () <AVUIViewControllerInteractivePopGesture>

@property (strong, nonatomic) AUILiveRoomPlayerView *playerView;
@property (strong, nonatomic) AUILiveRoomInteractionView *interactionView;

@property (strong, nonatomic) id<AUIRoomLiveManagerAudienceProtocol> liveManager;

@end

@implementation AUIEnterpriseLiveAudienceViewController

#pragma mark - LifeCycle

- (void)dealloc {
    NSLog(@"dealloc:AUIEnterpriseLiveAudienceViewController");
}

- (instancetype)initWithModel:(AUIRoomLiveInfoModel *)model {
    self = [super init];
    if (self) {
        [self createLiveManager:model];
    }
    return self;
}
//
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupRoomUI];

    __weak typeof(self) weakSelf = self;
    [self.liveManager enterRoom:^(BOOL success) {
        if (!weakSelf) {
            return;
        }
        if (!success) {
            [AVAlertController showWithTitle:nil message:@"进入直播间失败，请稍后重试~" needCancel:NO onCompleted:^(BOOL isCanced) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
}

- (void)setupRoomUI {

    self.view.backgroundColor = AUIFoundationColor(@"bg_weak");
    __weak typeof(self) weakSelf = self;

    self.playerView = [[AUILiveRoomPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.av_width, self.view.av_width * 9 / 16.0  + AVSafeTop) withLiveManager:self.liveManager];
    self.playerView.onPlayFullScreenBlock = ^(AUILiveRoomPlayerView * _Nonnull sender, BOOL fullScreen) {
        if (@available(iOS 16.0, *)) {
#if defined(__IPHONE_16_0)
            [weakSelf setNeedsUpdateOfSupportedInterfaceOrientations];
#else
            [weakSelf updateOrientation:fullScreen ? UIDeviceOrientationLandscapeRight : UIDeviceOrientationPortrait];
#endif
        }
        else {
            [weakSelf updateOrientation:fullScreen ? UIDeviceOrientationLandscapeRight : UIDeviceOrientationPortrait];
        }
    };
    [self.view addSubview:self.playerView];
    
    
    self.interactionView = [[AUILiveRoomInteractionView alloc] initWithFrame:CGRectMake(0, self.playerView.av_bottom, self.view.av_width, self.view.av_height - self.playerView.av_bottom) withLiveManager:self.liveManager];
    [self.view addSubview:self.interactionView];
    [self.view bringSubviewToFront:self.playerView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.playerView.isFullScreen) {
        self.playerView.frame = self.view.bounds;
    }
    else {
        self.playerView.frame = CGRectMake(0, 0, self.view.av_width, self.view.av_width * 9 / 16.0  + AVSafeTop);
    }
}

#pragma mark - AVUIViewControllerInteractivePopGesture

- (BOOL)disableInteractivePopGesture {
    return YES;
}

#pragma mark - orientation

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.playerView.isFullScreen) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)updateOrientation:(UIDeviceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        
        BOOL generatesDeviceOrientationNotifications = [UIDevice currentDevice].isGeneratingDeviceOrientationNotifications;
        if (!generatesDeviceOrientationNotifications) {
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        }
        
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = (int)orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
        
        if (!generatesDeviceOrientationNotifications) {
            [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        }
    }
    [UIViewController attemptRotationToDeviceOrientation];
}

#pragma mark - live manager

- (void)createLiveManager:(AUIRoomLiveInfoModel *)liveInfoModel {
    self.liveManager = [[AUIRoomBaseLiveManagerAudience alloc] initWithModel:liveInfoModel];
    self.liveManager.roomVC = self;
}

@end
