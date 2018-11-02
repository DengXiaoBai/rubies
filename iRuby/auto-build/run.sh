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

ipa_adhoc_name="yijian.ipa"
ipa_build_path="${project_dir_path}/ipa-build"
archive_path="${project_dir_path}/ipa-build/yijian.xcarchive"
output_directory="${project_dir_path}/ipa-build/"

fastlane gym --workspace ${workspace_path_name} --scheme 'AtFirstSight-Adhoc' --output_name "yijian" --configuration Adhoc --export_method "ad-hoc" --buildlog_path ${ipa_build_path} --archive_path ${archive_path} --output_directory ${ipa_build_path} --clean


# sftp 上传步骤
ruby ruby-sftp.rb -f "${ipa_build_path}/${ipa_adhoc_name}" -s "112.124.35.86" -u "joe" -p "cc840727cc" -r "/hd01/webapp/adhoc.skytech.cc/htdoc/yijianV2"



# 发送邮件
to_email_list_string="zhenzhen.zhang@stringstech.co"
cc_email_list_string="all@stringstech.co"

ruby ruby-smtp-mail.rb -u 'noreply@stringstech.co' -w 'Bucu0421' -s '一见 Adhoc 环境应用更新，详情请看邮件' -t "${to_email_list_string}" -c "${cc_email_list_string}" -f '../whatNews.txt'

