#define kBundlePath @"/Library/Application Support/VerticalVideoSyndrome10.bundle"
#define VIDEO 1

@interface VVSViewController : UIViewController
@end

@implementation VVSViewController

- (void)loadView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    NSBundle *bundle = [[[NSBundle alloc] initWithPath:kBundlePath] autorelease];
    NSString *imagePath = [bundle pathForResource:@"Warning" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:CGRectMake((screenWidth / 2) - (image.size.width / 2),
                                   80,
                                   imageView.frame.size.width,
                                   imageView.frame.size.height)];
    self.view = imageView;
}

@end

static VVSViewController *alertViewController;

@interface CAMViewfinderViewController : UIViewController
@property (nonatomic,readonly) long long _currentMode;
- (void)createVVSAlertViewControllerIfNeeded;
@end

@interface CAMPreviewViewController : UIViewController
@property (assign, nonatomic) CAMViewfinderViewController *delegate;
@property (nonatomic, readonly) long long _mode;
@end


%hook CAMViewfinderViewController

%new
- (void)createVVSAlertViewControllerIfNeeded {
    if (!alertViewController) {
        alertViewController = [[VVSViewController alloc] init];
        [self.view addSubview:alertViewController.view];
    }
}

- (void)_rotateTopBarAndControlsToOrientation:(long long)orientation shouldAnimate:(BOOL)animate {
    %orig;

    if (self._currentMode == VIDEO && (orientation == UIInterfaceOrientationPortrait ||
                                       orientation == UIDeviceOrientationPortraitUpsideDown)) {
        [self createVVSAlertViewControllerIfNeeded];
        [alertViewController.view setHidden:NO];
    } else if (alertViewController && !alertViewController.view.hidden) {
        [alertViewController.view setHidden:YES];
    }
}

- (BOOL)_startCapturingVideoWithRequest:(id)request {
    // Remove sign
    if (alertViewController && !alertViewController.view.hidden) {
        [alertViewController.view setHidden:YES];
    }

    return %orig;
}

- (BOOL)_stopCapturingVideo {
    // Add sign
    if (alertViewController && alertViewController.view.hidden) {
        [alertViewController.view setHidden:NO];
    }

    return %orig;
}

%end

%hook CAMPreviewViewController

- (void)didChangeToMode:(long long)mode device:(long long)device animated:(BOOL)animate {
    %orig;

    if (mode != VIDEO) {
        // Remove sign
        if (alertViewController) {
            [alertViewController.view setHidden:YES];
        }
    } else {
        // Add sign
        [self.delegate createVVSAlertViewControllerIfNeeded];
        [alertViewController.view setHidden:NO];
    }
}

%end
