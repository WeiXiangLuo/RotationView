//
//  RotationView.h
//  RotationView
//
//  Created by lwx on 16/10/27.
//  Copyright © 2016年 lwx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RotationView;

typedef void(^RotationViewHandle)(RotationView *rotationView);
@interface RotationView : UIView


@property (nonatomic, copy) NSString *imageName;//图片名字



@property (nonatomic, assign) CGFloat angle;//移动的角度



/**
 *  事件响应回调方法
 *
 *  @param handle block回调
 */
- (void)rotationViewHandle:(RotationViewHandle)handle;


@end
