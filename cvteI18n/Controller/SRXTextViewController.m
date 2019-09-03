//
//  SRXTextViewController.m
//  cvteI18n
//
//  Created by webull on 2019/9/3.
//  Copyright © 2019 cvte. All rights reserved.
//

#import "SRXTextViewController.h"

@interface SRXTextViewController () <UITextViewDelegate>
{
    NSInteger maxInputCount;
    NSString *textViewString;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *mybutton;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (nonatomic, strong) NSDictionary *normalAttr;

@property (nonatomic, strong) NSDictionary *errorAttr;

@property (nonatomic, strong) NSArray *unsupporttedWords;

@property (nonatomic, strong) NSMutableAttributedString *finalAttributedString;

@end

@implementation SRXTextViewController

- (NSDictionary *)normalAttr {
    if (_normalAttr == nil) {
        _normalAttr = @{NSForegroundColorAttributeName:UIColor.blackColor, NSFontAttributeName:[UIFont systemFontOfSize:16],};
    }
    return _normalAttr;
}

- (NSDictionary *)errorAttr {
    if (_errorAttr == nil) {
        _errorAttr = @{NSForegroundColorAttributeName:UIColor.redColor, NSFontAttributeName:[UIFont systemFontOfSize:16],};
    }
    return _errorAttr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    maxInputCount = 10;
    _unsupporttedWords = @[@"敏感词", @"废青"];
    
    self.textView.delegate = self;
    [self.textView resignFirstResponder];
    
    self.finalAttributedString = [[NSMutableAttributedString alloc] init];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //    self.inputView.inputTipLabel.hidden = self.textView.text.length > 0;
    
    // TODO: SRX处理文本变色
    if ([self matchRegular:text]) {
        NSString *supportted = [self supporttedString:text];
        if ([supportted isEqualToString:@""]) {
            return NO;
        } else {
            NSMutableAttributedString *pre = [self.textView.attributedText mutableCopy];
            //            textView.text = [pre stringByReplacingCharactersInRange:range withString: supportted];
            
            if (range.length > 0) {
                [pre replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:supportted attributes:self.normalAttr] ];
            } else {
                [pre insertAttributedString:[[NSAttributedString alloc] initWithString:supportted attributes:self.normalAttr] atIndex:textView.selectedRange.location];
            }
            
            textView.attributedText = [pre copy];
            
            
            
            
            //            NSInteger position = textView.selectedRange.location;
            
            //            if (range.length > 0) {
            //
            //                [self.finalAttributedString addAttributes:self.normalAttr range:range];
            //            } else {
            //                [self.finalAttributedString insertAttributedString:[[NSAttributedString alloc] initWithString:supportted attributes:self.normalAttr] atIndex:range.location];
            //            }
            
            
            
            
            
            
            // 判断文本长度
            //            NSInteger length = [self bytesCountByIgnoreCharacter:textView.text];
            //            NSLog(@"文本长度: %ld", (long)length);
            //            // 计算还可以输入的字符
            //            NSString *resultString = [self resultStringBySubstring:textView.text preLength:length maxLenght:maxInputCount];
            //            self.textView.attributedText = [[NSAttributedString alloc] initWithString: resultString attributes:self.normalAttr];
            //            // 恢复光标位置
            //            textView.selectedRange = NSMakeRange(position, 0);
            return NO;
        }
    }
    
    NSMutableAttributedString *pre = [self.textView.attributedText mutableCopy];
    //            textView.text = [pre stringByReplacingCharactersInRange:range withString: supportted];
    
    if (range.length > 0) {
        [pre replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:text attributes:self.normalAttr] ];
    } else {
        [pre insertAttributedString:[[NSAttributedString alloc] initWithString:text attributes:self.normalAttr] atIndex:textView.selectedRange.location];
    }
    self.finalAttributedString = pre;
    
    //    textView.attributedText = [pre copy];
    
    
    // 1、判断是插入还是替换，根据range的长度
    // 2、先去除replacement字符串的不符合的字符，然后加入
    // 3、加入完成之后做截断处理，截断处理在didChange中进行
    
    
    //    NSMutableAttributedString *pre = [self.textView.attributedText mutableCopy];
    //
    //    [pre insertAttributedString:[[NSAttributedString alloc] initWithString:text attributes:self.normalAttr] atIndex:textView.selectedRange.location];
    //
    //    textView.attributedText = [pre copy];
    
    
    // 处理attributedString
    NSLog(@"preString: %@, replaceMentText: %@, self.inputView.textView.text: %@", textView.text, text, self.textView.text);
    
    return YES;
    
}

- (void)textViewDidChange:(UITextView *)textView {
    
    NSInteger position = textView.selectedRange.location;
    
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    if (selectedRange != nil && pos != nil) {
        return;
    }
    
//    textView.attributedText = self.finalAttributedString;
    NSInteger preLength = [self bytesCountByIgnoreCharacter:self.finalAttributedString.string];
    textView.attributedText = [self resultAttributedStringBySubstring:self.finalAttributedString preLength:preLength maxLenght:maxInputCount];
    
    NSLog(@"cur: %@, text2: %@", textView.text, self.textView.text);
    
    textView.selectedRange = NSMakeRange(position, 0);
    
    
    // 需要获取外部文本框内容
    //    self.inputView.inputTipLabel.hidden = self.inputView.textView.text.length > 0;
    
    //    UITextRange *selectedRange = [textView markedTextRange];
    //    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //
    //    if (selectedRange != nil && pos != nil) {
    //        return;
    //    }
    //
    
    //
    //    // 判断文本长度
    NSInteger length = [self bytesCountByIgnoreCharacter:textView.text];
    self.countLabel.text = [NSString stringWithFormat:@"文本长度: %@", @(length)];
    NSLog(@"文本长度: %ld", (long)length);
    //
    //    // 计算还可以输入的字符
    //    NSString *resultString = [self resultStringBySubstring:textView.text preLength:length maxLenght:maxInputCount];
    //    self.textView.attributedText = [[NSAttributedString alloc] initWithString: resultString attributes:self.normalAttr];
    //
    //    textViewString = resultString;
    //
    //    // 恢复光标位置
    
    
}


// 统计字符个数，中文1个字符，英文0.5个字符
- (NSInteger)bytesCountByIgnoreCharacter:(NSString *)character {
    
    NSInteger count = 0;
    for (NSInteger i = 0; i < character.length; i++) {
        NSString *characterString = [character substringWithRange:NSMakeRange(i, 1)];
        
        NSData *data = [characterString dataUsingEncoding:NSUTF8StringEncoding];
        if (data.length == 0) {
            count += 2;
        } else if (data.length == 1) {
            count++;
        } else if (data.length == 2) {
            count++;
        } else if (data.length == 3) {
            count += 2;
        }
    }
    return ceil(count / 2.0);
}

// 获取限定字符长度的字符串
- (NSString *)resultStringBySubstring:(NSString *)origin preLength:(NSInteger) preLength maxLenght: (NSInteger)max {
    
    if (preLength <= max) {
        return origin;
    }
    
    NSInteger count = 0;
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < origin.length; i++) {
        NSString *characterString = [origin substringWithRange:NSMakeRange(i, 1)];
        NSData *data = [characterString dataUsingEncoding:NSUTF8StringEncoding];
        if (data.length == 0) {
            count += 2;
        } else if (data.length == 1) {
            count++;
        } else if (data.length == 2) {
            count++;
        } else if (data.length == 3) {
            count += 2;
        }
        
        NSInteger result = ceil(count / 2.0);
        
        // 结果超出，不加入
        if (result > max) {
            return [mutableString copy];
        }
        
        [mutableString appendString:characterString];
    }
    
    return [mutableString copy];
}


- (NSMutableAttributedString *)resultAttributedStringBySubstring:(NSMutableAttributedString *)origin preLength:(NSInteger) preLength maxLenght: (NSInteger)max {
    
    if (preLength <= max) {
        return origin;
    }
    
    NSInteger count = 0;
    NSMutableAttributedString *mutableString = [origin mutableCopy];
    NSInteger cutIndex = 0;
    for (NSInteger i = 0; i < origin.length; i++) {
        NSString *characterString = [origin.string substringWithRange:NSMakeRange(i, 1)];
        NSData *data = [characterString dataUsingEncoding:NSUTF8StringEncoding];
        if (data.length == 0) {
            count += 2;
        } else if (data.length == 1) {
            count++;
        } else if (data.length == 2) {
            count++;
        } else if (data.length == 3) {
            count += 2;
        }
        
        NSInteger result = ceil(count / 2.0);
        
        if (result > max) {
            cutIndex = i;
            break;
        }
        
      
    }
    
    return [[origin attributedSubstringFromRange:NSMakeRange(0, cutIndex)] mutableCopy];
    
//    return [mutableString copy];
}




/**
 //去除表情规则
 //  \\u0020-\\u007E  标点符号，大小写字母，数字
 //  \\u00A0-\\u00BE  特殊标点  (¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾)
 //  \\u2E80-\\uA4CF  繁简中文,日文，韩文 彝族文字
 //  \\uFE30-\\uFE4F  特殊标点(︴︵︶︷︸︹)
 //  \\uFF00-\\uFFEF  日文  (ｵｶｷｸｹｺｻ)
 //  \\u2000-\\u200f  特殊字符(空白，有些emoji中包含\\u200d，如🧚‍♀️)
 //  \\u2010-\\u201f  特殊字符(‐‑‒–—―‖‗‘’‚‛“”„‟)
 // 注：对照表 http://blog.csdn.net/hherima/article/details/9045765
 
 @param text 匹配的文本
 @return 返回匹配结果
 */
- (BOOL)matchRegular: (NSString *)text {
    // 中文、字母、数字、特殊符号、空格。输入表情不显示
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u2010-\\u201f\r\n]";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error != nil) {
        return NO;
    }
    
    NSTextCheckingResult *result = [regex firstMatchInString:text options:NSMatchingReportCompletion range:NSMakeRange(0, text.length)];
    if (result != nil) {
        NSLog(@"%@", [text substringWithRange:result.range]);
        return YES;
    }
    
    return NO;
}

- (NSString *)supporttedString: (NSString *)replaceText {
    // 中文、字母、数字、特殊符号、空格。输入表情不显示
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u2010-\\u201f\r\n]";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    return [regex stringByReplacingMatchesInString:replaceText options:0 range:NSMakeRange(0, replaceText.length) withTemplate:@""];
}

#pragma mark - IBAction

- (IBAction)actionToSensitiveWord:(id)sender {
    
    NSString *origin  = self.textView.text;
    
    // 提交的时候先全部恢复，然后处理
    
    NSMutableAttributedString *originAttr = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    NSLog(@"%@ %@", origin, _unsupporttedWords);
    
    for (NSString *word in self.unsupporttedWords) {
        NSRange range = [origin rangeOfString:word];
        
        if (range.location != NSNotFound) {
            [originAttr addAttributes:self.errorAttr range:range];
        }
    }
    
    self.textView.attributedText = [originAttr copy];
}


@end

