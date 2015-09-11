//
//  JImagePickerManager.h
//  JImagePicker
//
//  Created by 江钧龙 on 15/9/11.
//  Copyright (c) 2015年 江钧龙. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
typedef void (^ImagePickerCompletion) (UIImage *  image,  NSDictionary *  pickingMediainfo, BOOL *  dismiss);

@interface JImagePickerManager : NSObject

+ (void)chooseImageFromViewController:(UIViewController*)viewController
                        allowEditting:(BOOL )editing
                   imageMaxSizeLength:(CGFloat)lenght
                     completionHandle:(ImagePickerCompletion)completionHandler;

@end
