#!/usr/bin

to_email_list_string="jinghui.deng@stringstech.co"
cc_email_list_string="chao.yuan@stringstech.co"
url="https://itunes.apple.com/cn/app/yi-jian-bai-wen-bu-ru-yi-jian/id1089796058?mt=8"

ruby ruby-check-app-available.rb -u 'noreply@stringstech.co' -p 'Bucu0421' -r ${url} -a '3.0.1' -t ${to_email_list_string} -c ${cc_email_list_string} -e '3s' -f '../app_store_available.txt'

