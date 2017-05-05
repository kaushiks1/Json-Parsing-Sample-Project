//
//  Vendor.h
//  VendorList
//
//  Created by Virupaksh Futane on 12/22/15.
//  Copyright © 2015 Saltmines-Mac2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Vendor : NSObject 

@property (nonatomic, retain) NSString *vendorName;
@property (nonatomic, assign) int vendorID;
@property (nonatomic, retain) NSString *vendorDesc;
@property (nonatomic, retain) NSString *logo;
@property (nonatomic, retain) NSString *vendorContactDetails;
@property (nonatomic, assign) int pTaskID;
@property (nonatomic, assign) float price;
@property (nonatomic, retain) NSString *vendorLogo;

@end
