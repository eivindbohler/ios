//
//  SHCBaseTableViewController.h
//  Digipost
//
//  Created by Eivind Bohler on 16.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class SHCRootResource;

@interface SHCBaseTableViewController : UITableViewController

@property (strong, nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSEntityDescription *baseEntity;
@property (strong, nonatomic) NSArray *sortDescriptors;
@property (strong, nonatomic) NSPredicate *predicate;
@property (copy, nonatomic) NSString *screenName;
@property (strong, nonatomic) SHCRootResource *rootResource;

// Override these methods in subclass
- (void)updateContentsFromServerUserInitiatedRequest:(NSNumber *) userDidInititateRequest;
- (void)updateNavbar;

- (void)updateFetchedResultsController;
- (void)programmaticallyEndRefresh;


@end
