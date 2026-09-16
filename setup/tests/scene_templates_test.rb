# Created by yuxilong on 2026/09/16.

require 'fileutils'
require 'tmpdir'
require 'ostruct'
require 'cocoapods'
require_relative '../ProjectManipulator'

root = File.expand_path('../..', __dir__)
temp_root = File.join(root, '.tmp')
created_temp_root = !Dir.exist?(temp_root)
FileUtils.mkdir_p(temp_root)

begin
  Dir.mktmpdir('scene-templates-', temp_root) do |directory|
    %w[ios swift].each do |language|
      FileUtils.cp_r(File.join(root, 'templates', language), directory)
      example = File.join(directory, language, 'Example')
      configurator = Struct.new(:pod_name, :user_name, :date, :year).new('SceneDemo', 'tester', '2026/09/16', '2026')
      Pod::ProjectManipulator.new(
        configurator: configurator,
        xcodeproj_path: File.join(example, 'PROJECT.xcodeproj'),
        platform: :ios,
        remove_demo_project: false,
        prefix: language == 'ios' ? 'BT' : ''
      ).run

      project = Xcodeproj::Project.open(File.join(example, 'SceneDemo.xcodeproj'))
      app = project.native_targets.find { |target| target.product_type == 'com.apple.product-type.application' }
      plist = Xcodeproj::Plist.read_from_path(File.join(example, app.build_configurations.first.build_settings.fetch('INFOPLIST_FILE')))
      manifest = plist.fetch('UIApplicationSceneManifest')
      scene = manifest.fetch('UISceneConfigurations').fetch('UIWindowSceneSessionRoleApplication').first
      delegate = language == 'ios' ? 'BTSceneDelegate' : '$(PRODUCT_MODULE_NAME).SceneDelegate'
      raise "#{language}: scene delegate does not match generated class" unless scene.fetch('UISceneDelegateClassName') == delegate
      raise "#{language}: invalid scene class" unless scene.fetch('UISceneClassName') == 'UIWindowScene'
      raise "#{language}: unexpected multiple-window support" unless manifest.fetch('UIApplicationSupportsMultipleScenes') == false
      raise "#{language}: legacy main storyboard remains" if plist.key?('UIMainStoryboardFile')

      storyboard = File.join(example, 'SceneDemo', 'Base.lproj', "#{scene.fetch('UISceneStoryboardFile')}.storyboard")
      raise "#{language}: missing scene storyboard" unless File.file?(storyboard)
      raise "#{language}: missing initial view controller" unless File.read(storyboard).include?('initialViewController=')

      sources = app.source_build_phase.files_references
      scene_source = language == 'ios' ? 'BTSceneDelegate.m' : 'SceneDelegate.swift'
      raise "#{language}: scene delegate not compiled" unless sources.any? { |file| file.path == scene_source }
      sources.each { |file| raise "Missing generated source: #{file.real_path}" unless file.real_path.file? }
      if language == 'ios'
        header = File.join(example, 'SceneDemo', 'BTSceneDelegate.h')
        raise 'Objective-C scene header was not renamed' unless File.file?(header)
        raise 'Objective-C scene class was not renamed' unless File.read(header).include?('@interface BTSceneDelegate')
      end

      project.native_targets.each do |target|
        target.build_configurations.each do |config|
          inherited = project.build_configurations.find { |item| item.name == config.name }.build_settings
          minimum = config.build_settings.fetch('IPHONEOS_DEPLOYMENT_TARGET', inherited['IPHONEOS_DEPLOYMENT_TARGET'])
          raise "#{language}/#{target.name}/#{config.name}: expected iOS 15.0, got #{minimum}" unless minimum == '15.0'
        end
      end
      raise "#{language}: Podfile minimum differs" unless File.read(File.join(example, 'Podfile')).include?("platform :ios, '15.0'")

      # Exercise the real post_install callback without loading plugin hooks or accessing private repos.
      podfile_path = File.join(example, 'Podfile')
      podfile = Pod::Podfile.new do
        define_singleton_method(:baitu_use_frameworks!) {}
        instance_eval(File.read(podfile_path).gsub('${POD_NAME}', 'SceneDemo').gsub('${INCLUDED_PODS}', ''), podfile_path)
      end
      pods_project = Xcodeproj::Project.new(File.join(example, 'Pods.xcodeproj'))
      results = %w[15.0 16.0].map do |minimum|
        native_target = pods_project.new_target(:framework, "Pod#{minimum.delete('.')}", :ios, minimum)
        native_target.build_configurations.each { |config| config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.1' }
        target = OpenStruct.new(platform: Pod::Platform.new(:ios, minimum))
        [native_target.name, OpenStruct.new(target: target, native_target: native_target)]
      end.to_h
      installer = OpenStruct.new(target_installation_results: [results], generated_projects: [pods_project])
      podfile.post_install!(installer)
      results.each_value do |result|
        result.native_target.build_configurations.each do |config|
          minimum = result.target.platform.deployment_target.to_s
          raise "#{language}: plugin override not restored to #{minimum}" unless config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] == minimum
          raise "#{language}: signing override lost" unless config.build_settings['CODE_SIGN_IDENTITY'] == ''
        end
      end
      puts "#{language}: generated scene configuration, source references, and deployment targets passed"
    end
    raise 'Podspec minimum differs' unless File.read(File.join(root, 'NAME.podspec')).include?("s.ios.deployment_target = '15.0'")
  end
ensure
  Dir.rmdir(temp_root) if created_temp_root && Dir.empty?(temp_root)
end
