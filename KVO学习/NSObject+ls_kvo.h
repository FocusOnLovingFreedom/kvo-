//
//  NSObject+ls_kvo.h
//  KVO学习
//
//  Created by 小度－李山 on 16/9/12.
//  Copyright © 2016年 Baidu_video. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSObserverInfo.h"

@interface NSObject (ls_kvo)

- (void) ls_addObserver:(id)observer key:(NSString *)key callBack:(LSKVOCallBack)callBackBlcok;

- (void) ls_removeObserverForKey:(NSString *)key;

@end
