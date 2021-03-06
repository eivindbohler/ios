//
//  SHCDocument.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Core Data model entity names
extern NSString *const kDocumentEntityName;

// API keys
extern NSString *const kDocumentDocumentAPIKey;

@class SHCAttachment;
@class SHCFolder;

@interface SHCDocument : NSManagedObject

// Attributes
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSString *creatorName;
@property (strong, nonatomic) NSString *deleteUri;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *updateUri;

// Relationships
@property (strong, nonatomic) NSOrderedSet *attachments;
@property (strong, nonatomic) SHCFolder *folder;

+ (instancetype)documentWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)existingDocumentWithUpdateUri:(NSString *)updateUri inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)reconnectDanglingDocumentsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)deleteAllDocumentsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)allDocumentsInFolderWithName:(NSString *)folderName inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSString *)stringForDocumentDate:(NSDate *)date;
- (SHCAttachment *)mainDocumentAttachment;
- (void)updateWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@interface SHCDocument (CoreDataGeneratedAccessors)

- (void)addAttachmentsObject:(SHCAttachment *)value;
- (void)removeAttachmentsObject:(SHCAttachment *)value;

@end
