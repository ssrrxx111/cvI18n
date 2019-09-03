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
    
    maxInputCount = 10 * 2;
    _unsupporttedWords = @[@"敏感词", @"废青"];
    
    self.textView.delegate = self;
    [self.textView resignFirstResponder];
    
    self.finalAttributedString = [[NSMutableAttributedString alloc] init];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //    self.inputView.inputTipLabel.hidden = self.textView.text.length > 0;
    
    // 输入是否含有表情
    if ([self matchRegular:text]) {
        
        // 得到过滤表情之后的文本
        NSString *supportted = [self supporttedString:text];
        
        // 如果只有表情，不让输入
        if ([supportted isEqualToString:@""]) {
            return NO;
        } else {
            
            // 过滤表情之后的文本，可能含有自带输入法的markedText
            NSMutableAttributedString *pre = [self.textView.attributedText mutableCopy];
            
            // TODO: SRX 在这里计算需要替换的文本，拿到可以替换的文本长度
            
            // 代替换位置长度大于0，替换，否则插入
            if (range.length > 0) {
                [pre replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:supportted attributes:self.normalAttr] ];
            } else {
                [pre insertAttributedString:[[NSAttributedString alloc] initWithString:supportted attributes:self.normalAttr] atIndex:textView.selectedRange.location];
            }
            
            textView.attributedText = [pre copy];
           
            return NO;
        }
    }
    
    
    // 这里拿到剩余可以替换的文本长度，然后进行替换
    NSMutableAttributedString *pre = [self.textView.attributedText mutableCopy];
    
    if (range.length > 0) {
        [pre replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:text attributes:self.normalAttr] ];
    } else {
        [pre insertAttributedString:[[NSAttributedString alloc] initWithString:text attributes:self.normalAttr] atIndex:textView.selectedRange.location];
    }
    self.finalAttributedString = pre;
    
    return YES;
    
}

- (void)textViewDidChange:(UITextView *)textView {
    
    // 获取光标位置
    NSInteger position = textView.selectedRange.location;
    
    // markedText不做处理
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    if (selectedRange != nil && pos != nil) {
        return;
    }
    
    // 获取当前文本长度
    NSInteger preLength = [self bytesCountByIgnoreCharacter:self.finalAttributedString.string];
    // 截断文本到指定长度
    textView.attributedText = [self finalStringWith:self.finalAttributedString preLength:preLength maxLenght:maxInputCount];
    
    NSLog(@"cur: %@, text2: %@", textView.text, self.textView.text);
    
    // 恢复光标位置
    textView.selectedRange = NSMakeRange(position, 0);
 
    // 统计文本长度
    NSInteger length = [self bytesCountByIgnoreCharacter:textView.text];
    self.countLabel.text = [NSString stringWithFormat:@"文本长度: %@", @(ceil(length / 2.0))];
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
    return count;
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
        
//        NSInteger result = ceil(count / 2.0);
        
        // 结果超出，不加入
        if (count > max) {
            return [mutableString copy];
        }
        
        [mutableString appendString:characterString];
    }
    
    return [mutableString copy];
}


- (NSAttributedString *)finalStringWith:(NSMutableAttributedString *)origin preLength:(NSInteger) preLength maxLenght: (NSInteger)max {
    
    if (preLength <= max) {
        return origin;
    }
    
    NSInteger count = 0;
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
        
//        NSInteger result = ceil(count / 2.0);
        
        if (count > max) {
            cutIndex = i;
            break;
        }
      
    }
    
    return [[origin attributedSubstringFromRange:NSMakeRange(0, cutIndex)] copy];
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

