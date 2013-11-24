//
//  ExpandingCellDemoVC.m
//  ABMExpandingTableViewCells
//
//  Created by Alex Berger on 24/11/13.
//  Copyright (c) 2013 aberger.me. All rights reserved.
//

#import "ExpandingCellDemoVC.h"


@interface ExpandingCellDemoVC ()

@property (nonatomic) NSArray *dataSource;
@property (nonatomic) NSIndexPath *expandingIndexPath;
@property (nonatomic) NSIndexPath *expandedIndexPath;


- (NSIndexPath *)actualIndexPathForTappedIndexPath:(NSIndexPath *)indexPath;
- (void)createDataSourceArray;

@end


@implementation ExpandingCellDemoVC

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self createDataSourceArray];
}

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
		// take expanded cell into account when returning number of rows
	if (self.expandedIndexPath) {
		return [self.dataSource count] + 1;
	}
	
    return [self.dataSource count];
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	static NSString *cellIdentifier = nil;
	
		// init expanded cell
	if ([indexPath isEqual:self.expandedIndexPath]) {
		cellIdentifier = @"ExpandedCellIdentifier";
	}
		// init expanding cell
	else {
		cellIdentifier = @"ExpandingCellIdentifier";
	}
	
	cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
										   forIndexPath:indexPath];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:cellIdentifier];
	}
	
		// set text in expanding cell
	if ([[cell reuseIdentifier] isEqualToString:@"ExpandingCellIdentifier"]) {
		NSIndexPath *theIndexPath = [self actualIndexPathForTappedIndexPath:indexPath];
		[cell.textLabel setText:[self.dataSource objectAtIndex:[theIndexPath row]]];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
		// deselect row
	[tableView deselectRowAtIndexPath:indexPath
							 animated:NO];
	
		// get the actual index path
	indexPath = [self actualIndexPathForTappedIndexPath:indexPath];
	
		// save the expanded cell to delete it later
	NSIndexPath *theExpandedIndexPath = self.expandedIndexPath;
	
		// same row tapped twice - get rid of the expanded cell
	if ([indexPath isEqual:self.expandingIndexPath]) {
		self.expandingIndexPath = nil;
		self.expandedIndexPath = nil;
	}
		// add the expanded cell
	else {
		self.expandingIndexPath = indexPath;
		self.expandedIndexPath = [NSIndexPath indexPathForRow:[indexPath row] + 1
													inSection:[indexPath section]];
	}
	
	[tableView beginUpdates];
	
	if (theExpandedIndexPath) {
		[_theTableView deleteRowsAtIndexPaths:@[theExpandedIndexPath]
							 withRowAnimation:UITableViewRowAnimationNone];
	}
	if (self.expandedIndexPath) {
		[_theTableView insertRowsAtIndexPaths:@[self.expandedIndexPath]
							 withRowAnimation:UITableViewRowAnimationNone];
	}
	
	[tableView endUpdates];
}

#pragma mark - controller methods

- (void)createDataSourceArray
{
	NSMutableArray *dataSourceMutableArray = [NSMutableArray array];
	
	for (int i = 0; i <= 20; i++) {
		NSString *dataSourceString = [NSString stringWithFormat:@"Row #%u", i];
		[dataSourceMutableArray addObject:dataSourceString];
	}
	
	self.dataSource = [NSArray arrayWithArray:dataSourceMutableArray];
}

- (NSIndexPath *)actualIndexPathForTappedIndexPath:(NSIndexPath *)indexPath
{
	if (self.expandedIndexPath && [indexPath row] > [self.expandedIndexPath row]) {
		return [NSIndexPath indexPathForRow:[indexPath row] - 1
								  inSection:[indexPath section]];
	}
	
	return indexPath;
}

@end
