# cvI18n
一种应用内国际化方案

iOS对应用国际化做了原生的支持，一般获取系统的地区设置，然后根据设置读取设置的语言文件。iOS主要使用不同地区的Localizable.strings文件，然后使用NSLocalizedString方法进行国际化数据的获取。
~~~
NSLocalizedString(<#key#>, <#comment#>)
NSLocalizedStringWithDefaultValue(<#key#>, <#tbl#>, <#bundle#>, <#val#>, <#comment#>)
~~~
对于带参数的字符串，可以使用如下NSString...format的方法，将上面的国际化数据进行参数处理
~~~
"cvte.text.test" = "english %2$@ test %1$@ ";

[[NSString alloc] initWithFormat:<#(nonnull NSString *)#> arguments:<#(struct __va_list_tag *)#>]
~~~
使用系统切换地区的方式进行国际化处理，有一些不太适合的场景。
1、测试人员再做国际化文案测试的时候需要来回切换系统语言，有些语言，这样会使系统的主体语言也发生变化，当切换到类似阿拉伯语的时候，有可能系统使用起来都太方便，并且每次切换需要重启系统。 
2、对于销售人员，需要给国外客户做演示的时候，也需要切换系统为英文环境，使用不便 
 ![效果](https://github.com/ssrrxx111/cvI18n/blob/master/asstes/Jul-29-2019%2020-02-21.gif)


基于上述原因，可以做一些改进方案
1、应用内切换语言，重启应用，然后根据语言设置获取语言文件，进行国际化显示 
2、如果切换系统语言，与上次系统语言对比，如果改变了，将当前语言切换为系统语言 

iOS应用内切换语言重启应用对用户体验比较差，我们可以尝试采用下面的方式进行应用内动态语言切换

###基本原理
1、使用runtime为每个需要需要国际化的控件新增一个对象属性，对象属性中包含了控件本身和执行国际化的block 
2、切换语言的时候发出通知，控件新增的对象中监听通知，执行国际化block 

相关文件如下所示：
![国际化](https://github.com/ssrrxx111/cvI18n/blob/master/asstes/%E5%9B%BD%E9%99%85%E5%8C%96.jpg)

###注意事项
1、国际化文件要通过bundle方式获取
~~~
NSLocalizedStringWithDefaultValue(<#key#>, <#tbl#>, <#bundle#>, <#val#>, <#comment#>)
~~~ 
2、需要注意国际化处理中强引用问题，以免引起循环引用 
3、可变参数的处理，可以做到类似NSLog可变参数的传递 

###相关代码如下
1、国际化语言切换和处理单例I18nManager。I18nManager中维护了所有支持的语言，以及当前选中的语言和index，切换方式目前根据index切换，当然也可以增加通过地区code切换 
~~~
// 根据对应的国际化数组进行切换
- (void) changeIndex: (NSInteger)index

// 支持可变参数传递
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
~~~
2、为NSObject新增处理国际化的方法，主要使用runtime为当前对象新增属性 
~~~
- (void)handleLanguage: (void(^)(id))callback {
    callback(self);
    
    HandleModel *model = [[HandleModel alloc] initWithBlock:callback onObject:self];
    objc_setAssociatedObject(self, languageAssoKey, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
~~~
因为国际化通常是对控件处理的，这里也可以只对UIView进行扩展 

3、控件新增的对象主要包含控件本身和国际化block 
~~~
- (instancetype)initWithBlock: (void(^)(id))block onObject: (id)obj {
    self = [super init];
    if (self) {
        self.handleBlock = block;
        self.handleObj = obj;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealNotification) name:@"cvte.setting.language" object:nil];
    }
    return self;
}
~~~

4、为了兼容目前已经存在的国际化处理，可以使用下面的宏定义 
~~~
#define L(Languagekey, ...) [[I18nManager shareInstance] localized:Languagekey, ##__VA_ARGS__]
~~~

###需要改进
1、项目中目前的需求是根据系统语言进行app语言的切换，因此可以考虑这部分内容加入到后门中，如果后门没有打开语言切换，那么功能与现在一样。如果后门打开语言切换，那么项目根据切换的语言动态处理。
![改进](https://github.com/ssrrxx111/cvI18n/blob/master/asstes/%E8%AF%AD%E8%A8%80%E5%88%87%E6%8D%A2%E5%A4%84%E7%90%86.png)

###更多
1、通过这种获取自身的方式，在做自动布局或者设置界面属性的时候，可以使用统一的标识，如：
~~~
[self.tipsLabel customize:^(UILabel label) {
 label.text = @"";
 label.textColor= UIColor.red;
 label...
}];
~~~
之后在编码处理的时候，对于相同的ui设置，可以直接复制粘贴。

2、同样的，对于界面主题的切换，界面字体大小的切换，都可以采用这种方式处理


###Demo地址
https://github.com/ssrrxx111/cvI18n




