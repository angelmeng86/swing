/**
 *  \file		SimpleLogger.h
 *  \brief		SimpleLogger is used to logger information into console easily
 *  \author		AnkyHe ankyhe@gmail.com http://ankyhe.javaeye.com/
 *  \version    1.0
 *  \date       2009/03/31
 *  \license    You are authorized to EMPLOY/REVISED/REPUBLISH this source code both in commericial
 *              or free products
 */

#import <Foundation/Foundation.h>

//#define MAPPLE_DEBUG

//#define UPLOAD_DEBUG

#ifndef __SELF_DEFING_CLOSELOGGER__

#define LOG(level, format, ...) [[SimpleLogger getLogger] log:[NSString stringWithFormat:(format), ##__VA_ARGS__] \
                                                    withLevel:level \
													   inFile:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
													   inLine:__LINE__]
#define ENTER(format, ...) [[SimpleLogger getLogger] enter:[NSString stringWithFormat:(format), ##__VA_ARGS__] \
                                                    inFile:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                    inLine:__LINE__]
#define RETURN(returnValue, format, ...) [[SimpleLogger getLogger] retrn:[NSString stringWithFormat:(format), ##__VA_ARGS__] \
                                                                  inFile:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
													              inLine:__LINE__]; return (returnValue)
#define LOG_I(format, ...) [[SimpleLogger getLogger] info:[NSString stringWithFormat:(format), ##__VA_ARGS__] \
												  inFile:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                  inLine:__LINE__]
#define LOG_D(format, ...) [[SimpleLogger getLogger] debug:[NSString stringWithFormat:(format), ##__VA_ARGS__] \
                                                    inFile:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                    inLine:__LINE__]
#define LOG_W(format, ...) [[SimpleLogger getLogger] warn:[NSString stringWithFormat:(format), ##__VA_ARGS__] \
                                                  inFile:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                  inLine:__LINE__]
#define LOG_E(format, ...) [[SimpleLogger getLogger] error:[NSString stringWithFormat:(format), ##__VA_ARGS__] \
                                                    inFile:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                    inLine:__LINE__]

#define LOG_BEG(format, ...) [[SimpleLogger getLogger] begin:[NSString stringWithFormat:(format), ##__VA_ARGS__] \
inFile:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
inLine:__LINE__]

#define LOG_END(format, ...) [[SimpleLogger getLogger] end:[NSString stringWithFormat:(format), ##__VA_ARGS__] \
inFile:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
inLine:__LINE__]

#else

#define LOG(level, format, ...)
#define ENTER(format, ...)
#define RETURN(format, ...)
#define LOG_I(format, ...)
#define LOG_D(format, ...) 
#define LOG_W(format, ...) 
#define LOG_E(format, ...)

#define LOG_BEG(format, ...)
#define LOG_END(format, ...)

#endif

typedef enum {
	SLL_TINY    = 10,
	SLL_DETAIL  = 20,
	SLL_ENTER   = 30,
	SLL_RETURN  = 31,
    SLL_BEGIN   = 32,
    SLL_END     = 33,
	SLL_INFO    = 40,
	SLL_DEBUG   = 50,
	SLL_WARNING = 60,
	SLL_ERROR   = 70,
	SLL_FATAL   = 80
}SimpleLoggerLevel;

typedef enum {
	SLLS_ALL = 0, // should be smaller than all SimpleLoggerLevel
	SLLS_MAJOR = 21, // should be larger than SLL_DETAIL
	SLLS_MEDIUM = 35, // should be larger than SLL_RETURN
	SLLS_MINOR = 55, // should be larger than SLL_DEBUG
	SLLS_NONE = 1000 // should be larger than all
}SimpleLoggerLevelSetting;

@interface SimpleLogger : NSObject {
	SimpleLoggerLevelSetting logLevelSetting;
}

@property (nonatomic, assign) SimpleLoggerLevelSetting logLevelSetting;
#ifdef UPLOAD_DEBUG
@property (nonatomic, strong) NSMutableString* logCache;
#endif
- (id)initWithLogLevel:(SimpleLoggerLevelSetting)levelSetting;
- (void)log:(NSString *)msg 
  withLevel:(SimpleLoggerLevel)level
	 inFile:(NSString *)fileName 
     inLine:(int)lineNr;

- (void)begin:(NSString *)msg
       inFile:(NSString *)fileName
       inLine:(int)lineNr;
- (void)end:(NSString *)msg
       inFile:(NSString *)fileName
       inLine:(int)lineNr;
- (void)enter:(NSString *)msg 
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr;
- (void)retrn:(NSString *)msg 
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr;
- (void)info:(NSString *)msg 
	  inFile:(NSString *)fileName 
	  inLine:(int)lineNr;
- (void)debug:(NSString *)msg 
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr;
- (void)warn:(NSString *)msg 
	  inFile:(NSString *)fileName 
	  inLine:(int)lineNr;
- (void)error:(NSString *)msg 
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr;

+ (SimpleLogger *)getLogger;
+ (NSString *)levelName:(SimpleLoggerLevel)level;

@end
