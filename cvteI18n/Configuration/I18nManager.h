//
//  I18nManager.h
//  cvteI18n
//
//  Created by webull on 2019/7/29.
//  Copyright © 2019 cvte. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface I18nManager : NSObject

@property(nonatomic) NSDictionary *languageDic;
@property (nonatomic, assign) NSInteger index;
@property(nonatomic) NSString *currentLanguage;

+ (instancetype) shareInstance;

- (NSString *)localized: (NSString *)identifier, ...;
- (void) changeIndex: (NSInteger)index;

@end

NS_ASSUME_NONNULL_END
