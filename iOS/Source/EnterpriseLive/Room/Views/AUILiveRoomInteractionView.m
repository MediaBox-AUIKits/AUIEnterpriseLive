//
//  AUILiveRoomInteractionView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/6.
//

#import "AUILiveRoomInteractionView.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"

#import "AUIRoomAccount.h"
#import "AUILiveRoomBottomView.h"
#import "AUILiveRoomCommentView.h"
#import "AUILiveRoomActionManager.h"

//#define AUTO_COMMENT_TEST

typedef NS_ENUM(NSUInteger, AUILiveRoomInteractionHeaderType) {
    AUILiveRoomInteractionHeaderIntroduce,
    AUILiveRoomInteractionHeaderComment,
};

@interface AUILiveRoomInteractionHeaderView : UIView

@property (nonatomic, strong) NSArray<NSNumber *> *typeList;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) NSMutableArray<UIButton *> *buttonList;
@property (nonatomic, weak, readonly) UIButton *selectedButton;
@property (nonatomic, strong, readonly) UIView *selectLineView;

@property (nonatomic, copy) void (^onSelectedBlock)(AUILiveRoomInteractionHeaderType type);

@end

@implementation AUILiveRoomInteractionHeaderView

- (instancetype)initWithFrame:(CGRect)frame headerTypeList:(NSArray<NSNumber *> *)typeList {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = AUIFoundationColor(@"bg_weak");
        
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        _selectLineView = [[UIView alloc] initWithFrame:CGRectMake(0, _scrollView.av_height - 2, 40, 2)];
        _selectLineView.backgroundColor = AUIRoomColourfulFillStrong;
        _selectLineView.hidden = YES;
        [_scrollView addSubview:_selectLineView];
        
        _typeList = typeList;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _buttonList = [NSMutableArray array];
    
    NSArray *list = @[
        @"简介",
        @"聊天"
    ];
    
    __block CGFloat left = 0;
    CGFloat width = _scrollView.av_width / _typeList.count;
    CGFloat minWidth = _scrollView.av_width / 4.5;
    width = MAX(width, minWidth);
    [_typeList enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AUILiveRoomInteractionHeaderType type = [obj integerValue];
        NSString *name = [list objectAtIndex:type];
        UIButton *btn = [self createHeaderButton:type title:name];
        btn.frame = CGRectMake(left, 0, width, _scrollView.av_height);
        [_buttonList addObject:btn];
        [_scrollView addSubview:btn];
        left += btn.av_width;
    }];
    _scrollView.contentSize = CGSizeMake(MAX(left, _scrollView.av_width), _scrollView.av_height);
    _selectLineView.hidden = _buttonList.count <= 1;
    [self onButtonClick:_buttonList.firstObject];
}

- (UIButton *)createHeaderButton:(AUILiveRoomInteractionHeaderType)type title:(NSString *)title {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
    btn.tag = type;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:AUIFoundationColor(@"text_medium") forState:UIControlStateNormal];
    [btn setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateSelected];
    btn.titleLabel.font = AVGetRegularFont(14);
    [btn addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)onButtonClick:(UIButton *)sender {
    if (_selectedButton == sender) {
        return;
    }
    _selectedButton.selected = NO;
    _selectedButton.titleLabel.font = AVGetRegularFont(14);
    _selectedButton = sender;
    _selectedButton.selected = YES;
    _selectedButton.titleLabel.font = AVGetMediumFont(14);
    [UIView animateWithDuration:0.25 animations:^{
        self->_selectLineView.av_centerX = self->_selectedButton.av_centerX;
    }];
    if (_onSelectedBlock) {
        _onSelectedBlock(_selectedButton.tag);
    }
}

- (UIButton *)headerButton:(AUILiveRoomInteractionHeaderType)type {
    __block UIButton *btn = nil;
    [self.buttonList enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == type) {
            btn = obj;
            *stop = YES;
        }
    }];
    return btn;
}

@end

@interface AUILiveRoomIntroduceView : UIView

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation AUILiveRoomIntroduceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.contentLabel.numberOfLines = 0;
        [self addSubview:self.contentLabel];
    }
    return self;
}

- (void)refreshContent:(id<AUIRoomLiveManagerAudienceProtocol>)liveManager {
    NSString *title = [liveManager.liveInfoModel.title stringByAppendingString:@"\n"];
    NSString *notice = liveManager.notice;

    NSString *time = liveManager.liveInfoModel.created_at;
    if (time.length > 0) {
        NSISO8601DateFormatter *iso = [NSISO8601DateFormatter new];
        NSDate *date = [iso dateFromString:time];
        if (date) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm"];
            time = [dateFormatter stringFromDate:date];
        }
        if (time) {
            time = [time stringByAppendingString:@"\n"];
        }
    }
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.paragraphSpacing = 8;

    [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:AUIFoundationColor(@"text_strong"), NSFontAttributeName:AVGetMediumFont(16), NSParagraphStyleAttributeName:ps}]];
        
    if (time.length > 0) {
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:time attributes:@{NSForegroundColorAttributeName:AUIFoundationColor(@"text_weak"), NSFontAttributeName:AVGetRegularFont(12), NSParagraphStyleAttributeName:ps}]];
    }
    
    if (notice.length > 0) {
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:notice attributes:@{NSForegroundColorAttributeName:AUIFoundationColor(@"text_medium"), NSFontAttributeName:AVGetRegularFont(14), NSParagraphStyleAttributeName:ps}]];
    }
    
    self.contentLabel.attributedText = attributeString;
    
    self.contentLabel.frame = self.bounds;
    [self.contentLabel sizeToFit];
}

@end


@interface AUILiveRoomInteractionView ()

@property (nonatomic, strong) id<AUIRoomLiveManagerAudienceProtocol> liveManager;

@property (nonatomic, strong) AUILiveRoomInteractionHeaderView *headerView;
@property (nonatomic, strong) UILabel *commentUnreadNumberLabel;
@property (nonatomic, assign) NSUInteger commentUnreadNumber;

@property (nonatomic, strong) AUILiveRoomBottomView *bottomView;

@property (nonatomic, strong) AUILiveRoomCommentView *liveCommentView;
@property (nonatomic, strong) AUILiveRoomIntroduceView *introduceView;

@end


@implementation AUILiveRoomInteractionView

- (instancetype)initWithFrame:(CGRect)frame  withLiveManager:(id<AUIRoomLiveManagerAudienceProtocol>)liveManager {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = AUIFoundationColor(@"bg_medium");
        
        _liveManager = liveManager;
        __weak typeof(self) weakSelf = self;
        _liveManager.onReceivedComment = ^(AUIRoomUser * _Nonnull sender, NSString * _Nonnull content) {
            if (content.length == 0 || !weakSelf.liveCommentView) {
                return;
            }
            AUILiveRoomCommentModel* model = [[AUILiveRoomCommentModel alloc] init];
            model.sentContent = content;
            model.senderNick = sender.nickName;
            model.senderID = sender.userId;
            model.sentContentColor = AUIFoundationColor(@"text_strong");
            model.senderNickColor = AUIFoundationColor(@"text_weak");
            model.useFlag = YES;
            model.isAnchor = [sender.userId isEqualToString:weakSelf.liveManager.liveInfoModel.anchor_id];
            model.isMe = [sender.userId isEqualToString:AUIRoomAccount.me.userId];
            model.cellInsets = UIEdgeInsetsMake(6, 0, 6, 0);
            [weakSelf.liveCommentView insertLiveComment:model];
            
            if (weakSelf.liveCommentView.hidden) {
                weakSelf.commentUnreadNumber++;
                [weakSelf updateCommentUnreadNumber];
            }
        };
        
        _liveManager.onReceivedMuteAll = ^(BOOL isMuteAll) {
            weakSelf.bottomView.commentTextField.commentState = isMuteAll ?  AUILiveRoomCommentStateMute : AUILiveRoomCommentStateDefault;
        };
        
        _liveManager.onReceivedNoticeUpdate = ^(NSString * _Nonnull notice) {
            [weakSelf.introduceView refreshContent:weakSelf.liveManager];
        };
        
        [self headerView];
        [self bottomView];
        [self introduceView];
        [self liveCommentView];
    }
    return self;
}

- (AUILiveRoomInteractionHeaderView *)headerView {
    if (!_headerView) {
        NSArray *typeList = _liveManager.liveInfoModel.status == AUIRoomLiveStatusFinished ? @[@(AUILiveRoomInteractionHeaderIntroduce)] : @[@(AUILiveRoomInteractionHeaderIntroduce), @(AUILiveRoomInteractionHeaderComment)];
        _headerView = [[AUILiveRoomInteractionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.av_width, 44) headerTypeList:typeList];
        [self addSubview:_headerView];
        
        __weak typeof(self) weakSelf = self;
        _headerView.onSelectedBlock = ^(AUILiveRoomInteractionHeaderType type) {
            weakSelf.introduceView.hidden = type != AUILiveRoomInteractionHeaderIntroduce;
            weakSelf.liveCommentView.hidden = type != AUILiveRoomInteractionHeaderComment;
            weakSelf.bottomView.commentTextField.hidden = type != AUILiveRoomInteractionHeaderComment;
            weakSelf.commentUnreadNumber = 0;
            [weakSelf updateCommentUnreadNumber];
        };
    }
    return _headerView;
}

- (UILabel *)commentUnreadNumberLabel {
    UIButton *headerComment = [self.headerView headerButton:AUILiveRoomInteractionHeaderComment];
    if (!headerComment) {
        return nil;
    }
    if (!_commentUnreadNumberLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(headerComment.titleLabel.av_right + 2, headerComment.titleLabel.av_top, 16, 16)];
        label.font = AVGetRegularFont(12);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UIColor.whiteColor;
        label.backgroundColor = [UIColor av_colorWithHexString:@"#F53F3F"];
        label.layer.cornerRadius = 8;
        label.layer.borderWidth = 1;
        label.layer.borderColor = UIColor.whiteColor.CGColor;
        label.layer.masksToBounds = YES;
        label.userInteractionEnabled = NO;
        [headerComment addSubview:label];
        _commentUnreadNumberLabel = label;
        _commentUnreadNumberLabel.hidden = YES;
    }
    return _commentUnreadNumberLabel;
}

- (void)updateCommentUnreadNumber {
    if (!self.commentUnreadNumberLabel) {
        return;
    }
    NSUInteger number = self.commentUnreadNumber;
    self.commentUnreadNumberLabel.hidden = number == 0;
    if (!self.commentUnreadNumberLabel.hidden) {
        NSString *text = number > 99 ? @"99+" : [NSString stringWithFormat:@"%tu", number];
        self.commentUnreadNumberLabel.text = text;
        
        [self.commentUnreadNumberLabel sizeToFit];
        CGFloat width = self.commentUnreadNumberLabel.av_width + 8;
        width = MAX(width, 16);
        self.commentUnreadNumberLabel.av_width = width;
        self.commentUnreadNumberLabel.av_height = 16;
    }
}

- (AUILiveRoomIntroduceView *)introduceView {
    if (![self.headerView headerButton:AUILiveRoomInteractionHeaderIntroduce]) {
        return nil;
    }
    if (!_introduceView) {
        _introduceView = [[AUILiveRoomIntroduceView alloc] initWithFrame:CGRectMake(16, self.headerView.av_bottom + 12, self.av_width - 16 * 2, self.bottomView.av_top - self.headerView.av_bottom - 12 * 2)];
        _introduceView.hidden = NO;
        [self insertSubview:_introduceView belowSubview:self.bottomView];
        
        [_introduceView refreshContent:self.liveManager];
    }
    return _introduceView;
}

- (AUILiveRoomCommentView *)liveCommentView {
    if (![self.headerView headerButton:AUILiveRoomInteractionHeaderComment]) {
        return nil;
    }
    if (!_liveCommentView) {
        _liveCommentView = [[AUILiveRoomCommentView alloc] initWithFrame:CGRectMake(0, self.headerView.av_bottom, self.av_width, self.bottomView.av_top - self.headerView.av_bottom) mode:AUILiveRoomCommentViewModeTop needShowNewCommentTips:YES];
        _liveCommentView.commentBackgroundColor = AUIFoundationColor(@"bg_weak");
        _liveCommentView.showNewCommentTipsButton.backgroundColor = AUIFoundationColor(@"bg_weak");
        [_liveCommentView.showNewCommentTipsButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        _liveCommentView.hidden = YES;
        [self insertSubview:_liveCommentView belowSubview:self.bottomView];

        AUILiveRoomCommentModel* model = [[AUILiveRoomCommentModel alloc] init];
        model.sentContent = @"欢迎来到直播间，直播内容和评论禁止政治、低俗色情、吸烟酗酒或发布虚假信息等内容，若有违反将禁播、封停账号。";
        model.sentContentColor = [UIColor av_colorWithHexString:@"#3BB346"];
        model.sentContentFontSize = 12.0;
        model.sentContentInsets = UIEdgeInsetsMake(10, 8, 10, 8);
        model.cellInsets = UIEdgeInsetsMake(6, 0, 6, 0);
        [_liveCommentView insertLiveComment:model];
    }
    return _liveCommentView;
}

- (AUILiveRoomBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[AUILiveRoomBottomView alloc] initWithFrame:CGRectMake(0, self.av_height - AVSafeBottom - 44, self.av_width, AVSafeBottom + 44) linkMic:NO];
        _bottomView.backgroundColor = AUIFoundationColor(@"bg_weak");
        _bottomView.backgroundColorForNormalNormal = AUIFoundationColor(@"bg_weak");
        _bottomView.commentTextField.backgroundColorForNormal =  AUIFoundationColor(@"bg_medium");
        _bottomView.commentTextField.textColorForNormal = AUIFoundationColor(@"text_weak");
        _bottomView.commentTextField.placeHolderColorForNormal = AUIFoundationColor(@"text_weak");
        _bottomView.commentTextField.placeHolderColorForDisable = AUIFoundationColor(@"text_ultraweak");
        [_bottomView.commentTextField refreshDisplayColor];
        [_bottomView.commentTextField refreshCommentPlaceHolder];
        _bottomView.commentTextField.hidden = YES;
        _bottomView.likeButton.backgroundColor = AUIFoundationColor(@"bg_medium");
        _bottomView.shareButton.backgroundColor = AUIFoundationColor(@"bg_medium");
        [self addSubview:_bottomView];

        __weak typeof(self) weakSelf = self;
        _bottomView.onLikeButtonClickedBlock = ^(AUILiveRoomBottomView * _Nonnull sender) {
            [weakSelf.liveManager sendLike];
        };
        _bottomView.onShareButtonClickedBlock = ^(AUILiveRoomBottomView * _Nonnull sender) {
            if (AUILiveRoomActionManager.defaultManager.openShare) {
                AUILiveRoomActionManager.defaultManager.openShare(weakSelf.liveManager.liveInfoModel, weakSelf.liveManager.roomVC, nil);
            }
            
#ifdef AUTO_COMMENT_TEST
            // 发送评论自动化测试
            [weakSelf autoCommentTest];
#endif
        };
        _bottomView.sendCommentBlock = ^(AUILiveRoomBottomView * _Nonnull sender, NSString * _Nonnull comment) {
            [weakSelf.liveManager sendComment:comment completed:nil];
        };
    }
    return _bottomView;
}

#ifdef AUTO_COMMENT_TEST
// For test
static BOOL g_enableCommentTest = NO;

- (void)autoCommentTest {
    g_enableCommentTest = !g_enableCommentTest;
    [self sendCommentTest];
}

- (void)sendCommentTest {
    if (!g_enableCommentTest) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arc4random() % 1000 / 500.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *string = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
        NSUInteger count = string.length;
        NSMutableString *comment = [NSMutableString new];
        NSUInteger commentLength = arc4random() % 50 + 5;
        for (NSUInteger i=0; i<commentLength; i++) {
            [comment appendString:[string substringWithRange:NSMakeRange(arc4random()%count, 1)]];
        }
        
        [self.liveManager sendComment:comment completed:nil];
        
        if (self.liveCommentView.commentList.count < 100) {
            [self sendCommentTest];
        }
    });
}
#endif

@end
