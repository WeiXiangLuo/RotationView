//
//  ViewController.m
//  RotationView
//
//  Created by lwx on 16/10/27.
//  Copyright © 2016年 lwx. All rights reserved.
//

#import "ViewController.h"
#import "RotationView.h"



#define kMainW [UIScreen mainScreen].bounds.size.width
#define kMainH [UIScreen mainScreen].bounds.size.height

#define BallRevolution 100 //小球半径

#define BallDiameter BallRevolution * 2 //小球直径

#define BallRotation ((kMainW * 970.0 / 1080) - BallRevolution) //球公转半径

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI) //角度化为弧度


@interface ViewController () {
    
    
    CGPoint _beginPoint;//触摸手势的开始点
    
    CGPoint _center;
    
    NSTimer *_timer;
    
    CGFloat _tempAngle;

}

@property (nonatomic, strong) NSMutableArray *ballArray;//用于存放小球的数组

@end

@implementation ViewController



#pragma mark - set方法 懒加载初始化数组
- (NSMutableArray *)ballArray {
    if (!_ballArray) {
        _ballArray = [NSMutableArray new];
    }
    
    return _ballArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _center = CGPointMake(kMainW, kMainH/2);
    
    /*********************创建视图*********************/
    [self createView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self.view addGestureRecognizer:pan];
    
}


/**
 *  内部方法：创建视图
 */
- (void)createView {
    
    /*********************背景图片**********************/
    UIImageView *bgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"大背景.png"]];
    bgImg.frame = self.view.frame;
    bgImg.userInteractionEnabled = YES;
    [self.view addSubview:bgImg];
    
    NSArray *imageArray = @[@"球-国际商旅",@"球-来华人士",@"球-投资移民",@"球-外派工作",@"球-出国留学"];
    /*********************旋转球**********************/
    //第一个小球在180°的位置
    for (NSInteger i = 0; i < 5; i++) {
        
        RotationView *ball = [[RotationView alloc] initWithFrame:CGRectMake(0, 0, BallDiameter, BallDiameter)];
        
        ball.tag = i;
        
        ball.angle = 180 + i * 72;
        
        float x = cos(DEGREES_TO_RADIANS(ball.angle)) * BallRotation;
        
        float y = sin(DEGREES_TO_RADIANS(ball.angle)) * BallRotation;
        
        NSLog(@"(%f,%f)",x,y);
        
        ball.center = CGPointMake(_center.x + x, _center.y + y);
        
        
        ball.imageName = imageArray[i];
        
        [bgImg addSubview:ball];
        
        [self.ballArray addObject:ball];
        
        
        //小球点击方法
        [ball rotationViewHandle:^(RotationView *rotationView) {
            NSLog(@"你点击了我：%@",rotationView.imageName);
        }];

    }
    
    
    
}



/**
 *  拖拽手势回调方法
 *
 *  @param pan 正在拖拽的UIPanGestureRecognizer对象
 */
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)pan {
 
    if (pan.state == UIGestureRecognizerStateBegan) {
        NSLog(@"%s : 触摸开始",__FUNCTION__);
        _beginPoint = [pan locationInView:self.view];
        
        
    }else if (pan.state == UIGestureRecognizerStateEnded){
        NSLog(@"%s : 触摸结束",__FUNCTION__);
        [self dragEnd];
        
    }else {
        
        //当前触摸点
        CGPoint currentPoint = [pan locationInView:self.view];
        
        //两个触摸点的偏移量 ，右下为正，左上为负
        CGSize offsize = CGSizeMake(currentPoint.x - _beginPoint.x, currentPoint.y - _beginPoint.y);
        

        CGFloat angle;
        
        //在中心点下方时
        if (currentPoint.y >self.view.center.y) {
            
            
            //计算移动的角度
            angle = [self angleWithPoint:_beginPoint anotherPoint:currentPoint];
            
            //判断是顺时针转动还是逆时针转动
            if (offsize.height + offsize.width > 0) {
                //逆时针转动
                [self moveTheBall:angle * -1 changSize:YES];
            }else {
                //顺时针转动
                [self moveTheBall:angle * 1 changSize:YES];
            }
            
            
        }else{//在中心点上方时
            
            angle = [self angleWithPoint:_beginPoint anotherPoint:currentPoint];
            
            if (offsize.height - offsize.width > 0) {
                [self moveTheBall:angle * -1 changSize:YES];
            }else {
                [self moveTheBall:angle * 1 changSize:YES];
            }
            
            
        }
        _beginPoint = currentPoint;
    }
    
    
}



/**
 *  内部方法：小球变化位置
 *
 *  @param angle 移动的距离
 */
- (void)moveTheBall:(CGFloat)angle changSize:(BOOL)change{
    
    for (NSInteger i = 0; i < self.ballArray.count; i++) {
        
        RotationView *ball = self.ballArray[i];
        
        
        if (change) {
            ball.angle += angle;
        }
        
        float x = cos(DEGREES_TO_RADIANS(ball.angle)) * BallRotation;
        
        float y = sin(DEGREES_TO_RADIANS(ball.angle)) * BallRotation;
        
        ball.center = CGPointMake(_center.x + x, _center.y + y);
        
        
    }
    
}





/**
 *  内部方法：用于计算三点之间形成的角度
 *
 *  @param pointA 开始点
 *  @param pointB 结束点
 *
 *  @return 角度
 */
- (CGFloat)angleWithPoint:(CGPoint)pointA anotherPoint:(CGPoint)pointB {
    

    CGFloat distanceB = [self distanceWithPoint:pointA anotherPoint:_center];
    CGFloat distanceC = [self distanceWithPoint:pointB anotherPoint:_center];
    
    CGFloat a = pointA.x - _center.x;
    CGFloat b = pointA.y - _center.y;
    CGFloat c = pointB.x - _center.x;
    CGFloat d = pointB.y - _center.y;

    CGFloat angle = (180/M_PI) * acosf(((a*c) + (b*d)) / (distanceB * distanceC));
    
    return angle;
    
}



/**
 *  内部方法：计算两点间距离公式
 *
 *  @param pointA 起始点
 *  @param pointB 终点
 *
 *  @return 两点间的距离
 */
- (CGFloat)distanceWithPoint:(CGPoint)pointA anotherPoint:(CGPoint)pointB {
    
    CGFloat deltaX = pointB.x - pointA.x;
    CGFloat deltaY = pointB.y - pointA.y;
    
    return sqrt(deltaX*deltaX + deltaY*deltaY);
}




#pragma mark - 触摸结束触发事件
- (void)dragEnd {
    
    RotationView *view = [self getNearestBall];
    
    //调用动画移动小球的方法
    [self animationBallMoveWithAngle:180 - view.angle andBall:view];


}




/**
 *  获得需要旋转的距离
 */
- (RotationView *)getNearestBall {
    
    __block CGFloat minDistance = MAXFLOAT;
    
    __block NSInteger index = 0;
    
    [self.ballArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(RotationView *rotation, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat signedDistance = rotation.angle - 180;
        
        CGFloat distance = fabs(signedDistance);
        
        if (minDistance > distance) {
            minDistance = distance;
            index = idx;
        }
        
    }];

    
    return self.ballArray[index];
    
}





/**
 *  内部方法：小球动画移动
 *
 *  @param angle 总共需要移动的距离
 */
- (void)animationBallMoveWithAngle:(CGFloat)angle andBall:(RotationView *)ball{
    
    _tempAngle = angle;
    
    NSLog(@"%f",angle);
    for (RotationView *view in self.ballArray) {
        
        
        /*****************路径动画*****************************/
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        animation.duration = 0.4;
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:_center radius:BallRotation startAngle:DEGREES_TO_RADIANS(view.angle) endAngle:DEGREES_TO_RADIANS(view.angle + angle) clockwise:angle > 0 ? YES : NO];
        
        animation.path = bezierPath.CGPath;
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [view.layer addAnimation:animation forKey:nil];
        
        /*****************放大缩小动画*****************************/
        CGFloat scale = 1;
//
//        if (ball.angle + angle <= 180) {
//            
//            scale  = (view.angle + angle) / 180;
//        }else{
//            scale  = (360 - view.angle + angle) / 180;
//        }
        
        if (ball.tag == view.tag) {
            scale = 1;
        }else if((ball.tag == view.tag + 1) || (ball.tag == view.tag - 1) || (ball.tag == view.tag - 3) || (ball.tag == view.tag + 3)) {
            
            scale = 0.6;
            
        }else{
            
            scale = 0.2;
        }
        
        

        
        
        CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"bounds"];
        basic.duration = 0.4;
        basic.removedOnCompletion = NO;
        basic.delegate = self;
        basic.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, scale * BallDiameter, scale * BallDiameter)];
        [view.imageView.layer addAnimation:basic forKey:@"bounds"];
        
        
        
//                CGFloat toValueScale = scale * BallDiameter / view.imageView.bounds.size.width;
//        CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
//        keyFrameAnimation.duration = 0.4;
//        //动画路径上的各值
//        keyFrameAnimation.values    = @[@1,@((toValueScale - 1) / 3 + 1),@((toValueScale - 1) / 3 * 2 + 1),@(toValueScale)];
//        
//        keyFrameAnimation.keyTimes  = @[@(0),@(0.3),@(0.7),@(1)];
        
//        [view.imageView.layer addAnimation:keyFrameAnimation forKey:nil];
        
//        view.angle += angle;
        
        
    }
    

    [self moveTheBall:angle changSize:NO];


    
 
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    for (RotationView *view in self.ballArray) {
        
        if ([view.imageView.layer animationForKey:@"bounds"] ) {
            
            NSLog(@"找到了");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                view.angle += _tempAngle;
            });
            break;
            
        }
        
        
    }
}











@end
