//
//  NSObject+ls_kvo.m
//  KVO学习
//
//  Created by 小度－李山 on 16/9/12.
//  Copyright © 2016年 Baidu_video. All rights reserved.
//

#import "NSObject+ls_kvo.h"
#import <objc/objc-runtime.h>
#import <objc/message.h>
#define LSKVOClassPrefix @"LSKVO"
#define LSAssociateArrayKey @"LSAssociateArrayKey"
@implementation NSObject (ls_kvo)

- (void) ls_addObserver:(id)observer key:(NSString *)key callBack:(LSKVOCallBack)callBackBlcok
{
    assert(observer);
    assert(key);
    assert(callBackBlcok);
    //1,检查对象的类有没有相应的setter方法，如果没有抛出异常
    SEL setterSelector = NSSelectorFromString([self setterForGetter:key]);
    
    Method setterMethod = class_getInstanceMethod([self class], setterSelector);
    if (!setterMethod) {
        assert(@"can not find the key Conferrence method!");
    }
    //2,检查对象isa指向的类是不是一个kvo类，如果不是，新建一个继承原来类的子类，并把isa指向这个新建的子类
    Class clazz = object_getClass(self);
    NSString * className = NSStringFromClass([self class]);
    if (![className hasPrefix:LSKVOClassPrefix]) {
        clazz = [self ls_KVOClassWithOriginalClassName:className];
        object_setClass(self, clazz);
    }
    //3，为kvo class添加setter方法的实现
    const char * types = method_getTypeEncoding(setterMethod);
    class_addMethod(clazz, setterSelector, (IMP)ls_setter, types);
    
    //4,添加观察者到观察者列表
    //4.1 创建观察者信息
    LSObserverInfo * observerInfo = [[LSObserverInfo alloc] initWithObserver:self key:key callBack:callBackBlcok];
    //4.2 关联对象（获取所有监听者的数组）
    NSMutableArray * observers = objc_getAssociatedObject(self, LSAssociateArrayKey);
    if (!observers) {
        observers =  [NSMutableArray array];
        objc_setAssociatedObject(self, LSAssociateArrayKey, observers, OBJC_ASSOCIATION_RETAIN);
    }
    [observers addObject:observerInfo];
}
- (void) ls_removeObserverForKey:(NSString *)key
{
    NSMutableArray * observerInfoArray = objc_getAssociatedObject(self, LSAssociateArrayKey);
    if (!observerInfoArray) {
        return;
    }
    for (LSObserverInfo * observer in observerInfoArray) {
        if ([observer.key isEqualToString:key]) {
            [observerInfoArray removeObject:observer];
            break;
        }
    }
}

static void ls_setter(id self,SEL _cmd,id newValue)
{
    NSString * setterName = NSStringFromSelector(_cmd);
    NSString * getterName = [self getterForSetter:setterName];
    if (!getterName) {
        assert(@"kvo error:can not find the method");
    }
    //获取旧值
    id oldValue = [self valueForKey:getterName];
    //调用原类的setter方法
    struct objc_super superClazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
        /*
         注意：[self class] 和 object_getClass(self)是有区别的：
         object_getClass(obj)，object所属的类有可能是一个类簇，自动返回需要的类，属于抽象工厂的类。
        */
    };
    //这里需要做一个类型强转,否则会报too many argument
    ((void(*)(void *,SEL,id))objc_msgSendSuper)(&superClazz,_cmd,newValue);
    //找出观察者数组，调用对应对象的callBack
    NSMutableArray * observersArray = objc_getAssociatedObject(self, LSAssociateArrayKey);
    
    //遍历数组
    for (LSObserverInfo * observerInfo in observersArray) {
        if ([observerInfo.key isEqualToString:getterName]) {
            //gcd 异步调用callBack
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                observerInfo.callBackBlock(observerInfo.observer,getterName,oldValue,newValue);
            });
        }
    }
    
}
Class ls_class(id self, SEL cmd)
{
    Class clazz = object_getClass(self); // kvo_class
    Class superClazz = class_getSuperclass(clazz); // origin_class
    return superClazz; // origin_class
}
- (Class) ls_KVOClassWithOriginalClassName:(NSString *)className
{
    NSString * kvoClassName = [LSKVOClassPrefix stringByAppendingString:className];
    Class kvoClass = NSClassFromString(kvoClassName);
    if (kvoClass) {
        return kvoClass;
    }
    //如果kvo class不存在，则创建这个类
    Class originClass = object_getClass(self);
    kvoClass = objc_allocateClassPair(originClass, kvoClassName.UTF8String,0);
    //修改kvo class的方法实现，学习Apple的做法，隐瞒这个kvo_class
    Method clazzMethod = class_getInstanceMethod(originClass, @selector(class));
    const char *types = method_getTypeEncoding(clazzMethod);
    
    class_addMethod(kvoClass, @selector(class),(IMP)ls_class, types);
    
    //注册kvoclass
    objc_registerClassPair(kvoClass);
    return kvoClass;
    
}
- (NSString *)setterForGetter:(NSString *)key
{
    //name ->Name ->setName
    //1,首字母转换成大写
    unichar c = [key characterAtIndex:0];
   
    //2，添加set前缀
    NSString * str = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"%c",c-32]];
    /*
     疑问：如果传值的人不按照命名规范来的话，会不会出错？
     */
    
    NSString * setter = [NSString stringWithFormat:@"set%@:",str];
    
    return setter;

}
- (NSString *)getterForSetter:(NSString *)key
{
    //setName->Name->name
    //1.去掉set
    NSRange range = [key rangeOfString:@"set"];
    NSString *subStr1 = [key substringFromIndex:range.location + range.length];
    
    //2,首字母换成大写
    unichar c = [subStr1 characterAtIndex:0];
    NSString * subStr2 = [subStr1 stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"%c",c+32]];
    
    //3，去掉最后的
    NSRange range2 = [subStr2 rangeOfString:@":"];
    NSString * getter = [subStr2 substringToIndex:range2.location];
    return getter;
}



@end
