//
//  CoronaLiveBuildFileManagerLocal.mm
//
//  Copyright (c) 2016 Corona Labs. All rights reserved.
//  by Vlad Shcherban
//

#import "CoronaLiveBuildFileManagerLocal.h"

#import "CoronaLiveBuildCore.h"

#import <UIKit/UIKit.h>

#include <sys/socket.h>
#include <arpa/inet.h>


#include <CommonCrypto/CommonDigest.h>

static NSString * const kUsedServersRing = @".CoronaLiveServers";


@interface FileProps : NSObject
@property (assign) long long size;
@property (assign) long long mod;
@end

@implementation FileProps
-(BOOL)isEqualToFileProps:(FileProps*)other {
	return other && self.mod == other.mod && self.size == other.size;
}
@end


@interface LiveURLFetcherBaseDelegate : NSObject <NSURLConnectionDelegate>

@property (atomic, assign) BOOL complete;

@end


@implementation LiveURLFetcherBaseDelegate

static const UInt8 certificate[] = { 48,130,3,80,48,130,2,56,2,9,0,164,194,100,150,121,67,245,238,48,13,6,9,42,134,72,134,247,13,1,1,11,5,0,48,105,49,11,48,9,6,3,85,4,6,19,2,85,83,49,19,48,17,6,3,85,4,8,19,10,67,97,108,105,102,111,114,110,105,97,49,18,48,16,6,3,85,4,7,19,9,80,97,108,111,32,65,108,116,111,49,20,48,18,6,3,85,4,10,19,11,67,111,114,111,110,97,32,76,97,98,115,49,27,48,25,6,3,85,4,11,19,18,67,111,114,111,110,97,32,76,105,118,101,32,83,101,114,118,101,114,48,32,23,13,49,54,49,48,49,52,49,53,48,54,49,52,90,24,15,50,48,53,48,48,49,48,49,49,53,48,54,49,52,90,48,105,49,11,48,9,6,3,85,4,6,19,2,85,83,49,19,48,17,6,3,85,4,8,19,10,67,97,108,105,102,111,114,110,105,97,49,18,48,16,6,3,85,4,7,19,9,80,97,108,111,32,65,108,116,111,49,20,48,18,6,3,85,4,10,19,11,67,111,114,111,110,97,32,76,97,98,115,49,27,48,25,6,3,85,4,11,19,18,67,111,114,111,110,97,32,76,105,118,101,32,83,101,114,118,101,114,48,130,1,34,48,13,6,9,42,134,72,134,247,13,1,1,1,5,0,3,130,1,15,0,48,130,1,10,2,130,1,1,0,210,225,179,26,172,133,117,104,15,226,15,31,78,239,185,50,166,138,253,101,54,5,181,50,219,173,239,132,88,201,82,64,124,124,202,15,76,188,172,203,236,199,214,158,30,111,222,237,214,204,243,209,35,109,231,149,112,232,112,235,58,110,83,101,18,31,61,86,251,189,213,65,127,253,224,74,145,192,53,5,140,21,251,18,85,140,214,103,70,6,189,51,32,18,69,253,167,127,85,156,120,88,8,247,5,207,118,111,29,82,254,12,240,49,10,150,156,0,77,65,134,126,219,1,156,16,104,139,133,238,170,168,193,192,158,141,18,8,185,64,81,173,78,87,53,211,169,110,24,238,26,187,6,56,243,142,189,92,211,93,192,245,204,208,234,65,120,164,80,124,184,32,166,115,14,245,217,236,192,67,63,188,27,208,98,241,37,38,217,247,119,169,83,185,77,126,221,204,82,40,174,119,225,92,47,36,189,183,138,252,10,92,216,179,66,153,255,211,147,215,81,179,223,114,167,52,198,72,20,28,93,27,17,214,131,200,135,52,233,211,152,207,161,112,40,246,27,112,104,103,204,185,175,143,201,141,2,3,1,0,1,48,13,6,9,42,134,72,134,247,13,1,1,11,5,0,3,130,1,1,0,133,144,44,124,214,129,16,117,215,13,194,176,246,5,172,240,108,24,192,19,68,9,26,200,137,44,228,53,45,122,152,207,36,117,73,247,109,249,232,58,79,125,4,231,187,97,56,143,73,60,168,92,183,54,128,227,119,197,137,172,7,161,110,142,180,133,164,14,58,24,196,92,112,25,167,65,151,129,160,73,211,83,63,249,139,249,66,234,105,23,53,157,40,165,81,231,165,118,215,183,67,205,188,163,101,97,77,140,21,247,2,33,154,203,107,69,151,219,50,252,152,110,165,235,231,86,11,35,251,18,36,171,228,109,214,231,25,197,30,2,109,207,64,216,57,44,40,191,198,62,239,169,142,249,64,144,164,115,223,80,215,58,242,85,54,5,136,118,109,57,138,98,201,124,93,181,39,35,86,17,66,145,129,255,85,50,99,33,147,86,162,127,187,163,171,158,242,181,66,7,218,36,37,198,70,55,1,48,56,211,191,228,167,101,66,23,146,60,117,236,244,199,252,223,116,98,10,36,93,148,24,175,32,113,211,66,210,54,82,172,20,124,134,88,91,107,38,113,144,172,207,2,234,215,214,237 };

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
	return NO;
}


- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {

	BOOL serverConfirmed = NO;

	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {

		SecTrustRef originalTrust = challenge.protectionSpace.serverTrust;
		CFIndex numCerts = SecTrustGetCertificateCount(originalTrust);
		CFMutableArrayRef originalCerts = CFArrayCreateMutable(NULL, numCerts, NULL);
		for (CFIndex idx = 0; idx < numCerts; ++idx)
		{
			SecCertificateRef cert = SecTrustGetCertificateAtIndex(originalTrust, idx);
			CFArraySetValueAtIndex(originalCerts, idx, cert);
		}

		SecTrustRef newTrust = NULL;
		SecPolicyRef policy = SecPolicyCreateSSL(true, NULL);
		SecTrustCreateWithCertificates(originalCerts, policy, &newTrust);
		CFRelease(policy);
		CFRelease(originalCerts);


		CFDataRef certData = CFDataCreate(NULL, certificate, sizeof(certificate));
		SecCertificateRef cert = SecCertificateCreateWithData(NULL, certData);
		CFRelease(certData);

		CFArrayRef certArray = CFArrayCreate(NULL, (const void**)&cert, 1, NULL);
		SecTrustSetAnchorCertificates(newTrust, certArray);

		SecTrustResultType result = kSecTrustResultInvalid;
		SecTrustEvaluate(newTrust, &result);

		CFRelease(certArray);
		CFRelease(cert);
		CFRelease(newTrust);


		serverConfirmed = ((result == kSecTrustResultProceed || result == kSecTrustResultUnspecified));
	}
	if (serverConfirmed) {
		[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	} else {
		[challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
	}
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	self.complete = YES;
}

@end

@interface LiveFileFetcherDelegate : LiveURLFetcherBaseDelegate < NSURLConnectionDataDelegate >

@property (nonatomic, retain) NSString* filePath;
@property (nonatomic, retain) NSFileHandle *fileHandle;

@property BOOL result;
- (instancetype)initWithDestinationPath:(NSString*)path;

@end

@implementation LiveFileFetcherDelegate

-(void)dealloc {
	[_filePath release];
	_filePath = nil;

	[_fileHandle release];
	_fileHandle = nil;

	[super dealloc];
}

- (instancetype)initWithDestinationPath:(NSString*)path;
{
	if (self) {
		self.filePath = path;
	}
	return self;
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if([(NSHTTPURLResponse*)response statusCode] == 200) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if(![fileManager fileExistsAtPath:self.filePath]) {
			[fileManager createFileAtPath:self.filePath contents:nil attributes:nil];
		}
		self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
		if(!self.fileHandle) {
			NSLog(@"LiveBuild: Fatal Error: unable to open %@ for writing!", self.filePath);
			throw [NSException exceptionWithName:@"LiveBuild" reason:@"Fatal Error: unable to open file for writing!" userInfo:@{@"file":self.filePath}];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.fileHandle writeData:data];
	[self.fileHandle synchronizeFile];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self.fileHandle closeFile];
	[[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
	[super connection:connection didFailWithError:error];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self.fileHandle truncateFileAtOffset:[self.fileHandle offsetInFile]];
	[self.fileHandle synchronizeFile];
	[self.fileHandle closeFile];
	self.result = (self.filePath != nil);
	self.complete = YES;
}

@end


@interface LiveStringFetcherDelegate : LiveURLFetcherBaseDelegate < NSURLConnectionDataDelegate >

@property (retain) NSMutableData* data;
@property (retain) NSString* result;

@end

@implementation LiveStringFetcherDelegate

-(void)dealloc {
	[_data release];
	_data = nil;

	[_result release];
	_result = nil;

	[super dealloc];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.data = [[[NSMutableData alloc] init] autorelease];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.data appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	self.result = [[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding] autorelease];
	self.complete = YES;
}

@end

#define MAX_RING_LENGTH 3
#define SERVER_CHECK_TIMEOUT 13.0
#define SERVER_CHECK_TIMEOUT_QUICK 4.0

@class LiveServerDiscoverer;

@interface CoronaLiveBuildFileManagerLocal()

@property (retain, atomic) NSString *basePath;
@property (retain, atomic) NSString *server;
@property (retain, atomic) NSOperationQueue *ops;
@property (retain, atomic) LiveServerDiscoverer *discoverer;

@property (retain, atomic) NSString *configKey;
@property (retain, atomic) NSString *configIP;
@property (retain, atomic) NSNumber *configPort;

-(NSURL*)URLWithServer:(NSString*)server method:(NSString*)method andArgs:(NSDictionary<NSString*,NSString*>*)args;

@end

@interface LiveServerDiscoverer : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
-(instancetype)initWithManager:(CoronaLiveBuildFileManagerLocal*)manager;
@end

@implementation CoronaLiveBuildFileManagerLocal

@synthesize delegate;

- (id)initWithBasePath:(NSString *)base viewController:(UIViewController *)controller key:(NSString*)key ip:(NSString*)ip andPort:(NSNumber*)port
{
	self = [super init];
	if ( self )
	{
		self.basePath = base;
		self.server = nil;
		self.ops = [[[NSOperationQueue alloc] init] autorelease];
		self.ops.maxConcurrentOperationCount = 4;
		self.discoverer = nil;

		//reading config
		self.configKey = key;
		self.configIP = ip;
		self.configPort = port;

	}
	return self;
}


- (id)initWithParams:(NSDictionary *)params
{
	NSString *base = [params valueForKey:CLSK_BasePath];
	UIViewController *controller = [params valueForKey:CLSK_ViewController];
	NSString *key = [params valueForKey:CLSK_Key];
	NSString *ip = [params valueForKey:CLSK_IP];
	NSNumber *port = [params valueForKey:CLSK_Port];
	
	return [self initWithBasePath:base viewController:controller key:key ip:ip andPort:port];
}


-(void)dealloc
{
	[_ops release];
	_ops = nil;

	[_server release];
	_server = nil;

	[_basePath release];
	_basePath = nil;

	[_discoverer release];
	_discoverer = nil;

	[_configIP release];
	_configIP = nil;

	[_configPort release];
	_configPort = nil;

	[_configKey release];
	_configKey = nil;

	[super dealloc];
}


-(NSURL *)URLWithServer:(NSString *)server method:(NSString *)method andArgs:(NSDictionary *)args
{
	NSMutableDictionary<NSString *,NSString *>* finalArgs = [NSMutableDictionary dictionaryWithDictionary:args];
	if(self.configKey && ![args objectForKey:@"key"])
	{
		[finalArgs setObject:self.configKey forKey:@"key"];
	}
	NSMutableArray<NSString*> *queryElements = [NSMutableArray arrayWithCapacity:finalArgs.count];
	[finalArgs enumerateKeysAndObjectsUsingBlock:^(NSObject * key, NSObject * obj, BOOL * ) {
		[queryElements addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
	}];
	NSString * query = [queryElements componentsJoinedByString:@"&"];
	if(query.length)
		query = [@"?" stringByAppendingString:query];

	NSString * finalServer = server ?: self.server;
	NSString * finalMethod = method ?: @"";

	NSString *stringURL = [NSString stringWithFormat:@"%@%@%@", finalServer, finalMethod, query];

	return [NSURL URLWithString:stringURL];
}

-(NSString*)fetchStringFrom:(NSString*)server method:(NSString*)method args:(NSDictionary *)args andTimeout:(NSNumber*)timeout {
	NSURLRequest *request = nil;
	NSURL *requestUrl = [self URLWithServer:server method:method andArgs:args];
	if(timeout) {
		request = [NSURLRequest requestWithURL:requestUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeout.doubleValue];
	} else {
		request = [NSURLRequest requestWithURL:requestUrl];
	}

	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];

	LiveStringFetcherDelegate *connectiondelegate = [[LiveStringFetcherDelegate alloc] init];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:connectiondelegate startImmediately:NO];
	[connection scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];
	[connection start];
	while(!connectiondelegate.complete) [runLoop run];
	[connection release];

	return [[connectiondelegate autorelease] result];
}


-(BOOL)downloadFileTo:(NSString*)path from:(NSString*)server method:(NSString*)method args:(NSDictionary *)args {
	assert(path);
	NSURL *requestUrl = [self URLWithServer:server method:method andArgs:args];
	NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];

	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];

	LiveFileFetcherDelegate *connectionDelegate = [[LiveFileFetcherDelegate alloc] initWithDestinationPath:path];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:connectionDelegate startImmediately:NO];
	[connection scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];
	[connection start];
	while(!connectionDelegate.complete) [runLoop run];
	[connection release];

	return [[connectionDelegate autorelease] result];
}


-(void)scheduleFindServerAndStartSyncTimeout
{
	[self performSelectorInBackground:@selector(findServerAndStartSync) withObject:nil];
}

-(void)scheduleFindServerAndStartSync
{
	if([NSThread isMainThread])
	{
		[self performSelector:@selector(scheduleFindServerAndStartSyncTimeout) withObject:nil afterDelay:3.14];
	}
	else
	{
		[self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:NO];
	}
}

+(NSString*)sha256Of:(NSString*)string
{
	static NSMutableDictionary<NSString*,NSString*> *hashCache = [[NSMutableDictionary alloc] init];
	@synchronized (hashCache) {
		NSString *result = [hashCache objectForKey:string];
		if(result)
			return result;

		unsigned char digest[CC_SHA256_DIGEST_LENGTH];
		NSData *stringData = [string dataUsingEncoding:NSASCIIStringEncoding];
		CC_SHA256(stringData.bytes, (CC_LONG)stringData.length, digest);

		NSMutableString *mutResult = [[NSMutableString alloc] initWithCapacity:CC_SHA256_DIGEST_LENGTH*2+1];
		for (NSUInteger i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i) {
			[mutResult appendFormat:@"%02x", digest[i]];
		}
		result = [NSString stringWithString:mutResult];
		[mutResult release];
		[hashCache setObject:result forKey:string];
		return result;
	}
}

-(BOOL)checkServer:(NSString*)server withTimeout:(double)timeout
{
	if(!server) {
		return NO;
	}
	NSString *hashedKeyDigest = [CoronaLiveBuildFileManagerLocal sha256Of:[self.configKey stringByAppendingString:@"^eC*4K1ButGpA1Q8"]];
	NSString *reply = [self fetchStringFrom:server method:nil args:@{@"key": hashedKeyDigest} andTimeout:[NSNumber numberWithDouble:timeout]];
	return [reply isEqualToString:[CoronaLiveBuildFileManagerLocal sha256Of:[self.configKey stringByAppendingString:@"C@!GEB@v2tLN_CG$e"]]];

}

-(BOOL)checkServer:(NSString*)server
{
	return [self checkServer:server withTimeout:SERVER_CHECK_TIMEOUT];
}

-(void)findServerAndStartSync
{
	if([self.configIP length] > 0 && [self.configPort integerValue] > 0)
	{
		self.server = [NSString stringWithFormat:@"https://%@:%@/", self.configIP, self.configPort];
		if([self checkServer:self.server]) {
			[self startSyncingInternal];
		} else {
			[self scheduleFindServerAndStartSync];
		}
	}
	else
	{
		self.discoverer = [[[LiveServerDiscoverer alloc] initWithManager:self] autorelease];
	}
}

+(unsigned long long)parseStatusMessage:(NSString*)status files:(NSMutableArray <NSString*> *)receivedFiles filesProps:(NSMutableDictionary <NSString*, FileProps*> * )receivedFilesProps directories:(NSMutableArray <NSString*> *)receivedDirectories symlinks:(NSMutableDictionary <NSString*, NSString*> * )symlinks
{
	unsigned long long newUpdateTime = 0;
	@autoreleasepool
	{
		NSArray * entries = [status componentsSeparatedByString:@" //\n"];

		newUpdateTime = [[[[entries firstObject] componentsSeparatedByString:@" / "] firstObject] longLongValue];

		for(NSString *s in entries)
		{
			NSArray<NSString*> *ss = [s componentsSeparatedByString:@" / "];

			if(ss.count==3)
			{
				NSString *relPath = [ss objectAtIndex:2];

				if([relPath hasSuffix:@"/"])
				{
					[receivedDirectories addObject:relPath];
				}
				else
				{
					FileProps *fp = [[FileProps alloc] init];
					fp.size = [[ss objectAtIndex:0] longLongValue];
					fp.mod = [[ss objectAtIndex:1] longLongValue];
					[receivedFilesProps setObject:fp forKey:relPath];
					[fp release];

					[receivedFiles addObject:relPath];
				}
			}
			else if([s hasPrefix:@"S&"])
			{
				ss = [s componentsSeparatedByString:@"&"];
				if(ss.count!=3)
				{
					continue;
				}
				NSString * link = [[ss objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				NSString * linkDest = [[ss objectAtIndex:2] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				[symlinks setObject:linkDest forKey:link];
			}
		}

		[receivedDirectories sortUsingSelector:@selector(compare:)];
		[receivedFiles sortUsingSelector:@selector(compare:)];
	}
	return newUpdateTime;
}

-(void)startSyncingInternal
{
	NSString *rootPath = [NSString stringWithString:self.basePath];

	NSMutableArray <NSString*> * files =  [[NSMutableArray alloc] init];
	NSMutableDictionary <NSString*, NSString*> * symlinks = [[NSMutableDictionary alloc] init];
	NSMutableDictionary <NSString*, FileProps*> * filesProps = [[NSMutableDictionary alloc] init];
	NSMutableArray <NSString*> * directories = [[NSMutableArray alloc] init];
	unsigned long long newUpdateTime = 0;

	NSMutableArray<NSString*> *receivedFiles = [[NSMutableArray alloc] init];
	NSMutableDictionary <NSString*, FileProps*> * receivedFilesProps = [[NSMutableDictionary alloc] init];
	NSMutableDictionary <NSString*, NSString*> * receivedSymlinks = [[NSMutableDictionary alloc] init];
	NSMutableArray<NSString*> *receivedDirectories = [[NSMutableArray alloc] init];

	NSString *status = [self fetchStringFrom:nil method:@"status" args:nil andTimeout:nil];
	newUpdateTime = [CoronaLiveBuildFileManagerLocal parseStatusMessage:status files:receivedFiles filesProps:receivedFilesProps directories:receivedDirectories symlinks:receivedSymlinks];

	if(newUpdateTime) @autoreleasepool
	{
		NSUInteger rootLen = rootPath.length;
		NSURL *rootUrl = [NSURL fileURLWithPath:rootPath];

		NSFileManager *fileManager = [[NSFileManager alloc] init];
		NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:rootUrl
											  includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLFileSizeKey, NSURLContentModificationDateKey, NSURLPathKey]
																 options:NSDirectoryEnumerationSkipsHiddenFiles
															errorHandler:nil];
		for( NSURL *fileURL in enumerator )
		{
			NSNumber *isDir;
			[fileURL getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];

			NSNumber *isSymlink;
			[fileURL getResourceValue:&isSymlink forKey:NSURLIsSymbolicLinkKey error:nil];

			NSURL *resolvedPath = [[[fileURL URLByDeletingLastPathComponent] URLByResolvingSymlinksInPath] URLByAppendingPathComponent:[fileURL lastPathComponent]];
			NSString *path;
			[resolvedPath getResourceValue:&path forKey:NSURLPathKey error:nil];

			if([path hasPrefix:rootPath])
			{
				NSString *relPath = [path substringFromIndex:rootLen];
				if(isSymlink.boolValue)
				{
					NSString *dest = [fileManager destinationOfSymbolicLinkAtPath:path error:nil];
					[symlinks setObject:dest  forKey:relPath];
				}
				else if(isDir.boolValue)
				{
					[directories addObject:[relPath stringByAppendingString:@"/"]];
				}
				else
				{
					NSDate *mod;
					[fileURL getResourceValue:&mod forKey:NSURLContentModificationDateKey error:nil];

					NSNumber *size;
					[fileURL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];

					FileProps *fp = [[FileProps alloc] init];
					fp.size = size.longLongValue;
					fp.mod = mod.timeIntervalSince1970;
					[filesProps setObject:fp forKey:relPath];
					[fp release];
					[files addObject:relPath];

				}
			}
			else
			{
				NSLog(@"Relpath failure! %@ %@", rootPath, path);
			}
		}
		[fileManager release];

		[directories sortUsingSelector:@selector(compare:)];
		[files sortUsingSelector:@selector(compare:)];
	}

	NSMutableArray<NSString*>* taskDeleteDirs = [[NSMutableArray alloc] init];
	NSMutableArray<NSString*>* taskCreateDirs = [[NSMutableArray alloc] init];

	@autoreleasepool
	{
		NSSet * receivedDirSet = [NSSet setWithArray:receivedDirectories];
		NSSet * existingDirSet = [NSSet setWithArray:directories];

		NSMutableSet * toDelete = [NSMutableSet setWithSet:existingDirSet];
		[toDelete minusSet:receivedDirSet];

		NSMutableSet *toCreate = [NSMutableSet setWithSet:receivedDirSet];
		[toCreate minusSet:existingDirSet];

		[taskDeleteDirs addObjectsFromArray:[toDelete allObjects]];
		[taskDeleteDirs sortUsingSelector:@selector(compare:)];

		[taskCreateDirs addObjectsFromArray:[toCreate allObjects]];
		[taskCreateDirs sortUsingSelector:@selector(compare:)];
	}

	NSMutableArray<NSString*>* taskDeleteFiles = [[NSMutableArray alloc] init];

	for (NSString* f in files) {
		if(![receivedFilesProps objectForKey:f]) {
			[taskDeleteFiles addObject:f];
		}
	}

	[symlinks enumerateKeysAndObjectsUsingBlock:^(NSString * link, NSString * dest, BOOL*stop) {
		NSString* receivedLink = [receivedSymlinks objectForKey:link];
		if(![receivedLink isEqualToString:dest]) {
			[taskDeleteFiles addObject:link];
		}
	}];

	NSMutableArray<NSString*>* taskUpdateLinks = [[NSMutableArray alloc] init];
	[receivedSymlinks enumerateKeysAndObjectsUsingBlock:^(NSString* link, NSString * dest, BOOL*stop) {
		NSString *existingLink = [symlinks objectForKey:link];
		if(![existingLink isEqualToString:dest]) {
			[taskUpdateLinks addObject:link];
		}
	}];


	NSMutableArray<NSString*>* taskUpdateFiles = [[NSMutableArray alloc] init];

	NSArray<NSString*> *excludeRules = [[NSString stringWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"_corona_live_build_exclude.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
	NSMutableArray<NSPredicate*> *excludePredicates = [NSMutableArray arrayWithCapacity:excludeRules.count];

	for (NSString* p in excludeRules) {
		if(p.length > 0) {
			[excludePredicates addObject:[NSPredicate predicateWithFormat:@"SELF like %@", p]];
		}
	}

	NSPredicate *excludeChecker = [NSPredicate predicateWithValue:NO];
	if(excludePredicates.count) {
		excludeChecker = [NSCompoundPredicate orPredicateWithSubpredicates:excludePredicates];
	}

	for (NSString* f in receivedFiles) {
		FileProps *existing = [filesProps objectForKey:f];
		FileProps *remote = [receivedFilesProps objectForKey:f];
		if (![remote isEqualToFileProps:existing] && ![excludeChecker evaluateWithObject:[f substringFromIndex:1]]) {
			[taskUpdateFiles addObject:f];
		}
	}

	if([taskUpdateFiles containsObject:@"/build.settings"] || [taskUpdateFiles containsObject:@"/config.lua"]) {
		[self performSelectorOnMainThread:@selector(notifyAboutConfigurationChange) withObject:nil waitUntilDone:NO];
	}

	unsigned long numTasks = taskCreateDirs.count + taskDeleteDirs.count + taskDeleteFiles.count + taskUpdateFiles.count + taskUpdateLinks.count;
	if(newUpdateTime && numTasks>0)
	{
		@autoreleasepool
		{
			__block typeof(self) weakSelf = self;

			NSOperation *syncDone = [NSBlockOperation blockOperationWithBlock:^{
				[weakSelf sendDidSync];
			}];

			NSOperation *syncStart = [NSBlockOperation blockOperationWithBlock:^{
				[weakSelf performSelectorOnMainThread:@selector(sendWillSync) withObject:nil waitUntilDone:YES];
			}];

			NSOperation *prepareFileStructure = [NSBlockOperation blockOperationWithBlock:^{
				NSFileManager *fileManager = [[NSFileManager alloc] init];
				NSError *err = nil;
				for (NSString* fileToDelete in taskDeleteFiles) {
					NSString *path = [rootPath stringByAppendingString:fileToDelete];
					[fileManager removeItemAtPath:path error:&err];
				}
				for (NSString* dirToDelete in taskDeleteDirs) {
					NSString *path = [rootPath stringByAppendingString:dirToDelete];
					[fileManager removeItemAtPath:path error:&err];
				}
				for (NSString* dirToCreate in taskCreateDirs) {
					NSString *path = [rootPath stringByAppendingString:dirToCreate];
					[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
				}
				for (NSString* link in taskUpdateLinks) {
					NSString *dest = [receivedSymlinks objectForKey:link];
					NSString *path = [rootPath stringByAppendingString:link];
					[fileManager createSymbolicLinkAtPath:path withDestinationPath:dest error:nil];
				}
				[fileManager release];
			}];
			[prepareFileStructure addDependency:syncStart];
			[syncDone addDependency:prepareFileStructure]; // so if not file changes, wouldn't fire immediatelly

			for (NSString* f in taskUpdateFiles)
			{
				NSBlockOperation *fileUpdateOperation = [NSBlockOperation blockOperationWithBlock:^{
					NSString *escapedFilename = [[NSURL fileURLWithPath:[f substringFromIndex:1]] relativeString];
					NSString *method = [@"files/" stringByAppendingString:escapedFilename];
					NSString *filename = [rootPath stringByAppendingString:f];
					BOOL res = [self downloadFileTo:filename from:nil method:method args:nil];
					NSURL * fileUrl = [NSURL fileURLWithPath:filename];
					if(res) {
						NSDate *mod = [NSDate dateWithTimeIntervalSince1970:[receivedFilesProps objectForKey:f].mod];
						NSError *err = nil;
						[fileUrl setResourceValue:mod forKey:NSURLContentModificationDateKey error:&err];
					}
				}];
				[syncDone addDependency:fileUpdateOperation];
				[fileUpdateOperation addDependency:prepareFileStructure];
			}

			[self.ops cancelAllOperations];

			[self.ops addOperation:syncStart];
			[self.ops addOperations:syncDone.dependencies waitUntilFinished:NO];
			[self.ops addOperation:syncDone];
		}
	}
	else if(newUpdateTime)
	{
		//everything is up to date, schedule update listener!
		[self performSelectorInBackground:@selector(waitForUpdateSince:) withObject:[NSNumber numberWithLongLong:newUpdateTime]];
	}
	else
	{
		//server is down, try again?
		[self scheduleFindServerAndStartSync];
	}

	[files release];
	[filesProps release];
	[directories release];
	[receivedFiles release];
	[receivedFilesProps release];
	[receivedSymlinks release];
	[symlinks release];
	[receivedDirectories release];
	[taskDeleteDirs release];
	[taskCreateDirs release];
	[taskDeleteFiles release];
	[taskUpdateFiles release];
	[taskUpdateLinks release];

}

-(void)waitForUpdateSince:(NSNumber*)last
{
	NSDictionary * args = nil;
	if(last)
		args = @{@"modified": last};
	NSString *reply = [self fetchStringFrom:nil method:@"update" args:args andTimeout:nil];
	if(self.server)
	{
		if( [reply longLongValue] > last.longLongValue )
		{
			[self performSelector:@selector(startSyncingInternal) withObject:nil];
		}
		else
		{
			if([self checkServer:self.server])
			{
				[self performSelector:@selector(waitForUpdateSince:) withObject:last];
			}
			else
			{
				self.server = nil;
				[self scheduleFindServerAndStartSync];
			}
		}
	}
}

-(void)actualSendDidSync
{
	[self.delegate filesDidSync];
}

-(void)sendDidSync
{
	if([NSThread isMainThread])
	{
		[self performSelector:@selector(actualSendDidSync) withObject:nil afterDelay:0.5];
	}
	else
	{
		[self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:NO];
	}
}

-(void)sendWillSync
{
	[self.delegate filesWillSync];
}

-(void)startSyncing
{
	[self performSelectorInBackground:@selector(findServerAndStartSync) withObject:nil];
}


- (void)stopSyncing
{
	self.server = nil;
	[self.ops cancelAllOperations];
	[self.ops waitUntilAllOperationsAreFinished];
}

- (void)resync
{
	if([NSThread isMainThread])
	{
		[self performSelectorInBackground:_cmd withObject:nil];
		return;
	}

	[self performSelectorOnMainThread:@selector(sendWillSync) withObject:nil waitUntilDone:YES];

	NSString* bundleRootDir = [[NSBundle mainBundle] bundlePath];

	NSString * status = [[NSString alloc] initWithContentsOfFile:[bundleRootDir stringByAppendingPathComponent:@"_corona_live_build_manifest.txt"] encoding:NSUTF8StringEncoding error:nil];

	NSMutableArray<NSString*> *filesToCopy = [[NSMutableArray alloc] init];
	NSMutableDictionary <NSString*, FileProps*> * fileProps = [[NSMutableDictionary alloc] init];
	NSMutableArray<NSString*> *dirsToCreate = [[NSMutableArray alloc] init];

	[CoronaLiveBuildFileManagerLocal parseStatusMessage:status files:filesToCopy filesProps:fileProps directories:dirsToCreate symlinks:nil];
	[status release];


	NSFileManager * fileManager = [NSFileManager defaultManager];

	NSString *rootPath = self.basePath;

	[fileManager removeItemAtPath:rootPath error:nil];

	for (NSString* dir in dirsToCreate) {
		[fileManager createDirectoryAtPath:[rootPath stringByAppendingString:dir] withIntermediateDirectories:YES attributes:nil error:nil];
	}

	NSURL* srcDir = [NSURL fileURLWithPath:[bundleRootDir stringByAppendingString:@"/_corona_live_build_app"]];
	NSURL* dstDir = [NSURL fileURLWithPath:rootPath];
	for(NSString* f in filesToCopy) {
		NSURL *src = [srcDir URLByAppendingPathComponent:f];
		NSURL *dst = [dstDir URLByAppendingPathComponent:f];
		NSDate *mod = [NSDate dateWithTimeIntervalSince1970:[fileProps objectForKey:f].mod];

		[fileManager copyItemAtURL:src toURL:dst error:nil];
		[dst setResourceValue:mod forKey:NSURLContentModificationDateKey error:nil];

	}

	[dirsToCreate release];
	[fileProps release];
	[filesToCopy release];

	[self sendDidSync];

}


-(void)notifyAboutConfigurationChange {
	NSString *title = @"Configuration Change Detected";
	NSString *message = @"To properly reflect changes in 'build.settings' or 'config.lua' you may need to rebuild the app.";
	NSString *ok = @"OK";
#if not(TARGET_OS_TV)
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:nil
										  cancelButtonTitle:ok
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
#else
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
																   message:message
															preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault
														  handler:nil];
	[alert addAction:defaultAction];
	UIViewController* controller = [UIApplication sharedApplication].keyWindow.rootViewController;
	[controller presentViewController:alert animated:YES completion:nil];


#endif
}

@end

@interface LiveServerDiscoverer()
@property (retain, atomic) CoronaLiveBuildFileManagerLocal *manager;
@property (retain, atomic) NSNetServiceBrowser* browser;
@property (retain, atomic) NSMutableArray<NSString*>* ring;
@property (assign, atomic) BOOL continueDiscovery;
@property (retain, atomic) NSOperationQueue *checkers;

@end

@implementation LiveServerDiscoverer

-(void)dealloc
{
	[self terminate];

	[self.checkers cancelAllOperations];
	[self.checkers waitUntilAllOperationsAreFinished];
	[_checkers release];
	_checkers = nil;


	[_ring release];
	_ring = nil;

	[_manager release];
	_manager = nil;

	[super dealloc];
}

-(void)terminate
{
	_continueDiscovery = NO;

	if(_manager && _manager.discoverer == self) {
		_manager.discoverer = nil;
	}

	_browser.delegate = nil;
	[_browser stop];
	[_browser release];
	_browser = nil;
}

-(instancetype)initWithManager:(CoronaLiveBuildFileManagerLocal *)manager
{
	self = [super init];
	if (self) {
		self.continueDiscovery = YES;
		self.manager = manager;
		self.ring = [NSMutableArray arrayWithArray:([[NSUserDefaults standardUserDefaults] arrayForKey:kUsedServersRing] ?: @[])];

		_checkers = [[NSOperationQueue alloc] init];
		_checkers.maxConcurrentOperationCount = MAX_RING_LENGTH+2;
		[_checkers addOperationWithBlock:^{
			[self checkFirstServerAndStartDiscovery];
		}];
	}
	return self;
}

-(void)checkFirstServerAndStartDiscovery
{
	if([self.manager checkServer:self.ring.firstObject withTimeout:SERVER_CHECK_TIMEOUT_QUICK]) {
		self.manager.server = self.ring.firstObject;
		[self.manager performSelectorInBackground:@selector(startSyncingInternal) withObject:nil];
		[self terminate];
		return;
	}

	dispatch_async(dispatch_get_main_queue(), ^(void){
		self.browser = [[[NSNetServiceBrowser alloc] init] autorelease];
		self.browser.delegate = self;
		[self.browser searchForServicesOfType:@"_corona_live._tcp." inDomain:@"local"];
	});

	for (NSString *server in self.ring) {
		[_checkers addOperationWithBlock:^{
			[self checkingServer:server];
		}];
	}

}

-(void)saveRingAndAdd:(NSString*)server
{
	[self.ring removeObject:server];
	[self.ring insertObject:server atIndex:0];
	while(self.ring.count > MAX_RING_LENGTH) {
		[self.ring removeLastObject];
	}
	[[NSUserDefaults standardUserDefaults] setObject:self.ring forKey:kUsedServersRing];
}


-(void)checkingServer:(NSString*)server
{

	if(!self.continueDiscovery)
		return;

	BOOL serverOK = [self.manager checkServer:server];

	@synchronized (self) {

		if(!self.continueDiscovery)
			return;

		if(serverOK) {
			[self saveRingAndAdd:server];
			self.manager.server = server;
			[self.manager performSelectorInBackground:@selector(startSyncingInternal) withObject:nil];
			[self terminate];
		} else {
			if([self.ring containsObject:server]) {
				[_checkers addOperationWithBlock:^{
					[NSThread sleepForTimeInterval:3.14]; //doesn't matter much. Just sleep for some time so we don't just spam requests
					[self checkingServer:server];
				}];
			}
		}

	}
}



-(void)discoveredServer:(NSString*)server
{
	@synchronized (self) {
		if (!self.continueDiscovery) {
			return;
		}
		[self saveRingAndAdd:server];

		NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
			[self checkingServer:server];
		}];
		op.queuePriority = NSOperationQueuePriorityHigh;
		[_checkers addOperation:op];
	}
}


-(void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *,NSNumber *> *)errorDict {
	NSLog(@"Failure to search for Live Server: %@!", errorDict);
	[self.manager scheduleFindServerAndStartSync];
	[self terminate];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
	[service retain];
	service.delegate = self;
	[service resolveWithTimeout:30];
}

-(void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
	sender.delegate = nil;
	[sender release];
}


-(void)netServiceDidResolveAddress:(NSNetService *)sender
{
	if(self.continueDiscovery)
	{
		__block NSString *address = nil;

		[sender.addresses enumerateObjectsUsingBlock:^(NSData * sa_data, NSUInteger idx, BOOL * stop) {
			const struct sockaddr * sa = (const struct sockaddr *)sender.addresses.firstObject.bytes;
			char buff[INET6_ADDRSTRLEN]={0};
			if(sa->sa_family == AF_INET) {
				inet_ntop(AF_INET, &(((sockaddr_in*)sa)->sin_addr), buff, INET6_ADDRSTRLEN);
				if(strlen(buff)) {
					address = [[NSString alloc] initWithUTF8String:buff];
					*stop = YES;
				}
			}
		}];

		if(!address) {
			[sender.addresses enumerateObjectsUsingBlock:^(NSData * sa_data, NSUInteger idx, BOOL * stop) {
				const struct sockaddr * sa = (const struct sockaddr *)sender.addresses.firstObject.bytes;
				char buff[INET6_ADDRSTRLEN]={0};
				if (sa->sa_family == AF_INET6) {
					inet_ntop(AF_INET6, &(((sockaddr_in6*)sa)->sin6_addr), buff, INET6_ADDRSTRLEN);
					if(strlen(buff)) {
						address = [[NSString alloc] initWithUTF8String:buff];
						*stop = YES;
					}
				}
			}];
		}

		if(!address)
			address = sender.hostName;
		else
			[address autorelease];

		if(address && (sender.port > 0))
		{
			NSString *toCheck = [NSString stringWithFormat:@"https://%@:%ld/", address, (long)sender.port];
			[self.checkers addOperationWithBlock:^{
				[self discoveredServer:toCheck];
			}];
		}
	}
	sender.delegate = nil;
	[sender release];
}


@end

