//
//  XYView.m
//  ZHW
//
//  Created by 闫世超 on 16/10/29.
//  Copyright © 2016年 闫世超. All rights reserved.
//

#import "XYView.h"
#import <Masonry.h>

#define XYScreenW [UIScreen mainScreen].bounds.size.width

#define btnW 80
#define btnH 100
@interface XYView ()<UIGestureRecognizerDelegate>

@property (nonatomic ,strong) UIImageView * imageView;

@property (nonatomic ) CGFloat imageViewX;      //棋牌的X轴坐标

@property (nonatomic ,strong) NSMutableArray *cardNumer;

@property (nonatomic )  CGFloat space;    // 各个棋牌之间的间隙

@property (nonatomic ,strong) UIButton *notPlay;

@property (nonatomic ,strong) UIButton *reelect;

@property (nonatomic ,strong) UIButton *hintBtn;

@property (nonatomic ,strong) UIButton *playHand;

@property (nonatomic ,strong) UIButton *grabLandlord; //抢地主

@property (nonatomic ,strong) UIButton *callLandlord;     //叫地主

@property (nonatomic ,strong) UIButton *notCall;         //不叫


@end

@implementation XYView

-(instancetype)init{
    if (self = [super init]) {
       
        NSArray *arr = @[@100,@101,@102,@103,@104,@105,@106,@107,@108,@109,@110,@111,@112,@113,@114,@115,@116,@117,@118,@119,@120,@121,@122,@123,@124,@125,@126,@127,@128,@129,@130,@131,@132];
        self.cardNumer = [NSMutableArray arrayWithArray:arr];
        [self setUpTheImageView];
        [self addSelectionOperationButton];
    }
    return self;
}
-(void)setUpTheImageView{
    
    for (int i = 0; i < self.cardNumer.count; i++) {
        
        self.imageView = [[UIImageView alloc]init];
        
        self.imageView.tag = 100 + i;
        self.imageView.userInteractionEnabled = YES;
        //添加单击手势
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapGestureRecor:)];
        [self.imageView addGestureRecognizer:tapGesture];
        
        //添加平移手势
        UIPanGestureRecognizer *panGesture=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        [self.imageView addGestureRecognizer:panGesture];
        
        NSString *path = [NSString stringWithFormat:@"%d.JPG",i+1];
        self.imageView.image = [UIImage imageNamed:path];
        
        [self addSubview:self.imageView];
        self.space = (XYScreenW - btnW) / (self.cardNumer.count - 1);
        if (self.space >= btnW/2.0) {
            self.space = btnW/2.0;
        }
        if (i < ((self.cardNumer.count+1)/2.0)) {
            self.imageViewX = (XYScreenW / 2.0 - btnW/2.0) + self.space * i ;
        }else{
            self.imageViewX = ((XYScreenW / 2.0 - btnW/2.0)) - (self.space * (i-((self.cardNumer.count + 1)/2.0 - 1))) ;
            [self sendSubviewToBack:self.imageView];
        }
        self.imageView.frame = CGRectMake(self.imageViewX , 70, btnW, btnH);
        
        self.maskView = [[UIView alloc]init];
        self.maskView.frame = self.imageView.bounds;
        self.maskView.alpha = 0.0;
        self.maskView.backgroundColor = [UIColor blackColor];
        
        [self.imageView addSubview:self.maskView];
    }
    
}
//点击到屏幕，触发的方法；
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSInteger imageTag = [self stringToIntercept:touches];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = obj;
            if (imageTag == imageView.tag) {
                [imageView.subviews firstObject].alpha = 0.5;
            }
        }
    }];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    
    NSInteger imageTag = [self stringToIntercept:touches];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = obj;
            if (imageTag == imageView.tag) {
                [imageView.subviews firstObject].alpha = 0.0;
                [self judgeButtonPosition:imageView];
            }
        }
    }];
    
}

-(NSInteger)stringToIntercept:(NSSet<UITouch *> *)touches{
    NSString *imageStr = touches.description;
    
    NSRange range = [imageStr rangeOfString:@"tag"];
    NSString *imageTagStr = [imageStr substringWithRange:NSMakeRange(range.location+6, 3)];
    return [imageTagStr integerValue];
}

-(void)TapGestureRecor:(UITapGestureRecognizer*)recor{
    self.imageView = (UIImageView *)recor.view;
    NSLog(@"%@",self.imageView);
    [self judgeButtonPosition:self.imageView];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = obj;
            [imageView.subviews firstObject].alpha = 0.0;
        }
    }];
}

#pragma mark 平移
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)sender {
    //获取视图
    self.imageView = (UIImageView *)sender.view;
    //  NSLog(@"--点击的坐标--   :%f",self.button.frame.origin.x);
    //获取移动的点当前坐标
    CGPoint point=[sender translationInView:self.imageView.superview];
    CGFloat currentX = self.imageView.frame.origin.x + point.x;
    
    [self addMaskWithImageView:point.x currentX:currentX startX:self.imageView.frame.origin.x];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self setThePositionOfSlidingCard:point.x currentX:currentX startX:self.imageView.frame.origin.x];
    }
}


//设置滑动牌的位置
-(void)setThePositionOfSlidingCard:(CGFloat)direction currentX:(CGFloat)currentX startX:(CGFloat)startX{
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            UIImageView * imageView = obj;
            
            CGFloat btnX = imageView.frame.origin.x;
            if (direction > 0) {
                
                if (currentX >= btnX && btnX >= startX) {
                    [self judgeButtonPosition:imageView];
                    [self judgeMaskViewAlpha:direction currentX:currentX startX:startX];
                }
                
            }else{
                
                if (currentX <= btnX  && btnX <= startX) {
                    [self judgeButtonPosition:imageView];
                    [self judgeMaskViewAlpha:direction currentX:currentX startX:startX];
                }
            }
        }
    }];
    
}

//设置滑动牌的位置
-(void)addMaskWithImageView:(CGFloat)direction currentX:(CGFloat)currentX startX:(CGFloat)startX{
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            UIImageView * imageView = obj;
            
            CGFloat btnX = imageView.frame.origin.x;
           
            if(direction > 0){
                if (currentX >= btnX && btnX >= startX) {
                     [imageView.subviews firstObject].alpha = 0.5;
                }else{
                     [imageView.subviews firstObject].alpha = 0.0;
                }
            }else{
                if (currentX <= btnX && btnX <= startX) {
                    [imageView.subviews firstObject].alpha = 0.5;
                }else{
                    [imageView.subviews firstObject].alpha = 0.0;
                }
            
            }
            
        }
        
    }];
    
}

-(void)judgeMaskViewAlpha:(CGFloat)direction currentX:(CGFloat)currentX startX:(CGFloat)startX{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            UIImageView * imageView = obj;
            
            CGFloat btnX = imageView.frame.origin.x;
            
            if(direction > 0){
                if (currentX >= btnX && btnX >= startX) {
                    [imageView.subviews firstObject].alpha = 0.0;
                }
            }else{
                if (currentX <= btnX && btnX <= startX) {
                    [imageView.subviews firstObject].alpha = 0.0;
                }
                
            }
            
        }
        
    }];

}
//判断btn位置
-(void)judgeButtonPosition:(UIImageView *)imageView{
    
    if (imageView.frame.origin.y != 70) {
        [UIView animateWithDuration:0.15 animations:^{
            imageView.frame = CGRectMake(imageView.frame.origin.x, 70, btnW, btnH);
        }];
        
        [self.reelect setBackgroundImage:[UIImage imageNamed:@"bt_gray_bg"] forState:UIControlStateNormal];
        self.reelect.userInteractionEnabled = NO;
        
        [self.playHand setBackgroundImage:[UIImage imageNamed:@"bt_gray_bg"] forState:UIControlStateNormal];
        self.playHand.userInteractionEnabled = NO;
        
    }else{
        [UIView animateWithDuration:0.15 animations:^{
            imageView.frame = CGRectMake(imageView.frame.origin.x, 55, btnW, btnH);
        }];
        [self.notPlay setBackgroundImage:[UIImage imageNamed:@"bt_green_bg"] forState:UIControlStateNormal];
        self.notPlay.userInteractionEnabled = YES;
        
        [self.reelect setBackgroundImage:[UIImage imageNamed:@"bt_green_bg"] forState:UIControlStateNormal];
        self.reelect.userInteractionEnabled = YES;
        
        [self.hintBtn setBackgroundImage:[UIImage imageNamed:@"bt_green_bg"] forState:UIControlStateNormal];
        self.hintBtn.userInteractionEnabled = YES;
        
        [self.playHand setBackgroundImage:[UIImage imageNamed:@"bt_orange_bg"] forState:UIControlStateNormal];
        self.playHand.userInteractionEnabled = YES;
    }
}


//协议处理多个手势之间的互斥，返回yes 可以同时使用两个手势
#pragma mark UIgesture delegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


-(void)addSelectionOperationButton{
    UIButton *notPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    [notPlay setBackgroundImage:[UIImage imageNamed:@"bt_gray_bg"] forState:UIControlStateNormal];
    [notPlay setImage:[UIImage imageNamed:@"gray_pass_card"] forState:UIControlStateNormal];
    [notPlay addTarget:self action:@selector(notPlayClick:) forControlEvents:UIControlEventTouchUpInside];
    self.notPlay = notPlay;
    notPlay.userInteractionEnabled = NO;
    [self addSubview:notPlay];
    
    UIButton *reelect = [UIButton buttonWithType:UIButtonTypeCustom];
    [reelect setBackgroundImage:[UIImage imageNamed:@"bt_gray_bg"] forState:UIControlStateNormal];
    [reelect setImage:[UIImage imageNamed:@"gray_reset_card"] forState:UIControlStateNormal];
    [reelect addTarget:self action:@selector(reelectClick:) forControlEvents:UIControlEventTouchUpInside];
    self.reelect = reelect;
    reelect.userInteractionEnabled = NO;
    [self addSubview:reelect];
    
    UIButton *hintBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [hintBtn setBackgroundImage:[UIImage imageNamed:@"bt_gray_bg"] forState:UIControlStateNormal];
    [hintBtn setImage:[UIImage imageNamed:@"gray_prompt_card"] forState:UIControlStateNormal];
    [hintBtn addTarget:self action:@selector(hintBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.hintBtn = hintBtn;
    hintBtn.userInteractionEnabled = NO;
    [self addSubview:hintBtn];
    
    UIButton *playHand = [UIButton buttonWithType:UIButtonTypeCustom];
    [playHand setBackgroundImage:[UIImage imageNamed:@"bt_gray_bg"] forState:UIControlStateNormal];
    [playHand setImage:[UIImage imageNamed:@"gray_out_card"] forState:UIControlStateNormal];
    [playHand addTarget:self action:@selector(playHandClick:) forControlEvents:UIControlEventTouchUpInside];
    self.playHand = playHand;
    playHand.userInteractionEnabled = NO;
    [self addSubview:playHand];
    
    [reelect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_centerX).offset(-10);
        make.top.equalTo(self);
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(45);
    }];
    
    [notPlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(reelect.mas_leading).offset(-20);
        make.top.equalTo(self);
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(45);
    }];
    
    [hintBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_centerX).offset(10);
        make.top.equalTo(self);
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(45);
    }];
    
    [playHand mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(hintBtn.mas_trailing).offset(20);
        make.top.equalTo(self);
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(45);
    }];

}

//不出
-(void)notPlayClick:(UIButton *)sender{
 
    [self setUpBrandRaisedBackSitu];
    self.notPlay.hidden = YES;
    self.reelect.hidden = YES;
    self.playHand.hidden = YES;
    self.hintBtn.hidden = YES;
}
//重选
-(void)reelectClick:(UIButton *)sender{
    [self setUpBrandRaisedBackSitu];
}
//提示
-(void)hintBtnClick:(UIButton *)sender{
    
}
//出牌
-(void)playHandClick:(UIButton *)sender{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[UIImageView class]]) {
            UIImageView * imageView = obj;
            [imageView removeFromSuperview];
            if (imageView.frame.origin.y == 55) {
                [self.cardNumer removeObject:@(imageView.tag)];
            }
        }
    }];
    
    [self setUpTheImageView];
}


-(void)setUpBrandRaisedBackSitu{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[UIImageView class]]) {
            UIImageView * imageView = obj;
            
            if (imageView.frame.origin.y == 55) {
                [UIView animateWithDuration:0.15 animations:^{
                    imageView.frame = CGRectMake(imageView.frame.origin.x, 70, btnW, btnH);
                }];
                
                [self.reelect setBackgroundImage:[UIImage imageNamed:@"bt_gray_bg"] forState:UIControlStateNormal];
                self.reelect.userInteractionEnabled = NO;
                
                [self.playHand setBackgroundImage:[UIImage imageNamed:@"bt_gray_bg"] forState:UIControlStateNormal];
                self.playHand.userInteractionEnabled = NO;
                
            }
        }
    }];
}

@end
