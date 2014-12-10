# -*- coding: utf-8 -*-
$:.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/ios'

require 'bundler'
Bundler.require

# require 'bubble-wrap'

Motion::Project::App.setup do |app|

  app.name = 'masq'
  app.identifier = 'com.chunlea.masq'

  app.short_version = '0.1.0'
  # Get version from git
  #app.version = (`git rev-list HEAD --count`.strip.to_i).to_s
  app.version = app.short_version

  # SDK 8 for iOS 8 and above
  # app.sdk_version = '8.1'
  # app.deployment_target = '8.0'

  # SDK 8 for iOS 7 and above
  app.sdk_version = '8.1'
  app.deployment_target = '7.1'

  # Or for SDK 7
  # app.sdk_version = '7.1'
  # app.deployment_target = '7.0'

  app.icons = Dir.glob("resources/icon*.png").map{|icon| icon.split("/").last}

  # prerendered_icon is only needed in iOS 6
  #app.prerendered_icon = true

  app.device_family = [:iphone, :ipad]
  app.interface_orientations = [:portrait, :landscape_left, :landscape_right, :portrait_upside_down]

  app.files += Dir.glob(File.join(app.project_dir, 'lib/**/*.rb'))

  # Use `rake config' to see complete project settings, here are some examples:
  #
  # app.fonts = ['Oswald-Regular.ttf', 'FontAwesome.otf'] # These go in /resources
  # app.frameworks += %w(QuartzCore CoreGraphics MediaPlayer MessageUI CoreData)
  app.frameworks += %w(Accelerate AudioToolbox CoreAudio MediaPlayer AVFoundation CoreMedia)
  #
  # app.vendor_project('vendor/Flurry', :static)
  # app.vendor_project('vendor/DSLCalendarView', :static, :cflags => '-fobjc-arc') # Using arc
  app.vendor_project('vendor/Dirac3/', :static,
      :products => ['libDIRAC_iOS-fat.a']) # Directory with .h files relative to vendor/PROJECT-NAME)

  # app.pods do
  #   pod 'AFNetworking'
  #   pod 'JGProgressHUD'
  #   pod 'SVProgressHUD'
  #   pod 'JMImageCache'
  # end

  puts "Name: #{app.name}"
  puts "Using profile: #{app.provisioning_profile}"
  puts "Using certificate: #{app.codesign_certificate}"
end

task :"build:simulator" => :"schema:build"
