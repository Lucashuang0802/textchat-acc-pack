//
//  OTTextChatView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextMessage.h"
#import "OTTextMessage_Private.h"
#import "OTTextChatViewController.h"
#import "OTTextChatTableViewCell.h"

#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>
#import <OTKAnalytics/OTKLogger.h>

#import "OTTextChatKitBundle.h"
#import "GCDHelper.h"
#import "OTTestingInfo.h"
#import "Constant.h"
#import "UIViewController+Helper.h"

//static CGFloat StatusBarHeight = 20.0;

@interface OTTextChatViewController() <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    OTTextChatViewType typeOfTextChatTableView;
    NSInteger numberOfRowsInSection;
}

@property (weak, nonatomic) IBOutlet OTTextChatTableView *tableView;
@property (weak, nonatomic) IBOutlet OTTextChatInputView *textChatInputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewLayoutConstraint;

@end

@implementation OTTextChatViewController
+ (instancetype)textChatViewController {

    if (![OTTestingInfo isTesting]) {
        [OTKLogger analyticsWithClientVersion:KLogClientVersion
                                       source:[[NSBundle mainBundle] bundleIdentifier]
                                  componentId:kLogComponentIdentifier
                                         guid:[[NSUUID UUID] UUIDString]];
    }

    NSBundle *textChatViewBundle = [OTTextChatKitBundle textChatKitBundle];
    return [[OTTextChatViewController alloc] initWithNibName:NSStringFromClass([OTTextChatViewController class]) bundle:textChatViewBundle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *textChatViewControllerNib = [UINib nibWithNibName:NSStringFromClass([OTTextChatViewController class])
                                                      bundle:[OTTextChatKitBundle textChatKitBundle]];
    [textChatViewControllerNib instantiateWithOwner:self options:nil];
    [self configureTextChatViewController];
}

- (void)configureTextChatViewController {
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 130.0;
    self.textChatInputView.textField.delegate = self;
    
    NSBundle *textChatViewBundle = [OTTextChatKitBundle textChatKitBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatSentTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"SentChatMessage"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatSentShortTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"SentChatMessageShort"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatReceivedTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"RecvChatMessage"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatReceivedShortTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"RecvChatMessageShort"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatComponentDivTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"Divider"];
    
    __weak OTTextChatViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      
                                                      NSDictionary* info = [notification userInfo];
                                                      CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
                                                      double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
                                                      [UIView animateWithDuration:duration animations:^{

                                                          weakSelf.bottomViewLayoutConstraint.constant = kbSize.height;
                                                      } completion:^(BOOL finished) {

                                                          [weakSelf scrollTextChatTableViewToBottom];
                                                      }];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      
                                                      NSDictionary* info = [notification userInfo];
                                                      double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
                                                      [UIView animateWithDuration:duration animations:^{
                                                          
                                                          weakSelf.bottomViewLayoutConstraint.constant = 0;
                                                      }];
                                                  }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private methods

- (void)scrollTextChatTableViewToBottom {
    
    if (numberOfRowsInSection == 0) {
        return;
    }
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:(numberOfRowsInSection - 1) inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![tableView isKindOfClass:[OTTextChatTableView class]]) return 0;
    OTTextChatTableView *textChatTableView = (OTTextChatTableView *)tableView;
    typeOfTextChatTableView = [textChatTableView.textChatTableViewDelegate typeOfTextChatTableView:textChatTableView];
    numberOfRowsInSection = [textChatTableView.textChatTableViewDelegate textChatTableView:textChatTableView numberOfRowsInSection:section];
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![tableView isKindOfClass:[OTTextChatTableView class]]) return 0;
    OTTextChatTableView *textChatTableView = (OTTextChatTableView *)tableView;
    
    // check if final divider
    OTTextMessage *textMessage = [textChatTableView.textChatTableViewDelegate textChatTableView:textChatTableView textMessageItemAtIndexPath:indexPath];
    
    if (typeOfTextChatTableView == OTTextChatViewTypeDefault) {
        
        // determine text message cell type
        if (numberOfRowsInSection > 1 && indexPath.row == numberOfRowsInSection - 1) {
            
            OTTextMessage *textMessage = [textChatTableView.textChatTableViewDelegate textChatTableView:textChatTableView textMessageItemAtIndexPath:indexPath];
            NSIndexPath *prevIndexPath = [NSIndexPath indexPathForRow:numberOfRowsInSection - 2 inSection:0];
            OTTextMessage *prevTextMessage = [textChatTableView.textChatTableViewDelegate textChatTableView:textChatTableView textMessageItemAtIndexPath:prevIndexPath];
            
            if (textMessage.type == TCMessageTypesReceived && (prevTextMessage.type == TCMessageTypesSent || prevTextMessage.type == TCMessageTypesSentShort)) {
            
            }
            else if (textMessage.type == TCMessageTypesSent && (prevTextMessage.type == TCMessageTypesReceived || prevTextMessage.type == TCMessageTypesReceivedShort)) {
            
            }
            else {
                
                // not sure why 120
                if ([textMessage.dateTime timeIntervalSinceDate:prevTextMessage.dateTime] < 120 &&
                    [textMessage.senderId isEqualToString:prevTextMessage.senderId]) {
                    
                    if (textMessage.type == TCMessageTypesReceived) {
                        textMessage.type = TCMessageTypesReceivedShort;
                    }
                    else if (textMessage.type == TCMessageTypesSent) {
                        textMessage.type = TCMessageTypesSentShort;
                    }
                }
            }
        }
        
        NSString *cellId;
        switch (textMessage.type) {
            case TCMessageTypesSent:
                cellId = @"SentChatMessage";
                break;
            case TCMessageTypesSentShort:
                cellId = @"SentChatMessageShort";
                break;
            case TCMessageTypesReceived:
                cellId = @"RecvChatMessage";
                break;
            case TCMessageTypesReceivedShort:
                cellId = @"RecvChatMessageShort";
                break;
            default:
                break;
        }
        
        OTTextChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId
                                                                        forIndexPath:indexPath];
        [cell updateCellFromTextChat:textMessage];
        return cell;
    }
    
    return [textChatTableView.textChatTableViewDelegate textChatTableView:textChatTableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - UITextFieldDelegate

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [self onSendButton:textField];
//    return NO;
//}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    // Allow a backspace always, in case we went over inputMaxChars
//    const char *_char = [string cStringUsingEncoding:NSUTF8StringEncoding];
//    if (strcmp(_char, "\b") == -8) {
//        [self updateLabel:[textField.text length] - 1];
//        return YES;
//    }
//
//    // If it's not a backspace, allow it if we're still under 150 chars.
//    NSUInteger newLength = [textField.text length] + [string length] - range.length;
//    [self updateLabel: newLength];
//    return (newLength >= self.textChatComponent.maximumTextMessageLength) ? NO : YES;
//}
//
//
//-(void)updateLabel: (NSUInteger )Charlength {
//    [self.countLabel setHidden:YES];
//    self.countLabel.textColor = [UIColor blackColor];
//    self.textField.textColor = [UIColor blackColor];
//
//    NSUInteger charLeft = self.textChatComponent.maximumTextMessageLength - Charlength;
//    NSUInteger closeEnd = round(self.textChatComponent.maximumTextMessageLength * .1);
//    if (closeEnd >= 100) closeEnd = 30;
//    if (charLeft <= closeEnd) {
//        [self.countLabel setHidden:NO];
//        self.countLabel.textColor = [UIColor redColor];
//        self.textField.textColor = [UIColor redColor];
//    }
//    NSString* charCountStr = [NSString stringWithFormat:@"%lu", (unsigned long)charLeft];
//    self.countLabel.text = charCountStr;
//}
@end
