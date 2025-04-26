//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

<<<<<<< HEAD
import file_picker

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  FilePickerPlugin.register(with: registry.registrar(forPlugin: "FilePickerPlugin"))
=======
import amplify_auth_cognito
import amplify_secure_storage
import device_info_plus
import file_picker
import package_info_plus
import path_provider_foundation

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AmplifyAuthCognitoPlugin.register(with: registry.registrar(forPlugin: "AmplifyAuthCognitoPlugin"))
  AmplifySecureStoragePlugin.register(with: registry.registrar(forPlugin: "AmplifySecureStoragePlugin"))
  DeviceInfoPlusMacosPlugin.register(with: registry.registrar(forPlugin: "DeviceInfoPlusMacosPlugin"))
  FilePickerPlugin.register(with: registry.registrar(forPlugin: "FilePickerPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
>>>>>>> 8ec415c3b0053254ff218eb4e1ec03df590486a3
}
