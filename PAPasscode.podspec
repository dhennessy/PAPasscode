Pod::Spec.new do |s|
  s.name     'PAPasscode'
  s.version  '0.1.0'
  s.summary  'A recreation of Apple's Passcode View Controller'
  s.homepage 'https://github.com/gowalla/AFNetworking'
  s.authors  {'Denis Hennessy' => 'denis@hennessynet.com'}
  s.source   :git => 'https://github.com/gowalla/AFNetworking.git',
             :tag => '0.1.0'
  
  s.platforms 'iOS'
  s.sdk '>= 4.0'
  
  s.source_files 'PAPasscode'
end