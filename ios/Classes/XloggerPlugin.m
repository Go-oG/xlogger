#import <objc/runtime.h>
#import <objc/message.h>
#import "XloggerPlugin.h"
#import "Logan.h"

@implementation XloggerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_logan"
            binaryMessenger:[registrar messenger]];
  XloggerPlugin* instance = [[XloggerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
	SEL sel = NSSelectorFromString([call.method stringByAppendingString:@":result:"]);
	if(sel && [self respondsToSelector:sel]){
    ((void(*)(id,SEL,NSDictionary *,FlutterResult))objc_msgSend)(self,sel,call.arguments,result);
	//((void(*)(id,SEL,...))objc_msgSend)(self,sel,call.arguments,result);//SDK原始代码会报错
	}else{
		result(FlutterMethodNotImplemented);
	}
}

- (void)init:(NSDictionary *)args result:(FlutterResult)result{
	if(![args isKindOfClass:[NSDictionary class]]){
		result(@(NO));
		return;
	}
	NSString *key = args[@"aesKey"];
	NSString *iv = args[@"aesIv"];
	NSNumber *maxFileLen = args[@"maxFileLen"];
	if(key.length >0 && iv.length >0){
		loganInit([NSData dataWithBytes:key.UTF8String length:key.length],[NSData dataWithBytes:iv.UTF8String length:iv.length] , maxFileLen.integerValue);
		result(@(YES));
	}else{
		result(@(NO));
	}
}

- (void)log:(NSDictionary *)args result:(FlutterResult)result{
	if(![args isKindOfClass:[NSDictionary class]]){
		result(nil);
		return;
	}
	NSNumber *type = args[@"type"];
	NSString *log = args[@"log"];
	logan(type.integerValue, log);
	result(nil);
}

- (void)flush:(NSDictionary *)args result:(FlutterResult)result{
	loganFlush();
	result(nil);
}

- (void)getUploadPath:(NSDictionary *)args result:(FlutterResult)result{
	if(![args isKindOfClass:[NSDictionary class]]){
		result(@"");
		return;
	}
	NSString *date = args[@"date"];
	if(date.length >0){
		loganUploadFilePath(date, ^(NSString * _Nullable filePath) {
			result(filePath);
		});
	}else{
		result(@"");
	}
}

- (void)getAllLogs:(NSDictionary *)args result:(FlutterResult)result{
    NSDictionary *files= loganAllFilesInfo();
    if(files.count<=0){
        result([NSArray array]);
        return;
    }
    NSMutableArray<NSString *> *array = [NSMutableArray arrayWithCapacity:1];
    for (NSString *dateKey in files.allKeys) {
        loganUploadFilePath(dateKey,^(NSString * _Nullable filePath){
            [array addObject:filePath];
            //到了最后才回调
            if(array.count==files.count){
                NSArray<NSString *> *array2 = [ array copy];
                result(array2);
            }
        });
    }
}

- (void)upload:(NSDictionary *)args result:(FlutterResult)result{
	if(![args isKindOfClass:[NSDictionary class]]){
		result(@NO);
		return;
	}
	NSString *urlStr = args[@"serverUrl"];
	NSString *date = args[@"date"];
	NSString *appid = args[@"appId"];
	NSString *unionId = args[@"unionId"];
	NSString *deviceId = args[@"deviceId"];
	loganUpload(urlStr,date,appid,unionId,deviceId,^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error){
		if(error){
			result(@NO);
		}else{
			result(@YES);
		}
	});
}

- (void)cleanAllLogs:(NSArray *)param result:(FlutterResult)result{
	loganClearAllLogs();
	result(nil);
}

@end
