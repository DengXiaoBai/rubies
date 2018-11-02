#!/usr/bin/env sh

local_folder_path='../first_time_upload_resource'
user_name='ios'
password='ios12345678'
remote_path='http://10.0.1.112:8081/artifactory/iOS_afs_debug/resources'

ruby ruby-upload-folder.rb -f ${local_folder_path} -u ${user_name} -p ${password} -r ${remote_path}