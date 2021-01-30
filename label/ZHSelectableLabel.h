//
//  ZHSelectableLabel.h
//  ZHSelectableLabel
//
//  Created by ZhangHao on 2021/1/30.
//

#import "YYLabel.h"
#import <YYText/YYText.h>
NS_ASSUME_NONNULL_BEGIN

/*
 注意 ：
 这个label的使用需要保证
 
 label的文字显示区域 与 label的frame是一致的
 
 即label的frame是通过计算文字得到的
 
 
 */


@class ZHSelectableLabel;
@protocol ZHSelectableLabelDelegate <NSObject>

///即将开始选择文本
- (void)lableWillStartSelection:(ZHSelectableLabel *)alable;
///选择文本的范围改变
- (void)lable:(ZHSelectableLabel *)alable didChangeSelectionWithRange:(NSRange)arange;
///选择文本结束 手指离开屏幕
- (void)lable:(ZHSelectableLabel *)alable didEndSelectionWithRange:(NSRange)arange;


@end

@interface ZHSelectableLabel : YYLabel
@property(nonatomic ,strong)id<ZHSelectableLabelDelegate>selectionDeleagte;
///选中的范围  可KVO
@property(nonatomic ,readonly) NSRange selectedRange;

///结束选择
- (void)endSelection;
///开始选择 默认开始选择的范围是0到text.length
- (void)startSelection;
///开始选择并且指定初始范围
- (void)startSelectionWithRange:(NSRange)range;
@end


///左右两边的光栅
@interface ZHSelectionCursorView : UIView

+ (ZHSelectionCursorView *)cursor;

@end



NS_ASSUME_NONNULL_END
