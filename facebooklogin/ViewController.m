//
//  ViewController.m
//  facebooklogin
//
//  Created by NEIL on 2015/4/21.
//  Copyright (c) 2015年 NEIL. All rights reserved.
//

#import "ViewController.h"
#import <PFFacebookUtils.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface ViewController ()

@end

@implementation ViewController
- (IBAction)login:(id)sender {

    
    NSArray *permissionArray = @[@"user_about_me",@"user_relationships",@"user_birthday",@"user_location",@"user_friends",@"email"];
    
    [PFFacebookUtils logInWithPermissions:permissionArray block:^(PFUser *user,NSError *error){
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"oh NO");
                errorMessage = @" Oh no";
            }
            else{
                NSLog(@"ohoh error ");
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"log in error" message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        else{
            if (user.isNew) {
                NSLog(@"user with facebook signed up and logged in !");
            }
            else{
                NSLog(@"user with facebook loggedin");
            }
            [self saveUserDataToParse];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) saveUserDataToParse
{
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            //some people may be make birthday public
            //NSString *birthday = userData[@"birthday"];
            NSString *email =userData[@"email"];
            NSString *pictureURL =[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            NSString *gender =userData[@"gender"];
            
            [[PFUser currentUser] setObject:name forKey:@"name"];
            [[PFUser currentUser] setObject:facebookID forKey:@"facebookID"];
            //[[PFUser currentUser] setObject:birthday forKey:@"birthday"];
            [[PFUser currentUser] setObject:email forKey:@"email"];
            [[PFUser currentUser] setObject:pictureURL forKey:@"pictureURL"];
            [[PFUser currentUser] setObject:gender forKey:@"gender"];
            
            [[PFUser currentUser] saveInBackground];
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
}

@end
