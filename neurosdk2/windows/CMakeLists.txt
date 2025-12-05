# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "neurosdk2")
project(${PROJECT_NAME} LANGUAGES CXX)

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "neurosdk2_plugin")

set(NEUROLIB_PATH "${CMAKE_CURRENT_SOURCE_DIR}/neuro_dll")
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(NEUROLIB_DLL_PATH "${CMAKE_CURRENT_SOURCE_DIR}/neuro_dll/neurosdk2-x64.dll")
else()
    set(NEUROLIB_DLL_PATH "${CMAKE_CURRENT_SOURCE_DIR}/neuro_dll/neurosdk2-x32.dll")
endif()

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "neurosdk2_plugin.cpp"
  "neurosdk2_plugin.h"
  "pigeon_messages/pigeon_messages.g.cpp"
  "pigeon_messages/pigeon_messages.g.h"
  "include/neurosdk2/cmn_type.h"
  "include/neurosdk2/sdk_api.h"
  "include/neurosdk2/lib_export.h"
  "include/utils.h"
  "include/constants.h"
  "utils.cpp"
  "include/event_holder.h"
  "event_holder.cpp"
)

# Choose neurosdk lib
if (${CMAKE_SIZEOF_VOID_P} MATCHES 8)
	set(LIB_NEURO "neurosdk2-x64")
else()
	set(LIB_NEURO "neurosdk2-x32")
endif()

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} SHARED
  "include/neurosdk2/neurosdk2_plugin_c_api.h"
  "neurosdk2_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
)

target_link_directories(${PLUGIN_NAME} PRIVATE "${NEUROLIB_PATH}") # .lib
find_file(NEUROSDK_DLL NAMES "${LIB_NEURO}.dll" HINTS "${NEUROLIB_PATH}" REQUIRED NO_CMAKE_FIND_ROOT_PATH) # .dll
target_link_libraries(${PLUGIN_NAME} PRIVATE ${LIB_NEURO})

# install(FILES ${LIB_NEURO} DESTINATION ${CMAKE_BINARY_DIR}/runner/Release CONFIGURATIONS Profile;Release COMPONENT Runtime)
# add_custom_command(TARGET ${PLUGIN_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${NEUROSDK_DLL} $<TARGET_FILE_DIR:${PROJECT_NAME}>)

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
apply_standard_settings(${PLUGIN_NAME})

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

# Source include directories and library dependencies. Add any plugin-specific
# dependencies here.
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/pigeon_messages")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(neurosdk2_bundled_libraries
  ${NEUROLIB_DLL_PATH}
  PARENT_SCOPE
)
