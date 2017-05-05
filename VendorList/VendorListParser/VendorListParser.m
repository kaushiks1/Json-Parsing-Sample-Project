//
//  VendorListParser.m
//  VendorList
//
//  Created by Virupaksh Futane on 12/22/15.
//  Copyright © 2015 Saltmines-Mac2. All rights reserved.
//

#import "VendorListParser.h"
#import "CustomHTTPRequest.h"

@implementation VendorListParser

- (void)getVendorsList:(onSuccessBlock)iSuccessBlock withFailureBlock:(onFailureBlock)iFailureBlock {
    
    self.successBlock = iSuccessBlock;
    self.failureBlock = iFailureBlock;
    
    NSURL *aUrl = [NSURL URLWithString:@"http://mymovecheck.azurewebsites.net/client/GetAllVendors"];
    NSMutableDictionary *aBodyDict = [[NSMutableDictionary alloc] init];
    [aBodyDict setValue:@"5E58C749-6670-48D1-BFE3-0AA139F7EB97" forKey:@"deviceId"];
    [aBodyDict setValue:@"8FHMWi7DWnF6vNj5dbGq9iS0ME91Bkgnwwnpx1n33ZBlca+V7xTxrwxGYOSsLmnA" forKey:@"accessToken"];
    [aBodyDict setValue:@"15" forKey:@"pTaskId"];
    [aBodyDict setValue:@"32615" forKey:@"moveTo"];
    [aBodyDict setValue:@"68959" forKey:@"moveFrom"];
    [aBodyDict setValue:@"1" forKey:@"categoryId"];
    
    
    CustomHTTPRequest *aHttpRequesr = [[CustomHTTPRequest alloc] initWithURL:aUrl body:aBodyDict timeoutInterval:60.0 method:HTTPRequestMethodPOST onSuccess:^(CustomHTTPRequest *request, id resultObject, NSHTTPURLResponse *response) {
        NSLog(@"resultObject : %@",resultObject);
        [self parseVendorListResponse:resultObject];
        
    } onFailure:^(CustomHTTPRequest *request, NSError *error) {
        NSLog(@"Failure Block = %@",request.responseObject);
        self.failureBlock(error.localizedDescription);

    } onCompletion:^(CustomHTTPRequest *request, BOOL didSucceed) {
        
    }];
    
    [aHttpRequesr sendRequest];
    //[customHTTPRequest release];
    aHttpRequesr = nil;
}

#pragma mark - Parse vendor list response
- (void)parseVendorListResponse:(id)iResponse {
    NSDictionary *aResultDict = [iResponse valueForKey:@"result"];
    int aHttpStatusCode = [([aResultDict valueForKey:@"httpstatus"] == [NSNull null] ? @"NA" : [aResultDict valueForKey:@"httpstatus"]) intValue];
    NSMutableArray *aVendorsList = [[NSMutableArray alloc] init];
    if (aHttpStatusCode == 200) {
        NSArray *aVendors = [aResultDict valueForKey:@"vendors"] == [NSNull null] ? @"NA" : [aResultDict valueForKey:@"vendors"];
        for(NSDictionary *aDict in aVendors){
            Vendor *aVendor = [[Vendor alloc] init];
           int aVendorPTaskID = [([aDict valueForKey:@"pTaskId"] == [NSNull null] ? @"NA" : [aDict valueForKey:@"pTaskId"]) intValue];
            aVendor.pTaskID = aVendorPTaskID;
            int aVendorID = [([aDict valueForKey:@"vendorId"] == [NSNull null] ? @"NA" : [aDict valueForKey:@"vendorId"]) intValue];
            aVendor.vendorID = aVendorID;
            aVendor.vendorName = [aDict valueForKey:@"vendorName"] == [NSNull null] ? @"NA" : [aDict valueForKey:@"vendorName"];
            aVendor.vendorDesc = [aDict valueForKey:@"description"] == [NSNull null] ? @"NA" : [aDict valueForKey:@"description"];
            aVendor.vendorContactDetails = [aDict valueForKey:@"phone"] == [NSNull null] ? @"NA" : [aDict valueForKey:@"phone"];
            aVendor.vendorLogo = [aDict valueForKey:@"logo"] == [NSNull null] ? @"NA" : [aDict valueForKey:@"logo"];
            aVendor.price = [([aDict valueForKey:@"price"] == [NSNull null] ? @"NA" : [aDict valueForKey:@"price"]) floatValue];
            [aVendorsList addObject:aVendor];
        }
    }
    self.successBlock(aVendorsList);
    
}

@end
