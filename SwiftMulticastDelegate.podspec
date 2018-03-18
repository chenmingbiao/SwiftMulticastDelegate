Pod::Spec.new do |s|
  s.name     = 'SwiftMulticastDelegate'
  s.version  = '2.1.1'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  s.swift_version = '4.0'
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
