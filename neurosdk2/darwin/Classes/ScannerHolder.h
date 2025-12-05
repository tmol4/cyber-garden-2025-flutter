#ifndef ScannerHolder_h
#define ScannerHolder_h

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#import "neurosdkOSX.h"
#else
#import <Flutter/Flutter.h>
#import <flutter_neurosdk2_ios/neurosdk.h>
#endif

#import "pigeon_messages.g.h"
#import "EventHolder.h"

@interface ScannerHolder : NSObject

- (nonnull instancetype)init:(EventHolder* _Nonnull) eventHolder;

- (void)createScannerFilters:(NSArray<NSNumber *> * _Nullable)filters completion:(void (^ _Nonnull)(NSString *_Nullable, FlutterError *_Nullable))completion;
- (void)startScanGuid:(NSString * _Nonnull)guid completion:(void (^ _Nonnull)(FlutterError *_Nullable))completion;
- (void)stopScanGuid:(NSString * _Nonnull)guid completion:(void (^ _Nonnull)(FlutterError *_Nullable))completion;
- (void)closeScannerGuid:(NSString * _Nonnull)guid completion:(void (^ _Nonnull)(FlutterError *_Nullable))completion;

- (NTScanner*_Nullable) getScanner:(NSString*_Nonnull)guid;

/// @return `nil` only when `error != nil`.
- (nullable NSArray<PGNFSensorInfo *> *)getSensorsGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
@end

#endif /* ScannerHolder_h */
