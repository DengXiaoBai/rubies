#!/usr/bin/env ruby

#--------------------------------------------
# function：build and export ipa file
#     -n：need to clean before build or not
#     -w <name.xcworkspace or the_path_of_workspace_name>：  Build the workspace name.xcworkspace.
#     -c <configuration_name>：                              Use the build configuration specified by configuration_name when building each target.
#     -t <target_name>：                                     Build the target specified by target_name.
#     -s <scheme_name>：                                     Build the scheme specified by scheme_name.  Required if building a workspace.
#     -i <name.ipa>:                                         Rename the ipa to name.ipa
#     -p <exportIPA2FullPath>:                               Export the ipa to a full path name
# author：iCrany
# E-mail:crany1992@gmail.com
# created：2016/08/23
# example: ruby ipa-build.rb -w Administrator.xcworkspace -c AdhocWithAdhocServers -t Administrator -s Administrator_Adhoc -n
#--------------------------------------------


require 'optparse'
require 'pathname'
require './util'


def error(msg)
  puts "\e[31m#{msg}\e[0m"
end

def info(msg)
  puts "\e[32m#{msg}\e[0m"
end

options = {}

OptionParser.new do |opts|

  opts.banner = 'This is used for build and explore IPA by ruby'

  options[:clean] = false
  opts.on('-n', 'need to clean before build') do
    options[:clean] = true
  end

  options[:workspace] = false
  opts.on('-w <workspace_name or the_path_of_workspace_name>', 'build the the path name of the workspace') do |value|
    options[:workspace] = value
  end

  opts.on('-c <configuration_name>', 'use the build configuration NAME for building each target, default is release') do |value|
    options[:configuration] = value
  end

  opts.on('-t <target_name>', 'build the target NAME') do |value|
    options[:target] = value
  end

  opts.on('-s <scheme_name>', 'build the scheme NAME') do |value|
    options[:scheme] = value
  end

  opts.on('-i <ipa_name>', 'set the IPA file name') do |value|
    options[:ipaname] = value
  end

  opts.on('-p <exportIPA2FullPath>', 'export the ipa to a full path name') do |value|
    options[:exportFullPath] = value
  end

  opts.on('-o <export_options_plist>', 'export_options_plist, xcodebuild -help see more detail') do |value|
    options[:exportOptionsPlist] = value
  end

end.parse!

puts options


#用户填写的参数相关
need_clean     = options[:clean]
workspace_name = options[:workspace]
configuration  = options[:configuration]
target_name    = options[:target]
scheme         = options[:scheme]
ipa_name       = options[:ipaname]
export_ipa_path = options[:exportFullPath]
exportOptionsPlist = options[:exportOptionsPlist]

puts info("begin ipa-build:\n need_clean : #{need_clean}\n workspace_name : #{workspace_name}\n configuration : #{configuration}\n target_name : #{target_name}\n scheme : #{scheme}\n ipa_name : #{ipa_name}\n exportFullPath : #{export_ipa_path}")

#项目的绝对路径
# project_path = Dir.pwd
project_path = File.dirname(workspace_name)


Dir.chdir(workspace_name) do 
  puts "Dir.chidr(#{workspace_name}) pwd: #{Dir.pwd}"
  project_path = File.dirname(Dir.pwd)  
end

#默认是 Release
if !configuration
  configuration = 'Release'
end

if !target_name
  puts error('Please ensure input -t <target_name> command')
  exit
end

if !scheme
  puts error('Please ensure input -s <scheme_name> command')
  exit
end


app_dir_name = "#{configuration}-iphoneos"
build_path = project_path + '/build'
compiled_path = "#{build_path}/#{app_dir_name}"

puts info("project_path : #{project_path}")
puts info("build_path : #{build_path}")
puts info("compiled_path : #{compiled_path}")

# if need_clean
#   system("xcodebuild clean -workspace #{workspace_name} -scheme #{scheme} -configuration #{configuration} CONFIGURATION_BUILD_DIR='#{compiled_path}'")
#   system("xcodebuild clean -workspace #{workspace_name} -scheme #{scheme} -configuration #{configuration}")

#   puts "xcodebuild clean -workspace #{workspace_name} -scheme #{scheme} -configuration #{configuration} CONFIGURATION_BUILD_DIR='#{compiled_path}'".green
# end

# build_cmd = 'xcodebuild'
# if !workspace_name
#   #TODO: build project
#   puts 'build the project'.green

# else
#   #build workspace
#   # cmd =  "#{build_cmd} -workspace #{workspace_name} -scheme #{scheme} -configuration #{configuration} CONFIGURATION_BUILD_DIR='#{compiled_path}' ONLY_ACTIVE_ARCH=NO"
#   cmd =  "#{build_cmd} -workspace #{workspace_name} -scheme #{scheme} -configuration #{configuration} CONFIGURATION_BUILD_DIR='#{compiled_path}' ONLY_ACTIVE_ARCH=NO -archivePath #{compiled_path}/#{scheme}.xcarchive archive"
#   system("#{cmd}")
# end

# if !workspace_name
#   currentDir = Dir.pwd
#   workspace_name = IPAModel.getCurrentDirWorkspaceName(currentDir)
# end


complied_appname = File.basename("#{workspace_name}", '.xcworkspace')
app_info_plist_path = "#{compiled_path}/#{scheme}.xcarchive/Products/Applications/#{target_name}.app/Info.plist"

display_name = `/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName" "#{app_info_plist_path}"`
display_name = display_name.strip

bundle_short_version = `/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "#{app_info_plist_path}"`
bundle_short_version = bundle_short_version.strip

bundle_version = `/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "#{app_info_plist_path}"`
bundle_version = bundle_version.strip

if ipa_name
  ipa_name = ipa_name.strip
end

if !ipa_name
  ipa_name = "#{target_name}_#{configuration}"
end

if !export_ipa_path
  export_ipa_path = "#{project_path}/ipa-build"
end

if !File.directory?("#{export_ipa_path}")
  FileUtils.mkdir_p("#{export_ipa_path}")
end

puts "export_ipa_path: #{export_ipa_path}".green
puts "complied_appname: #{complied_appname}".green
puts "app_info_plist_path: #{app_info_plist_path}".green
puts "display_name: #{display_name}".green
puts "bundle_short_version: #{bundle_short_version}".green
puts "bundle_version: #{bundle_version}".green

# `xcrun -sdk iphoneos PackageApplication -v #{compiled_path}/*.app -o #{export_ipa_path}/#{ipa_name}.ipa`
archive_path = "#{compiled_path}/#{scheme}.xcarchive"
export_path = "#{export_ipa_path}/#{ipa_name}.ipa"
export_options_plist = "#{exportOptionsPlist}"

puts "archive_path: #{archive_path}".green
puts "export_path: #{export_path}".green
puts "export_options_plist: #{export_options_plist}".green
`xcodebuild -exportArchive -archivePath #{archive_path} -exportPath #{export_path} -exportOptionsPlist #{export_options_plist}`

puts "end".green