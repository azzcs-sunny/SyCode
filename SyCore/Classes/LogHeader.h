//
//  LogHeader.h
//  SunnyCore
//
//  Created by 肖志强 on 2021/3/9.
//

#ifndef LogHeader_h
#define LogHeader_h

#import <CocoaLumberjack/CocoaLumberjack.h>
#import "Log.h"
#import "Event.h"
#import "EventType.h"

#ifdef DEBUG
    static const int ddLogLevel = DDLogLevelVerbose;
#else
    static const int ddLogLevel = DDLogLevelVerbose;
#endif

#define Log(args ...) Log.verboseInfo(__FILE__, __LINE__, __FUNCTION__, args)

#endif /* LogHeader_h */
