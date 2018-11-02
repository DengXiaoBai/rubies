#!/bin/sh

current_path=`pwd`
workspace_path_name="../AtFirstSight.xcworkspace"

ruby ipa-build-archive.rb -w ${workspace_path_name} -c Debug -t AtFirstSight -s AtFirstSight -i yijian-debug -o '../plist/debug.plist' -n

# sftp 上传步骤

project_dir_path=`dirname ${workspace_path_name}`

now_dir=`pwd`
alias cd_project_dir="cd ${project_dir_path}"
alias cd_now_dir="cd ${now_dir}"
cd_project_dir
project_dir_path=`pwd`
cd_now_dir

ipa_adhoc_name="yijian-debug.ipa"
ipa_build_path="${project_dir_path}/ipa-build"

ruby ruby-sftp.rb -f "${ipa_build_path}/${ipa_adhoc_name}" -s "112.124.35.86" -u "joe" -p "cc840727cc" -r "/hd01/webapp/adhoc.skytech.cc/htdoc/yijianV2" 



# 发送邮件
# to_email_list_string="zhenzhen.zhang@stringstech.co"
# cc_email_list_string="jan.xian@stringstech.co,chao.yuan@stringstech.co,junxuan.chen@stringstech.co"

# ruby ruby-smtp-mail.rb -u 'noreply@stringstech.co' -w 'Bucu0421' -s '一见 Debug 环境应用更新，详情请看邮件' -t "${to_email_list_string}" -c "${cc_email_list_string}" -f '../whatNews.txt'

