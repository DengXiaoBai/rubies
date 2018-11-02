#!/usr/bin/env ruby

require 'plist'
require 'optparse'
require 'fileutils'

#--------------------------------------------
# function：Using SFTP to upload the specified items-service to the https's server specified path
#     -f：the full path of the ipa file
#     -s：server address
#     -u：sftp username
#     -p：sftp password
#     -r：the full sftp remote path to be uploaded: such as /hd01/webapp/adhoc.skytech.cc/htdoc/afs_admin
# author：iCrany
# E-mail: crany1992@gmail.com
# created：2017/07/03
# example:
#--------------------------------------------

def error(msg)
  puts "\e[31m#{msg}\e[0m"
end

def info(msg)
  puts "\e[32m#{msg}\e[0m"
end

options = {}

OptionParser.new do |opts|

  opts.banner = "Using SFTP to upload the specified items-service to the https server specified path"

  opts.separator ''
  opts.separator "\e[4mCommands:\e[24m"

  opts.on('-f <local_ipa_path>', 'need to upload ipa full path') do |value|
    options[:local_IPA_path] = value
  end

  opts.on('-s <host>', 'server ip') do |value|
    options[:host] = value
  end

  opts.on('-t <target_name>', '--targetName', 'Build the target specified by target name') do |target_name|
    options[:target_name] = target_name
  end

  opts.on('-u <username>', '--username' , 'sftp username') do |value|
    options[:username] = value
  end

  opts.on('-p <password>', '--password', 'sftp password') do |value|
    options[:password] = value
  end

  opts.on('-r <remote plist dir path>', '--remote_plist_dir_path', 'the remote plist dir path, may be the jfrog not supports https protocol yet, then you can upload the items-service to the https server and the ipa to the http server, if have value, the plist url in index.html will use this value') do |value|
    options[:remote_plist_dir_path] = value
  end

  # "\e[31m Common options: \e[0m"
  opts.separator ''
  opts.separator "\e[31m\e[4mOptions:\e[24m\e[0m"
  opts.on_tail('-h', '--help', 'Show help banner of specified command') do
    puts opts
    exit
  end

end.parse!


local_IPA_path = options[:local_IPA_path]
host = options[:host]
target_name = options[:target_name]
username = options[:username]
password = options[:password]
remote_plist_dir_path = options[:remote_plist_dir_path]

info options

if !local_IPA_path || !username || !password || !remote_plist_dir_path || !target_name || !host
  error('please ensure input all param')
  exit
end

if !File.exist?(local_IPA_path)
  error("#{local_IPA_path} not exist")
  exit
end


# Step 1: Get the ipa info and generate the item-service file
ipa_dir_path = File.dirname("#{local_IPA_path}")


info "ipa_dir_path: #{ipa_dir_path}"


#unzip ipa file to get the Info.plist file
tar_cmd = "tar -zxf #{local_IPA_path} -C #{ipa_dir_path}"
`#{tar_cmd}`


# 获取 Payload 文件夹下的文件名称
unzip_ipa_dir = "#{ipa_dir_path}/Payload"
export_ipa_app_name = ''
if File.directory?(unzip_ipa_dir)
  dir = Dir.open(unzip_ipa_dir)
  while name = dir.read
    next if name == '.'
    next if name == '.'

    if File.extname(name) == '.app'
      export_ipa_app_name = File.basename(name, '.app')
      break
    end
  end
end

if export_ipa_app_name.length <= 0
  error "Can not find the export app in #{unzip_ipa_dir}"
  exit
end

info "app name in Payload dir: #{export_ipa_app_name}"
app_info_plist_path = "#{ipa_dir_path}/Payload/#{export_ipa_app_name}.app/Info.plist"
info "app_info_plist_path: #{app_info_plist_path}"


display_name = `/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName" "#{app_info_plist_path}"`
display_name = display_name.strip

bundle_short_version = `/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "#{app_info_plist_path}"`
bundle_short_version = bundle_short_version.strip

bundle_version = `/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "#{app_info_plist_path}"`
bundle_version = bundle_version.strip

bundle_identifier = `/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "#{app_info_plist_path}"`
bundle_identifier = bundle_identifier.strip

#Delete the Payload folder
`rm -rf #{ipa_dir_path}/Payload`

items_service_file_name = "#{target_name}_#{bundle_short_version}_#{bundle_version}"

if !File.directory?("#{ipa_dir_path}")
  error("Not exist: #{ipa_dir_path}, will create dir")
  FileUtils.mkdir_p "#{ipa_dir_path}"
end

if !File.exist?("#{ipa_dir_path}/#{items_service_file_name}.plist")
  error "Can not find #{items_service_file_name} in #{ipa_dir_path}"
end

local_item_service_file_path = "#{ipa_dir_path}/#{items_service_file_name}.plist"

# Upload the items-service file to server
info %Q{ruby ruby-sftp.rb -f "#{local_item_service_file_path}" -s "#{host}" -u "#{username}" -p "#{password}" -r "#{remote_plist_dir_path}"}
`ruby ruby-sftp.rb -f "#{local_item_service_file_path}" -s "#{host}" -u "#{username}" -p "#{password}" -r "#{remote_plist_dir_path}"`







