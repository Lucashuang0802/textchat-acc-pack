//
//  OTTextChatView.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OTTextChatKit/OTTextMessage.h>
#import <OTTextChatKit/OTTextChatTableView.h>
#import <OTTextChatKit/OTTextChatInputView.h>

@interface OTTextChatViewController : UIViewController

@property (readonly, nonatomic) UINavigationBar *navigationBar;

@property (readonly, weak, nonatomic) OTTextChatTableView *tableView;

@property (readonly, weak, nonatomic) OTTextChatInputView *textChatInputView;

/**
 *  @return Returns an initialized text chat view controller object.
 */
+ (instancetype)textChatViewController;

- (void)scrollTextChatTableViewToBottom;

@end
