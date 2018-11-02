#!/bin/sh

current_path=`pwd`
workspace_path_name="../AtFirstSight.xcworkspace"

project_dir_path=`dirname ${workspace_path_name}`

now_dir=`pwd`
alias cd_project_dir="cd ${project_dir_path}"
alias cd_now_dir="cd ${now_dir}"
cd_project_dir
project_dir_path=`pwd`
cd_now_dir

ipa_debug_name="yijian-debug.ipa"
ipa_build_path="${project_dir_path}/ipa-build"
archive_path="${project_dir_path}/ipa-build/yijian-debug.xcarchive"
output_directory="${project_dir_path}/ipa-build/"

# 先删除本地旧的ipa
rm "${ipa_build_path}/${ipa_debug_name}"

fastlane gym --workspace ${workspace_path_name} --scheme 'AtFirstSight' --output_name "yijian-debug" --configuration Debug --export_method "development" --buildlog_path ${ipa_build_path} --archive_path ${archive_path} --output_directory ${ipa_build_path} --clean

red="\033[0;31m"
green="\033[0;32m"
clearColor="\033[0m"

# 打包成功则上传ipa
if [ -f "${ipa_build_path}/${ipa_debug_name}" ]; then
    # sftp 上传步骤
	local_file_path='../ipa-build/yijian-debug.ipa'
	target_name='yijian-debug'
	display_image='yijian'
	user_name='ios'
	password='ios12345678'
	remote_path='http://10.0.1.112:8081/artifactory/iOS_afs_debug'
	remote_plist_dir_path='http://10.0.1.112:8081/artifactory/iOS_plist_files'
	ruby ruby-upload-ipa.rb -f ${local_file_path} -t ${target_name} -d ${display_image} -u ${user_name} -p ${password} -r ${remote_path} -s ${remote_plist_dir_path}

	#Upload the items-service-plist file to https server
	#https://adhoc.skytech.cc/jfrog_plist_file/yijian_debug
	#plist_remote_https_path="/hd01/webapp/adhoc.skytech.cc/htdoc/jfrog_plist_file/yijian_debug"
	#ruby ruby-upload-items-service-to-https.rb -f ${local_file_path} -s "112.124.35.86" -t ${target_name} -u "joe" -p "cc840727cc" -r ${plist_remote_https_path}

	# 发送邮件
	to_email_list_string="zhenzhen.zhang@stringstech.co"
    cc_email_list_string="all@stringstech.co"

	echo "${green}  打包成功 ${clearColor}"
	ruby ruby-smtp-mail.rb -u 'noreply@stringstech.co' -w 'Bucu0421' -s '一见 Debug 环境应用更新，详情请看邮件' -t "${to_email_list_string}" -c "${cc_email_list_string}" -f '../whatNews.txt'
	
else
	echo "${red}  打包失败 ${clearColor}"
fi

