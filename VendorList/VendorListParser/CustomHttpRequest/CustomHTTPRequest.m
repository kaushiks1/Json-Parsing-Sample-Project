//
//  CustomHTTPRequest.m
//
//  Booie
//
//  Created by divyaprasad on 10/04/14.
//  Copyright (c) 2014 divyaprasad. All rights reserved.

#import "CustomHTTPRequest.h"
//#import "Utility.h"


static NSString *const kHTTPRequestErrorDomain = @"HTTPRequestErrorDomain";
static BOOL HTTPRequestDefaultVerboseLogging = YES;
static NSString *HTTPRequestAuxURLParamKey = nil;
static NSString *HTTPRequestAuxURLParamValue = nil;
@interface CustomHTTPRequest ()

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) HTTPRequestMethod method;
@property (nonatomic, retain) NSHTTPURLResponse *response;
@property (nonatomic, readwrite, retain) id responseObject;
@property (nonatomic, readwrite, assign) uint64_t inFlightDurationNanos;

+ (NSString *)methodStringForMethod:(HTTPRequestMethod)iMethod;
- (NSString *)methodStringForMethod:(HTTPRequestMethod)iMethod;
- (NSString *)contentTypeStringForType:(HTTPRequestContentType)iType;
//- (id)objectFromResponseDataForContentType:(HTTPRequestContentType)iContentType;

@end


@implementation CustomHTTPRequest

@synthesize tag;
@synthesize userInfo;
@synthesize request;
@synthesize connection;
@synthesize method;
@synthesize body;
@synthesize contentType;
@synthesize responseContentType;
@synthesize onCompletion;
@synthesize onSuccess;
@synthesize onFailure;
@synthesize response;
@synthesize responseData;
@synthesize responseObject;
@synthesize verboseLogging;
@synthesize inFlightDurationNanos;

+ (void)setVerboseLoggingDefault:(BOOL)iDefaultValue {
	HTTPRequestDefaultVerboseLogging = YES; // iDefaultValue;
}


+ (void)setAuxiliaryURLParamValue:(NSString *)iURLParamValue forKey:(NSString *)iURLParamKey {
	[HTTPRequestAuxURLParamKey release];
	HTTPRequestAuxURLParamKey = [iURLParamKey copy];
	
	[HTTPRequestAuxURLParamValue release];
	HTTPRequestAuxURLParamValue = [iURLParamValue copy];
}


//+ (CustomHTTPRequest *)requestWithProtocol:(HTTPRequestProtocol)iProtocol method:(HTTPRequestMethod)iMethod hostName:(NSString *)iHostName servicesPath:(NSString *)iServicesPath endPoint:(NSString *)iEndPoint URLParameters:(NSDictionary *)iURLParams body:(NSDictionary *)iBody timeoutInterval:(NSTimeInterval)iTimeoutInterval {
//	if (iHostName.length <= 0) {
//		NSLog(@"*** HTTPRequest ERROR: You MUST provide a hostname! Returning nil. ***");
//		return nil;
//	}
//	
//	NSString *aProtocolString = (iProtocol == HTTPRequestProtocolSecure ? @"https" : @"http");
//	NSString *aBaseURLString = iHostName;
//	// if a services path is specified, be sure to use it
//	if (iServicesPath.length > 0) {
//		// if the host name doesn't end with a slash and the services path also doesn't begin with one, we need one
//		if ([iHostName characterAtIndex:[iHostName length] - 1] != '/' && [iServicesPath characterAtIndex:0] != '/') {
//			iServicesPath = [@"/" stringByAppendingString:iServicesPath];
//		}
//		aBaseURLString = [NSString stringWithFormat:@"%@%@", iHostName, iServicesPath];
//	}
//	if (iEndPoint.length > 0) {
//		// if the endpoint doesn't begin with a slash and the URL so far also doesn't end in a slash, we need one
//		if ([iEndPoint characterAtIndex:0] != '/' && [aBaseURLString characterAtIndex:[aBaseURLString length] - 1] != '/') {
//			aBaseURLString = [aBaseURLString stringByAppendingString:@"/"];
//		}
//		aBaseURLString = [aBaseURLString stringByAppendingString:iEndPoint];
//	}
//	
//	NSString *aWholeURLString = [NSString stringWithFormat:@"%@://%@", aProtocolString, aBaseURLString];
//	// if there are url params, now's the time to use them
//	if (!iURLParams && HTTPRequestAuxURLParamKey && HTTPRequestAuxURLParamValue) {
//		iURLParams = [NSDictionary dictionaryWithObject:HTTPRequestAuxURLParamValue forKey:HTTPRequestAuxURLParamKey];
//	}
//	
//	if (iURLParams && iURLParams.allKeys.count > 0) {
//		NSMutableDictionary *aURLParams = [NSMutableDictionary dictionaryWithDictionary:iURLParams];
//		if (HTTPRequestAuxURLParamKey && HTTPRequestAuxURLParamValue) {
//			if (![aURLParams objectForKey:HTTPRequestAuxURLParamKey])
//				[aURLParams setObject:HTTPRequestAuxURLParamValue forKey:HTTPRequestAuxURLParamKey];
//		}
//		
//		NSString *anOperator = @"?";
//		if ([aWholeURLString rangeOfString:@"?"].location != NSNotFound) {
//			anOperator = @"&";
//		}
//		aWholeURLString = [aWholeURLString stringByAppendingFormat:@"%@%@", anOperator, [aURLParams POSTBodyString]];
//	}
//	
//	if (HTTPRequestDefaultVerboseLogging)
//		NSLog(@"<%@> - creating request with URL %@ and body %@", NSStringFromClass([self class]), aWholeURLString, [self dictionaryForLogging:iBody]);
//	
//	NSURL *aRequestURL = [NSURL URLWithString:aWholeURLString];
//	return [[[CustomHTTPRequest alloc] initWithURL:aRequestURL body:iBody timeoutInterval:iTimeoutInterval method:iMethod] autorelease];
//}


+ (NSDictionary *)dictionaryForLogging:(NSDictionary *)iDictionary {
	NSMutableDictionary *aLoggedDictionary = [NSMutableDictionary dictionary];
	
	for (NSString *aKey in iDictionary) {
		id aValue = [iDictionary objectForKey:aKey];
		if ([aValue isKindOfClass:[NSString class]]) {
			aValue = [[self class] stringForLogging:aValue];
		} else if ([aValue isKindOfClass:[NSDictionary class]]) {
			aValue = [[self class] dictionaryForLogging:aValue];
		} else if ([aValue isKindOfClass:[NSArray class]]) {
			aValue = [[self class] arrayForLogging:aValue];
		}
		[aLoggedDictionary setObject:aValue forKey:aKey];
        
	}
	
	return aLoggedDictionary;
}


+ (NSArray *)arrayForLogging:(NSArray *)iArray {
	NSMutableArray *aLoggedArray = [NSMutableArray array];
	
	for (id anObject in iArray) {
		if ([anObject isKindOfClass:[NSString class]]) {
			[aLoggedArray addObject:[[self class] stringForLogging:anObject]];
		} else if ([anObject isKindOfClass:[NSDictionary class]]) {
			[aLoggedArray addObject:[[self class] dictionaryForLogging:anObject]];
		} else if ([anObject isKindOfClass:[NSArray class]]) {
			[aLoggedArray addObject:[[self class] arrayForLogging:anObject]];
		}
	}
	
	return aLoggedArray;
}


+ (NSString *)stringForLogging:(NSString *)iString {
	NSString *aLoggedString = iString;
	
	if ([iString length] > 1000) { // yay arbitrarily imposed limits
		NSString *aShorterString = [iString substringToIndex:1000];
		aShorterString = [aShorterString stringByAppendingString:@"... <truncated for sanity>"];
		aLoggedString = aShorterString;
	}
	
	return aLoggedString;
}


- (id)initWithURL:(NSURL *)iURL body:(id)iBody timeoutInterval:(NSTimeInterval)iInterval method:(HTTPRequestMethod)iMethod onSuccess:(HTTPOnSuccessBlock)iSuccess onFailure:(HTTPOnFailureBlock)iFailure onCompletion:(HTTPOnCompletionBlock)iCompletion {
	if ((self = [super init])) {
		self.body = iBody;
        self.contentType = HTTPRequestContentTypeJSON;
		self.responseContentType = HTTPRequestContentTypeUnspecified;
		self.method = iMethod;
        self.onSuccess = iSuccess;
        self.onFailure = iFailure;
        self.onCompletion = iCompletion;
		
		NSString *aURLString = [iURL absoluteString];
		if ([aURLString length] > 0 && HTTPRequestAuxURLParamKey && HTTPRequestAuxURLParamValue) {
			if ([aURLString rangeOfString:[NSString stringWithFormat:@"%@=", HTTPRequestAuxURLParamKey]].location == NSNotFound) {
				//NSString *anOperator = ([aURLString rangeOfString:@"?"].location == NSNotFound) ? @"?" : @"&";
			//	aURLString = iURL;
			//	iURL = [NSURL URLWithString:aURLString];
			}
		}
		
        self.request = [NSMutableURLRequest requestWithURL:iURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:iInterval];
		self.verboseLogging = HTTPRequestDefaultVerboseLogging;
	}
	return self;
}


- (void)sendRequest {
	if (self.connection) return;
	
//    if (![Utility isNetworkReachable]) {
//        self.onFailure(self, [NSError errorWithDomain:kHTTPRequestErrorDomain code:999 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The internet connection appear to be offline.", NSLocalizedFailureReasonErrorKey, nil]]);
//        return;
//    }
	[self.request setHTTPMethod:[self methodStringForMethod:self.method]];
	
	if ([self.body isKindOfClass:[NSData class]]) {
		[self.request setHTTPBody:self.body];
	}
	else if ([self.body isKindOfClass:[NSMutableArray class]] || [self.body isKindOfClass:[NSMutableDictionary class]]) {
		NSDictionary *aBodyDictionary = (NSDictionary*)self.body;
		NSData *aBodyData = nil;
		
		if (self.contentType == HTTPRequestContentTypeFormData) {
			if (self.verboseLogging) {
			}
		} else if (self.contentType == HTTPRequestContentTypeStringPlist || self.contentType == HTTPRequestContentTypeBinaryPlist) {
			NSError *aConversionError = nil;
			NSPropertyListFormat aPlistFormat = (self.contentType == HTTPRequestContentTypeStringPlist ? NSPropertyListXMLFormat_v1_0 : NSPropertyListBinaryFormat_v1_0);
			aBodyData = [NSPropertyListSerialization dataWithPropertyList:aBodyDictionary format:aPlistFormat options:0 error:&aConversionError];
			
			if (aConversionError) {
			}
		} else if (self.contentType == HTTPRequestContentTypeJSON) {
            NSError *error = nil;
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self.body options:NSJSONWritingPrettyPrinted error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            aBodyData =  [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            [jsonString release];
        }
		
		[self.request setHTTPBody:aBodyData];
	}
	
	[self.request setValue:[[NSNumber numberWithUnsignedInteger:[[self.request HTTPBody] length]] stringValue] forHTTPHeaderField:@"Content-Length"];
	//[self.request setValue:[self contentTypeStringForType:self.contentType] forHTTPHeaderField:@"Content-Type"];
    [self.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //application/x-www-form-urlencoded
   // [self.request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    [self.request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
	if (self.verboseLogging) {
		[self logRequest];
	}
	
	self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
}


- (void)dealloc {
	self.userInfo = nil;
	self.responseObject = nil;
	self.body = nil;
	self.connection = nil;
	self.request = nil;
	self.onCompletion = nil;
	self.onFailure = nil;
	self.response = nil;
	self.responseData = nil;
	self.responseObject = nil;
	self.onCompletion = nil;
	self.onSuccess = nil;
	self.onFailure = nil;
	[super dealloc];
}//


+ (NSString *)methodStringForMethod:(HTTPRequestMethod)iMethod {
	NSArray *aStringMap = [NSArray arrayWithObjects:@"GET", @"HEAD", @"POST", @"PUT", @"DELETE", nil];
	return (iMethod < [aStringMap count] ? [aStringMap objectAtIndex:(NSUInteger)iMethod] : nil);
}


- (NSString *)methodStringForMethod:(HTTPRequestMethod)iMethod {
	return [CustomHTTPRequest methodStringForMethod:iMethod];
}


- (NSString *)contentTypeStringForType:(HTTPRequestContentType)iType {
	NSArray *aStringMap = [NSArray arrayWithObjects:@"application/x-www-form-urlencoded", @"text/xml", @"application/json", @"application/x-splist", @"application/x-plist", nil];
	return (iType < [aStringMap count] ? [aStringMap objectAtIndex:(NSUInteger)iType] : nil);
}


#pragma mark -
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)iConnection didReceiveResponse:(NSURLResponse *)iResponse {
	self.response = (NSHTTPURLResponse *)iResponse;
}


- (void)connection:(NSURLConnection *)iConnection didReceiveData:(NSData *)iData {
	if (!self.responseData) {
		self.responseData = [NSMutableData data];
	}
	[self.responseData appendData:iData];
}


- (void)connection:(NSURLConnection *)iConnection didFailWithError:(NSError *)iError {
	if (self.onFailure) {
		self.onFailure(self, iError);
	}
	if (self.onCompletion) {
		self.onCompletion(self, NO);
	}
	self.connection = nil;
	self.request = nil;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)iConnection {
    
	BOOL aSuccess = YES;
	
	if (self.verboseLogging) {
		////NSLog(@"<%@ %p> - response string \"%@\"", NSStringFromClass([self class]), self, [self.responseData stringUsingEncoding:NSUTF8StringEncoding]);
	}
	
	if ([self.response statusCode] != 200) 
    {
		aSuccess = NO;
		
		if (self.onFailure) {
			self.onFailure(self, [NSError errorWithDomain:kHTTPRequestErrorDomain code:[self.response statusCode] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSHTTPURLResponse localizedStringForStatusCode:[self.response statusCode]], NSLocalizedFailureReasonErrorKey, nil]]);
		}
	} else {
		NSString *aContentTypeString = [[self.response allHeaderFields] objectForKey:@"Content-Type"];
//		HTTPRequestContentType aContentType; // set as 'unspecified' in init
		
		BOOL aPlistMimeType = [aContentTypeString rangeOfString:@"plist" options:NSCaseInsensitiveSearch].location != NSNotFound;
		BOOL aJSONMimeType = [aContentTypeString rangeOfString:@"json" options:NSCaseInsensitiveSearch].location != NSNotFound;
        
        BOOL aXMLMimeType = [aContentTypeString rangeOfString:@"xml" options:NSCaseInsensitiveSearch].location != NSNotFound;
        
		if (aPlistMimeType && self.responseContentType == HTTPRequestContentTypeUnspecified) {
//			aContentType = HTTPRequestContentTypeBinaryPlist; // it doesn't actually matter if this is string or binary, as it is handled by NSPropertyListSerialization
		} else if (aJSONMimeType && self.responseContentType == HTTPRequestContentTypeUnspecified) {
//			aContentType = HTTPRequestContentTypeJSON;
            
		} else if (aXMLMimeType && self.responseContentType == HTTPRequestContentTypeUnspecified) {
//			aContentType = HTTPRequestContentTypeXML;
            
		} else if (self.responseContentType == HTTPRequestContentTypeBinaryData) {
//			aContentType = HTTPRequestContentTypeBinaryData;
//			if ([aContentTypeString rangeOfString:@"base64"].location != NSNotFound) {
//				aContentType = HTTPRequestContentTypeBinaryDataBase64;
//			}
        }
        
		if (self.responseData) {
//			self.responseObject = [self objectFromResponseDataForContentType:aContentType];
		}
		
		if (self.onSuccess) {
            NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
            ;
            self.responseObject = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONWritingPrettyPrinted error:nil];
            
//            if (![self.responseObject isKindOfClass:[NSDictionary class]]) {
//                self.responseObject = (NSArray *)[self.responseObject objectAtIndex:0];
//            }
            [responseString release];
            
            if (self.verboseLogging) {
                [self logResponse];
            }
			self.onSuccess(self, self.responseObject, self.response);
		}
	}
	
	if (self.onCompletion) {
		self.onCompletion(self, aSuccess);
	}
	
	self.connection = nil;
	self.request = nil;
}


//- (id)objectFromResponseDataForContentType:(HTTPRequestContentType)iContentType {
//	id anObject = nil;
//	
//	switch (iContentType) {
//		case HTTPRequestContentTypeBinaryPlist:
//		case HTTPRequestContentTypeStringPlist: {
//			NSError *aConversionError = nil;
//			anObject = [NSPropertyListSerialization propertyListWithData:self.responseData options:NSPropertyListImmutable format:NULL error:&aConversionError];
//			if (aConversionError) {
//				//NSLog(@"HTTPRequest - error while converting server response data to plist: %@", aConversionError);
//			}
//			break;
//		}
//		case HTTPRequestContentTypeJSON: {
//			anObject = [self.responseData objectFromJSONData];
//			break;
//		}
//		case HTTPRequestContentTypeBinaryData:
//			anObject = self.responseData;
//			break;
//		case HTTPRequestContentTypeBinaryDataBase64: {
//			NSString *aBase64String = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
//			anObject = [NSData dataFromBase64String:aBase64String];
//			[aBase64String release];
//			break;
//		}
//		case HTTPRequestContentTypeUnspecified:
//		default: {
//			anObject = [self.responseData stringUsingEncoding:NSUTF8StringEncoding];
//			break;
//		}
//	}
//	
//	return anObject;
//}


- (void)logRequest {
	if (self.request) {
        
        NSString *unicodeStringBody = [[[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding] autorelease];
        #pragma unused (unicodeStringBody)
        
		NSLog(@"HTTPRequest <%p> {", self);
		NSLog(@"    headers: %@", [self.request allHTTPHeaderFields]);
		NSLog(@"    URL: %@", [[self.request URL] absoluteString]);
		NSLog(@"	method: %@", [self.request HTTPMethod]);
		NSLog(@"    body: %@", unicodeStringBody);
	}
}

- (void)logResponse {
	id aLoggedObject = self.responseObject;
	
	if ([aLoggedObject isKindOfClass:[NSDictionary class]]) {
		aLoggedObject = [[self class] dictionaryForLogging:aLoggedObject];
	} else if ([aLoggedObject isKindOfClass:[NSString class]]) {
		aLoggedObject = [[self class] stringForLogging:aLoggedObject];
	}
    #pragma unused(aLoggedObject)
    
}

- (void)logAll {
	[self logRequest];
	[self logResponse];
}


@end
