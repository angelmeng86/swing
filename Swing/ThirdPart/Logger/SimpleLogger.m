#import "SimpleLogger.h"
#import "GlobalCache.h"
//#import <AVOSCloud/AVOSCloud.h>

@implementation SimpleLogger

@synthesize logLevelSetting;

#pragma mark Class Method
+ (SimpleLogger *)getLogger
{
	static SimpleLogger *logger = nil;
	if ( logger == nil)
	{
		logger = [[SimpleLogger alloc]init];
	}
	return logger;
}

+ (NSString *)levelName:(SimpleLoggerLevel)level
{
	switch (level) {
		case SLL_TINY:    return @"TINY";break;
		case SLL_DETAIL:  return @"DETAIL";break;
		case SLL_ENTER:   return @"ENTER";break;
		case SLL_RETURN:  return @"RETURN";break;
        case SLL_BEGIN:   return @"BEGIN";break;
        case SLL_END:     return @"END";break;
		case SLL_INFO:    return @"INFO";break;
		case SLL_DEBUG:   return @"DEBUG";break;
		case SLL_WARNING: return @"WARN";break;
		case SLL_ERROR:   return @"ERROR";break;
		case SLL_FATAL:   return @"FATAL";break;
		default: return @"NOLEVE"; break;
	}
}

#pragma mark -
#pragma mark Method init

- (id)initWithLogLevel:(SimpleLoggerLevelSetting)levelSetting
{
	if (self = [super init])
	{
		self.logLevelSetting = levelSetting;
	}
	return self;
}

- (id)init
{
#ifdef MAPPLE_DEBUG
	return [self initWithLogLevel:SLLS_ALL];
#else
    return [self initWithLogLevel:SLLS_NONE];
#endif
}

#pragma mark -
#pragma mark Method
#ifdef UPLOAD_DEBUG
- (void)checkLogSize:(BOOL)upload
{
    if (!upload && self.logCache.length < 16 * 1024) {
        //日志如果需要上传或者长度超过16KB则进行上传，并停止记录
        return;
    }

    AVObject *logObject = [AVObject objectWithClassName:@"SwingLog"];
    if ([GlobalCache shareInstance].user.email) {
        [logObject setObject:[GlobalCache shareInstance].user.email forKey:@"userName"];
    }
    [logObject setObject:self.logCache forKey:@"log"];
    [logObject saveEventually];

//    if (upload) {
        self.logCache = nil;
//    }
//    else {
//        self.logCache = [NSMutableString stringWithCapacity:1024];
//    }
}
#endif
- (void)log:(NSString *)msg 
  withLevel:(SimpleLoggerLevel)level
	 inFile:(NSString *)fileName 
     inLine:(int)lineNr
{
#ifdef UPLOAD_DEBUG
    [self.logCache appendFormat:@"[%@]{%@:%d}[%@]%@\n", [NSDate date], fileName, lineNr,
     [SimpleLogger levelName:level], msg];
    [self checkLogSize:NO];
#endif
	if (level > logLevelSetting)
	{
		NSLog(@"{%@:%d}[%@]%@", fileName, lineNr,
			  [SimpleLogger levelName:level], msg);
	}
}

- (void)enter:(NSString *)msg
       inFile:(NSString *)fileName
       inLine:(int)lineNr
{
#ifdef UPLOAD_DEBUG
    self.logCache = nil;
#endif
    [self log:msg withLevel:SLL_ENTER inFile:fileName inLine:lineNr];
}

- (void)retrn:(NSString *)msg
       inFile:(NSString *)fileName
       inLine:(int)lineNr
{
    [self log:msg withLevel:SLL_RETURN inFile:fileName inLine:lineNr];
}

- (void)begin:(NSString *)msg
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr
{
#ifdef UPLOAD_DEBUG
    self.logCache = [NSMutableString stringWithCapacity:1024];
#endif
	[self log:msg withLevel:SLL_BEGIN inFile:fileName inLine:lineNr];
}

- (void)end:(NSString *)msg
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr
{
	[self log:msg withLevel:SLL_END inFile:fileName inLine:lineNr];
#ifdef UPLOAD_DEBUG
    [self checkLogSize:YES];
#endif
}

- (void)info:(NSString *)msg 
	  inFile:(NSString *)fileName 
	  inLine:(int)lineNr
{
	[self log:msg withLevel:SLL_INFO inFile:fileName inLine:lineNr];
}

- (void)debug:(NSString *)msg 
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr
{
	[self log:msg withLevel:SLL_DEBUG inFile:fileName inLine:lineNr];
	
}

- (void)warn:(NSString *)msg 
	  inFile:(NSString *)fileName 
	  inLine:(int)lineNr
{
	[self log:msg withLevel:SLL_WARNING inFile:fileName inLine:lineNr];
	
}

- (void)error:(NSString *)msg 
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr
{
	[self log:msg withLevel:SLL_ERROR inFile:fileName inLine:lineNr];
	
}

@end
