//
//  WBBaseTableViewCell.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/4.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "WBBaseTableViewCell.h"

@implementation WBBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

@end
