#include "include/neurosdk2/neurosdk2_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "neurosdk2_plugin.h"

void Neurosdk2PluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  neurosdk2::Neurosdk2Plugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
