Pod::Spec.new do |s|
  s.name     = 'PAPasscodeMM'
  s.version  = '0.3'
  s.summary  = 'A Passcode View Controller for iOS similar to the one in Settings.app'
  s.homepage = 'https://github.com/maximeMachado/PAPasscode'
  s.authors  = { 'Maxime MACHADO' => 'mmachado.sio@gmail.com' }
  s.source   = { :git => 'https://github.com/maximeMachado/PAPasscode.git', :tag => '0.3' } 
  s.platform = :ios
  s.requires_arc = true

  s.source_files = 'PAPasscode'
  s.resources = 'Assets/*.png'
  s.framework = 'QuartzCore'
end
