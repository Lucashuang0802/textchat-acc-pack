//
//  ViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "ViewController.h"
#import <OTTextChatKit/OTTextChatKit.h>

@interface ViewController ()
@property (nonatomic) OTTextChatView *textChatView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.textChatView = [TextChatView textChatViewWithBottomView:self.bottomView];
    self.textChatView = [OTTextChatView textChatView];
    
    [self.textChatView setMaximumTextMessageLength:200];
    [self.textChatView setAlias:@"Tokboxer"];
    
    // starting the accellpack connection with the session
    [self.textChatView connect];
}

- (IBAction)startTextChat:(UIButton *)sender {
    if (!self.textChatView.isShown) {
        [self.textChatView show];
    } else {
        [self.textChatView dismiss];
    }
}
@end
