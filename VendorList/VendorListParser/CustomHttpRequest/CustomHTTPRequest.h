//
//  CustomHTTPRequest.h
//
//  Booie
//
//  Created by divyaprasad on 10/04/14.
//  Copyright (c) 2014 divyaprasad. All rights reserved.

#import <Foundation/Foundation.h>


typedef enum {
	HTTPRequestMethodGET = 0,
	HTTPRequestMethodHEAD,
	HTTPRequestMethodPOST,
	HTTPRequestMethodPUT,
	HTTPRequestMethodDELETE,
} HTTPRequestMethod;

typedef enum {
	HTTPRequestContentTypeFormData = 0,
	HTTPRequestContentTypeXML,
	HTTPRequestContentTypeJSON,
	HTTPRequestContentTypeStringPlist,
	HTTPRequestContentTypeBinaryPlist,
	HTTPRequestContentTypeBinaryData,
	HTTPRequestContentTypeBinaryDataBase64,
	HTTPRequestContentTypeUnspecified = 999,
} HTTPRequestContentType;

typedef enum {
	HTTPRequestProtocolDefault,
	HTTPRequestProtocolSecure,
} HTTPRequestProtocol;

@class CustomHTTPRequest;

typedef void (^HTTPOnCompletionBlock)(CustomHTTPRequest *request, BOOL didSucceed);
typedef void (^HTTPOnSuccessBlock)(CustomHTTPRequest *request, id resultObject, NSHTTPURLResponse *response);
typedef void (^HTTPOnFailureBlock)(CustomHTTPRequest *request, NSError *error);

@interface CustomHTTPRequest : NSObject {}

@property (nonatomic, retain) NSMutableURLRequest *request;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) id body;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, retain) id userInfo;
@property (nonatomic, assign) HTTPRequestContentType contentType;
@property (nonatomic, assign) HTTPRequestContentType responseContentType; // this defaults to unspecified. if set, it will be used instead of the response content-type header
@property (nonatomic, copy) HTTPOnCompletionBlock onCompletion; // completion is called regardless of success or failure
@property (nonatomic, copy) HTTPOnSuccessBlock onSuccess;
@property (nonatomic, copy) HTTPOnFailureBlock onFailure;
@property (nonatomic, readonly, retain) id responseObject; // this is the final output of the request
@property (nonatomic, assign) BOOL verboseLogging;
@property (nonatomic, readonly, assign) uint64_t inFlightDurationNanos; // nanoseconds


/* Explanation of parameters for the following method:
	
	iProtocol - Either 'default' or 'secure'. Secure means use https, default is http.
	iMethod - The HTTP method to use (get, post, put, delete)
	iHostName - ie: "smunoth@bridgetree.com"
	iServicesPath - ie: "/services"
	iEndPoint - ie: "/some/thing/create"
	iURLParams - These are parameters passed GET-style in the URL itself
	iBody - The actual request body. Ignored when method is GET.
	iTimeoutInterval - Self explanatory, I hope
 
	The combination of iProtocol, iHostName, iServicesPath, and iEndPoint make up the final URL.
	
	        https://  smunoth.bridgetree.com   /services   /some/thing/create
	
	NOTE: the services path is optional - if the service you are trying to hit is deployed at /, just pass nil and everything will continue on just fine.
			
 */

// ONE METHOD TO RULE THEM ALL!
//+ (CustomHTTPRequest *)requestWithProtocol:(HTTPRequestProtocol)iProtocol method:(HTTPRequestMethod)iMethod hostName:(NSString *)iHostName servicesPath:(NSString *)iServicesPath endPoint:(NSString *)iEndPoint URLParameters:(NSDictionary *)iURLParams body:(NSDictionary *)iBody timeoutInterval:(NSTimeInterval)iTimeoutInterval;

// ----------------------------------------------------------
+ (void)setVerboseLoggingDefault:(BOOL)iDefaultValue; // allows you to not have to enable it on every request, if that's what you want
+ (void)setAuxiliaryURLParamValue:(NSString *)iURLParamValue forKey:(NSString *)iURLParamKey;
- (id)initWithURL:(NSURL *)iURL body:(id)iBody timeoutInterval:(NSTimeInterval)iInterval method:(HTTPRequestMethod)iMethod onSuccess:(HTTPOnSuccessBlock)iSuccess onFailure:(HTTPOnFailureBlock)iFailure onCompletion:(HTTPOnCompletionBlock)iCompletion;
- (void)sendRequest;
- (void)logRequest;
- (void)logResponse;
- (void)logAll;

+ (NSDictionary *)dictionaryForLogging:(NSDictionary *)iDictionary;
+ (NSArray *)arrayForLogging:(NSArray *)iArray;
+ (NSString *)stringForLogging:(NSString *)iString;

@end
