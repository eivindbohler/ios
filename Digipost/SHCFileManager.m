//
//  SHCFileManager.m
//  Digipost
//
//  Created by Eivind Bohler on 02.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "SHCFileManager.h"
#import "NSString+SHA1String.h"
#import <RNCryptor/RNEncryptor.h>
#import <RNCryptor/RNDecryptor.h>
#import "SHCOAuthManager.h"
#import "SHCAttachment.h"
#import "NSError+ExtraInfo.h"

// Custom NSError consts
NSString *const kFileManagerDecryptingErrorDomain = @"FileManagerDecryptingErrorDomain";
NSString *const kFileManagerEncryptingErrorDomain = @"FileManagerEncryptingErrorDomain";

NSString *const kFileManagerEncryptedFilesFolderName = @"encryptedFiles";
NSString *const kFileManagerDecryptedFilesFolderName = @"decryptedFiles";

@implementation SHCFileManager

#pragma mark - Public methods

+ (instancetype)sharedFileManager
{
    static SHCFileManager *sharedInstance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SHCFileManager alloc] init];
    });

    return sharedInstance;
}

- (BOOL)decryptDataForAttachment:(SHCAttachment *)attachment error:(NSError *__autoreleasing *)error
{
    NSString *password = [SHCOAuthManager sharedManager].refreshToken;

    if (!password) {
        DDLogError(@"Error: Can't decrypt data for attachment without a password");

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerDecryptingErrorDomain
                                         code:SHCFileManagerErrorCodeDecryptingNoPassword
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"FILE_MANAGER_DECRYPT_ERROR_NO_PASSWORD", @"No password")}];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    // First, ensure that we have the encrypted file
    NSString *encryptedFilePath = [attachment encryptedFilePath];

    if (![[NSFileManager defaultManager] fileExistsAtPath:encryptedFilePath]) {
        DDLogError(@"Error: Can't decrypt data for attachment without an encrypted file at %@", encryptedFilePath);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerDecryptingErrorDomain
                                         code:SHCFileManagerErrorCodeDecryptingEncryptedFileNotFound
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"FILE_MANAGER_DECRYPT_ERROR_ENCRYPTED_FILE_NOT_FOUND", @"Encrypted file not found")}];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    NSError *localError = nil;
    NSData *encryptedFileData = [NSData dataWithContentsOfFile:encryptedFilePath options:NSDataReadingMappedIfSafe error:&localError];
    if (localError) {
        DDLogError(@"Error reading encrypted file: %@", [localError localizedDescription]);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerDecryptingErrorDomain
                                         code:SHCFileManagerErrorCodeDecryptingErrorReadingEncryptedFile
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"FILE_MANAGER_DECRYPT_ERROR_ERROR_READING_ENCRYPTED_FILE", @"Error reading encrypted file")}];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    NSData *decryptedFileData = [RNDecryptor decryptData:encryptedFileData
                                            withSettings:kRNCryptorAES256Settings
                                                password:password
                                                   error:&localError];
    if (localError) {
        DDLogError(@"Error decrypting file: %@", [localError localizedDescription]);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerDecryptingErrorDomain
                                         code:SHCFileManagerErrorCodeDecryptingDecryptionError
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"FILE_MANAGER_DECRYPT_ERROR_DECRYPTION_ERROR", @"Decryption error")}];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    NSString *decryptedFilePath = [attachment decryptedFilePath];

    // If we previously haven't done a proper cleanup job and the decrypted file still exists,
    // we need to manually remote it before writing a new one, to avoid NSFileManager throwing a tantrum
    if ([[NSFileManager defaultManager] fileExistsAtPath:decryptedFilePath]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:decryptedFilePath error:&localError]) {
            DDLogError(@"Error removing decrypted file: %@", [localError localizedDescription]);

            if (error) {
                *error = [NSError errorWithDomain:kFileManagerDecryptingErrorDomain
                                             code:SHCFileManagerErrorCodeDecryptingRemovingDecryptedFile
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"FILE_MANAGER_DECRYPT_ERROR_REMOVING_DECRYPTED_FILE", @"Error removing decrypted file")}];
                (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
            }

            return NO;
        }
    }

    if (![decryptedFileData writeToFile:decryptedFilePath options:NSDataWritingAtomic error:&localError]) {
        DDLogError(@"Error writing decrypted file: %@", [localError localizedDescription]);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerDecryptingErrorDomain
                                         code:SHCFileManagerErrorCodeDecryptingWritingDecryptedFile
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"FILE_MANAGER_DECRYPT_ERROR_WRITING_DECRYPTED_FILE", @"Error writing decrypted file")}];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    return YES;
}

- (BOOL)encryptDataForAttachment:(SHCAttachment *)attachment error:(NSError *__autoreleasing *)error
{
    NSString *password = [SHCOAuthManager sharedManager].refreshToken;

    if (!password) {
        DDLogError(@"Error: Can't encrypt data for attachment without a password");

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerEncryptingErrorDomain
                                         code:SHCFileManagerErrorCodeEncryptingNoPassword
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"FILE_MANAGER_ENCRYPT_ERROR_NO_PASSWORD", @"No password")}];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    // First, ensure htat we have the decrypted file
    NSString *decryptedFilePath = [attachment decryptedFilePath];

    if (![[NSFileManager defaultManager] fileExistsAtPath:decryptedFilePath]) {
        DDLogError(@"Error: Can't encrypt data for attachment without a decrypted file at %@", decryptedFilePath);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerEncryptingErrorDomain
                                         code:SHCFileManagerErrorCodeEncryptingDecryptedFileNotFound
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"FILE_MANAGER_ENCRYPT_ERROR_DECRYPTED_FILE_NOT_FOUND", @"Decrypted file not found")}];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    NSError *localError = nil;
    NSData *decryptedFileData = [NSData dataWithContentsOfFile:decryptedFilePath options:NSDataReadingMappedIfSafe error:&localError];
    if (localError) {
        DDLogError(@"Error reading decrypted file: %@", [localError localizedDescription]);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerEncryptingErrorDomain
                                         code:SHCFileManagerErrorCodeEncryptingErrorReadingDecryptedFile
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"FILE_MANAGER_ENCRYPT_ERROR_ERROR_READING_DECRYPTED_FILE", @"Error reading decrypted file")}];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    NSData *encryptedFileData = [RNEncryptor encryptData:decryptedFileData
                                            withSettings:kRNCryptorAES256Settings
                                                password:password
                                                   error:&localError];
    if (localError) {
        DDLogError(@"Error encrypting file: %@", [localError localizedDescription]);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerEncryptingErrorDomain
                                         code:SHCFileManagerErrorCodeEncryptingEncryptionError
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"FILE_MANAGER_ENCRYPT_ERROR_ENCRYPTION_ERROR", @"Encryption error")}];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    NSString *encryptedFilePath = [attachment encryptedFilePath];

    // If we previously haven't done a proper cleanup job and the encrypted file still exists,
    // we need to manually remote it before writing a new one, to avoid NSFileManager throwing a tantrum
    if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedFilePath]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:encryptedFilePath error:&localError]) {
            DDLogError(@"Error removing encrypted file: %@", [localError localizedDescription]);

            if (error) {
                *error = [NSError errorWithDomain:kFileManagerEncryptingErrorDomain
                                             code:SHCFileManagerErrorCodeEncryptingRemovingEncryptedFile
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"FILE_MANAGER_ENCRYPT_ERROR_REMOVING_ENCRYPTED_FILE", @"Error removing encrypted file")}];
                (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
            }

            return NO;
        }
    }

    if (![encryptedFileData writeToFile:encryptedFilePath options:NSDataWritingAtomic error:&localError]) {
        DDLogError(@"Error writing encrypted file: %@", [localError localizedDescription]);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerEncryptingErrorDomain
                                         code:SHCFileManagerErrorCodeEncryptingWritingEncryptedFile
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"FILE_MANAGER_ENCRYPT_ERROR_WRITING_ENCRYPTED_FILE", @"Error writing decrypted file")}];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    return YES;
}

- (BOOL)removeAllDecryptedFiles
{
    BOOL success = [self removeAllFilesInFolder:[self decryptedFilesFolderPath]];

    return success;
}

- (BOOL)removeAllFiles
{
    BOOL successfullyRemovedEncryptedFiles = [self removeAllFilesInFolder:[self encryptedFilesFolderPath]];
    BOOL successfullyRemovedDecryptedFiles = [self removeAllFilesInFolder:[self decryptedFilesFolderPath]];

    return successfullyRemovedEncryptedFiles && successfullyRemovedDecryptedFiles;
}

- (NSString *)encryptedFilesFolderPath
{
    return [self folderPathWithFolderName:kFileManagerEncryptedFilesFolderName];
}

- (NSString *)decryptedFilesFolderPath
{
    return [self folderPathWithFolderName:kFileManagerDecryptedFilesFolderName];
}

#pragma mark - Private methods

- (NSString *)folderPathWithFolderName:(NSString *)folderName
{
    NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:folderName];

    BOOL isFolder = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isFolder]) {
        if (isFolder) {
            return folderPath;
        }
    }

    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        DDLogError(@"Error creating folder: %@", [error localizedDescription]);
        return nil;
    }

    return folderPath;
}

- (BOOL)removeAllFilesInFolder:(NSString *)folder
{
    NSError *error = nil;
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:&error];
    if (error) {
        DDLogError(@"Error getting list of files: %@", [error localizedDescription]);
        return NO;
    } else {
        NSUInteger failures = 0;

        for (NSString *fileName in fileNames) {
            NSString *filePath = [folder stringByAppendingPathComponent:fileName];

            if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
                DDLogError(@"Error removing file: %@", [error localizedDescription]);
                failures++;
            }
        }

        if (failures > 0) {
            return NO;
        }
    }
    
    return YES;
}

@end
