//
//  ViewController.m
//  JImagePicker
//
//  Created by 江钧龙 on 15/9/11.
//  Copyright (c) 2015年 江钧龙. All rights reserved.
//

#import "ViewController.h"
#import "JImagePickerManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

   
}

- (IBAction)choose:(id)sender {
    
    [JImagePickerManager chooseImageFromViewController:self allowEditting:YES imageMaxSizeLength:320 completionHandle:^ (UIImage *  image,  NSDictionary *  pickingMediainfo, BOOL *  dismiss){
        //image
    }];
    
   
}


@end
