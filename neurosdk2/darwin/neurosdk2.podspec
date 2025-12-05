Pod::Spec.new do |s|
  s.name             = 'neurosdk2'
  s.version          = '1.0.13'
  s.summary          = 'Flutter wrapper for NeuroSDK2'
  s.description      = <<-DESC
Flutter wrapper for NeuroSDK2
                       DESC
  s.homepage         = 'https://sdk.brainbit.com/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'BRAINBIT Inc.' => 'support@brainbit.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/*', 'Classes/Neuro/*'
  s.public_header_files = 'Classes/*.h', 'Classes/Neuro/*.h'

  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'

  s.osx.vendored_libraries = 'libneurosdk2.dylib'
  s.ios.dependency 'flutter_neurosdk2_ios', '1.0.8'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
