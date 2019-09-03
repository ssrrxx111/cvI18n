//
//  NSObject+extesion.m
//  cvteI18n
//
//  Created by webull on 2019/7/26.
//  Copyright © 2019 cvte. All rights reserved.
//

#import "NSObject+Handle.h"
#import <objc/runtime.h>

#import "HandleModel.h"

static char *languageAssoKey = "languageAssoKey";

@implementation NSObject (Handle)

- (void)handleLanguage: (void(^)(id))callback {
    callback(self);
    
    HandleModel *model = [[HandleModel alloc] initWithBlock:callback onObject:self];
    objc_setAssociatedObject(self, languageAssoKey, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
