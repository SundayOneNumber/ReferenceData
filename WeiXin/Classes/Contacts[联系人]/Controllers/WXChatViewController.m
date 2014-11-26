//
//  WXChatViewController.m
//  WeiXin
//
//  Created by Yong Feng Guo on 14-11-21.
//  Copyright (c) 2014年 Fung. All rights reserved.
//

#import "WXChatViewController.h"
#import "WXInputView.h"
#import "WXChatCell.h"

#define InputViewH 50 //输入框调度
#define FunctionViewH 200 //功能框高度

@interface WXChatViewController()<UITextViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>{
    NSFetchedResultsController *_resultsContr;
}

@property(nonatomic,weak)UITableView *tableView;
@property(nonatomic,weak)WXInputView *inputView;
@property(nonatomic,strong)NSLayoutConstraint *bottomConstraint;
@end

@implementation WXChatViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupView];
    // 设置标题
    self.title = self.friendJid.user;
    
    // 键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbFrmWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbFrmWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 加载数据
    [self loadMessage];
}

#pragma mark 键盘将显示
-(void)kbFrmWillShow:(NSNotification *)notifi{
    CGRect kbBounds = [notifi.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 键盘的高度
    CGFloat keyboardH = kbBounds.size.height;
    
    // iPad横屏时键盘的高度是bounds的width[打印测试即可]
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    if (!iSiPhoneDevice && isLandscape) {
        keyboardH = kbBounds.size.width;
    }

    [UIView animateWithDuration:0.25 animations:^{
        //self.view.y = -keyboardH;
        self.bottomConstraint.constant = keyboardH;
        [self.view layoutIfNeeded];
    }];
}
#pragma mark 键盘将消失
-(void)kbFrmWillHide:(NSNotification *)notifi{
    [UIView animateWithDuration:0.25 animations:^{
        //self.view.y = 0;
        self.bottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 代码布局
-(void)setupView{
    // 表格

    UITableView *tableView = [[UITableView alloc] init];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    //tableView.backgroundColor = [UIColor purpleColor];
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 输入框
    WXInputView *inputView = [WXInputView inputView] ;
    inputView.backgroundColor = [UIColor redColor];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    inputView.msgTextView.delegate = self;
    [self.view addSubview:inputView];
    
#warning 预留，未实现
    // 表情与功能选择
    UIView *functionView = [[UIView alloc] init];
    [self.view addSubview:functionView];
    
    NSDictionary *views = @{@"tableView":tableView,@"inputView":inputView,@"functionView":functionView};
    
    // 表格的的水平约束
    NSArray *tableViewHConst = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:tableViewHConst];
    
    // 输入框的水平约束
    NSArray *inputViewHConst = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[inputView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:inputViewHConst];
    
    // 垂直约束
    NSArray *vConst = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableView]-0-[inputView(50)]-0-|" options:0 metrics:nil views:views];
    self.bottomConstraint = vConst[vConst.count - 1];
    [self.view addConstraints:vConst];
    WXLog(@"%@",vConst);
    
}

#pragma mark 监听TextField的换行，即回车发送
-(void)textViewDidChange:(UITextView *)textView{
    // 换行
    if ([textView.text rangeOfString:@"\n"].length != 0) {
        //去除掉首尾的空白字符和换行字符
        NSString *msg = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        textView.text = nil;
        [self sendMsg:msg];
        
    }
}

#pragma mark 从数据库加载聊天数据
-(void)loadMessage{
   // NSManagedObjectContext *context = xmppDelegate.msgStorage.mainThreadManagedObjectContext;
     NSManagedObjectContext *context = [WXXMPPTools sharedWXXMPPTools].msgStorage.mainThreadManagedObjectContext;
    
    NSFetchRequest *requset = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    requset.sortDescriptors = @[timeSort];
    
    // 查找属于当前用户和当前好友的聊天信息
    NSString *bareJidStr = self.friendJid.bare;
    NSString *streamBardJid = [WXUserInfo sharedWXUserInfo].userJid;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@ AND streamBareJidStr = %@",bareJidStr,streamBardJid];
    requset.predicate = predicate;
    
    
    _resultsContr = [[NSFetchedResultsController alloc] initWithFetchRequest:requset managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _resultsContr.delegate = self;
    NSError *error = nil;
    [_resultsContr performFetch:&error];
    if (error) {
        WXLog(@"%@",error);
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
    
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_resultsContr.fetchedObjects.count - 1 inSection:0];
    // 滑动到底部
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark 表格数据源
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _resultsContr.fetchedObjects.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WXChatCell *chatCell = [WXChatCell chatCellWithTableView:tableView];
    
    XMPPMessageArchiving_Message_CoreDataObject *msg = [_resultsContr objectAtIndexPath:indexPath];
    
    chatCell.textLabel.text = msg.body;
    
    return chatCell;
}

#pragma mark 发送聊消息
-(void)sendMsg:(NSString *)msg{
    //WXLog(@"%@ %d",msg,msg.length);
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [message addBody:msg];
    
    [[WXXMPPTools sharedWXXMPPTools].xmppStream sendElement:message];
    
    
}
@end
