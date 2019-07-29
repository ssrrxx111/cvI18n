//
//  ViewController.m
//  cvteI18n
//
//  Created by webull on 2019/7/26.
//  Copyright © 2019 cvte. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *i18nLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;


@end

//#define weakSelf(type) __weak typeof(type) weak##type = type;



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.i18nLabel handleLanguage:^(UILabel *ob){
//        ob.text = [[I18nManager shareInstance] localized:@"cvte.text.test", @"参数1", @"参数2"];
        ob.text = L(@"cvte.text.test", @"参数1", @"参数2");
        
    }];
   
    
    [self loadDataAndPickerView];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadDataAndPickerView {
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    // 设置选中项
    [self.pickerView selectRow:[I18nManager shareInstance].index inComponent:0 animated:YES];
    
}

#pragma mark - pickerView delegate and dataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [I18nManager shareInstance].languageDic.allKeys.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [I18nManager shareInstance].languageDic[[I18nManager shareInstance].languageDic.allKeys[row]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"选中语言: %@, key:%@, 选中行:%ld",
          [I18nManager shareInstance].languageDic[[I18nManager shareInstance].languageDic.allKeys[row]],
          [I18nManager shareInstance].languageDic.allKeys[row],
          (long)row);
    
    [[I18nManager shareInstance] changeIndex:row];
}


@end
