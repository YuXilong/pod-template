use_framework = ENV['USE_FRAMEWORK']
dev_framework = ENV['USE_DEV_FRAMEWORK_${POD_NAME}']
use_framework = dev_framework ? false : use_framework

# 支持的混淆模式, 例如：SUPPORT_MIXUP = ['XXX', 'YYY']
SUPPORT_MIXUP = []

# Beta版本 默认不包含BT 例如：BETA_SUPPORT_MIXUP = ['VO']
BETA_SUPPORT_MIXUP = []

Pod::Spec.new do |s|
  s.name             = '${POD_NAME}'
  s.version          = '99'
  s.summary          = 'A short description of ${POD_NAME}.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  git_source = use_framework ? "https://gitlab.v.show/ios_framework/#{s.name.to_s}.git" : "https://gitlab.v.show/ios_component/#{s.name.to_s}.git"

  s.homepage         = git_source
  s.author           = { '${USER_NAME}' => '${USER_EMAIL}' }

  zip_file_path = s.version.to_s.include?('.b') ? "repository/files/#{s.version.to_s.split('.b')[0]}-beta" : "repository/files/#{s.version.to_s}"
  if use_framework
    s.default_subspec = 'CoreFramework'
    s.source = { 
      :http => "https://gitlab.v.show/api/v4/projects/83/#{zip_file_path}%2F#{s.name.to_s}-#{s.version.to_s}.zip/raw?ref=main",
      :type => "zip",
      :headers => ["Authorization: Bearer #{ENV['GIT_LAB_TOKEN']}"]
    }  
  else
    s.default_subspec   = 'Core'
    s.license           = { :type => 'MIT', :file => 'LICENSE' }
    s.source            = { :git => git_source, :tag => s.version.to_s }
  end

  s.ios.deployment_target = '13.0'
  s.swift_version         = '5.0'
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
