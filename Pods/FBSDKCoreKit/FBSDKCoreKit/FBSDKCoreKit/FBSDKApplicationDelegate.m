// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "FBSDKApplicationDelegate.h"
#import "FBSDKApplicationDelegate+Internal.h"

#import <objc/runtime.h>

#import "FBSDKAppEvents+Internal.h"
#import "FBSDKBoltsMeasurementEventListener.h"
#import "FBSDKBridgeAPIRequest.h"
#import "FBSDKBridgeAPIResponse.h"
#import "FBSDKConstants.h"
#import "FBSDKDynamicFrameworkLoader.h"
#import "FBSDKError.h"
#import "FBSDKInternalUtility.h"
#import "FBSDKProfile+Internal.h"
#import "FBSDKServerConfiguration.h"
#import "FBSDKServerConfigurationManager.h"
#import "FBSDKSettings+Internal.h"
#import "FBSDKTimeSpentData.h"
#import "FBSDKUtility.h"

NSString *const FBSDKApplicationDidBecomeActiveNotification = @"com.facebook.sdk.FBSDKApplicationDidBecomeActiveNotification";

static NSString *const FBSDKAppLinkInboundEvent = @"fb_al_inbound";

@implementation FBSDKApplicationDelegate
{
  FBSDKBridgeAPIRequest *_pendingRequest;
  FBSDKBridgeAPICallbackBlock _pendingRequestCompletionBlock;
  id<FBSDKURLOpening> _pendingURLOpen;
  BOOL _expectingBackground;
  UIViewController *_safariViewController;
}

#pragma mark - Class Methods

+ (void)load
{
  // when the app becomes active by any means,  kick off the initialization.
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(initializeWithLaunchData:)
                                               name:UIApplicationDidFinishLaunchingNotification
                                             object:nil];
}

// Initialize SDK listeners
// Don't call this function in any place else. It should only be called when the class is loaded.
+ (void)initializeWithLaunchData:(NSNotification *)note
{
  NSDictionary *launchData = note.userInfo;
  // Register Listener for Bolts measurement events
  [FBSDKBoltsMeasurementEventListener defaultListener];

  // Set the SourceApplication for time spent data. This is not going to update the value if the app has already launched.
  [FBSDKTimeSpentData setSourceApplication:launchData[UIApplicationLaunchOptionsSourceApplicationKey]
                                   openURL:launchData[UIApplicationLaunchOptionsURLKey]];
  // Register on UIApplicationDidEnterBackgroundNotification events to reset source application data when app backgrounds.
  [FBSDKTimeSpentData registerAutoResetSourceApplication];

  // Remove the observer
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance
{
  static FBSDKApplicationDelegate *_sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[self alloc] _init];
  });
  return _sharedInstance;
}

#pragma mark - Object Lifecycle

- (instancetype)_init
{
  if ((self = [super init]) != nil) {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
  }
  return self;
}

- (instancetype)init
{
  return nil;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
  if (sourceApplication != nil && ![sourceApplication isKindOfClass:[NSString class]]) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"Expected 'sourceApplication' to be NSString. Please verify you are passing in 'sourceApplication' from your app delegate (not the UIApplication* parameter). If your app delegate implements iOS 9's application:openURL:options:, you should pass in options[UIApplicationOpenURLOptionsSourceApplicationKey]. "
                                 userInfo:nil];
  }
  [FBSDKTimeSpentData setSourceApplication:sourceApplication openURL:url];
  // if they completed a SFVC flow, dimiss it.
  [_safariViewController.presentingViewController dismissViewControllerAnimated:YES completion: nil];
  _safariViewController = nil;

  if (_pendingURLOpen) {
    id<FBSDKURLOpening> pendingURLOpen = _pendingURLOpen;

    _pendingURLOpen = nil;

    if ([pendingURLOpen application:application
                            openURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation]) {
      return YES;
    }
  }
  if ([self _handleBridgeAPIResponseURL:url sourceApplication:sourceApplication]) {
    return YES;
  }

  [self _logIfAppLinkEvent:url];

  return NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  FBSDKProfile *cachedProfile = [FBSDKProfile fetchCachedProfile];
  [FBSDKProfile setCurrentProfile:cachedProfile];

  FBSDKAccessToken *cachedToken = [[FBSDKSettings accessTokenCache] fetchAccessToken];
  [FBSDKAccessToken setCurrentAccessToken:cachedToken];

  NSURL *launchedURL = launchOptions[UIApplicationLaunchOptionsURLKey];
  NSString *sourceApplication = launchOptions[UIApplicationLaunchOptionsSourceApplicationKey];

  if (launchedURL &&
      sourceApplication) {
    Class loginManagerClass = NSClassFromString(@"FBSDKLoginManager");
    if (loginManagerClass) {
      id annotation = launchOptions[UIApplicationLaunchOptionsAnnotationKey];
      id<FBSDKURLOpening> loginManager = [[loginManagerClass alloc] init];
      return [loginManager application:application
                               openURL:launchedURL
                     sourceApplication:sourceApplication
                            annotation:annotation];
    }
  }
  return NO;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
  _active = NO;
  _expectingBackground = NO;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
  //  _expectingBackground can be YES if the caller started doing work (like login)
  // within the app delegate's lifecycle like openURL, in which case there
  // might have been a "didBecomeActive" event pending that we want to ignore.
  if (!_expectingBackground && !_safariViewController) {
    _active = YES;
    [_pendingURLOpen applicationDidBecomeActive:[notification object]];

    [self _cancelBridgeRequest];

    [[NSNotificationCenter defaultCenter] postNotificationName:FBSDKApplicationDidBecomeActiveNotification object:self];
  }
}

#pragma mark - SFSafariViewControllerDelegate


// This means the user tapped "Done" which we should treat as a cancellation.
- (void)safariViewControllerDidFinish:(UIViewController *)safariViewController
{
  if (_pendingURLOpen) {
    id<FBSDKURLOpening> pendingURLOpen = _pendingURLOpen;

    _pendingURLOpen = nil;

    [pendingURLOpen application:nil
                            openURL:nil
                  sourceApplication:nil
                     annotation:nil];

  }
  [self _cancelBridgeRequest];
}

#pragma mark - Internal Methods

- (void)openBridgeAPIRequest:(FBSDKBridgeAPIRequest *)request
     useSafariViewController:(BOOL)useSafariViewController
             completionBlock:(FBSDKBridgeAPICallbackBlock)completionBlock
{
  if (!request) {
    return;
  }
  NSError *error;
  NSURL *requestURL = [request requestURL:&error];
  if (!requestURL) {
    FBSDKBridgeAPIResponse *response = [FBSDKBridgeAPIResponse bridgeAPIResponseWithRequest:request error:error];
    completionBlock(response);
    return;
  }
  _pendingRequest = request;
  _pendingRequestCompletionBlock = [completionBlock copy];
  void (^handler)(BOOL) = ^(BOOL openedURL) {
    if (!openedURL) {
      _pendingRequest = nil;
      _pendingRequestCompletionBlock = nil;
      NSError *openedURLError;
      if ([request.scheme hasPrefix:@"http"]) {
        openedURLError = [FBSDKError errorWithCode:FBSDKBrowswerUnavailableErrorCode
                                           message:@"the app switch failed because the browser is unavailable"];
      } else {
        openedURLError = [FBSDKError errorWithCode:FBSDKAppVersionUnsupportedErrorCode
                                           message:@"the app switch failed because the destination app is out of date"];
      }
      FBSDKBridgeAPIResponse *response = [FBSDKBridgeAPIResponse bridgeAPIResponseWithRequest:request
                                                                                        error:openedURLError];
      completionBlock(response);
      return;
    }
  };
  if (useSafariViewController) {
    [self openURLWithSafariViewController:requestURL sender:nil handler:handler];
  } else {
    [self openURL:requestURL sender:nil handler:handler];
  }
}

- (void)openURLWithSafariViewController:(NSURL *)url sender:(id<FBSDKURLOpening>)sender handler:(void(^)(BOOL))handler
{
  if (![url.scheme hasPrefix:@"http"]) {
    [self openURL:url sender:sender handler:handler];
    return;
  }

  _expectingBackground = NO;
  _pendingURLOpen = sender;

  // trying to dynamically load SFSafariViewController class
  // so for the cases when it is available we can send users through Safari View Controller flow
  // in cases it is not available regular flow will be selected
  Class SFSafariViewControllerClass = fbsdkdfl_SFSafariViewControllerClass();

  if (SFSafariViewControllerClass) {
    UIViewController *parent = [FBSDKInternalUtility topMostViewController];
    if (parent.transitionCoordinator != nil) {
      // Wait until the transition is finished before presenting SafariVC to avoid a blank screen.
      [parent.transitionCoordinator animateAlongsideTransition:NULL completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Note SFVC init must occur inside block to avoid blank screen.
        _safariViewController = [[SFSafariViewControllerClass alloc] initWithURL:url];
        [_safariViewController performSelector:@selector(setDelegate:) withObject:self];
        [[FBSDKInternalUtility topMostViewController] presentViewController:_safariViewController animated:YES completion:nil];
      }];
    } else {
      _safariViewController = [[SFSafariViewControllerClass alloc] initWithURL:url];
      [_safariViewController performSelector:@selector(setDelegate:) withObject:self];
      [parent presentViewController:_safariViewController animated:YES completion:nil];
    }

    // Assuming Safari View Controller always opens
    if (handler) {
      handler(YES);
    }
  } else {
    [self openURL:url sender:sender handler:handler];
  }
}

- (void)openURL:(NSURL *)url sender:(id<FBSDKURLOpening>)sender handler:(void(^)(BOOL))handler
{
  _expectingBackground = YES;
  _pendingURLOpen = sender;
  dispatch_async(dispatch_get_main_queue(), ^{
    // Dispatch openURL calls to prevent hangs if we're inside the current app delegate's openURL flow already
    BOOL opened = [[UIApplication sharedApplication] openURL:url];

    if ([url.scheme hasPrefix:@"http"] && !opened) {
      NSOperatingSystemVersion iOS8Version = { .majorVersion = 8, .minorVersion = 0, .patchVersion = 0 };
      if (![FBSDKInternalUtility isOSRunTimeVersionAtLeast:iOS8Version]) {
        // Safari openURL calls can wrongly return NO on iOS 7 so manually overwrite that case to YES.
        // Otherwise we would rather trust in the actual result of openURL
        opened = YES;
      }
    }
    if (handler) {
      handler(opened);
    }
  });
}

#pragma mark - Helper Methods

- (BOOL)_handleBridgeAPIResponseURL:(NSURL *)responseURL sourceApplication:(NSString *)sourceApplication
{
  FBSDKBridgeAPIRequest *request = _pendingRequest;
  FBSDKBridgeAPICallbackBlock completionBlock = _pendingRequestCompletionBlock;
  _pendingRequest = nil;
  _pendingRequestCompletionBlock = NULL;
  if (![responseURL.scheme isEqualToString:[FBSDKInternalUtility appURLScheme]]) {
    return NO;
  }
  if (![responseURL.host isEqualToString:@"bridge"]) {
    return NO;
  }
  if (!request) {
    return NO;
  }
  if (!completionBlock) {
    return YES;
  }
  NSError *error;
  FBSDKBridgeAPIResponse *response = [FBSDKBridgeAPIResponse bridgeAPIResponseWithRequest:request
                                                                              responseURL:responseURL
                                                                        sourceApplication:sourceApplication
                                                                                    error:&error];
  if (response) {
    completionBlock(response);
    return YES;
  } else if (error) {
    completionBlock([FBSDKBridgeAPIResponse bridgeAPIResponseWithRequest:request error:error]);
    return YES;
  } else {
    return NO;
  }
}

- (void)_logIfAppLinkEvent:(NSURL *)url
{
  if (!url) {
    return;
  }
  NSDictionary *params = [FBSDKUtility dictionaryWithQueryString:url.query];
  NSString *applinkDataString = params[@"al_applink_data"];
  if (!applinkDataString) {
    return;
  }

  NSDictionary * applinkData = [FBSDKInternalUtility objectForJSONString:applinkDataString error:NULL];
  if (!applinkData) {
    return;
  }

  NSURL *targetURL = [NSURL URLWithString:applinkData[@"target_url"]];
  NSMutableDictionary *logData = [[NSMutableDictionary alloc] init];
  [FBSDKInternalUtility dictionary:logData setObject:[targetURL absoluteString] forKey:@"targetURL"];
  [FBSDKInternalUtility dictionary:logData setObject:[targetURL host] forKey:@"targetURLHost"];

  NSDictionary *refererData = applinkData[@"referer_data"];
  if (refererData) {
    [FBSDKInternalUtility dictionary:logData setObject:refererData[@"target_url"] forKey:@"referralTargetURL"];
    [FBSDKInternalUtility dictionary:logData setObject:refererData[@"url"] forKey:@"referralURL"];
    [FBSDKInternalUtility dictionary:logData setObject:refererData[@"app_name"] forKey:@"referralAppName"];
  }
  [FBSDKInternalUtility dictionary:logData setObject:[url absoluteString] forKey:@"inputURL"];
  [FBSDKInternalUtility dictionary:logData setObject:[url scheme] forKey:@"inputURLScheme"];

  [FBSDKAppEvents logImplicitEvent:FBSDKAppLinkInboundEvent
                        valueToSum:nil
                        parameters:logData
                       accessToken:nil];
}

- (void)_cancelBridgeRequest
{
  if (_pendingRequest && _pendingRequestCompletionBlock) {
    _pendingRequestCompletionBlock([FBSDKBridgeAPIResponse bridgeAPIResponseCancelledWithRequest:_pendingRequest]);
  }
  _pendingRequest = nil;
  _pendingRequestCompletionBlock = NULL;
}
@end
