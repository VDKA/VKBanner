
Pod::Spec.new do |s|
  s.name 				= 'VKBanner'
  s.version 			= '0.0.1'
  s.platform 			= :ios, '8.0'
  s.license 			= { :type => 'MIT' }
  s.homepage 			= 'https://github.com/VDKA/VKBanner'
  s.authors 			= { 'Ethan Jackwitz' => 'ethanjackwitz@gmail.com' }
  s.summary 			= "A simple popup notification system for iOS"
  s.source 				= { :git => "https://github.com/VDKA/VKBanner.git", :tag => "#{s.version}" }
  s.source_files 		= "VKBanner/VKBanner.swift"
  s.framework 			= 'UIKit'
  s.requires_arc 		= true
  s.dependency  		  'EZSwiftExtensions'
end

