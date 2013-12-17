//
//  SHCFoldersViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCFoldersViewController.h"
#import "SHCAPIManager.h"
#import "SHCModelManager.h"
#import "SHCFolderTableViewCell.h"
#import "SHCFolder.h"
#import "UIAlertView+Blocks.h"
#import "SHCOAuthManager.h"
#import "SHCLoginViewController.h"
#import "SHCDocumentsViewController.h"

// Storyboard identifiers (to enable programmatic storyboard instantiation)
NSString *const kFoldersViewControllerIdentifier = @"FoldersViewController";

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushFoldersIdentifier = @"PushFolders";

// Google Analytics screen name
NSString *const kFoldersViewControllerScreenName = @"Folders";

@interface SHCFoldersViewController ()

@end

@implementation SHCFoldersViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    self.baseEntity = [[SHCModelManager sharedManager] folderEntity];
    self.sortDescriptorKeyPath = NSStringFromSelector(@selector(name));

    self.screenName = kFoldersViewControllerScreenName;

    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_LOGOUT_BUTTON_TITLE", @"Log Out");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPushDocumentsIdentifier]) {
        SHCFolder *folder = (SHCFolder *)sender;

        SHCDocumentsViewController *documentsViewController = (SHCDocumentsViewController *)segue.destinationViewController;
        documentsViewController.folder = folder;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHCFolder *folder = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFolderTableViewCellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = folder.name;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHCFolder *folder = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [self performSegueWithIdentifier:kPushDocumentsIdentifier sender:folder];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

*/

#pragma mark - IBActions

- (IBAction)didTapLogoutButton:(id)sender
{
    [[SHCOAuthManager sharedManager] removeAllTokens];

    [[NSNotificationCenter defaultCenter] postNotificationName:kPopToLoginViewControllerNotificationName object:nil];
}

#pragma mark - Private methods

- (void)updateContentsFromServer
{
    [[SHCAPIManager sharedManager] updateRootResourceWithSuccess:^{
        [self updateFetchedResultsController];
        [self programmaticallyEndRefresh];
    } failure:^(NSError *error) {

        [self programmaticallyEndRefresh];

        [UIAlertView showWithTitle:NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error")
                           message:[error localizedDescription]
                 cancelButtonTitle:nil
                 otherButtonTitles:@[NSLocalizedString(@"GENERIC_OK_BUTTON_TITLE", @"OK")]
                          tapBlock:nil];
    }];
}

@end
