//
//  URLTextFieldViewController.m
//  AppInWebview
//
//  Created by Dermendzhiev, Teodor (external - Project) on 3.07.22.
//  Copyright © 2022 Progress. All rights reserved.
//

#import "URLTextFieldViewController.h"


@interface URLTextFieldViewController ()
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;

@end

@implementation URLTextFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)didPressRun:(id)sender {
    [self.urlLoader loadURL:_urlTextField.text];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
