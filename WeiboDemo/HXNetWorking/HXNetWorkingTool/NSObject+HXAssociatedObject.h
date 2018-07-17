//
//  NSObject+HXAssociatedObject.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/9.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (HXAssociatedObject)

- (void)hx_associateValue:(id)value withKey:(const void *)key;

- (id)hx_associateValueForKey:(const void *)key;

- (void)hx_associateValue:(id)value withKey:(const void *)key policy:(objc_AssociationPolicy)policy;

@end
