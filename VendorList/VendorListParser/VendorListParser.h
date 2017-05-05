//
//  VendorListParser.h
//  VendorList
//
//  Created by Virupaksh Futane on 12/22/15.
//  Copyright © 2015 Saltmines-Mac2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vendor.h"
#import "JSONKit.h"

typedef void (^onSuccessBlock)(NSMutableArray *vendorsList);
typedef void (^onFailureBlock)(NSString *errorMessage);


@interface VendorListParser : NSObject 

@property (nonatomic, copy) onSuccessBlock successBlock;
@property (nonatomic, copy) onFailureBlock failureBlock;


#pragma mark - Get vendors list
- (void)getVendorsList:(onSuccessBlock)iSuccessBlock withFailureBlock:(onFailureBlock)iFailureBlock;

@end
