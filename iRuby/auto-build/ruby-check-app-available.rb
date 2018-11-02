#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'rufus-scheduler'
require 'optparse'

#<span itemprop="softwareVersion">1.0.21</span>
#https://itunes.apple.com/cn/app/yi-jian-bai-wen-bu-ru-yi-jian/id1089796058?mt=8

options = {}

OptionParser.new do |opts|

  opts.banner = 'This is used for check app is available in AppStore'

  opts.on('-a <target_app_version>', 'need to check target_app_version') do |value|
  	options[:target_app_version] = value
  end

  opts.on('-t <to_user_email_list_string>', 'To email list string, separated by comma, such as \'qqq@ccc.com, rrr@ccc.com\'') do |value|
  	options[:to_email_list_string] = value
  end

  opts.on('-c <cc_email_list_string>', 'Cc email list string, separated by comma, such as \'qqq@ccc.com, rrr@ccc.com\'') do |value|
  	options[:cc_email_list_string] = value
  end

  opts.on('-e <Tap, example: 1m>', 'example: 1s or 2m or 3h or 4d') do |value|
  	options[:every_time] = value
  end

  opts.on('-r <target_uri>', 'App url in AppStore') do |value|
  	options[:target_uri] = value
  end

  opts.on('-u <email_username>', 'email username') do |value|
    options[:email_username] = value
  end

  opts.on('-p <email_password>', 'email password') do |value|
  	options[:email_password] = value
  end

  opts.on('-f <email_content_file_path>', 'email content file path') do |value|
  	options[:file_path] = value
  end

end.parse!

puts options

every_time = options[:every_time]
cc_email_list_string = options[:cc_email_list_string]
to_email_list_string = options[:to_email_list_string]
target_app_version = options[:target_app_version]
target_uri = options[:target_uri]
email_username = options[:email_username]
email_password = options[:email_password]
file_path = options[:file_path]

scheduler = Rufus::Scheduler.new

puts "run every #{every_time}"

scheduler.every every_time do

  puts "bengin loop.."	

	@html = open(target_uri)
	doc = Nokogiri::HTML(@html)

	@app_version = nil
	doc.search('//div//ul//li//span[@itemprop="softwareVersion"]').each do |link|
		@app_version = link.content
		puts link.content
	end

	if @app_version && @app_version == target_app_version
		puts "app_version correct: #{@app_version}"

# ruby ruby-smtp-mail.rb -u 'noreply@stringstech.co' -w 'Bucu0421' -s '一见 Debug 环境应用更新，详情请看邮件' -t "${to_email_list_string}" -c "${cc_email_list_string}" -f '../whatNews.txt'
		`ruby ruby-smtp-mail.rb -u '#{email_username}' -w "#{email_password}" -s "#{target_app_version} 版本已经可以在 AppStore 中下载" -t "#{to_email_list_string}" -c "#{cc_email_list_string}" -f "#{file_path}"`

		exit(0)
	else
		puts "app_version not correct, app_version: #{@app_version} target_app_version: #{target_app_version}"
	end

  puts "end loop.."

end

# let the current thread join the scheduler thread
scheduler.join
	



