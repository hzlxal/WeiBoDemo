//
//  NSObject+HXAssociatedObject.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/9.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "NSObject+HXAssociatedObject.h"
#import <objc/runtime.h>

@implementation NSObject (HXAssociatedObject)

- (void)hx_associateValue:(id)value withKey:(const void *)key{
    [self hx_associateValue:value withKey:key policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (void)hx_associateValue:(id)value withKey:(const void *)key policy:(objc_AssociationPolicy)policy{
       objc_setAssociatedObject(self, key, value, policy);
}

- (id)hx_associateValueForKey:(const void *)key{
   return objc_getAssociatedObject(self, key);
}

@end
