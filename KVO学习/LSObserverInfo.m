//
//  LSObserverInfo.m
//  KVO学习
//
//  Created by 小度－李山 on 16/9/12.
//  Copyright © 2016年 Baidu_video. All rights reserved.
//

#import "LSObserverInfo.h"

@implementation LSObserverInfo
- (instancetype) initWithObserver:(id)observer key:(NSString *)key callBack:(LSKVOCallBack)callBackBlock
{
    self = [super init];
    if (self) {
        self.observer = observer;
        self.key = key;
        self.callBackBlock = callBackBlock;
    }
    return self;
}
@end
