Pod::Spec.new do |s|
  s.name             = 'MapScaleView-iOS'
  s.module_name      = 'MapScaleView'
  s.version          = '1.0.1'
  s.summary          = 'Map scale bar view for iOS — mirrors the Android pengrad/mapscaleview library.'
  s.description      = <<-DESC
    MapScaleView displays an accurate map scale bar (metric and/or imperial) on any iOS map.
    Works with Google Maps SDK, MapKit, Mapbox, or any map that exposes zoom level and latitude.
    API mirrors the Android pengrad/mapscaleview library for cross-platform consistency.
  DESC

  s.homepage         = 'https://github.com/foolzz/MapScaleView-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Yan Zhao' => 'yzhao.ca@gmail.com' }
  s.source           = { :git => 'https://github.com/foolzz/MapScaleView-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.9'

  s.source_files = 'Sources/MapScaleView/**/*.swift'
end
