//
//  ViewController.m
//  ZHSelectableLabel
//
//  Created by ZhangHao on 2021/1/30.
//

#import "ViewController.h"
#import "ZHSelectableLabel.h"
#import "Masonry.h"
#import <AudioToolbox/AudioToolbox.h>
@interface ViewController ()<ZHSelectableLabelDelegate>
@property(nonatomic ,strong) ZHSelectableLabel *label;
@property(nonatomic ,strong) UIScrollView *scroll;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scroll = [UIScrollView new];
    self.scroll.frame = self.view.bounds;
    [self.view addSubview:self.scroll];

    self.label = [[ZHSelectableLabel alloc]init];
    self.label.numberOfLines = 0;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.text = @"Objective-C，通常写作ObjC或OC和较少用的Objective C或Obj-C，是扩充C的面向对象编程语言。它主要使用于Mac OS X和GNUstep这两个使用OpenStep标准的系统，而在NeXTSTEP和OpenStep中它更是基本语言。 GCC与Clang含Objective-C的编译器，Objective-C可以在GCC以及Clang运作的系统上编译。 1980年代初布莱德·考克斯(Brad Cox)在其公司Stepstone发明Objective-C。他对软件设计和编程里的真实可用度问题十分关心。Objective-C最主要的描述是他1986年出版的书 Object Oriented Programming: An Evolutionary Approach. Addison Wesley. ISBN 0-201-54834-8.Objective-C，通常写作ObjC或OC和较少用的Objective C或Obj-C，是扩充C的面向对象编程语言。它主要使用于Mac OS X和GNUstep这两个使用OpenStep标准的系统，而在NeXTSTEP和OpenStep中它更是基本语言。 GCC与Clang含Objective-C的编译器，Objective-C可以在GCC以及Clang运作的系统上编译。 1980年代初布莱德·考克斯(Brad Cox)在其公司Stepstone发明Objective-C。他对软件设计和编程里的真实可用度问题十分关心。Objective-C最主要的描述是他1986年出版的书 Object Oriented Programming: An Evolutionary Approach. Addison Wesley. ISBN 0-201-54834-8.Objective-C，通常写作ObjC或OC和较少用的Objective C或Obj-C，是扩充C的面向对象编程语言。它主要使用于Mac OS X和GNUstep这两个使用OpenStep标准的系统，而在NeXTSTEP和OpenStep中它更是基本语言。 GCC与Clang含Objective-C的编译器，Objective-C可以在GCC以及Clang运作的系统上编译。 1980年代初布莱德·考克斯(Brad Cox)在其公司Stepstone发明Objective-C。他对软件设计和编程里的真实可用度问题十分关心。Objective-C最主要的描述是他1986年出版的书 Object Oriented Programming: An Evolutionary Approach. Addison Wesley. ISBN 0-201-54834-8.Objective-C，通常写作ObjC或OC和较少用的Objective C或Obj-C，是扩充C的面向对象编程语言。它主要使用于Mac OS X和GNUstep这两个使用OpenStep标准的系统，而在NeXTSTEP和OpenStep中它更是基本语言。 GCC与Clang含Objective-C的编译器，Objective-C可以在GCC以及Clang运作的系统上编译。 1980年代初布莱德·考克斯(Brad Cox)在其公司Stepstone发明Objective-C。他对软件设计和编程里的真实可用度问题十分关心。Objective-C最主要的描述是他1986年出版的书 Object Oriented Programming: An Evolutionary Approach. Addison Wesley. ISBN 0-201-54834-8.Objective-C，通常写作ObjC或OC和较少用的Objective C或Obj-C，是扩充C的面向对象编程语言。它主要使用于Mac OS X和GNUstep这两个使用OpenStep标准的系统，而在NeXTSTEP和OpenStep中它更是基本语言。 GCC与Clang含Objective-C的编译器，Objective-C可以在GCC以及Clang运作的系统上编译。 1980年代初布莱德·考克斯(Brad Cox)在其公司Stepstone发明Objective-C。他对软件设计和编程里的真实可用度问题十分关心。Objective-C最主要的描述是他1986年出版的书 Object Oriented Programming: An Evolutionary Approach. Addison Wesley. ISBN 0-201-54834-8.Objective-C，通常写作ObjC或OC和较少用的Objective C或Obj-C，是扩充C的面向对象编程语言。它主要使用于Mac OS X和GNUstep这两个使用OpenStep标准的系统，而在NeXTSTEP和OpenStep中它更是基本语言。 GCC与Clang含Objective-C的编译器，Objective-C可以在GCC以及Clang运作的系统上编译。 1980年代初布莱德·考克斯(Brad Cox)在其公司Stepstone发明Objective-C。他对软件设计和编程里的真实可用度问题十分关心。Objective-C最主要的描述是他1986年出版的书 Object Oriented Programming: An Evolutionary Approach. Addison Wesley. ISBN 0-201-54834-8.";
    self.label.frame = CGRectMake(0, 0, self.view.frame.size.width, 2000);
    self.scroll.contentSize = CGSizeMake(0, CGRectGetMaxY(self.label.frame));
    [self.scroll addSubview:self.label];
    [self.view addSubview:self.scroll];
    
    __weak __typeof(&*self)weakSelf = self;
    [self.label setTextTapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        [weakSelf.label endSelection];
    }];
    self.label.userInteractionEnabled = YES;
    [self.label addGestureRecognizer: [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)]];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        AudioServicesPlaySystemSoundWithCompletion(1519, nil);
        CGPoint positon = [sender locationInView:self.label];
        [self.label startSelectionWithPressPosition:positon];
    }
}

///即将开始选择文本
- (void)lableWillStartSelection:(ZHSelectableLabel *)alable{
    
}
///选择文本的范围改变
- (void)lable:(ZHSelectableLabel *)alable didChangeSelectionWithRange:(NSRange)arange{
    
}
///选择文本结束 手指离开屏幕
- (void)lable:(ZHSelectableLabel *)alable didEndSelectionWithRange:(NSRange)arange{
    NSString *selectedString = [alable.text substringWithRange:arange];
    NSLog(@"选中文字:%@",selectedString);
}


@end
