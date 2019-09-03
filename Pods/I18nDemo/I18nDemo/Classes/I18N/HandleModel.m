//
//  HandleModel.m
//  cvteI18n
//
//  Created by webull on 2019/7/26.
//  Copyright © 2019 cvte. All rights reserved.
//

#import "HandleModel.h"

@interface HandleModel()
    @property (nonatomic, weak) id handleObj;
@end

@implementation HandleModel

- (instancetype)initWithBlock: (void(^)(id))block onObject: (id)obj {
    self = [super init];
    if (self) {
        self.handleBlock = block;
        self.handleObj = obj;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealNotification) name:@"cvte.setting.language" object:nil];
    }
    return self;
}

- (void)dealNotification {
    if (self.handleBlock) {
        self.handleBlock(self.handleObj);
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
