#!/usr/bin/env ruby

$:.unshift(File.join(Dir.pwd, "lib"))
$:.unshift(File.join(Dir.pwd, "app"))
$:.unshift(File.join(Dir.pwd, "middleware"))

# require "pry"
# binding.pry

require "cloud_controller"
#VCAP::CloudController::Constants::API_VERSION
$stdout.printf(
  '- ["api_version", "%s"]' + "\n",
    VCAP::CloudController::Constants::API_VERSION
)
