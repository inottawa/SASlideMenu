//
//  SASlideContentSegue.m
//  SASlideMenu
//
//  Created by Stefano Antonelli on 1/17/13.
//  Edited by Ryan Spears on 6/18/13.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SASlideMenuContentSegue.h"
#import "SASlideMenuRootViewController.h"
#import "SASlideMenuViewController.h"

@implementation SASlideMenuContentSegue

-(void) perform{
    
    SASlideMenuViewController* source = self.sourceViewController;
    SASlideMenuRootViewController* rootController = source.rootController;
    UINavigationController* destination = self.destinationViewController;
    
    UIButton* menuButton = nil;
    
    if ([destination isKindOfClass:[UINavigationController class]]) {
        UINavigationItem* navigationItem = destination.navigationBar.topItem;
        menuButton = [[UIButton alloc] init];
        [menuButton addTarget:rootController action:@selector(doSlideToSide) forControlEvents:UIControlEventTouchUpInside];
        navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        [rootController.leftMenu.slideMenuDataSource configureMenuButton:menuButton];
    } else if ([destination isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *sv = (UISplitViewController *)destination;
        id viewController = [sv.viewControllers objectAtIndex:0];
        if([viewController isMemberOfClass:[UITabBarController class]]) {
            UITabBarController *tabBar = (UITabBarController*)viewController;
            for (id idController in tabBar.viewControllers) {
                if([idController isMemberOfClass:[UINavigationController class]]) {
                    UINavigationController *nvController = (UINavigationController*)idController;
                    if(nvController) {
                        UINavigationItem* navigationItem = nvController.navigationBar.topItem;
                        menuButton = [[UIButton alloc] init];
                        [menuButton addTarget:rootController action:@selector(doSlideToSide) forControlEvents:UIControlEventTouchUpInside];
                        navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
                        [rootController.leftMenu.slideMenuDataSource configureSplitMenuButton:menuButton];
                    }
                }
            }
        } else {
            UINavigationController *navC = [sv.viewControllers objectAtIndex:0];
            UINavigationItem* navigationItem = navC.navigationBar.topItem;
            menuButton = [[UIButton alloc] init];
            [menuButton addTarget:rootController action:@selector(doSlideToSide) forControlEvents:UIControlEventTouchUpInside];
            navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
            [rootController.leftMenu.slideMenuDataSource configureSplitMenuButton:menuButton];
        }
    }
    
    Boolean hasRightMenu = NO;
    rootController.isRightMenuEnabled = NO;
    NSIndexPath* selectedIndexPath = [rootController.leftMenu.tableView indexPathForSelectedRow];
    
    if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(hasRightMenuForIndexPath:)]) {
        hasRightMenu = [rootController.leftMenu.slideMenuDataSource hasRightMenuForIndexPath:selectedIndexPath];
    }
    if (hasRightMenu) {
        rootController.isRightMenuEnabled = YES;
        if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(configureRightMenuButton:)]) {
            UIButton* rightMenuButton = [[UIButton alloc] init];
            [rootController.leftMenu.slideMenuDataSource configureRightMenuButton:rightMenuButton];
            [rightMenuButton addTarget:rootController action:@selector(rightMenuAction) forControlEvents:UIControlEventTouchUpInside];
            
            UINavigationItem* navigationItem = destination.navigationBar.topItem;
            navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightMenuButton];
        }
    }
    
    if([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(configureSlideLayer:)]) {
        [rootController.leftMenu.slideMenuDataSource configureSlideLayer:[destination.view layer]];
    }else{
        CALayer* layer = destination.view.layer;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 0.3;
        layer.shadowOffset = CGSizeMake(-15, 0);
        layer.shadowRadius = 10;
        layer.masksToBounds = NO;
        layer.shadowPath =[UIBezierPath bezierPathWithRect:layer.bounds].CGPath;
    }
    
    [rootController switchToContentViewController:destination];
    
    if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(segueIdForIndexPath:)]) {
        [rootController addContentViewController:destination withIndexPath:selectedIndexPath];
    }
    Boolean disablePanGesture= NO;
    if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(disablePanGestureForIndexPath:)]) {
        disablePanGesture = [rootController.leftMenu.slideMenuDataSource disablePanGestureForIndexPath:selectedIndexPath];
    }
    if (!disablePanGesture) {
        UIPanGestureRecognizer* panGesture= [[UIPanGestureRecognizer alloc] initWithTarget:rootController action:@selector(panItem:)];
        [panGesture setMaximumNumberOfTouches:2];
        [panGesture setDelegate:source];
        [destination.view addGestureRecognizer:panGesture];
    }
    
}

@end
