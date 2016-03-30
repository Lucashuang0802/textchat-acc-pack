#import "MainView.h"

@interface MainView()
@property (strong, nonatomic) IBOutlet UIView *publisherView;
@property (strong, nonatomic) IBOutlet UIView *subscriberView;
@property (strong, nonatomic) IBOutlet UIView *textChatContainer;

// 3 action buttons at the bottom of the view
@property (strong, nonatomic) IBOutlet UIButton *videoHolder;
@property (strong, nonatomic) IBOutlet UIButton *callHolder;
@property (strong, nonatomic) IBOutlet UIButton *micHolder;
@property (strong, nonatomic) IBOutlet UIButton *textChatHolder;

@property (strong, nonatomic) IBOutlet UIButton *subscriberVideoButton;
@property (strong, nonatomic) IBOutlet UIButton *subscriberAudioButton;

@property (strong, nonatomic) IBOutlet UILabel *connectingLabel;
@property (strong, nonatomic) IBOutlet UIButton *errorMessage;

@property (strong, nonatomic) UIImageView *subscriberPlaceHolderImageView;
@property (strong, nonatomic) UIImageView *publisherPlaceHolderImageView;
@end

@implementation MainView


- (UIImageView *)publisherPlaceHolderImageView {
    if (!_publisherPlaceHolderImageView) {
        _publisherPlaceHolderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page1"]];
        _publisherPlaceHolderImageView.backgroundColor = [UIColor clearColor];
        _publisherPlaceHolderImageView.contentMode = UIViewContentModeScaleAspectFit;
        _publisherPlaceHolderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _publisherPlaceHolderImageView;
}

- (UIImageView *)subscriberPlaceHolderImageView {
    if (!_subscriberPlaceHolderImageView) {
        _subscriberPlaceHolderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page1"]];
        _subscriberPlaceHolderImageView.backgroundColor = [UIColor clearColor];
        _subscriberPlaceHolderImageView.contentMode = UIViewContentModeScaleAspectFit;
        _subscriberPlaceHolderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _subscriberPlaceHolderImageView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.publisherView.hidden = YES;
    self.publisherView.alpha = 1;
    self.publisherView.layer.borderWidth = 1;
    self.publisherView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.publisherView.layer.backgroundColor = [UIColor grayColor].CGColor;
    self.publisherView.layer.cornerRadius = 3;
    
    [self drawBorderOn:self.micHolder withWhiteBorder:YES widthColorBorder: nil];
    [self drawBorderOn:self.callHolder withWhiteBorder:NO widthColorBorder: nil];
    [self drawBorderOn:self.videoHolder withWhiteBorder:YES widthColorBorder: nil];
    [self drawBorderOn:self.textChatHolder withWhiteBorder:YES widthColorBorder: nil];
    [self hideSubscriberControls];
}

- (void)drawBorderOn:(UIView *)view
     withWhiteBorder:(BOOL)withWhiteBorder
    widthColorBorder:(UIColor *)borderColor {
    
    view.layer.cornerRadius = (view.bounds.size.width / 2);
    if (withWhiteBorder) {
        view.layer.borderWidth = 1;
        view.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    if (borderColor != nil){
        view.layer.borderColor = borderColor.CGColor;
    }
}

#pragma mark - publisher view
- (void)addPublisherView:(UIView *)publisherView {
    
    [self.publisherView setHidden:NO];
    publisherView.frame = CGRectMake(0, 0, CGRectGetWidth(self.publisherView.bounds), CGRectGetHeight(self.publisherView.bounds));
    [self.publisherView addSubview:publisherView];
}

- (void)removePublisherView {
    [self.publisherView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)addPlaceHolderToPublisherView {
    self.publisherPlaceHolderImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.publisherView.bounds), CGRectGetHeight(self.publisherView.bounds));
    [self.publisherView addSubview:self.publisherPlaceHolderImageView];
    [self addAttachedLayoutConstantsToSuperview:self.publisherPlaceHolderImageView];
}

- (void)callHolderConnected {
    [self.callHolder setImage:[UIImage imageNamed:@"startCall"] forState:UIControlStateNormal];
    self.callHolder.layer.backgroundColor = [UIColor colorWithRed:(106/255.0) green:(173/255.0) blue:(191/255.0) alpha:1.0].CGColor;
}

- (void)callHolderDisconnected {
    [self.callHolder setImage:[UIImage imageNamed:@"hangUp"] forState:UIControlStateNormal];
    self.callHolder.layer.backgroundColor = [UIColor colorWithRed:(205/255.0) green:(32/255.0) blue:(40/255.0) alpha:1.0].CGColor;
}

- (void)publisherMicMuted {
    [self.micHolder setImage:[UIImage imageNamed:@"mutedMicLineCopy"] forState: UIControlStateNormal];
}

- (void)publisherMicUnmuted {
    [self.micHolder setImage:[UIImage imageNamed:@"mic"] forState: UIControlStateNormal];
}

- (void)publisherVideoConnected {
    [self.videoHolder setImage:[UIImage imageNamed:@"videoIcon"] forState:UIControlStateNormal];
}

- (void)publisherVideoDisconnected {
    [self.videoHolder setImage:[UIImage imageNamed:@"noVideoIcon"] forState: UIControlStateNormal];
}

- (void) addBorderToTextChatIcon {
    [self drawBorderOn: self.textChatHolder withWhiteBorder:NO widthColorBorder: [UIColor colorWithRed:(205/255.0) green:(32/255.0) blue:(40/255.0) alpha:1.0]];
}

- (void) removeBorderFromTextChatIcon {
    [self drawBorderOn: self.textChatHolder withWhiteBorder: YES widthColorBorder: nil];
}

- (void) TextChatButtonPressed: (UIView *) TextChat {
    if (![self checkIfViewAlreadyAttached:TextChat]) {
        [TextChat setFrame: self.textChatContainer.bounds];
        [self.textChatContainer addSubview: TextChat];
        // fade in
        TextChat.alpha = 0;
        [UIView animateWithDuration:0.1 animations:^() {
            _connectingLabel.alpha = 0;
            TextChat.alpha = 1;
        }];
    } else {
        [TextChat removeFromSuperview];
    }
}

#pragma mark - subscriber view
- (void)addSubscribeView:(UIView *)subsciberView {
    subsciberView.frame = CGRectMake(0, 0, CGRectGetWidth(self.subscriberView.bounds), CGRectGetHeight(self.subscriberView.bounds));
    [self.subscriberView addSubview:subsciberView];
}

- (void)removeSubscriberView {
    [self.subscriberView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)addPlaceHolderToSubscriberView {
    self.subscriberPlaceHolderImageView.frame = self.subscriberView.bounds;
    [self.subscriberView addSubview:self.subscriberPlaceHolderImageView];
    [self addAttachedLayoutConstantsToSuperview:self.subscriberPlaceHolderImageView];
}

- (void)subscriberMicMuted {
    [self.subscriberAudioButton setImage:[UIImage imageNamed:@"noSoundCopy"] forState: UIControlStateNormal];
}

- (void)subscriberMicUnmuted {
    [self.subscriberAudioButton setImage:[UIImage imageNamed:@"audio"] forState: UIControlStateNormal];
}

- (void)subscriberVideoConnected {
    [self.subscriberVideoButton setImage:[UIImage imageNamed:@"videoIcon"] forState: UIControlStateNormal];
}

- (void)subscriberVideoDisconnected {
    [self.subscriberVideoButton setImage:[UIImage imageNamed:@"noVideoIcon"] forState: UIControlStateNormal];
}

- (void)showSubscriberControls {
    [self.subscriberAudioButton setAlpha:1.0];
    [self.subscriberVideoButton setAlpha:1.0];
}

- (void)hideSubscriberControls {
    [self.subscriberAudioButton setAlpha:0.0];
    [self.subscriberVideoButton setAlpha:0.0];
}

#pragma mark - other controls
- (void)showConnectingLabel {
    
    [UIView animateWithDuration:0.25 animations:^(){
        
        [self.connectingLabel setAlpha:0.5];
        
        [UIView animateWithDuration:0.25 animations:^(){
            
            [self.connectingLabel setAlpha:1.0];
        }];
    }];
}

- (void)hideConnectingLabel {
    
    [UIView animateWithDuration:0.25 animations:^(){
        
        [self.connectingLabel setAlpha:0.5];
        
        [UIView animateWithDuration:0.25 animations:^(){
            
            [self.connectingLabel setAlpha:0.0];
        }];
    }];
}

- (void)showErrorMessageLabelWithMessage:(NSString *)message
                            dismissAfter:(CGFloat)seconds {
    
    [self.errorMessage setTitle:message forState:UIControlStateNormal];
    [self.errorMessage setAlpha:1.0];
    
    if (seconds != 0.0) {
        [UIView animateWithDuration:0.5
                              delay:seconds
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             [self.errorMessage setAlpha:0.5];
                         }
                         completion:^(BOOL finished){
                             [self.errorMessage setAlpha:0.0];
                         }];
    }
}

- (void)hideErrorMessageLabel {
    [self.errorMessage setAlpha:0.0];
}

- (void)removePlaceHolderImage {
    [self.publisherPlaceHolderImageView removeFromSuperview];
    [self.subscriberPlaceHolderImageView removeFromSuperview];
}

#pragma mark - private method
-(void)addAttachedLayoutConstantsToSuperview:(UIView *)view {
    
    if (!view.superview) {
        return;
    }
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:view
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:view.superview
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:0.0];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:view.superview
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0
                                                                constant:0.0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:view
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:view.superview
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                                 constant:0.0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:view
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:view.superview
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0];
    [NSLayoutConstraint activateConstraints:@[top, leading, trailing, bottom]];
}

#pragma mark TextChatComponet Methods

/**
 * This function will allow me to know if the view im asking was already added
 * to the current self.view, so readding the view can be prevented
 */
-(BOOL) checkIfViewAlreadyAttached: (UIView *) checkingView {
    if(![checkingView isDescendantOfView: self]) {
        return NO;
    } else {
        return YES;
    }
}


@end
