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

  s.homepage         = "https://gitlab.v.show/ios_component/#{s.name}.git"
  s.author           = { '${USER_NAME}' => '${USER_EMAIL}' }
  s.default_subspec  = 'Core'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.source           = { :git => s.homepage, :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version         = '5.0'
  s.static_framework      = true

  s.subspec 'Core' do |ss|
    ss.source_files = '${POD_NAME}/Classes/**/*'
  end

end
