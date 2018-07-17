//
//  WBMacro.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#ifndef WBCommonMacro_h
#define WBCommonMacro_h
#import "UIColor+HXAdd.h"

#define UIColorHex(_hex_)   [UIColor colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]

#define kScreenWidth   [UIScreen mainScreen].bounds.size.width
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height

#define kScreenScale  [UIScreen mainScreen].scale

#endif /* WBMacro_h */
