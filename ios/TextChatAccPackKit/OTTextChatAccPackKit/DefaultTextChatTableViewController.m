//
//  ViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "DefaultTextChatTableViewController.h"

@interface DefaultTextChatTableViewController () <OTTextChatTableViewDataSource>
@property (nonatomic) OTTextChat *textChat;
@property (nonatomic) NSMutableArray *textMessages;
@end

@implementation DefaultTextChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textChat = [OTTextChat textChat];
    self.textChat.alias = @"Tokboxer";
    self.textMessages = [[NSMutableArray alloc] init];
    self.tableView.textChatTableViewDelegate = self;
    
    __weak DefaultTextChatTableViewController *weakSelf = self;
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
    
    [self.textChatInputView.sendButton addTarget:self action:@selector(sendTextMessage) forControlEvents:UIControlEventTouchUpInside];
}

- (void)sendTextMessage {
    [self.textChat sendMessage:self.textChatInputView.textField.text];
}

- (OTTextChatViewType)typeOfTextChatTableView:(OTTextChatTableView *)tableView {
    
    return OTTextChatViewTypeDefault;
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
    
    return nil;
}

@end
