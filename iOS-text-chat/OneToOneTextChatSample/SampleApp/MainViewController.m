#import "MainView.h"
#import "MainViewController.h"
#import "OneToOneCommunicator.h"
#import "TextChat.h"

@interface MainViewController ()
@property (nonatomic) MainView *mainView;
@property (nonatomic) OneToOneCommunicator *oneToOneCommunicator;
@property (nonatomic) TextChatComponent *textChat;
@property (nonatomic) TextChat *textChatDelegate;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainView = (MainView *)self.view;
    self.oneToOneCommunicator = [OneToOneCommunicator oneToOneCommunicator];
    self.textChatDelegate = [[TextChat alloc] initWithCommunicator: self.oneToOneCommunicator];
    // When we've connected to the session, we can create the chat component.
    self.textChat = [[TextChatComponent alloc] init];
    self.textChat.delegate = self.textChatDelegate;
    [self.textChat setMaxLength:1050];
}

/** 
 * toggles the call start/end handles the color of the buttons
 */
- (IBAction)publisherCallButtonPressed:(UIButton *)sender {
    if (self.oneToOneCommunicator.isCallEnabled) {
        [self.mainView callHolderDisconnected];
        self.oneToOneCommunicator.isCallEnabled = NO;
        [self.mainView showConnectingLabel];
        [self.oneToOneCommunicator connectWithHandler:^(OneToOneCommunicationSignal signal, NSError *error) {
            
            [self.mainView hideConnectingLabel];
            if (!error) {
                [self handleCommunicationSignal:signal];
            }
        }];
    }
    else {
        [self.mainView callHolderConnected];
        self.oneToOneCommunicator.isCallEnabled = YES;
        [self.oneToOneCommunicator disconnect];
        
        [self.mainView removePublisherView];
        [self.mainView hideErrorMessageLabel];
        [self.mainView removePlaceHolderImage];
    }
}

- (void)handleCommunicationSignal:(OneToOneCommunicationSignal)signal {
    
    
    switch (signal) {
        case OneToOneCommunicationSignalSessionDidConnect: {
            [self.mainView addPublisherView:self.oneToOneCommunicator.publisher.view];
            break;
        }
        case OneToOneCommunicationSignalSessionDidDisconnect:{
            [self.mainView removePublisherView];
            [self.mainView removeSubscriberView];
            break;
        }
        case OneToOneCommunicationSignalSessionDidFail:{
            [self.mainView hideConnectingLabel];
            break;
        }
        case OneToOneCommunicationSignalSessionStreamCreated:{
            break;
        }
        case OneToOneCommunicationSignalSessionStreamDestroyed:{
            [self.mainView removeSubscriberView];
            break;
        }
        case OneToOneCommunicationSignalPublisherDidFail:{
            [self.mainView showErrorMessageLabelWithMessage:@"Problem when publishing" dismissAfter:4.0];
            break;
        }
        case OneToOneCommunicationSignalSubscriberConnect:{
            [self.mainView addSubscribeView:self.oneToOneCommunicator.subscriber.view];
            break;
        }
        case OneToOneCommunicationSignalSubscriberDidFail:{
            [self.mainView showErrorMessageLabelWithMessage:@"Problem when subscribing" dismissAfter:4.0];
            break;
        }
        case OneToOneCommunicationSignalSubscriberVideoDisabled:{
            [self.mainView addPlaceHolderToSubscriberView];
            break;
        }
        case OneToOneCommunicationSignalSubscriberVideoEnabled:{
            [self.mainView hideErrorMessageLabel];
            [self.mainView addSubscribeView:self.oneToOneCommunicator.subscriber.view];
            break;
        }
        case OneToOneCommunicationSignalSubscriberVideoDisableWarning:{
            [self.mainView addPlaceHolderToSubscriberView];
            self.oneToOneCommunicator.subscriber.subscribeToVideo = NO;
            [self.mainView showErrorMessageLabelWithMessage:@"Network connection is unstable." dismissAfter:0.0];
            break;
        }
        case OneToOneCommunicationSignalSubscriberVideoDisableWarningLifted:{
            [self.mainView hideErrorMessageLabel];
            [self.mainView addSubscribeView:self.oneToOneCommunicator.subscriber.view];
            break;
        }
            
        default:
            break;
    }
}

/**
 * toggles the audio comming from the publisher
 */
- (IBAction)publisherAudioButtonPressed:(UIButton *)sender {
    
    if(self.oneToOneCommunicator.publisher.publishAudio) {
        [self.mainView publisherMicMuted];
    }
    else {
        [self.mainView publisherMicUnmuted];
    }
    self.oneToOneCommunicator.publisher.publishAudio = !self.oneToOneCommunicator.publisher.publishAudio;
}

/**
 * toggles the video comming from the publisher 
 */
- (IBAction)publisherVideoButtonPressed:(UIButton *)sender {
    
    if (self.oneToOneCommunicator.publisher.publishVideo) {
        [self.mainView publisherVideoDisconnected];
        [self.mainView removePublisherView];
        [self.mainView addPlaceHolderToPublisherView];
    }
    else {
        [self.mainView publisherVideoConnected];
        [self.mainView addPublisherView:self.oneToOneCommunicator.publisher.view];
    }
    
    self.oneToOneCommunicator.publisher.publishVideo = !self.oneToOneCommunicator.publisher.publishVideo;
}

/**
 * toggle the camera position (front camera) <=> (back camera)
 */
- (IBAction)publisherCameraButtonPressed:(UIButton *)sender {
    
    if (self.oneToOneCommunicator.publisher.cameraPosition == AVCaptureDevicePositionBack) {
        self.oneToOneCommunicator.publisher.cameraPosition = AVCaptureDevicePositionFront;
    }
    else {
        self.oneToOneCommunicator.publisher.cameraPosition = AVCaptureDevicePositionBack;
    }
}

/**
 * toggles the video comming from the subscriber 
 */
- (IBAction)subscriberVideoButtonPressed:(UIButton *)sender {
    
    if (self.oneToOneCommunicator.subscriber.subscribeToVideo) {
        [self.mainView subscriberVideoDisconnected];
    }
    else {
        [self.mainView subscriberVideoConnected];
    }
    self.oneToOneCommunicator.subscriber.subscribeToVideo = !self.oneToOneCommunicator.subscriber.subscribeToVideo;
}

/**
 * toggles the audio comming from the susbscriber
 */
- (IBAction)subscriberAudioButtonPressed:(UIButton *)sender {

    if (self.oneToOneCommunicator.subscriber.subscribeToAudio) {
        [self.mainView subscriberMicMuted];
    }
    else {
        [self.mainView subscriberMicUnmuted];
    }
    self.oneToOneCommunicator.subscriber.subscribeToAudio = !self.oneToOneCommunicator.subscriber.subscribeToAudio;
}

/**
 * action to handle the textchat to be attached into the main view, also add the listeners for show the keyboard
 * and set the title for the top bar in the text chat component
 */
- (IBAction)textChatButtonPressed:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.textChatDelegate setListenersAndTitle: self.textChat];
    [self.mainView TextChatButtonPressed: self.textChat.view];
}

/**
 * functions to handle the show of the keyboard
 */
- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        CGRect r = self.mainView.bounds;
        r.origin.y += 20;
        r.size.height -= 20 + kbSize.height;
        _textChat.view.frame = r;
    }];
}

/**
 * functions to handle the hide of the keyboard
 */
- (void)keyboardWillHide:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        CGRect r = self.mainView.bounds;
        r.origin.y += 20;
        r.size.height -= 20;
        _textChat.view.frame = r;
        
    }];
}

/**
 * Method that invoque the signal for the messages to be push onto the TextChat component window
 */
- (BOOL)onMessageReadyToSend:(TextChatComponentMessage *)message {
    return [self.textChatDelegate onMessageReadyToSend: message];
}

/**
 * handles the event when the user does a touch to show and then hide the buttons for
 * subscriber actions within 7 seconds
*/
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.mainView showSubscriberControls];
    [self.mainView performSelector:@selector(hideSubscriberControls)
             withObject:nil
             afterDelay:7.0];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
