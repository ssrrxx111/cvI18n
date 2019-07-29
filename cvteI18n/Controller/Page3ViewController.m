//
//  Page3ViewController.m
//  cvteI18n
//
//  Created by webull on 2019/7/29.
//  Copyright © 2019 cvte. All rights reserved.
//

#import "Page3ViewController.h"

@interface Page3ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *i18nLabel;

@end

@implementation Page3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.i18nLabel handleLanguage:^(UILabel *view) {
        view.text = [[I18nManager shareInstance] localized:@"cvte.text.page3"];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
