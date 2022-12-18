//
//  Entitlements.h
//  printents
//
//  Created by Serena on 18/12/2022
//
	

#ifndef Entitlements_h
#define Entitlements_h

// Reverse engineered from Apple's AppSandbox.framework
@interface AppSandboxEntitlements : NSObject
+ (AppSandboxEntitlements *)entitlementsForCodeAtURL:(NSURL *)appURL error:(NSError **)error;
- (NSDictionary *)allEntitlements;
@end

#endif /* Entitlements_h */
