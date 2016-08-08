//
//  CustomTextChatTableViewController.m
//  OTTextChatAccPackKit
//
//  Created by Xi Huang on 8/6/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "CustomTextChatTableViewController.h"

#import "CustomSendTextChatTableViewCell.h"
#import "CustomReceiveTextChatTableViewCell.h"

@interface CustomTextChatTableViewController()<OTTextChatTableViewDataSource>
@property (nonatomic) OTTextChat *textChat;
@property (nonatomic) NSMutableArray *textMessages;

@end

@implementation CustomTextChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textChat = [OTTextChat textChat];
    self.textChat.alias = @"BD Demo";
    self.textMessages = [[NSMutableArray alloc] init];
    
    self.navigationBar.topItem.title = self.textChat.alias;
    self.tableView.textChatTableViewDelegate = self;
    
    __weak CustomTextChatTableViewController *weakSelf = self;
    [self.textChat connectWithHandler:^(OTTextChatViewEventSignal signal, OTTextMessage *message, NSError *error) {
        
        if (signal == OTTextChatViewEventSignalDidSendMessage || signal == OTTextChatViewEventSignalDidReceiveMessage) {
            
            if (!error) {
                [weakSelf.textMessages addObject:message];
                [weakSelf.tableView reloadData];
                weakSelf.textChatInputView.textField.text = nil;
                [weakSelf scrollTextChatTableViewToBottom];
            }
        }
    }];
    
    [self configureCustomCells];
    [self.textChatInputView.sendButton addTarget:self action:@selector(sendTextMessage) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureCustomCells {
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomSendTextChatTableViewCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"CustomSendTextChatTableViewCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomReceiveTextChatTableViewCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"CustomReceiveTextChatTableViewCell"];
}

- (void)configureBlurBackground {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    CGRect mainBounds = [UIScreen mainScreen].bounds;
    blurView.frame = CGRectMake(0, 0, CGRectGetWidth(mainBounds), CGRectGetHeight(mainBounds));
    [self.view insertSubview:blurView atIndex:0];
}

- (void)sendTextMessage {
    [self.textChat sendMessage:self.textChatInputView.textField.text];
}

#pragma mark - OTTextChatTableViewDataSource
- (OTTextChatViewType)typeOfTextChatTableView:(OTTextChatTableView *)tableView {
    
    return OTTextChatViewTypeCustom;
}

- (NSInteger)textChatTableView:(OTTextChatTableView *)tableView
         numberOfRowsInSection:(NSInteger)section {
    
    return self.textMessages.count;
}

- (OTTextMessage *)textChatTableView:(OTTextChatTableView *)tableView
          textMessageItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.textMessages[indexPath.row];
}

- (UITableViewCell *)textChatTableView:(OTTextChatTableView *)tableView
                 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OTTextMessage *textMessage = self.textMessages[indexPath.row];
    
    NSString *cellIdentifier;
    if ([textMessage.senderId isEqualToString:self.textChat.connectionId]) {
        cellIdentifier = @"CustomSendTextChatTableViewCell";
    }
    else {
        cellIdentifier = @"CustomReceiveTextChatTableViewCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ([textMessage.senderId isEqualToString:self.textChat.connectionId]) {
        CustomSendTextChatTableViewCell *sendCell = (CustomSendTextChatTableViewCell *)cell;
        sendCell.textLabel.text = textMessage.text;
        sendCell.timeLabel.text = [self convertToTimeFromDate:textMessage.dateTime];
    }
    else {
        CustomReceiveTextChatTableViewCell *receiveCell = (CustomReceiveTextChatTableViewCell *)cell;
        receiveCell.textLabel.text = textMessage.text;
        receiveCell.timeLabel.text = [self convertToTimeFromDate:textMessage.dateTime];
        receiveCell.receiverAliasLabel.text = textMessage.alias;
    }
    
    return cell;
}

- (NSString *)convertToTimeFromDate:(NSDate  *)date {
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    return [timeFormatter stringFromDate:date];
}

@end
