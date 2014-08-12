//
//  ConfigData.h
//  Smartime
//
//  Created by Ricardo Pereira on 11/04/14.
//  Copyright (c) 2014 Ricardo Pereira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ConfigData : NSManagedObject

@property (nonatomic, retain) NSNumber * ticketNumber;
@property (nonatomic, retain) NSNumber * ticketCurrent;
@property (nonatomic, retain) NSNumber * ticketLast;
@property (nonatomic, retain) NSNumber * idService;
@property (nonatomic, retain) NSString * serverAddress;
@property (nonatomic, retain) NSNumber * idTerminal;
@property (nonatomic, retain) NSNumber * idDesk;
@property (nonatomic, retain) NSNumber * idStore;
@property (nonatomic, retain) NSString * info;

@end
