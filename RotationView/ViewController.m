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

#define BallRevolution 50 //小球半径

#define BallDiameter BallRevolution * 2 //小球直径

#define BallRotation ((kMainW * 970.0 / 1080) - BallRevolution) //球公转半径

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI) //角度化为弧度


@interface ViewController () {
    
    
    CGPoint _beginPoint;//触摸手势的开始点
    
    CGPoint _center;

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
                [self moveTheBall:angle * -1];
            }else {
                //顺时针转动
                [self moveTheBall:angle * 1];
            }
            
            
        }else{//在中心点上方时
            
            angle = [self angleWithPoint:_beginPoint anotherPoint:currentPoint];
            
            if (offsize.height - offsize.width > 0) {
                [self moveTheBall:angle * -1];
            }else {
                [self moveTheBall:angle * 1];
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
- (void)moveTheBall:(CGFloat)angle {
    
    for (NSInteger i = 0; i < self.ballArray.count; i++) {
        
        RotationView *ball = self.ballArray[i];
        
        ball.angle += angle;
        
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
















@end
