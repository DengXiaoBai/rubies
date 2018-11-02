#!/usr/bin/env ruby

require 'optparse'

#--------------------------------------------
# function：Using CURL to upload the specified folder to the JFrog Artifactory's server specified path(not included the sub folder)
#     -f：the local folder full path to be uploaded
#     -u：artifactory username
#     -p：artifactory password
#     -r：remote path to be uploaded (the full path), such as "http://111.14.35.86:8081/artifactory/{your_artifact_repository_name}", can not include "/" at the end of path
# author：iCrany
# E-mail:crany1992@gmail.com
# created：2017/05/05
# example: ruby ruby-upload-folder.rb -f ./download -u username -p password -r http://112.114.35.76:8081/artifactory/afs_admin/
#--------------------------------------------

def error(msg)
  puts "\e[31m#{msg}\e[0m"
end

def info(msg)
  puts "\e[32m#{msg}\e[0m"
end

options = {}

OptionParser.new do |opts|

  opts.banner = "Using CURL to upload the specified folder to the JFrog Artifactory's server specified path"

  opts.separator ''
  opts.separator "\e[4mCommands:\e[24m"

  opts.on('-f <local_folder_path>', 'need to upload folder full path') do |value|
    options[:local_folder_path] = value
  end

  opts.on('-u <username>', '--username' , 'artifactory username') do |value|
    options[:username] = value
  end

  opts.on('-p <password>', '--password', 'artifactory password') do |value|
    options[:password] = value
  end

  opts.on('-r <remote_dir_path>', '--remote_dir_path' , 'server remote dir path, can not include "/" at the end of path') do |value|
    options[:remote_dir_path] = value
  end

  # "\e[31m Common options: \e[0m"
  opts.separator ''
  opts.separator "\e[31m\e[4mOptions:\e[24m\e[0m"
  opts.on_tail('-h', '--help', 'Show help banner of specified command') do
    puts opts
    exit
  end

end.parse!


local_folder_Path = options[:local_folder_path]
username = options[:username]
password = options[:password]
remote_dir_path = options[:remote_dir_path]

if !local_folder_Path || !username || !password || !remote_dir_path
  error('please ensure input all param')
  exit
end

if !File.directory?(local_folder_Path)
  error("#{local_folder_Path} not a directory")
  exit
end

dir = Dir.open(local_folder_Path)

while name = dir.read

  next if name == '.'
  next if name == '..'

  next if File.directory?("#{local_folder_Path}/#{name}") #ignore the sub dir

  local_file_full_path = "#{local_folder_Path}/#{name}"
  remote_file_full_path = "#{remote_dir_path}/#{name}"

  info "need to update file: #{local_file_full_path} -> #{remote_file_full_path}"

  #begin to upload this file to remote path
  #curl -k -u "admin:password" \
  # -H "X-Checksum-Sha1:$(shasum -a 1 -b "index.html" | awk '{print $1}')" \
  #     -T "index.html" "http://10.0.1.80:8081/artifactory/libs-release-local/testhtml/1.0.0/index.html"
  cmd = %Q{curl -k -u "#{username}:#{password}" -H "X-Checksum-Sha1:$(shasum -a 1 -b #{local_file_full_path} | awk '{print $1}')" -T "#{local_file_full_path}" "#{remote_file_full_path}"}

  `#{cmd}`

end
