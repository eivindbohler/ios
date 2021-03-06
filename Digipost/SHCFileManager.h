//
//  SHCFileManager.h
//  Digipost
//
//  Created by Eivind Bohler on 02.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>

// Custom NSError code enum
typedef NS_ENUM(NSUInteger, SHCFileManagerErrorCodeDecrypting) {
    SHCFileManagerErrorCodeDecryptingNoPassword = 1,
    SHCFileManagerErrorCodeDecryptingEncryptedFileNotFound,
    SHCFileManagerErrorCodeDecryptingErrorReadingEncryptedFile,
    SHCFileManagerErrorCodeDecryptingDecryptionError,
    SHCFileManagerErrorCodeDecryptingRemovingDecryptedFile,
    SHCFileManagerErrorCodeDecryptingWritingDecryptedFile
};

typedef NS_ENUM(NSUInteger, SHCFileManagerErrorCodeEncrypting) {
    SHCFileManagerErrorCodeEncryptingNoPassword = 1,
    SHCFileManagerErrorCodeEncryptingDecryptedFileNotFound,
    SHCFileManagerErrorCodeEncryptingErrorReadingDecryptedFile,
    SHCFileManagerErrorCodeEncryptingEncryptionError,
    SHCFileManagerErrorCodeEncryptingRemovingEncryptedFile,
    SHCFileManagerErrorCodeEncryptingWritingEncryptedFile
};

// Custom NSError consts
extern NSString *const kFileManagerDecryptingErrorDomain;
extern NSString *const kFileManagerEncryptingErrorDomain;

@class SHCBaseEncryptedModel;

@interface SHCFileManager : NSObject

+ (instancetype)sharedFileManager;
- (BOOL)decryptDataForBaseEncryptionModel:(SHCBaseEncryptedModel *)baseEncryptionModel error:(NSError *__autoreleasing *)error;
- (BOOL)encryptDataForBaseEncryptionModel:(SHCBaseEncryptedModel *)baseEncryptionModel error:(NSError *__autoreleasing *)error;
- (BOOL)removeAllDecryptedFiles;
- (BOOL)removeAllFiles;
- (BOOL)removeAllFilesInFolder:(NSString *)folder;
- (NSString *)encryptedFilesFolderPath;
- (NSString *)decryptedFilesFolderPath;
- (NSString *)uploadsFolderPath;
- (NSString *)inboxFolderPath;

@end
