#import "ConnectionController.h"
#import "SharedDefine.h"
#import "Protocol.h"

@interface ConnectionController()
-(const char*)simpleCStringConvert:(NSString*)string;
@end

@implementation ConnectionController

-(instancetype)init{
	self = [super init];
	self.state = kStateDisconnected;
	self.HOST = @"localhost";
	self.PORT = 6667;
	return self;
}

-(void)establishConnection
{
    CFReadStreamRef ingoingConnectionCF;
    CFWriteStreamRef outgoingConnectionCF;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)self.HOST, self.PORT, &ingoingConnectionCF, &outgoingConnectionCF);
    ingoingConnection = (NSInputStream *)ingoingConnectionCF;
    outgoingConnection = (NSOutputStream *)outgoingConnectionCF;

	[ingoingConnection setDelegate:self];
	[outgoingConnection setDelegate:self];

	[ingoingConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outgoingConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

	[ingoingConnection open];
	[outgoingConnection open];

	[[NSRunLoop currentRunLoop] run];
}


-(void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
	switch(streamEvent){
		case NSStreamEventNone:
			[self handleEventNone];
			break;
		case NSStreamEventOpenCompleted:
			[self handleConnected];
			break;
		case NSStreamEventHasBytesAvailable:
			[self handleBytesAvailable];
			break;
		case NSStreamEventErrorOccurred:
			[self handleConnectionError];
			break;
		case NSStreamEventEndEncountered:
			[self handleDisconnected];
			break;
		case NSStreamEventHasSpaceAvailable:
			break;
		}
}

-(void)handleEventNone
{
	printf("%s",IRC_NAME);
}

-(void)handleConnected
{	
	if(self.state == kStateDisconnected){
	const char* host = [self.HOST cStringUsingEncoding:[NSString defaultCStringEncoding]];
	NSLog(@"%s Connected to %s:%d",IRC_NAME,host,self.PORT);
	self.state = kStateConnected;
	}
}

-(void)handleBytesAvailable
{
	uint8_t buf[1024];
	int rLen; 
	while([ingoingConnection hasBytesAvailable]){
		rLen = [ingoingConnection read:buf maxLength:sizeof(buf)];
		if(rLen > 0){//GOT DATA
			__unused NSString* dataStream = [[NSString alloc] initWithBytes:buf length:rLen encoding:NSASCIIStringEncoding];
		}
		if(dataStream){
			printf("%s %s",IRC_NAME,[self simpleCStringConvert:dataStream]);
		}
	}
}

-(void)handleConnectionError
{
	const char* host = [self simpleCStringConvert:self.HOST];
	printf("%s There was an error while connecting to <%s:%d>",IRC_NAME,host,self.PORT);
}

-(void)handleDisconnected
{
	const char* host = [self simpleCStringConvert:self.HOST];
	printf("%s Disconnected from <%s:%d>",IRC_NAME,host,self.PORT);
}

-(const char*)simpleCStringConvert:(NSString*)string
{
	const char* str = [string cStringUsingEncoding:[NSString defaultCStringEncoding]];
	return str;
}

@end










