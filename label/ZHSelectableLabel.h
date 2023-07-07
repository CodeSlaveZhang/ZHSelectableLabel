//
//  ZHSelectableLabel.h
//  ZHSelectableLabel
//
//  Created by ZhangHao on 2021/1/30.
//

#import "YYLabel.h"
#import <YYText/YYText.h>
NS_ASSUME_NONNULL_BEGIN
@class ZHSelectionCursorView;
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
@property(nonatomic ,weak)id <ZHSelectableLabelDelegate>selectionDeleagte;
///选中的范围  可KVO
@property(nonatomic ,readonly) NSRange selectedRange;

///两个光标
@property(nonatomic ,strong) ZHSelectionCursorView *leftCursor;
@property(nonatomic ,strong) ZHSelectionCursorView *rightCursor;


- (void)setTextSelectedRange:(NSRange)selectedRange;

@property(nonatomic ,readonly)NSString *selectedText;

///结束选择
- (void)endSelection;
///开始选择 默认开始选择的范围是0到text.length
- (void)startSelection;
///开始选择并且指定初始范围
- (void)startSelectionWithRange:(NSRange)range;
///从点击的位置开始选择
- (void)startSelectionWithPressPosition:(CGPoint)position;
@end




///左右两边的光栅
@interface ZHSelectionCursorView : UIView

+ (ZHSelectionCursorView *)leftCursor;
+ (ZHSelectionCursorView *)rightCursor;

@end






NS_ASSUME_NONNULL_END
