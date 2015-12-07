/*
 Copyright © 2014-2015 Andrew Stevens <andy@andxyz.com>,
 Modern Alchemits <office@modalog.at>

 Licensed under MIT.

 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated
 documentation files (the "Software"), to deal in the Software without
 restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 sell copies of the Software, and
 to permit persons to whom the Software is furnished to do so, subject to the
 following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of
 the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO
 THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
 THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
*/

#import "Cache.h"

@implementation Cache

@synthesize command;

- (void)clear:(CDVInvokedUrlCommand *)command {
  NSLog(@"Cordova iOS Cache.clear() called.");

  _callbackId = command.callbackId;

  // Arguments arenot used at the moment.
  // NSArray* arguments = command.arguments;

  [self.commandDelegate runInBackground:^{
    // clear cache
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
  }];

  [self success];
}

- (void)cleartemp:(CDVInvokedUrlCommand *)command {
  NSLog(@"Cordova iOS Cache.cleartemp() called.");

  _callbackId = command.callbackId;

  // empty the tmp directory
  NSFileManager *fileMgr = [[NSFileManager alloc] init];
  NSError *err = nil;
  BOOL hasErrors = NO;

  // setup loop vars
  NSString *tempDirectoryPath = NSTemporaryDirectory();
  NSDirectoryEnumerator *directoryEnumerator =
      [fileMgr enumeratorAtPath:tempDirectoryPath];
  NSString *fileName = nil;
  BOOL result;
  // clear contents of NSTemporaryDirectory
  while ((fileName = [directoryEnumerator nextObject])) {
    NSString *filePath =
        [tempDirectoryPath stringByAppendingPathComponent:fileName];
    result = [fileMgr removeItemAtPath:filePath error:&err];
    if (!result && err) {
      NSLog(@"Failed to delete: %@ (error: %@)", filePath, err);
      hasErrors = YES;
    }
  }

  // send result
  CDVPluginResult *pluginResult;
  if (hasErrors) {
    pluginResult = [CDVPluginResult
        resultWithStatus:CDVCommandStatus_IO_EXCEPTION
         messageAsString:@"One or more files failed to be deleted."];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  }
  [self.commandDelegate sendPluginResult:pluginResult
                              callbackId:_callbackId];
}

- (void)success {
  NSString *resultMsg = @"Cordova iOS webview cache cleared.";
  NSLog(@"%@", resultMsg);

  // create cordova result
  CDVPluginResult *pluginResult = [CDVPluginResult
      resultWithStatus:CDVCommandStatus_OK
       messageAsString:[resultMsg stringByAddingPercentEscapesUsingEncoding:
                                      NSUTF8StringEncoding]];

  // send cordova result
  [self.commandDelegate sendPluginResult:pluginResult
                              callbackId:_callbackId];
}

- (void)error:(NSString *)message {
  NSString *resultMsg = [NSString
      stringWithFormat:@"Error while clearing webview cache (%@).", message];
  NSLog(@"%@", resultMsg);

  // create cordova result
  CDVPluginResult *pluginResult = [CDVPluginResult
      resultWithStatus:CDVCommandStatus_ERROR
       messageAsString:[resultMsg stringByAddingPercentEscapesUsingEncoding:
                                      NSUTF8StringEncoding]];

  // send cordova result
  [self.commandDelegate sendPluginResult:pluginResult
                              callbackId:_callbackId];
}

@end
