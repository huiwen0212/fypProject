//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <camera/CameraPlugin.h>
#import <connectivity/ConnectivityPlugin.h>
#import <firebase_ml_vision/FirebaseMlVisionPlugin.h>
#import <flutter_local_notifications/FlutterLocalNotificationsPlugin.h>
#import <flutter_plugin_pdf_viewer/FlutterPluginPdfViewerPlugin.h>
#import <fluttertoast/FluttertoastPlugin.h>
#import <image_picker/ImagePickerPlugin.h>
#import <multi_image_picker/MultiImagePickerPlugin.h>
#import <path_provider/PathProviderPlugin.h>
#import <shared_preferences/SharedPreferencesPlugin.h>
#import <sqflite/SqflitePlugin.h>
#import <url_launcher/UrlLauncherPlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [CameraPlugin registerWithRegistrar:[registry registrarForPlugin:@"CameraPlugin"]];
  [FLTConnectivityPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTConnectivityPlugin"]];
  [FLTFirebaseMlVisionPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseMlVisionPlugin"]];
  [FlutterLocalNotificationsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterLocalNotificationsPlugin"]];
  [FlutterPluginPdfViewerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterPluginPdfViewerPlugin"]];
  [FluttertoastPlugin registerWithRegistrar:[registry registrarForPlugin:@"FluttertoastPlugin"]];
  [FLTImagePickerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTImagePickerPlugin"]];
  [MultiImagePickerPlugin registerWithRegistrar:[registry registrarForPlugin:@"MultiImagePickerPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
  [SqflitePlugin registerWithRegistrar:[registry registrarForPlugin:@"SqflitePlugin"]];
  [FLTUrlLauncherPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTUrlLauncherPlugin"]];
}

@end
