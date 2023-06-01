//
//  AUILiveRoomPlayerView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/6.
//

#import "AUILiveRoomPlayerView.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"

#import "AUILiveRoomMemberButton.h"
#import "AUILiveRoomPrestartView.h"
#import "AUILiveRoomFinishView.h"

@interface AUIRoomLiveDisplayControlView : UIView

@property (strong, nonatomic) AVBlockButton* playButton;
@property (strong, nonatomic) AVBlockButton* fullscreenButton;
@property (nonatomic, strong) CAGradientLayer *bottomViewLayer;
@property (assign, nonatomic) UIEdgeInsets bottomBarEdgeInset;
@property (nonatomic, assign) BOOL immerse;
@property (copy, nonatomic) void (^onPlayImmerseBlock)(void);

@end

@implementation AUIRoomLiveDisplayControlView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bottomBarEdgeInset = UIEdgeInsetsMake(8, 8, 8, 8);
        
        CAGradientLayer *bottomViewLayer = [CAGradientLayer layer];
        bottomViewLayer.frame = CGRectMake(0, self.av_height - 44, self.av_width, 44);
        bottomViewLayer.colors = @[(id)[UIColor av_colorWithHexString:@"#141416" alpha:0].CGColor,(id)[UIColor av_colorWithHexString:@"#141416" alpha:0.7].CGColor];
        bottomViewLayer.startPoint = CGPointMake(0.5, 0);
        bottomViewLayer.endPoint = CGPointMake(0.5, 1);
        [self.layer addSublayer:bottomViewLayer];
        self.bottomViewLayer = bottomViewLayer;
#ifdef LIVE_PAUSE
        AVBlockButton *play = [[AVBlockButton alloc] initWithFrame:CGRectZero];
        play.titleEdgeInsets = UIEdgeInsetsMake(18, 18, 18, 18);
        [play setImage:AUIRoomGetCommonImage(@"ic_player_pause") forState:UIControlStateNormal];
        [play setImage:AUIRoomGetCommonImage(@"ic_player_play") forState:UIControlStateSelected];
        [self addSubview:play];
        self.playButton = play;
#endif
        AVBlockButton *fullscreen = [[AVBlockButton alloc] initWithFrame:CGRectZero];
        fullscreen.titleEdgeInsets = UIEdgeInsetsMake(18, 18, 18, 18);
        [fullscreen setImage:AUIRoomGetCommonImage(@"ic_player_fullscreen") forState:UIControlStateNormal];
        [fullscreen setImage:AUIRoomGetCommonImage(@"ic_player_fullscreen_selected") forState:UIControlStateSelected];
        [self addSubview:fullscreen];
        self.fullscreenButton = fullscreen;
        
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bottomViewLayer.frame = CGRectMake(0, self.av_height - 44, self.av_width, 44);
    self.playButton.frame = CGRectMake(self.bottomBarEdgeInset.left, self.av_height - 40 - self.bottomBarEdgeInset.bottom, 40, 40);
    self.fullscreenButton.frame = CGRectMake(self.av_width - 40 - self.bottomBarEdgeInset.right, self.av_height - 40 - self.bottomBarEdgeInset.bottom, 40, 40);
}

- (void)onTap:(UITapGestureRecognizer *)recognizer {
    self.immerse = !self.immerse;
}

- (void)setImmerse:(BOOL)immerse {
    if (_immerse == immerse) {
        return;
    }
    _immerse = immerse;
    self.bottomViewLayer.hidden = _immerse;
    self.playButton.hidden = _immerse;
    self.fullscreenButton.hidden = _immerse;
    if (self.onPlayImmerseBlock) {
        self.onPlayImmerseBlock();
    }
}

@end

@interface AUILiveRoomPlayerView ()

@property (strong, nonatomic) id<AUIRoomLiveManagerAudienceProtocol> liveManager;

@property (strong, nonatomic) CAGradientLayer *backgroundLayer;
@property (strong, nonatomic) AUIRoomDisplayLayoutView *liveDisplayView;
@property (strong, nonatomic) AUIRoomLiveDisplayControlView *liveDisplayControlView;

@property (strong, nonatomic) AVBlockButton* exitButton;
@property (strong, nonatomic) AUILiveRoomMemberButton *membersButton;
@property (strong, nonatomic) AUILiveRoomPrestartView *livePrestartView;
@property (strong, nonatomic) AUILiveRoomFinishView *liveFinishView;

@property (assign, nonatomic) BOOL isFullScreen;

@end

@implementation AUILiveRoomPlayerView

- (instancetype)initWithFrame:(CGRect)frame withLiveManager:(id<AUIRoomLiveManagerAudienceProtocol>)liveManager {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBackground];

        _liveManager = liveManager;
        _liveManager.displayLayoutView = self.liveDisplayView;
        [_liveManager setupPullPlayer:YES];

        __weak typeof(self) weakSelf = self;
        _liveManager.onReceivedPV = ^(AUIRoomUser * _Nonnull sender, NSInteger pv) {
            [weakSelf.membersButton updateMemberCount:pv];
        };
        _liveManager.onReceivedStartLive = ^{
            [weakSelf showLivingUI];
        };
        _liveManager.onReceivedStopLive = ^{
            [weakSelf showFinishUI];
        };
        
        [self livePrestartView];
        [self liveFinishView];
        [self exitButton];
        [self membersButton];

        if (self.liveManager.liveInfoModel.status == AUIRoomLiveStatusNone) {
            [self showPrestartUI];
        }
        else if (self.liveManager.liveInfoModel.status == AUIRoomLiveStatusFinished) {
            [self showFinishUI];
        }
        else {
            [self showLivingUI];
        }

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundLayer.frame = self.bounds;
    
    CGFloat safeLeft = UIView.av_isIphoneX ? 48 : 0;
    CGFloat safeRight = UIView.av_isIphoneX ? 34 : 0;

    
    self.liveDisplayView.contentInsets = self.isFullScreen ? UIEdgeInsetsZero: UIEdgeInsetsMake(AVSafeTop, 0, 0, 0);
    self.liveDisplayView.frame = self.bounds;
    
    self.liveDisplayControlView.bottomBarEdgeInset = self.isFullScreen ? UIEdgeInsetsMake(8, safeLeft + 8, AVSafeBottom, safeRight + 8) : UIEdgeInsetsMake(8, 8, 8, 8);
    self.liveDisplayControlView.frame = self.liveDisplayView.bounds;
    self.livePrestartView.frame = CGRectMake(0, AVSafeTop, self.av_width, self.av_height - AVSafeTop);
    
    if (self.isFullScreen) {
        self.exitButton.frame = CGRectMake(safeLeft + 8, 22, self.exitButton.av_width, self.exitButton.av_height);
        self.membersButton.frame = CGRectMake(self.av_right - safeRight - 16 - self.membersButton.av_width, 30, self.membersButton.av_width, self.membersButton.av_height);
    }
    else {
        self.exitButton.frame = CGRectMake(8, AVSafeTop, self.exitButton.av_width, self.exitButton.av_height);
        self.membersButton.frame = CGRectMake(self.av_right - 16 - self.membersButton.av_width, AVSafeTop + 10, self.membersButton.av_width, self.membersButton.av_height);
    }

    self.liveFinishView.frame = self.bounds;
}

- (void)showPrestartUI {
    self.livePrestartView.hidden = NO;
    self.liveDisplayView.hidden = YES;
    self.liveFinishView.hidden = YES;
}

- (void)showLivingUI {
    self.livePrestartView.hidden = YES;
    self.liveDisplayView.hidden = NO;
    self.liveFinishView.hidden = YES;
}

- (void)showFinishUI {
    self.livePrestartView.hidden = YES;
    self.liveFinishView.hidden = NO;
    self.liveFinishView.vodModel = self.liveManager.liveInfoModel.vod_info;
    self.liveDisplayView.hidden = YES;
    self.membersButton.hidden = NO;
    self.exitButton.hidden = NO;
}

- (void)setupBackground {
    self.backgroundColor = AUIFoundationColor(@"bg_weak");
    CAGradientLayer *bgLayer = [CAGradientLayer layer];
    bgLayer.frame = self.bounds;
    bgLayer.colors = @[(id)[UIColor colorWithRed:0x39 / 255.0 green:0x1a / 255.0 blue:0x0f / 255.0 alpha:1.0].CGColor,(id)[UIColor colorWithRed:0x1e / 255.0 green:0x23 / 255.0 blue:0x26 / 255.0 alpha:1.0].CGColor];
    bgLayer.startPoint = CGPointMake(0, 0.5);
    bgLayer.endPoint = CGPointMake(1, 0.5);
    [self.layer addSublayer:bgLayer];
    self.backgroundLayer = bgLayer;
}

- (void)setIsFullScreen:(BOOL)isFullScreen {
    if (_isFullScreen == isFullScreen) {
        return;
    }
    _isFullScreen = isFullScreen;
    self.liveFinishView.isFullScreen = _isFullScreen;
    self.liveDisplayControlView.fullscreenButton.selected = _isFullScreen;
    if (self.onPlayFullScreenBlock) {
        self.onPlayFullScreenBlock(self, _isFullScreen);
    }
}

- (AUIRoomDisplayLayoutView *)liveDisplayView {
    if (!_liveDisplayView) {
        _liveDisplayView = [[AUIRoomDisplayLayoutView alloc] initWithFrame:self.bounds];
        _liveDisplayView.resolution = CGSizeMake(720, 1280);
        _liveDisplayView.contentInsets = UIEdgeInsetsMake(AVSafeTop, 0, 0, 0);
        
        __weak typeof(self) weakSelf = self;
        _liveDisplayView.onlayoutChangedBlock = ^(AUIRoomDisplayLayoutView * _Nonnull sender) {
            if (sender.displayViewList.count > 0 && !weakSelf.liveDisplayControlView) {
                AUIRoomLiveDisplayControlView *liveDisplayControlView = [[AUIRoomLiveDisplayControlView alloc] initWithFrame:sender.bounds];
                liveDisplayControlView.onPlayImmerseBlock = ^{
                    BOOL immerse = weakSelf.liveDisplayControlView.immerse;
                    weakSelf.membersButton.hidden = immerse;
                    weakSelf.exitButton.hidden = immerse;
                };
                liveDisplayControlView.playButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
                    sender.selected = [weakSelf.liveManager pause:!sender.selected];
                };
                liveDisplayControlView.fullscreenButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
                    weakSelf.isFullScreen = !sender.selected;
                };
                [sender addSubview:liveDisplayControlView];
                weakSelf.liveDisplayControlView = liveDisplayControlView;
            }
            weakSelf.liveDisplayControlView.hidden = sender.displayViewList.count == 0;
            weakSelf.liveDisplayView.backgroundColor = weakSelf.liveDisplayControlView.hidden ? UIColor.clearColor : UIColor.blackColor;
        };
        [self addSubview:_liveDisplayView];
    }
    return _liveDisplayView;
}

- (AVBlockButton *)exitButton {
    if (!_exitButton) {
        AVBlockButton* button = [[AVBlockButton alloc] initWithFrame:CGRectMake(8, AVSafeTop, 40, 40)];
        button.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [button setImage:AUIRoomGetCommonImage(@"ic_living_close") forState:UIControlStateNormal];
        [self addSubview:button];
        
        __weak typeof(self) weakSelf = self;
        button.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            
            if (weakSelf.isFullScreen) {
                weakSelf.isFullScreen = NO;
            }
            else {
                void (^destroyBlock)(void) = ^{
                    [weakSelf.liveManager leaveRoom:nil];
                    [weakSelf.liveManager.roomVC.navigationController popViewControllerAnimated:YES];
                };
                destroyBlock();
            }
        };
        _exitButton = button;
    }
    return _exitButton;
}

- (AUILiveRoomMemberButton *)membersButton {
    if (!_membersButton) {
        _membersButton = [[AUILiveRoomMemberButton alloc] initWithFrame:CGRectMake(self.av_right - 16 - 55, AVSafeTop + 10, 55, 24)];
        _membersButton.layer.cornerRadius = 12;
        _membersButton.layer.masksToBounds = YES;
        [_membersButton updateMemberCount:self.liveManager.pv];
        [self addSubview:_membersButton];
    }
    return _membersButton;
}

- (AUILiveRoomPrestartView *)livePrestartView {
    if (!_livePrestartView) {
        _livePrestartView = [[AUILiveRoomPrestartView alloc] initWithFrame:CGRectMake(0, AVSafeTop, self.av_width, self.av_height - AVSafeTop)];
        _livePrestartView.hidden = YES;
        [self insertSubview:_livePrestartView belowSubview:self.liveDisplayView];
    }
    return _livePrestartView;
}

- (AUILiveRoomFinishView *)liveFinishView {
    if (!_liveFinishView) {
        _liveFinishView = [[AUILiveRoomFinishView alloc] initWithFrame:self.bounds landscapeMode:YES];
        _liveFinishView.hidden = YES;
        [self insertSubview:_liveFinishView aboveSubview:self.liveDisplayView];

        __weak typeof(self) weakSelf = self;
        _liveFinishView.onPlayImmerseBlock = ^(AUILiveRoomFinishView * _Nonnull sender, BOOL immerse) {
            weakSelf.membersButton.hidden = immerse;
            weakSelf.exitButton.hidden = immerse;
        };
        _liveFinishView.onPlayFullScreenBlock = ^(AUILiveRoomFinishView * _Nonnull sender, BOOL fullScreen) {
            weakSelf.isFullScreen = fullScreen;
        };
    }
    return _liveFinishView;
}

@end
