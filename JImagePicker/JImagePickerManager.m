//
//  JImagePickerManager.m
//  JImagePicker
//
//  Created by 江钧龙 on 15/9/11.
//  Copyright (c) 2015年 江钧龙. All rights reserved.
//

#import "JImagePickerManager.h"
#import <objc/runtime.h>

#pragma mark UIActionSheet Category

static char kUIActionSheetDismissKey;
static char KUIActionSheetCancleKey;

typedef void(^ActionSheetDismissHandler)(NSInteger selectIndex);
typedef void(^ActionSheetCancleHandel)();

@interface UIActionSheet (ImagePicker)<UIActionSheetDelegate>
@property (nonatomic ,copy)ActionSheetDismissHandler dismissHandler;
@property (nonatomic ,copy)ActionSheetCancleHandel cancleHandler;
@end

@implementation UIActionSheet(ImagePicker)
@dynamic dismissHandler;
@dynamic cancleHandler;
-(void)setDismissHandler:(ActionSheetDismissHandler)dismissHandler{
    objc_setAssociatedObject(self, &kUIActionSheetDismissKey, dismissHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(ActionSheetDismissHandler)dismissHandler{
    return objc_getAssociatedObject(self, &kUIActionSheetDismissKey);
}
-(void)setCancleHandler:(ActionSheetCancleHandel)cancleHandler{
    objc_setAssociatedObject(self, &KUIActionSheetCancleKey, cancleHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(ActionSheetCancleHandel)cancleHandler{
    return  objc_getAssociatedObject(self, &KUIActionSheetCancleKey);
}
#pragma mark - public

- (void)showInView:(UIView *)view withDismissHandler:(ActionSheetDismissHandler )dismissHandler andCancleHandler:(ActionSheetCancleHandel)cancelHandler{
    self.delegate = self;
    self.dismissHandler = dismissHandler;
    self.cancleHandler = cancelHandler;
    
    [self showInView:view];
}
#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        if (actionSheet.cancleHandler){
            actionSheet.cancleHandler();
        }
    }else{
        if (actionSheet.dismissHandler) {
            actionSheet.dismissHandler(buttonIndex);
        }
    }
    
}
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    if (actionSheet.cancleHandler) {
        actionSheet.cancleHandler();
    }
}
@end


#pragma mark - UIImagePicker catergory

static char kUIImagePickerSelectImageHandlerKey;
static char kUIImagePickerCancleHandlerKey;

typedef void(^ImagePickerControllerSelectImageHandler)(UIImage *image, NSDictionary *info, BOOL *dismiss);
typedef void(^ImagePickerControllerCancelBlock) ();


@interface UIImagePickerController (ImagePicker)<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>
@property (nonatomic ,copy)ImagePickerControllerSelectImageHandler selectImageHandler;
@property (nonatomic ,copy)ImagePickerControllerCancelBlock cancelBlock;
- (void)showWithModalViewController:(UIViewController *)modalViewController
                              animated:(BOOL)animated
                       selectedHandler:(ImagePickerControllerSelectImageHandler) slectedHandler
                                cancel:(ImagePickerControllerCancelBlock) cancelBlock;

@end

@implementation UIImagePickerController (ImagePicker)
@dynamic selectImageHandler;
@dynamic cancelBlock;

-(void)setSelectImageHandler:(ImagePickerControllerSelectImageHandler)selectImageHandler{
    objc_setAssociatedObject(self, &kUIImagePickerSelectImageHandlerKey, selectImageHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(ImagePickerControllerSelectImageHandler)selectImageHandler{
    return  objc_getAssociatedObject(self, &kUIImagePickerSelectImageHandlerKey);
}

-(void)setCancelBlock:(ImagePickerControllerCancelBlock)cancelBlock{
    objc_setAssociatedObject(self, &kUIImagePickerCancleHandlerKey, cancelBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(ImagePickerControllerCancelBlock)cancelBlock{
    return  objc_getAssociatedObject(self, &kUIImagePickerCancleHandlerKey);
}
-(void)showWithModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated selectedHandler:(ImagePickerControllerSelectImageHandler)slectedHandler cancel:(ImagePickerControllerCancelBlock)cancelBlock{
    
    self.delegate = self;
    self.selectImageHandler = slectedHandler;
    self.cancelBlock = cancelBlock;
    [modalViewController presentViewController:self animated:animated completion:NULL];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editedImage = (UIImage *)info[UIImagePickerControllerEditedImage];
    if(!editedImage)
        editedImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
    
    BOOL dismiss = YES;
    if (self.selectImageHandler) {
        self.selectImageHandler(editedImage,info,&dismiss);
    }
    if (dismiss) {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (picker.cancelBlock) {
        picker.cancelBlock();
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end

#pragma mark - UIImage Category
@interface UIImage (ResizeImage)
- (UIImage *)imageWithMaxSide:(CGFloat)length;
@end

@implementation UIImage (ResizeImage)
- (UIImage *)imageWithMaxSide:(CGFloat)length
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize imgSize = IMSizeReduce(self.size, length);
    UIImage *img = nil;
    
    // 创建一个 bitmap context
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, scale);
    // 将图片绘制到当前的 context 上
    [self drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)
           blendMode:kCGBlendModeNormal alpha:1.0];
    img = UIGraphicsGetImageFromCurrentImageContext();
    return img;
}

// 按比例减少尺寸
static inline
CGSize IMSizeReduce(CGSize size, CGFloat limit)
{
    CGFloat max = MAX(size.width, size.height);
    if (max < limit) {
        return size;
    }
    
    CGSize imgSize;
    CGFloat scale = size.height / size.width;
    
    if (size.width > size.height) {
        imgSize = CGSizeMake(limit, limit * scale);
    } else {
        imgSize = CGSizeMake(limit / scale, limit);
    }
    
    return imgSize;
}
@end



@interface JImagePickerManager()
@property (nonatomic ,copy)ImagePickerCompletion imagePickerCompletion;
@property (nonatomic ,weak)UIViewController * fromViewController;
@end

@implementation JImagePickerManager
+ (void)chooseImageFromViewController:(UIViewController*)viewController
                        allowEditting:(BOOL )editing
                   imageMaxSizeLength:(CGFloat)lenght
                     completionHandle:(ImagePickerCompletion)completionHandler{
    JImagePickerManager *imagePicker = [[JImagePickerManager alloc]init];
    imagePicker.fromViewController = viewController;
    imagePicker.imagePickerCompletion = completionHandler;
    //creat actionsheet
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                            delegate:nil
                                                   cancelButtonTitle:@"取消"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"拍照",@"从相册选取",nil];
    
    [actionSheet showInView:viewController.view withDismissHandler:^(NSInteger selectIndex){
       
        UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
        pickerController.allowsEditing = editing;
        if (selectIndex == 0) {
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else{
            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        [pickerController showWithModalViewController:viewController animated:YES selectedHandler:^(UIImage *image, NSDictionary *info, BOOL *dismiss) {
            //resize image
            UIImage *lastImage = nil;
            if (lenght > 0) {
                lastImage = [image imageWithMaxSide:lenght];
            } else {
                lastImage = image;
            }
            imagePicker.imagePickerCompletion(lastImage,info,dismiss);
        } cancel:^{
            //cancle
            
        }];
    }andCancleHandler:^{
        //cancle
    }];
    
    

}

@end

