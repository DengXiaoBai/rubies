#!/usr/bin/env ruby         # 使用用户环境变量$PATH中设置的ruby,放在首行
require 'plist'
require 'optparse'
require 'fileutils'
require 'aliyun/oss'

#--------------------------------------------
# function：Using CURL to upload the specified folder to the JFrog Artifactory's server specified path (If upload IPA file, Please remember to change the version and build number when packaged, We will get the version and build number from your IPA file to create folder in server).
# function: upload iap/item-service plist/index.htmp to our internal http server, upload item-service plist to aliyun oss (https server) for item- service protocol
#     -f：the local folder full path to be uploaded
#     -u：artifactory username
#     -p：artifactory password
#     -r：remote path to be uploaded (not the full path), such as "http://111.14.35.86:8081/artifactory/{your_artifact_repository_name}", can not include "/" at the end of path
#     -s: optioanl, the remote plist dir path, may be the jfrog not supports https protocol yet, then you can upload the items-service to the https server and the ipa to the http server. For now this is just a backup url in our internal server, plist file also uploaded to https server(aliyun oss)
# author：iCrany
# E-mail: crany1992@gmail.com
# created：2017/07/01
# maintainer: DengXiaoBai
# email : dengxiaobaigo@outlook.com
# example:
#--------------------------------------------

def error(msg)
  # 没有指定接收者的puts/gets,默认为标准输出/输入
  puts "\e[31m#{msg}\e[0m"
end

def info(msg)
  puts "\e[32m#{msg}\e[0m"
end

# 接收打印参数
options = {}

# block 变量opts为刚创建的OptionParser
# OptionParser 用于解析名行传入的参数
# OptionParser#on: 定义option, 解析option的值
# Detail: https://ruby-china.org/wiki/building-a-command-line-tool-with-optionparser
OptionParser.new do |opts|

  opts.banner = "Using CURL to upload the specified IPA to the JFrog Artifactory's server specified path"

  opts.separator ''
  opts.separator "\e[4mCommands:\e[24m"

  opts.on('-f <localIPAPath>', 'need to upload ipa full path') do |value|
    options[:local_IPA_path] = value
  end

  opts.on('-t <target_name>', '--targetName', 'Build the target specified by target name') do |target_name|
    options[:target_name] = target_name
  end

  opts.on('-d <display_image_name>', '--displayImageName', 'the ipa display image which display in device') do |display_image_name|
    options[:display_image_name] = display_image_name
  end

  opts.on('-u <username>', '--username' , 'artifactory username') do |value|
    options[:username] = value
  end

  opts.on('-p <password>', '--password', 'artifactory password') do |value|
    options[:password] = value
  end

  opts.on('-r <remote_dir_name>', '--remote_dir_path' , 'server remote path(not the full path, see description example), can not include "/" at the end of path') do |value|
    options[:remote_dir_path] = value
  end

  options[:remote_plist_dir_path] = '' # default value is empty
  opts.on('-s <remote plist dir path>', '--remote_plist_dir_path', 'optioanl, the remote plist dir path, may be the jfrog not supports https protocol yet, then you can upload the items-service to the https server and the ipa to the http server, if have value, the plist url in index.html will use this value') do |value|
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
target_name = options[:target_name]
display_image_name = options[:display_image_name]
username = options[:username]
password = options[:password]
remote_dir_path = options[:remote_dir_path]
remote_plist_dir_path = options[:remote_plist_dir_path]

info options

if !local_IPA_path || !username || !password || !remote_dir_path || !target_name
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
# 把ipa解压到当前目录 => ./Payload/
tar_cmd = "tar -zxf #{local_IPA_path} -C #{ipa_dir_path}"
`#{tar_cmd}`


# 获取app 名字 /Payload/AtFirstSight.app
unzip_ipa_dir = "#{ipa_dir_path}/Payload"
export_ipa_app_name = ''
if File.directory?(unzip_ipa_dir)
  dir = Dir.open(unzip_ipa_dir)
  while name = dir.read
    next if name == '.'
    next if name == '..'

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

# 获取plist信息
info "app name in Payload dir: #{export_ipa_app_name}"
app_info_plist_path = "#{ipa_dir_path}/Payload/#{export_ipa_app_name}.app/Info.plist"
info "app_info_plist_path: #{app_info_plist_path}"

# More detail see: /usr/libexec/PlistBuddy -h
# 命令行的标准输出赋值给ruby 变量
display_name = `/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName" "#{app_info_plist_path}"`
display_name = display_name.strip

bundle_short_version = `/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "#{app_info_plist_path}"`
bundle_short_version = bundle_short_version.strip

bundle_version = `/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "#{app_info_plist_path}"`
bundle_version = bundle_version.strip

bundle_identifier = `/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "#{app_info_plist_path}"`
bundle_identifier = bundle_identifier.strip

#Delete the Payload folder
# -f, --force   忽略不存在的文件，从不给出提示。
# -r, -R, --recursive   指示rm将参数中列出的全部目录和子目录均递归地删除。
`rm -rf #{ipa_dir_path}/Payload`

display_image_dir = "#{remote_dir_path}/resources"
# 真正的下载路径
ipa_download_url = "#{remote_dir_path}/#{bundle_short_version}_#{bundle_version}/#{target_name}.ipa"
display_image_download_url = "#{display_image_dir}/#{display_image_name}_display.png"
full_size_image_download_url = "#{display_image_dir}/#{display_image_name}_display_full_size.png"
alert_title = "#{display_name}"
alert_subtitle = "#{display_name}"

# 按照items-service协议创建hash
# 包含app下载地址等信息
resultPlist = {
    'items' => [
        {
            'assets' => [
                {
                    'kind' => 'software-package',
                    'url' => "#{ipa_download_url}"
                },
                {
                    'kind' => 'display-image',
                    'needs-shine' => true,
                    'url' => "#{display_image_download_url}"
                },
                {
                    'kind' => 'full-size-image',
                    'needs-shine' => true,
                    'url' => "#{full_size_image_download_url}"
                }
            ],
            'metadata' => {
                'bundle-identifier' => "#{bundle_identifier}",
                'bundle-version'  => "#{bundle_short_version}",
                'kind'  => 'software',
                'subtitle' => "#{alert_subtitle}",
                'title' => "#{alert_title}"
            }
        }
    ]
}

# 在本地生成items_service plist
items_service_file_name = "#{target_name}_#{bundle_short_version}_#{bundle_version}"

if !File.directory?("#{ipa_dir_path}")
  error("Not exist: #{ipa_dir_path}, will create dir")
  FileUtils.mkdir_p "#{ipa_dir_path}"
end

if File.exist?("#{ipa_dir_path}/#{items_service_file_name}.plist")
  File.open("#{ipa_dir_path}/#{items_service_file_name}.plist", 'w') do |file|
    file.write(resultPlist.to_plist)
  end
else
  File.write("#{ipa_dir_path}/#{items_service_file_name}.plist", resultPlist.to_plist)
end

local_item_service_file_path = "#{ipa_dir_path}/#{items_service_file_name}.plist"
remote_item_service_file_path = "#{remote_dir_path}/#{bundle_short_version}_#{bundle_version}/#{items_service_file_name}.plist"

# 如果没有指定plist地址, 上传到仓库
if remote_plist_dir_path.length > 0 #If have set the remote_plist_dir_path then use it
  remote_item_service_file_path = "#{remote_plist_dir_path}/#{items_service_file_name}.plist"
end


# Step 2: Generate the ipa index.html file
if !File.directory?("#{ipa_dir_path}")
  FileUtils.mkdir_p("#{ipa_dir_path}")
end

# items-services协议 url,包含plist https url
download_ipa_url_for_index_html = "itms-services://?action=download-manifest&url=https://ios-plist-files.oss-cn-shenzhen.aliyuncs.com/#{items_service_file_name}"

# 存储网页url
just_index_html_remote_url  = "#{remote_dir_path}/#{bundle_short_version}_#{bundle_version}/index.html"

File.open("#{ipa_dir_path}/index.html", 'w+') do |file|

  # 创建多行String <<-EOH content EOH
  html_content = <<-EOH
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <style>
    .button {
      background-color: #4CAF50; /* Green */
          border: none;
      color: white;
      padding: 15px 32px;
      text-align: center;
      text-decoration: none;
      display: inline-block;
      font-size: 16px;
    }

    .download_btn {
      display: block;
      margin: auto;
      width: 20%;
    }

    .qr_code {
      display: block;
      margin: auto;
      width: 250px;
    }
    </style>
        <meta charset="UTF-8">
        <title>#{target_name}</title>
    <script type="text/javascript" src="../resources/jquery.min.js"></script>
        <script type="text/javascript" src="../resources/qrcode.min.js"></script>
    </head>
    <body>
        <div style="width: 100%">
            <div id="qrcode" class="qr_code"></div>
            <script type="text/javascript">
                # 用网页url生成二维码
                new QRCode(document.getElementById("qrcode"), "#{just_index_html_remote_url}");
            </script>
            <br/>
            <br/>
            <br/>
            <a href="#{download_ipa_url_for_index_html}" class="button download_btn">Download</a>
    </div>
    </body>
    </html>
  EOH
  file.write(html_content)
end

# Step 3: Upload the ipa
# 创建有"" '' 的String: %Q{}
# -H : 自定义header 字段. X-Checksum-Sha1字段用来检测长传后的文件是否被改动
ipa_upload_cmd = %Q{curl -k -u "#{username}:#{password}" -H "X-Checksum-Sha1:$(shasum -a 1 -b #{local_IPA_path} | awk '{print $1}')" -T "#{local_IPA_path}" "#{ipa_download_url}"}
`#{ipa_upload_cmd}`


# Step 4: Upload the item-service file to our internal server
upload_item_service_cmd = %Q{curl -k -u "#{username}:#{password}" -H "X-Checksum-Sha1:$(shasum -a 1 -b #{local_item_service_file_path} | awk '{print $1}')" -T "#{local_item_service_file_path}" "#{remote_item_service_file_path}"}
`#{upload_item_service_cmd}`

# Step 5: Upload the index.html file
local_index_html_file_path = "#{ipa_dir_path}/index.html"
remote_index_html_file_path = "#{remote_dir_path}/#{bundle_short_version}_#{bundle_version}/index.html"
upload_index_html_cmd = %Q{curl -k -u "#{username}:#{password}" -H "X-Checksum-Sha1:$(shasum -a 1 -b #{local_index_html_file_path} | awk '{print $1}')" -T "#{local_index_html_file_path}" "#{remote_index_html_file_path}"}
`#{upload_index_html_cmd}`

# TODO: 配置 阿里云不生成log
# Step 6: upload plist to https server
# aliyun oss will EXPIRE on 2019-04-20 00:00
if Date.parse('2019-04-20') > Date.today
  error "aliyun oss will EXPIRE on 2019-04-20 00:00"
  info "upload plist file to aliyunoss(https server)"

  client = Aliyun::OSS::Client.new(
    endpoint: 'oss-cn-shenzhen.aliyuncs.com',
    access_key_id: 'LTAIB3U48dRa7G3Y', 
    access_key_secret: 'GTnrqd01tns5AfBDEV2gkfrmVlQ5me')
  
  bucket = client.get_bucket('ios-plist-files')
  bucket.put_object(items_service_file_name, :file => local_item_service_file_path)
  bucket.set_object_acl(items_service_file_name, Aliyun::OSS::ACL::PUBLIC_READ)
end