//
//  RotationView.m
//  RotationView
//
//  Created by lwx on 16/10/27.
//  Copyright © 2016年 lwx. All rights reserved.
//

#import "RotationView.h"


@interface RotationView (){
    
    //背景图片
    UIImageView *_imageView;
    
    //初始大小
    CGSize      _myBounds;
    
}


@property (nonatomic, assign) float scale;

@property (nonatomic, copy) RotationViewHandle block;

@end

@implementation RotationView


#pragma mark - 初始化视图
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createView];
        
        _myBounds = frame.size;
        
        _scale = 1;
        
    }
    return self;
}


#pragma mark - 创建UI
- (void)createView {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
    _imageView = imageView;
    
    UITapGestureRecognizer *tag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTouch:)];
    [self addGestureRecognizer:tag];
    
}


/**
 *  手势响应回调
 *
 *  @param sender 手势对象
 */
- (void)singleTouch:(UITapGestureRecognizer *)sender {
    
    self.block(self);
    
}


#pragma mark - 重新布局
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect imageBounds = _imageView.bounds;
    imageBounds.size.width = _myBounds.width * _scale;
    imageBounds.size.height = _myBounds.height * _scale;
    
    _imageView.bounds = imageBounds;
    _imageView.image = [UIImage imageNamed:self.imageName];
}






#pragma mark - set方法
- (void)setScale:(float)scale {
    if (_scale != scale) {
        _scale = scale;
        
        [self setNeedsLayout];
        
    }
}


- (void)setImageName:(NSString *)imageName {
    
    if (_imageName != imageName) {
        _imageName = imageName;
        
        [self layoutSubviews];
    }
}


- (void)setAngle:(CGFloat)angle {
    if (_angle != angle) {
        _angle = angle;
        
        if (_angle > 360) {
            _angle -= 360;
        }
        
        if (_angle < 0) {
            _angle += 360;
        }
        
        //180 : 1;
        //0 : 0;
        //180 -> 360;变小
        //0 —>180;变大
        if (_angle <= 180) {
            
            self.scale = _angle / 180;
        }else{
            self.scale = (360 - _angle) / 180;
        }
        
        
    }
}


/**
 *  点击事件的响应方法
 *
 *  @param handle 传递进来的响应block块
 */
- (void)rotationViewHandle:(RotationViewHandle)handle {
    
    self.block = handle;
    
}







@end
