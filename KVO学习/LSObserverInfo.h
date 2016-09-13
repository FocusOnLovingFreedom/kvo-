//
//  LSObserverInfo.h
//  KVO学习
//
//  Created by 小度－李山 on 16/9/12.
//  Copyright © 2016年 Baidu_video. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LSKVOCallBack)(id observer,NSString * key,id oldValue, id newValue);

@interface LSObserverInfo : NSObject

/**
 *  观察者
 */
@property (nonatomic,weak) id observer;

/**
 *  监听属性
 */
@property (nonatomic,copy) NSString * key;

/**
 *  回调
 */
@property (nonatomic,copy) LSKVOCallBack callBackBlock;

- (instancetype) initWithObserver:(id)observer key:(NSString *)key callBack:(LSKVOCallBack)callBackBlock;

@end
