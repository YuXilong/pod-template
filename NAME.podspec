use_framework = ENV['USE_FRAMEWORK']

Pod::Spec.new do |s|
  s.name             = '${POD_NAME}'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ${POD_NAME}.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  git_source = use_framework ? "https://gitlab.v.show/ios_framework/#{s.name.to_s}.git" : "https://gitlab.v.show/ios_component/#{s.name.to_s}.git"

  s.homepage         = git_source
  s.author           = { '${USER_NAME}' => '${USER_EMAIL}' }

  if use_framework
    s.default_subspec = 'CoreFramework'
    s.source = { 
      :http => "https://gitlab.v.show/api/v4/projects/126/repository/files/#{s.name.to_s}-#{s.version.to_s}.zip/raw?ref=main",
      :type => "zip",
      :headers => ["Authorization: Bearer #{ENV['GIT_LAB_TOKEN']}"]
    }  
  else
    s.default_subspec   = 'Core'
    s.license           = { :type => 'MIT', :file => 'LICENSE' }
    s.source            = { :git => git_source, :tag => s.version.to_s }
  end

  s.ios.deployment_target = '10.0'
  s.static_framework      = true
  s.pod_target_xcconfig   = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'VALID_ARCHS' => 'arm64' }
  s.user_target_xcconfig  = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'VALID_ARCHS' => 'arm64' }

  s.subspec 'CoreFramework' do |ss|
    ss.vendored_frameworks = '${POD_NAME}.framework'
  end
  
  s.subspec 'Core' do |ss|
    ss.source_files = '${POD_NAME}/Classes/**/*'
  end
  
end
