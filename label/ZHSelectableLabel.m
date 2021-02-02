//
//  ZHSelectableLabel.m
//  KS-iOS
//
//  Created by ZhangHao on 2021/1/30.
//  Copyright © 2021 KyExpress. All rights reserved.
//

#import "ZHSelectableLabel.h"
#import <Masonry/Masonry.h>
#define ZHUIColorFromRGBA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]
#define ZHUIColorFromRGB(rgbValue) ZHUIColorFromRGBA(rgbValue, 1.0)

#define ZHSelectionCursorWidth 2

@protocol ZHSelectableLabel_Super_Private_Methods <NSObject>
@optional
///super private method
- (CGRect)_convertRectFromLayout:(CGRect)rect;
- (CGRect)_convertRectToLayout:(CGRect)rect;
///将文字区域的坐标转换为self里面的坐标
- (CGPoint)_convertPointFromLayout:(CGPoint)point;
///将self里面的坐标转换为文字里面的坐标
- (CGPoint)_convertPointToLayout:(CGPoint)point;

@end


@interface ZHSelectableLabel()<ZHSelectableLabel_Super_Private_Methods>
///选中的范围
@property(nonatomic ,assign) NSRange selectedRange;
///两个光标
@property(nonatomic ,strong) ZHSelectionCursorView *leftCursor;
@property(nonatomic ,strong) ZHSelectionCursorView *rightCursor;
///背景色
@property(nonatomic ,strong) UIView *selectionBackGroundView;
///手势
@property(nonatomic ,strong) UIPanGestureRecognizer *panGesture;
///放大镜
@property(nonatomic ,strong) UIImageView *magnifierView;


@end



@implementation ZHSelectableLabel{
    ZHSelectionCursorView *_panGuestureLocateView;///当前滑动手势在哪个view上
}

- (void)prepareSelectionIfNeed{
    if (!_leftCursor || !_rightCursor || !_selectionBackGroundView) {
        self.leftCursor = [ZHSelectionCursorView leftCursor];
        self.rightCursor = [ZHSelectionCursorView rightCursor];
        self.selectionBackGroundView = [[UIView alloc]initWithFrame:self.bounds];
        [self addSubview:self.selectionBackGroundView];
        [self.selectionBackGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [self addSubview:self.leftCursor];
        [self addSubview:self.rightCursor];
    }
    [self addPanGesture];
}

- (void)startSelection{
    [self startSelectionWithRange:NSMakeRange(0, self.text.length)];
}

- (void)endSelection{
    [self removePanGesture];
    self.leftCursor.hidden = YES;
    self.rightCursor.hidden = YES;
    self.selectedRange = NSMakeRange(0, 0);
    [self removeAllSubviewsForView:self.selectionBackGroundView];
    self.selectionBackGroundView.hidden = YES;
}

- (void)removeAllSubviewsForView:(UIView *)view{
    for (UIView *sub in view.subviews) {
        [sub removeFromSuperview];
    }
}

- (void)startSelectionWithRange:(NSRange)range{
    [self prepareSelectionIfNeed];
    self.leftCursor.hidden = NO;
    self.rightCursor.hidden = NO;
    self.selectionBackGroundView.hidden = NO;
    [self _setSelectedRange:range];
    [self callBackChange];
}

- (void)_setSelectedRange:(NSRange)range{
    self.selectedRange = range;
    [self _adjustSelectionBackGroundView];
}

#pragma mark - 背景
- (void)_adjustSelectionBackGroundView{
    YYTextRange *range = [YYTextRange rangeWithRange:self.selectedRange];
    NSArray *rects = [self.textLayout selectionRectsForRange:range];
    [rects enumerateObjectsUsingBlock:^(YYTextSelectionRect *rect, NSUInteger idx, BOOL *stop) {
        rect.rect = [self _convertRectFromLayout:rect.rect];
    }];
    [self removeAllSubviewsForView:self.selectionBackGroundView];
    [rects enumerateObjectsUsingBlock: ^(YYTextSelectionRect *r, NSUInteger idx, BOOL *stop) {
        CGRect rect = r.rect;
        rect = CGRectStandardize(rect);
        rect = YYTextCGRectPixelRound(rect);
        if (r.containsStart || r.containsEnd) {
            rect = [self cursorFrameKeepWidth:rect];
            if (r.containsStart) {
                self.leftCursor.frame = rect;
            }
            if (r.containsEnd) {
                self.rightCursor.frame = rect;
            }
        }else{
            if (rect.size.width > 0 && rect.size.height > 0){
                UIView *mark = [[UIView alloc] initWithFrame:rect];
                mark.backgroundColor = ZHUIColorFromRGB(0x3CB371);
                mark.alpha = 0.6;
                [self.selectionBackGroundView addSubview:mark];
            }
        }
    }];
    [self bringSubviewToFront:self.leftCursor];
    [self bringSubviewToFront:self.rightCursor];
}

- (CGRect)cursorFrameKeepWidth:(CGRect)rect{
    return CGRectMake(rect.origin.x, rect.origin.y, ZHSelectionCursorWidth, rect.size.height);
}

- (YYTextLine *)firstTextLine{
    return self.textLayout.lines.firstObject;;
}

- (CGFloat)firstTextLineTop{
    return [self firstTextLine].top;
}




#pragma mark - 光栅
- (CGRect)leftCursorNearTextFrame{
    YYTextPosition *position = [self.textLayout closestPositionToPoint:[self _convertPointFromLayout:self.leftCursor.center]];
    CGRect leftRectInText = [self.textLayout caretRectForPosition:position];
    return [self _convertRectFromLayout:leftRectInText];;
}

- (CGRect)rightCursorNearTextFrame{
    YYTextPosition *position = [self.textLayout closestPositionToPoint:[self _convertPointFromLayout:self.rightCursor.center]];
    CGRect rightRectInText = [self.textLayout caretRectForPosition:position];
    return [self _convertRectFromLayout:rightRectInText];;
}

- (CGRect)cursorNearTextFrameForPosition:(CGPoint)point{
    ///将self坐标转换为文字里面的坐标
    CGPoint textPoint = [self _convertPointToLayout:point];
    YYTextLayout *layout = self.textLayout;
    ///获取此点的文字position
    YYTextPosition *position = [layout closestPositionToPoint:textPoint];
    CGRect caretRect = [layout caretRectForPosition:position];
    CGRect res = [self _convertRectFromLayout:caretRect];
    return res;
}

- (YYTextPosition *)startPositionForCursor{
    return [self.textLayout closestPositionToPoint:[self _convertPointToLayout:self.leftCursor.center]];
}

- (YYTextPosition *)endPositionForCursor{
    return [self.textLayout closestPositionToPoint:[self _convertPointToLayout:self.rightCursor.center]];
}

#pragma mark - 滑动手势

- (void)addPanGesture{
    self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(cursorMoved:)];
    [self addGestureRecognizer:self.panGesture];
}

- (void)removePanGesture{
    [self removeGestureRecognizer:self.panGesture];
}

//手势
- (void)cursorMoved:(UIPanGestureRecognizer *)pan{
    CGPoint location = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        CGFloat xedge = 35;
        CGFloat yedge = 10;
        CGRect visibleLeftRect = CGRectMake(self.leftCursor.frame.origin.x - xedge, self.leftCursor.frame.origin.y-yedge, self.leftCursor.frame.size.width + xedge *2, self.leftCursor.frame.size.height + yedge *2);
        CGRect visibleRightRect = CGRectMake(self.rightCursor.frame.origin.x - xedge, self.rightCursor.frame.origin.y-yedge, self.rightCursor.frame.size.width + xedge *2, self.rightCursor.frame.size.height + yedge *2);
        BOOL willStart = YES;
        if (CGRectContainsPoint(visibleLeftRect, location)) {
            _panGuestureLocateView = self.leftCursor;///滑动左边的光标
        }else if (CGRectContainsPoint(visibleRightRect, location)){
            _panGuestureLocateView = self.rightCursor;///滑动右边的光标
        }else{
            _panGuestureLocateView = nil;//无效手势
            willStart = NO;
        }
        if (willStart) {
            [self callBackStart];
        }
    }else{
        if (!_panGuestureLocateView) {
            return;
        }
        if(pan.state == UIGestureRecognizerStateChanged){
            [self moveCursor:_panGuestureLocateView toPoint:location];
            [self callBackChange];
        }else{
            [self removeMagnifier];
            [self callBackEnd];
        }
    }
}

- (void)callBackStart{
    if (self.selectionDeleagte && [self.selectionDeleagte respondsToSelector:@selector(lableWillStartSelection:)]) {
        [self.selectionDeleagte lableWillStartSelection:self];
    }
}

- (void)callBackChange{
    if (self.selectionDeleagte && [self.selectionDeleagte respondsToSelector:@selector(lable:didChangeSelectionWithRange:)]) {
        [self.selectionDeleagte lable:self didChangeSelectionWithRange:self.selectedRange];
    }
}

- (void)callBackEnd{
    if (self.selectionDeleagte && [self.selectionDeleagte respondsToSelector:@selector(lable:didEndSelectionWithRange:)]) {
        [self.selectionDeleagte lable:self didEndSelectionWithRange:self.selectedRange];
    }
}

///手指一动 先获取光标应该一动的坐标  再获取当前起止点的textPosition 然后改变range 再刷新UI
- (void)moveCursor:(ZHSelectionCursorView *)cursor toPoint:(CGPoint)point{
    ///先设置光标位置
    CGRect frame = [self cursorNearTextFrameForPosition:point];
    cursor.frame = [self cursorFrameKeepWidth:frame];
    ///再读取起止点的postion
    YYTextPosition *start = [self startPositionForCursor];
    YYTextPosition *end = [self endPositionForCursor];
    ///再获取range
    YYTextRange *range = [YYTextRange rangeWithStart:start end:end];
    self.selectedRange = [self correctRange:[range asRange]];
    ///刷新标记
    [self _adjustSelectionBackGroundView];
    [self updataMagnifierForCursor:cursor];
}

// 两个光标的间距最小为1
// 两个光标的间距最小为1
- (NSRange)correctRange:(NSRange)arange{
    ///防止左右两边顶到头并且length为0
    if (arange.location == self.text.length - 1) {///顶到最右边了
        return NSMakeRange(self.text.length - 2, 1);
    }
    if (arange.location == 0 && arange.length == 0) {
        return NSMakeRange(0, 1);///顶到最左边了
    }
    if(arange.length == 0){
        ///在中间length为0
        return NSMakeRange(arange.location - 1, 1);
    }
    return arange;
}

//TODO: 放大镜
- (void)updataMagnifierForCursor:(ZHSelectionCursorView *)cursor{
    [self addMagnifier];
    ///先拿到整个window的截图
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIGraphicsBeginImageContextWithOptions(window.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [window.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    //再获取需要截取的大小
    CGFloat captureWidth = 114;
    CGFloat captureHeight = cursor.frame.size.height * 1.4;
    CGRect focusRect = CGRectMake(cursor.center.x - captureWidth/2, cursor.center.y - captureHeight/2, captureWidth, captureHeight);
    focusRect = [self convertRect:focusRect toView:window];
    
    if (image) {
        //由于CGImage的坐标系以像素为单位需要缩放
        CGFloat scale = [UIScreen mainScreen].scale;
        CGRect captureRect = CGRectMake(focusRect.origin.x * scale, focusRect.origin.y * scale, focusRect.size.width * scale, focusRect.size.height * scale);
        CGImageRef finalImageRef =CGImageCreateWithImageInRect(image.CGImage,captureRect);
        UIImage *finalImage = [UIImage imageWithCGImage:finalImageRef];
        CGImageRelease(finalImageRef);///要养成随手release的习惯
        self.magnifierView.image = finalImage;
    }
    ///结束使用上下文 要养成习惯
    UIGraphicsEndImageContext();
    ///计算放大镜显示的区域
    CGFloat displayScale = 1.5;
    CGSize displaySize = CGSizeMake(captureWidth *displayScale, captureHeight * displayScale);
    CGRect displayRect = CGRectMake(cursor.center.x - displaySize.width/2, cursor.center.y - displaySize.height/2 - 40,displaySize.width,displaySize.height);
    self.magnifierView.frame = [self convertRect:displayRect toView:window];
}

- (void)addMagnifier{
    if (!self.magnifierView) {
        self.magnifierView = [UIImageView new];
        self.magnifierView.backgroundColor = [UIColor whiteColor];
        self.magnifierView.layer.cornerRadius = 3;
        self.magnifierView.layer.masksToBounds = YES;
        self.magnifierView.layer.borderWidth = 0.5;
        self.magnifierView.layer.borderColor = UIColor.whiteColor.CGColor;
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!self.magnifierView.superview) {
        [window addSubview:self.magnifierView];
    }
}

- (void)removeMagnifier{
    [self.magnifierView removeFromSuperview];
}
@end



@implementation ZHSelectionCursorView : UIView


+ (ZHSelectionCursorView *)leftCursor{
    ZHSelectionCursorView *view = [[ZHSelectionCursorView alloc]initWithFrame:CGRectMake(0, 0, ZHSelectionCursorWidth, 17)];
    [view creatSubview:YES];
    view.backgroundColor = ZHUIColorFromRGB(0x008B45);
    return view;
}

+ (ZHSelectionCursorView *)rightCursor{
    ZHSelectionCursorView *view = [[ZHSelectionCursorView alloc]initWithFrame:CGRectMake(0, 0, ZHSelectionCursorWidth, 17)];
    [view creatSubview:NO];
    view.backgroundColor = ZHUIColorFromRGB(0x008B45);
    return view;
}

- (void)creatSubview:(BOOL)isLeft{
    self.layer.masksToBounds = NO;
    UIView *dot = [UIView new];
    dot.backgroundColor = ZHUIColorFromRGB(0x008B45);
    dot.layer.cornerRadius = 4;
    dot.layer.masksToBounds = YES;
    [self addSubview:dot];
    if (isLeft) {
        [dot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_top);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(8, 8));
        }];
    }else{
        [dot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_bottom);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(8, 8));
        }];
    }
}


-(void)removeFromSuperview{
    [super removeFromSuperview];
}
@end
