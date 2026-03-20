Pod::Spec.new do |s|
  s.name     = 'SwiftMulticastDelegate'
  s.version  = '1.0.0'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'
  s.watchos.deployment_target = '4.0'
  s.tvos.deployment_target = '12.0'
  s.swift_versions = ['5.0', '6.0']
  s.license  = { :type => 'MIT'}
  s.summary  = 'Swift Multicast Delegate'
  s.homepage = 'https://github.com/chenmingbiao/SwiftMulticastDelegate'
  s.author   = { 'Bill Chan' => 'mbillchan@gmail.com' }

  s.source   = { :git => 'https://github.com/chenmingbiao/SwiftMulticastDelegate.git',
		:tag => "#{s.version}" }

  s.description  = 'Swift Multicast Delegate.'
  s.source_files = 'Source/SwiftMulticastDelegate.swift'
  s.requires_arc = true
end
