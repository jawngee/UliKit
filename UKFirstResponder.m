//
//  UKFirstResponder.m
//  Shovel
//
//  Created by Uli Kusterer on 04.10.04.
//  Copyright 2004 Uli Kusterer.
//
//	This software is provided 'as-is', without any express or implied
//	warranty. In no event will the authors be held liable for any damages
//	arising from the use of this software.
//
//	Permission is granted to anyone to use this software for any purpose,
//	including commercial applications, and to alter it and redistribute it
//	freely, subject to the following restrictions:
//
//	   1. The origin of this software must not be misrepresented; you must not
//	   claim that you wrote the original software. If you use this software
//	   in a product, an acknowledgment in the product documentation would be
//	   appreciated but is not required.
//
//	   2. Altered source versions must be plainly marked as such, and must not be
//	   misrepresented as being the original software.
//
//	   3. This notice may not be removed or altered from any source
//	   distribution.
//

#import "UKFirstResponder.h"

@interface UKFirstResponder (PrivateMethods)

-(id)	responderForAction: (SEL)itemAction;

@end

static UKFirstResponder*	sFirstResponder = nil;


@implementation UKFirstResponder

+(id)	firstResponder
{
	if( !sFirstResponder )
		sFirstResponder = [[[self class] alloc] init];
	
	return sFirstResponder;
}


// This is a singleton:
+(id)	init
{
	if( !sFirstResponder )
	{
		self = [super init];
		sFirstResponder = self;
		
		return self;
	}
	else
	{
		[self autorelease];
		return sFirstResponder;
	}
}

// -----------------------------------------------------------------------------
//	Finding out what messages the first responder understands/sending messages:
// -----------------------------------------------------------------------------

-(id)	performSelector: (SEL)itemAction withObject: (id)obj
{
	BOOL	does = [super respondsToSelector: itemAction];
	if( does )
		return [super performSelector: itemAction withObject: obj];
	
	id	resp = [self responderForAction: itemAction];
	if( !resp )
		[self doesNotRecognizeSelector: itemAction];
	return [resp performSelector: itemAction withObject: obj];
}

-(id)	performSelector: (SEL)itemAction
{
	BOOL	does = [super respondsToSelector: itemAction];
	if( does )
		return [super performSelector: itemAction];
	
	id	resp = [self responderForAction: itemAction];
	if( !resp )
		[self doesNotRecognizeSelector: itemAction];
	return [resp performSelector: itemAction];
}

-(BOOL)	respondsToSelector: (SEL)itemAction
{
	BOOL	does = [super respondsToSelector: itemAction];
	
	return( does || ([self responderForAction: itemAction] != nil) );
}


// -----------------------------------------------------------------------------
//	Forwarding unknown methods to the first responder:
// -----------------------------------------------------------------------------

-(NSMethodSignature*)	methodSignatureForSelector: (SEL)itemAction
{
	NSMethodSignature*	sig = [super methodSignatureForSelector: itemAction];
	id					friend = [self responderForAction: itemAction];

	if( sig )
		return sig;
	
	if( friend )
		return [friend methodSignatureForSelector: itemAction];
	
	return nil;
}

-(void)	forwardInvocation: (NSInvocation*)invocation
{
    SEL itemAction = [invocation selector];
	id	friend = [self responderForAction: itemAction];

    if( friend )
        [invocation invokeWithTarget: friend];
    else
        [self doesNotRecognizeSelector: itemAction];
}

@end


@implementation UKFirstResponder (PrivateMethods)

-(id)	responderForAction: (SEL)itemAction
{
	NSResponder*	resp = [[NSApp keyWindow] firstResponder];
	id				actualResponder = nil;

	do
	{
		if( [resp respondsToSelector: itemAction] )
			actualResponder = resp;
		else if( [resp respondsToSelector: @selector(delegate)] )
		{
			id del = [(id)resp delegate];
			if( [del respondsToSelector: itemAction] )
				actualResponder = del;
		}
	}
	while( !actualResponder && (resp = [resp nextResponder]) );
	
	if( !actualResponder )
	{
		if( [NSApp respondsToSelector: itemAction] )
			actualResponder = NSApp;
		else
		{
			id del = [NSApp delegate];
			if( [del respondsToSelector: itemAction] )
				actualResponder = del;
		}
	}
	
	return actualResponder;
}

@end
