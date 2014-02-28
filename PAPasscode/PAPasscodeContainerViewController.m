//
//  PAPasscodeContainerViewController.m
//  PAPasscode Example
//
//  Created by Justin Buchanan 2 on 2/27/14.
//  Copyright (c) 2014 Peer Assembly. All rights reserved.
//

#import "PAPasscodeContainerViewController.h"
#import "PAPasscodeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>



const int blurIterations = 3;
const float blurRadius = 40;


@interface UIImage (Blur)
- (UIImage *)blurredImageWithRadius:(CGFloat)radius iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor;
@end



@implementation PAPasscodeContainerViewController

- (instancetype)initWithPasscodeVC:(PAPasscodeViewController *)passcodeVC backgroundView:(UIView *)bg {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
		self.passcodeVC = passcodeVC;
		UIImage *snapshot = [[PAPasscodeContainerViewController snapshotOfView:bg] blurredImageWithRadius:5 iterations:3 tintColor:nil];
		self.blurredImage = snapshot;
		
		self.passcodeVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    }
    return self;
}

- (UINavigationController *)passcodeNavVC {
	if (!_passcodeNavVC) {
		_passcodeNavVC = [[UINavigationController alloc] initWithRootViewController:self.passcodeVC];
		_passcodeNavVC.modalPresentationStyle = UIModalPresentationFormSheet;
	}
	
	return _passcodeNavVC;
}

- (void)loadView {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		UIImageView *blurView = [[UIImageView alloc] initWithImage:self.blurredImage];
		self.view = blurView;
	} else {
		self.view = [[UIView alloc] init];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	if (!self.presentedViewController) {
		[self presentViewController:self.passcodeNavVC animated:YES completion:nil];
	}
}

- (void)cancel {
	
	[self dismissViewControllerAnimated:YES completion:^{
		[self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
	}];
}

//	inspired / borrowed from https://github.com/nicklockwood/FXBlurView/blob/master/FXBlurView/FXBlurView.m
+ (UIImage *)snapshotOfView:(UIView *)view {
	CGFloat scale = 0.5;
	if (blurIterations)
	{
		CGFloat blockSize = 12.0f/blurIterations;
		scale = blockSize/MAX(blockSize * 2, blurRadius);
		scale = 1.0f/floorf(1.0f/scale);
	}
	CGSize size = view.bounds.size;
	
	//prevents edge artefacts
	size.width = floorf(size.width * scale) / scale;
	size.height = floorf(size.height * scale) / scale;
	
	UIGraphicsBeginImageContextWithOptions(size, YES, scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[view.layer renderInContext:context];
	UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return snapshot;
}

@end



@implementation UIImage (Blur)

//	inspired / borrowed from https://github.com/nicklockwood/FXBlurView/blob/master/FXBlurView/FXBlurView.m
- (UIImage *)blurredImageWithRadius:(CGFloat)radius iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor
{
    //image must be nonzero size
    if (floorf(self.size.width) * floorf(self.size.height) <= 0.0f) return self;
    
    //boxsize must be an odd integer
    uint32_t boxSize = (uint32_t)(radius * self.scale);
    if (boxSize % 2 == 0) boxSize ++;
    
    //create image buffers
    CGImageRef imageRef = self.CGImage;
    vImage_Buffer buffer1, buffer2;
    buffer1.width = buffer2.width = CGImageGetWidth(imageRef);
    buffer1.height = buffer2.height = CGImageGetHeight(imageRef);
    buffer1.rowBytes = buffer2.rowBytes = CGImageGetBytesPerRow(imageRef);
    size_t bytes = buffer1.rowBytes * buffer1.height;
    buffer1.data = malloc(bytes);
    buffer2.data = malloc(bytes);
    
    //create temp buffer
    void *tempBuffer = malloc((size_t)vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, NULL, 0, 0, boxSize, boxSize,
                                                                 NULL, kvImageEdgeExtend + kvImageGetTempBufferSize));
    
    //copy image data
    CFDataRef dataSource = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
    memcpy(buffer1.data, CFDataGetBytePtr(dataSource), bytes);
    CFRelease(dataSource);
    
    for (NSUInteger i = 0; i < iterations; i++)
    {
        //perform blur
        vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, tempBuffer, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        
        //swap buffers
        void *temp = buffer1.data;
        buffer1.data = buffer2.data;
        buffer2.data = temp;
    }
    
    //free buffers
    free(buffer2.data);
    free(tempBuffer);
    
    //create image context from buffer
    CGContextRef ctx = CGBitmapContextCreate(buffer1.data, buffer1.width, buffer1.height,
                                             8, buffer1.rowBytes, CGImageGetColorSpace(imageRef),
                                             CGImageGetBitmapInfo(imageRef));
    
    //apply tint
    if (tintColor && CGColorGetAlpha(tintColor.CGColor) > 0.0f)
    {
        CGContextSetFillColorWithColor(ctx, [tintColor colorWithAlphaComponent:0.25].CGColor);
        CGContextSetBlendMode(ctx, kCGBlendModePlusLighter);
        CGContextFillRect(ctx, CGRectMake(0, 0, buffer1.width, buffer1.height));
    }
    
    //create image from context
    imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    CGContextRelease(ctx);
    free(buffer1.data);
    return image;
}

@end
