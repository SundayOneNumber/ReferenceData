//
//  WXInputView.h
//  WeiXin
//
//  Created by Yong Feng Guo on 14-11-22.
//  Copyright (c) 2014年 Fung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXInputView : UIView
@property (weak, nonatomic) IBOutlet UITextView *msgTextView;
+(instancetype)inputView;
@end
