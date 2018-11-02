#!/usr/bin/env ruby

require 'net/smtp'
require 'optparse'
require 'mail'

#--------------------------------------------
# function：Use the SMTP protocol to send mail, You may need to execute the 'gem install mail' command
#     -a <address>:                    Remote SMTP address, the default address is smtp.office365.com.
#     -p <port>：                      Remote SMTP port number, the default port 587.
#     -u <username>：                  Mailbox account, the default account is noreply@sachsen.cc.
#     -w <password>：                  Mailbox account password.
#     -t <to_user_email_list_string>： To email list string, separated by comma, such as \'qqq@ccc.com, rrr@ccc.com\'.
#     -c <Cc_email_address>:           Cc email list string, separated by comma, such as \'qqq@ccc.com, rrr@ccc.com\'
#     -s <Mail subject>:               Mail subject.
#     -f <file_path_name>:             The file address of the message body.
# author：iCrany
# E-mail:crany1992@gmail.com
# created：2016/10/10
# to_email_list_string = "xxxx@sachsen.cc"
# cc_email_list_string = "xxxxx@qq.com, yyyyy@gmail.com"
# example: `ruby ruby-smtp-mail.rb -w password -t '#{to_email_list_string}' -c '#{cc_email_list_string}' -f './body_file.txt'`
#--------------------------------------------


def error(msg)
  puts "\e[31m#{msg}\e[0m"
end

def info(msg)
  puts "\e[32m#{msg}\e[0m"
end

option = {}

OptionParser.new do |opts|

  opts.banner = 'Use the SMTP protocol to send mail'

  option[:address] = 'smtp.office365.com'
  opts.on('-a <address>', 'Remote SMTP address, the default address is smtp.office365.com') do |value|
    option[:address] = value
  end

  option[:port] = 587
  opts.on('-p <port>', 'Remote SMTP port number, the default port 587') do |value|
    option[:port] = value
  end

  option[:user_name] = 'noreply@sachsen.cc'
  opts.on('-u <username>', 'Mailbox account, the default account is noreply@sachsen.cc') do |value|
    option[:user_name] = value
  end

  opts.on('-w <password>', 'Mailbox account password') do |value|
    option[:password] = value
  end

  opts.on('-t <to_user_email_list_string>', 'To email list string, separated by comma, such as \'qqq@ccc.com, rrr@ccc.com\'') do |value|
    option[:to] = value
  end

  option[:subject] = 'Automatically send mail'
  opts.on('-s <Mail subject>', 'Mail subject') do |value|
    option[:subject] = value
  end

  opts.on('-f <file_path_name>', 'The file address of the message body') do |value|
    option[:body_file_path_name] = value
  end

  opts.on('-c <Cc_email_address>', 'Cc email list string, separated by comma, such as \'qqq@ccc.com, rrr@ccc.com\'') do |value|
    option[:cc] = value
  end

end.parse!

address                 = option[:address]
port                    = option[:port]
user_name               = option[:user_name]
password                = option[:password]
subject                 = option[:subject]
to_email_list_string    = option[:to]
body_file_path_name     = option[:body_file_path_name]
cc_email_list_string    = option[:cc]

puts info("begin\naddress: #{address}\nport: #{port}\nuser_name: #{user_name}\npassword: #{password}\nsubject: #{subject}\nto_email_list_string: #{to_email_list_string}\ncc_email_list_string: #{cc_email_list_string}\nbody_file_path_name: #{body_file_path_name}")

if !password
  error('Please ensure have input password')
  exit
end

if !to_email_list_string
  error('Please ensure have input to email list')
  exit
end

if !File.exist?(body_file_path_name)
  error('Please ensure have body_file_path_name')
  exit
end

# 设置全局邮箱
smtp = {
    :address => address,
    :port => port,
    :domain => 'stringstech.co',
    :user_name => user_name,
    :password => password,
    :enable_starttls_auto => true,
    :openssl_verify_mode => 'none',
    :authentication => 'login' }

# delivery_method 是一个方法
# :smtp是一个Symbol, 方便判断. 这里也可以用"smtp"
# Symbol 和 String 其实都一样
Mail.defaults { delivery_method :smtp, smtp }

# 创建邮箱对象
mail = Mail.new do
  from user_name
  to to_email_list_string
  cc cc_email_list_string
  subject subject
  body File.read(body_file_path_name)
end
mail.charset = 'UTF-8'

# 发送邮件
mail.deliver!


