//
//  SYTimer.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/30.
//

#import "SYTimer.h"
#import "LogHeader.h"

#pragma mark - Task

@interface SYTask()

@property(nonatomic, copy)NSString                                  *name;
@property(nonatomic, assign)CGFloat                                 interval;
@property(nonatomic, assign)id                                      data;
@property(nonatomic, assign)NSInteger                               repeatTimes;
@property(nonatomic, assign, setter=setFinished:)BOOL               finished;
@property(nonatomic, assign, setter=setIsPaused:)BOOL               isPaused;
@property(nonatomic, weak)id                                        <SYTimerDelegate>delegate;
@property(nonatomic, copy)void                                      (^fireClosure)(NSString *name, id data);
@property(nonatomic, copy)void                                      (^finishedClosure)(NSString *name);
@property(nonatomic, assign)SYTaskType                              type;

@end

@implementation SYTask
    
- (instancetype)initWithName: (NSString *)name interval: (CGFloat)interval repeatTimes: (NSInteger)repeatTimes data: (id)data  delegate: (id <SYTimerDelegate>)delegate type: (SYTaskType)type fire: (void(^)(NSString *taskName, id data))fire finished: (void(^)(NSString *taskName))finished {
    self = [super init];
    if (self) {
        self.name = name;
        self.repeatTimes = repeatTimes;
        self.interval = interval;
        self.data = data;
        self.delegate = delegate;
        self.fireClosure = fire;
        self.finishedClosure = finished;
        self.type = type;
        self.finished = false;
        self.isPaused = false;
    }
    return self;
}

- (instancetype)initWithName: (NSString *)name interval: (CGFloat)interval fire: (void(^)(NSString *taskName, id data))fire {
    self = [super init];
    if (self) {
        self.name = name;
        self.repeatTimes = 0;
        self.interval = interval;
        self.data = nil;
        self.delegate = nil;
        self.type = SYTaskTypeTimer;
        self.fireClosure = fire;
        self.finished = false;
        self.isPaused = false;
    }
    return  self;
}

- (instancetype)initWithName: (NSString *)name interval: (CGFloat)interval delegate: (id <SYTimerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.name = name;
        self.repeatTimes = 0;
        self.interval = interval;
        self.data = nil;
        self.delegate = delegate;
        self.type = SYTaskTypeTimer;
        self.finished = false;
        self.isPaused = false;
    }
    return  self;
}

- (void)fire {
    if ([self.delegate respondsToSelector:@selector(fireTaskName:any:)]) {
        [self.delegate fireTaskName: self.name any: self.data];
    }
    if (self.fireClosure) {
        self.fireClosure(self.name, self.data);
    }
}

- (void)finish{
    self.finished = true;
    self.isPaused = true;
    if ([self.delegate respondsToSelector:@selector(finishedTaskName:)]) {
        [self.delegate finishedTaskName:self.name];
    }
}

- (void)dealloc
{
    Log(@"TFTask deinit");
}

@end

#pragma mark - TFTimerTask

@interface SYTimerTask()

@property(nonatomic, strong)SYTask                  *task;
@property(nonatomic, assign)CGFloat                 offset;
@property(nonatomic, assign)NSInteger               timesLeft;
@property(nonatomic, assign)BOOL                    pause;

@end
@implementation SYTimerTask

- (instancetype)initWithTask: (SYTask *)task offset: (CGFloat)offset {
    self = [super init];
    if (self) {
        self.pause = false;
        self.task = task;
        self.offset = offset;
        self.timesLeft = task.repeatTimes;
    }
    return self;
}


@end

#pragma mark - TFTimerTask

@interface SYTimer()

/// 队列
@property(nonatomic, strong)NSMutableArray                      <SYTimerTask *>*queue;

@property(nonatomic, strong)dispatch_source_t                   timer;
@property(nonatomic, assign)CGFloat                             interval;
@property(nonatomic, assign)CGFloat                             count;
@property(nonatomic, assign)BOOL                                isRunning;
@property(nonatomic, strong)CADisplayLink                       *displayLink;

@end
@implementation SYTimer

static SYTimer *_timer = nil;

+(instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _timer = [[super allocWithZone:NULL]init];
    });
    return _timer;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [SYTimer shared];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [SYTimer shared];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.queue = [[NSMutableArray alloc]init];
        self.interval = 4;
        self.count = 20;
        self.isRunning = false;
        [self createTimer];
        [self createDisplayLink];
    }
    return self;
}

- (void)createTimer {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t startTime = dispatch_walltime(NULL, 0);
    uint64_t interval = self.interval * NSEC_PER_MSEC;
     //2设置定时器的相关参数:开始时间,间隔时间,精准度等
    dispatch_source_set_timer( self.timer, startTime, interval, 0 * NSEC_PER_MSEC);
    dispatch_source_set_event_handler(self.timer, ^{
        [self onTiemer];
    });
    
}

- (void)createDisplayLink {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
    self.displayLink.paused = true;
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
}

- (void)onTiemer {
    self.count = self.count + 1;
    for (SYTimerTask *timerTask in self.queue) {
        SYTask *task = timerTask.task;
        NSInteger taskInterval = task.interval * 1000 / self.interval;
        CGFloat totalInterval = self.count - timerTask.offset;
        NSInteger a = totalInterval * 1000000;
        NSInteger b = taskInterval * 1000000;
        if (b != 0) {
            NSInteger z = a % b;
            NSInteger mod = taskInterval == 0 ? 0 : z / 1000000;
            if (mod == 0) {
                if (timerTask.pause == false && timerTask.task.finished == false) {
                    timerTask.offset = 0;
                    if (task.repeatTimes > 0) {
                        timerTask.timesLeft--;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [task fire];
                    });
                }
                if (task.repeatTimes > 0 && timerTask.timesLeft <= 0 && timerTask.task.finished == false) {
                    timerTask.pause = true;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [task finish];
                    });
                    [self checkQueue];
                }
            }
        }
    }
    if (self.count >= CGFLOAT_MAX - 10) {
        self.count = 0;
    }
}

- (void)onDisplayLink: (CADisplayLink *)displayLink {
    [self onTiemer];
}

- (void)checkQueue {
    BOOL stillNeedWork = false;
    BOOL hasTimerType = false;
    BOOL hasDisplayLinkType = false;
    for (SYTimerTask *timerTask in self.queue) {
        if (timerTask.pause == false) {
            stillNeedWork = true;
        }
        if (timerTask.task.type == SYTaskTypeCADisplayLink) {
            hasDisplayLinkType = true;
        }
        if (timerTask.task.type == SYTaskTypeTimer) {
            hasTimerType = true;
        }
    }
    if (stillNeedWork == false) {
        Log(@"Timer: no more work to do, so suspend");
        if (!hasTimerType) {
            [self suspend];
        }
        if (!hasDisplayLinkType) {
            [self pauseDisplayLink];
        }
    }else {
        if (!self.isRunning) {
            self.isRunning = true;
            if (hasTimerType) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    dispatch_resume(self.timer);
                });
            }
            if (hasDisplayLinkType) {
                [self resumeDisplayLink];
            }
        }
    }
}

- (void)resumeDisplayLink {
    self.displayLink.paused = false;
}

- (void)pauseDisplayLink {
    self.displayLink.paused = true;
}


#pragma mark - 公开方法
/// 将任务添加到队列
- (void)addToQueueTask: (SYTask *)task {
    NSInteger index = [self firstIndex:task.name];
    if (index != -1 && index >= 0) {
        [self.queue removeObjectAtIndex:index];
    }
    SYTimerTask *timerTask = [[SYTimerTask alloc]initWithTask:task offset:self.count];
    [self.queue addObject:timerTask];
    if (self.isRunning == false) {
        [self resume];
    }
}

/// 通过name获取该任务， 如果不存在则返回nil
- (SYTask *)getFromQueueName: (NSString *)name {
    NSInteger index = [self firstIndex:name];
    if (index != -1 && index >= 0) {
        return self.queue[index].task;
    }
    return nil;
}

/// 通过name查询队列中是否存在该任务
- (BOOL)existFromQueueName: (NSString *)name {
    NSInteger index = [self firstIndex:name];
    if (index != -1 && index >= 0) {
        return true;
    }
    return false;
}

/// 从队列删除
- (void)removeFromQueueName: (NSString *)name {
    NSInteger index = [self firstIndex:name];
    if (index != -1 && index >= 0) {
        [self.queue removeObjectAtIndex:index];
        [self checkQueue];
    }
}

/// 暂停计时
- (void)pauseTaskWithName: (NSString *)name {
    for (SYTimerTask *timerTask in self.queue) {
        if (timerTask.task.name == name) {
            if (timerTask.pause == false && timerTask.task.isPaused == false) {
                timerTask.pause = true;
                timerTask.task.isPaused = true;
                [self checkQueue];
            }
        }
    }
}

/// 开始计时
- (void)restartTaskWithName: (NSString *)name {
    for (SYTimerTask *timerTask in self.queue) {
        if (timerTask.task.name == name) {
            /// 开始计时吧count = 0; 否则依旧保留上次暂停之前的记述，导致可能出现快速执行两次
            self.count = 0;
            BOOL paused = timerTask.task.isPaused;
            if (paused) {
                timerTask.offset = self.count;
            }
            timerTask.pause = false;
            timerTask.task.isPaused = false;
            timerTask.task.finished = false;
            return;;
        }
    }
    if (self.isRunning == false) {
        [self checkQueue];
    }
}

/// 重制定时器
- (void)resetTaskWithName: (NSString *)name {
    for (SYTimerTask *timerTask in self.queue) {
        if (timerTask.task.name == name) {
            timerTask.timesLeft = timerTask.task.repeatTimes;
            timerTask.offset = 0;
            return;
        }
    }
}

/// 重制并且开始计时
- (void)resetAndStartTaskWithName: (NSString *)name {
    for (SYTimerTask *timerTask in self.queue) {
        if (timerTask.task.name == name) {
            timerTask.timesLeft = timerTask.task.repeatTimes;
            timerTask.offset = 0;
            timerTask.pause = false;
            timerTask.task.isPaused = false;
            timerTask.task.finished = false;
            return;
        }
    }
    if (self.isRunning == false) {
        [self checkQueue];
    }
}

- (void)suspend {
    if (self.isRunning) {
        self.count = 0;
        self.isRunning = false;
        Log(@"ALTimer suspended");
        dispatch_suspend(self.timer);
    }
}

- (void)resume {
    [self checkQueue];
}

/// 防抖
- (void)debounceAction: (void(^)(void))action {
    NSString *debounceTaskName = @"debounce-key-create-automatically";
    [[SYTimer shared]removeFromQueueName:debounceTaskName];
    SYTask *debounceTask = [[SYTask alloc]initWithName:debounceTaskName interval:0.2 fire:^(NSString * _Nonnull taskName, id  _Nonnull data) {
        [[SYTimer shared]removeFromQueueName:debounceTaskName];
        action();
    }];
    [[SYTimer shared]addToQueueTask:debounceTask];
}

- (NSInteger)firstIndex: (NSString *)name {
    NSInteger index = -1;
    for (int i =0; i < self.queue.count; i++) {
        if (self.queue[i].task.name == name) {
            index = i;
        }
    }
    return index;
}

- (void)dealloc
{
    dispatch_source_cancel(self.timer);
    self.timer = nil;
    Log(@"%@ deinit", self.class);
}

@end
