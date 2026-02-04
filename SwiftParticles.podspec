Pod::Spec.new do |s|
  s.name             = 'SwiftParticles'
  s.version          = '1.0.0'
  s.summary          = 'Particle system framework for stunning visual effects in SwiftUI.'
  s.description      = 'SwiftParticles provides a particle system for creating stunning visual effects in SwiftUI.'
  s.homepage         = 'https://github.com/muhittincamdali/SwiftParticles'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muhittin Camdali' => 'contact@muhittincamdali.com' }
  s.source           = { :git => 'https://github.com/muhittincamdali/SwiftParticles.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.swift_versions = ['5.9', '5.10', '6.0']
  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'Foundation', 'SwiftUI'
end
