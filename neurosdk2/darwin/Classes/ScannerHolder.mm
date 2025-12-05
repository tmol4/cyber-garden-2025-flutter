#import <Foundation/Foundation.h>
#import "ScannerHolder.h"
#import "Constants.h"
#import "EventHolder.h"
#import "WrapperUtils.h"

@implementation ScannerHolder{
    NSMutableDictionary<NSString*, NTScanner*>* _scanners;
    EventHolder* _eventHolder;
}

- (nonnull instancetype)init:(EventHolder*) eventHolder{
    self = [super init];
    if (self) {
        _scanners = [NSMutableDictionary new];
        _eventHolder = eventHolder;
      }
    
    return self;
}

- (void)createScannerFilters:(NSArray<NSNumber *> *)filters completion:(void (^)(NSString *_Nullable, FlutterError *_Nullable))completion{
    if(filters == nil){
        completion(nil, [FlutterError errorWithCode:@"INVALID_ARGUMENT" message:@"Filters array is empty" details:nil]);
        return;
     }
     NSString *uuid = [[NSUUID UUID] UUIDString];
    
    // Convert filters
    NSMutableArray<NSNumber *> *convertedFilters = [filters mutableCopy];
    for (int i = 0; i < convertedFilters.count; i++) {
        PGNFSensorFamily filter = (PGNFSensorFamily)[convertedFilters[i] intValue];
        convertedFilters[i] = @([WrapperUtils NTSensorFamilyFromPGNF:filter]);
    }
    
     @try {
         NTScanner* scanner = [[NTScanner alloc] initWithSensorFamily:convertedFilters];
         __weak EventHolder* weakEventHolder = _eventHolder;
         [scanner setSensorsCallback:^(NSArray<NTSensorInfo*>* sensors){
             NSMutableArray<NSDictionary*>* sensorsArray = [[NSMutableArray alloc] initWithCapacity: [sensors count]];
             for (NTSensorInfo* info in sensors) {
                 [sensorsArray addObject:[WrapperUtils JsonSensorInfoFromNT:info]];
             }
             NSMutableDictionary* res = [NSMutableDictionary new];
             [res setObject:uuid forKey:GUID_ID];
             [res setObject:sensorsArray forKey:DATA_ID];
             
             if (weakEventHolder.scannerSensorsSink) {
                 weakEventHolder.scannerSensorsSink(res);
             }
         }];
         
         [_scanners setObject:scanner forKey:uuid];
         completion(uuid, nil);
     } @catch (NSException *exception) {
         completion(nil, [FlutterError errorWithCode:@"Error while scanner create:" message:exception.description details:nil]);
         return;
     }
}

- (void)startScanGuid:(NSString *)guid completion:(void (^)(FlutterError *_Nullable))completion{
    @try {
        NTScanner* scanner = [_scanners objectForKey:guid];
        if(scanner == nil) @throw [[NSException alloc] initWithName:@"NilScanner" reason:@"Scanner does not exist" userInfo:nil];
        [scanner startScan];
        completion(nil);
    } @catch (NSException *e) {
        completion([FlutterError errorWithCode:@"Error while starting scan:" message:e.description details:nil]);
    }
}

- (void)stopScanGuid:(NSString *)guid completion:(void (^)(FlutterError *_Nullable))completion{
    @try {
        NTScanner* scanner = [_scanners objectForKey:guid];
        if(scanner == nil) @throw [[NSException alloc] initWithName:@"NilScanner" reason:@"Scanner does not exist" userInfo:nil];
        [scanner stopScan];
        completion(nil);
    } @catch (NSException *e) {
        completion([FlutterError errorWithCode:@"Error while stopping scan:" message:e.description details:nil]);
    }
}

- (void)closeScannerGuid:(NSString *)guid completion:(void (^)(FlutterError *_Nullable))completion{
    @try {
        NTScanner* scanner = [_scanners objectForKey:guid];
        [scanner setSensorsCallback:nil];
        scanner = nil;
        [_scanners removeObjectForKey:guid];
        completion(nil);
     }
     @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        completion([FlutterError errorWithCode:@"Error while closing scan:" message:e.description details:nil]);
     }
}

- (NTScanner*_Nullable) getScanner:(NSString*_Nonnull)guid{
    return _scanners[guid];
}

- (nullable NSArray<PGNFSensorInfo *> *)getSensorsGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    @try {
        NTScanner* scanner = [_scanners objectForKey:guid];
        if(scanner != nil){
            NSMutableArray<PGNFSensorInfo*>* result = [NSMutableArray new];
            NSArray<NTSensorInfo *> * sensors = [scanner sensors];
                for (NTSensorInfo* info in sensors){
                    [result addObject:[WrapperUtils PGNFSensorInfoFromNT:info]];
                };
            return result;
        }else{
            @throw [[NSException alloc] initWithName:@"NilScanner" reason:@"Scanner does not exist" userInfo:nil];
        }
    } @catch (NSException *e) {
        *error = [FlutterError errorWithCode:@"Error while getting sensors:" message:e.description details:nil];
        return nil;
    }
}

@end
