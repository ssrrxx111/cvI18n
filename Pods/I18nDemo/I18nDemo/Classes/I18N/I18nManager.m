//
//  I18nManager.m
//  cvteI18n
//
//  Created by webull on 2019/7/29.
//  Copyright © 2019 cvte. All rights reserved.
//

#import "I18nManager.h"

@implementation I18nManager

@synthesize languageDic;
@synthesize currentLanguage;
@synthesize index;

static I18nManager *_instance = nil;

+ (instancetype) shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    [_instance initData];
    return _instance;
}

- (void) initData {
    self.languageDic = @{@"en": @"English", @"zh-Hans": @"简体中文"};
}

- (void) changeIndex: (NSInteger)index {
    if (self.index != index) {
        self.index = index;
        self.currentLanguage = self.languageDic.allKeys[index];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"cvte.setting.language" object:nil];
    }
}

// 1、获取app所有支持的语言信息
// 2、选择对应的语言和locale
// 3、修改locale对应语言文件
// 4、获取国际化数据
// zh-Hans/ en
- (NSString *)localized: (NSString *)identifier, ... {
    self.currentLanguage = self.languageDic.allKeys[self.index];
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:self.currentLanguage ofType:@"lproj"]];
    
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
    
    NSString *localized_str = NSLocalizedStringFromTableInBundle(identifier, nil, bundle, @"");
    va_list paramList;
    va_start(paramList, identifier);
    NSString *result = [[NSString alloc] initWithFormat:localized_str arguments: paramList];
    va_end(paramList);
    
    NSLog(@"key: %@, value为: %@ 结果为: %@", identifier, localized_str, result);
    
    return result;
}

@end

