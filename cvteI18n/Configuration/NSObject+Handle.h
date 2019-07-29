//
//  NSObject+extesion.h
//  cvteI18n
//
//  Created by webull on 2019/7/26.
//  Copyright © 2019 cvte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN



@interface NSObject (Handle)

- (void)handleLanguage: (void(^)(id))callback;

@end

NS_ASSUME_NONNULL_END
