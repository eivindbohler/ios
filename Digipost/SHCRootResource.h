//
//  SHCRootResource.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SHCNotice.h"

// Core Data model entity names
extern NSString *const kRootResourceEntityName;

@class SHCMailbox;

@interface SHCRootResource : NSManagedObject

// Attributes
@property (strong, nonatomic) NSNumber *authenticationLevel;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSString *currentBankAccount;
@property (strong, nonatomic) NSString *currentBankAccountUri;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *logoutUri;
@property (strong, nonatomic) NSString *middleName;
@property (strong, nonatomic) NSNumber *numberOfCards;
@property (strong, nonatomic) NSNumber *numberOfCardsReadyForVerification;
@property (strong, nonatomic) NSNumber *numberOfReceiptsHiddenUntilVerification;
@property (strong, nonatomic) NSNumber *unreadItemsInInbox;
@property (strong, nonatomic) NSString *uploadDocumentUri;
// Relationships
@property (strong, nonatomic) NSSet *mailboxes;
/**
 *  Attribute not stored in core data, should only be shown when once.
 */
@property (nonatomic,strong) SHCNotice *notice;

+ (instancetype)existingRootResourceInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)rootResourceWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)deleteAllRootResourcesInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end


@interface SHCRootResource (CoreDataGeneratedAccessors)

- (void)addMailboxesObject:(SHCMailbox *)value;
- (void)removeMailboxesObject:(SHCMailbox *)value;
- (void)addMailboxes:(NSSet *)values;
- (void)removeMailboxes:(NSSet *)values;

@end
