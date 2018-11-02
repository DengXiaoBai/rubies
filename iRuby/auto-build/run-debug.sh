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

	# 上传 Debug
	ruby ruby-sftp.rb -f "${ipa_build_path}/${ipa_debug_name}" -s "112.124.35.86" -u "joe" -p "cc840727cc" -r "/hd01/webapp/adhoc.skytech.cc/htdoc/yijianV2"


	# 发送邮件
	to_email_list_string="zhenzhen.zhang@stringstech.co"
	cc_email_list_string="jan.xian@stringstech.co,chao.yuan@stringstech.co,junxuan.chen@stringstech.co"

	echo "${green}  打包成功 ${clearColor}"
	ruby ruby-smtp-mail.rb -u 'noreply@stringstech.co' -w 'Bucu0421' -s '一见 Debug 环境应用更新，详情请看邮件' -t "${to_email_list_string}" -c "${cc_email_list_string}" -f '../whatNews.txt'
	
else
	echo "${red}  打包失败 ${clearColor}"
fi

