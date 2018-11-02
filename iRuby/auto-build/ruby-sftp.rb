#!/usr/bin/env ruby

require 'net/sftp'
require 'optparse'
require './util'

#--------------------------------------------
# function：Using SFTP to upload the specified file to the server specified path
#     -f：the full path to the file name to be uploaded
#     -s：server address
#     -u：sftp username
#     -p：sftp password
#     -r：the full sftp remote path to be uploaded
# author：iCrany
# E-mail:crany1992@gmail.com
# created：2016/08/25
# example: ruby ruby-sftp.rb -f "./test.html" -s "112.124.35.86" -u "username" -p "password" -r "/hd01/webapp/adhoc.skytech.cc/htdoc/afs_admin"
#--------------------------------------------

options = {}

OptionParser.new do |opts|

  opts.banner = "This is use for upload file to server use sftp service"

  opts.on('-f <localFilePath>', 'need to upload file full path') do |value|
    options[:localFilePath] = value
  end

  opts.on('-s <host>', 'server ip') do |value|
    options[:host] = value
  end

  opts.on('-u <username>', 'login username') do |value|
    options[:username] = value
  end

  opts.on('-p <password>', 'login password') do |value|
    options[:password] = value
  end

  opts.on('-r <remotePath>', 'server remote path, can not include "/" at the end of path') do |value|
    options[:remotePath] = value
  end

end.parse!


localFilePath = options[:localFilePath]
filename = File.basename(localFilePath)
host = options[:host]
username = options[:username]
password = options[:password]
remotePath = options[:remotePath]

puts "filename : #{filename}".green

if !localFilePath || !host || !username || !password || !remotePath
  puts "please ensure input all param".red
  exit
end

if !File.exist?(localFilePath)
  puts "#{localFilePath} not exitst".red
  exit
end

Net::SFTP.start("#{host}", "#{username}", :password => "#{password}") do |sftp|
  # upload a file or directory to the remote host
  sftp.upload!("#{localFilePath}", "#{remotePath}/#{filename}") do |event, uploader, *args|
    case event
      when :open then
        # args[0] : file metadata
        puts "starting upload: #{args[0].local} -> #{args[0].remote} (#{args[0].size} bytes}".green

      when :put then
        # args[0] : file metadata
        # args[1] : byte offset in remote file
        # args[2] : data being written (as string)
        progress = (args[1] * 1.0 / args[0].size) * 100
        print "############################# #{progress.round(2)}%".green
        print "\r"
      when :close then
        # args[0] : file metadata
        puts "finished with #{args[0].remote}"
      when :mkdir then
        # args[0] : remote path name
        puts "creating directory #{args[0]}"
      when :finish then
        puts "############################# 100%".green
    end
  end

  # download a file or directory from the remote host
  # sftp.download!("/path/to/remote", "/path/to/local")

  # grab data off the remote host directly to a buffer
  # data = sftp.download!("/path/to/remote")

  # open and write to a pseudo-IO for a remote file
  # sftp.file.open("/path/to/remote", "w") do |f|
  #   f.puts "Hello, world!\n"
  # end

  # open and read from a pseudo-IO for a remote file
  # sftp.file.open("/path/to/remote", "r") do |f|
  #   puts f.gets
  # end

  # create a directory
  # sftp.mkdir! "/path/to/directory"

  # list the entries in a directory
  # sftp.dir.foreach("/path/to/directory") do |entry|
  #   puts entry.longname
  # end
end