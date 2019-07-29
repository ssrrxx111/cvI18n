//
//  HandleModel.h
//  cvteI18n
//
//  Created by webull on 2019/7/26.
//  Copyright © 2019 cvte. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HandleModel : NSObject

@property(nonatomic, strong) void (^handleBlock)(id);

//@property(nonatomic, weak) id ob;

- (instancetype)initWithBlock: (void(^)(id))block onObject: (id)obj;

@end



NS_ASSUME_NONNULL_END
