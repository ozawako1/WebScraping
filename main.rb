#!/usr/bin/env ruby
# encoding: utf-8

require_relative "hv_export_proj_hours"
require_relative "hv_export_user_hours"
require_relative "hv_export_users"
require_relative "hv_export_projects"
require_relative "cw_post"


subdomain = get_config("Harvest",	"SubDomain")
username  = get_config("Harvest",	"ID")
password  = get_config("Harvest",	"Password")

use_proxy = 0
use_debug = 0
use_dump  = 0
yyyy = 0
mm = 0

TEST_EXPORT_USER_HOURS = 0
TEST_EXPORT_PROJ_HOURS = 1
TEST_EXPORT_USER_MASTER = 2
TEST_EXPORT_PROJ_MASTER = 3
TEST_EXPORT_TASK_MASTER = 4

TEST_CW_POST = 10

#TestMode = TEST_EXPORT_USER_HOURS
#TestMode = TEST_EXPORT_PROJ_HOURS
#TestMode =  TEST_EXPORT_TASK_MASTER
#TestMode = TEST_EXPORT_USER_MASTER
#TestMode = TEST_EXPORT_PROJ_MASTER
TestMode = TEST_CW_POST

ARGV.each { |arg|
    case arg
    when "PROXY"
        use_proxy = 1
    when "DEBUG"
        use_debug = 1
    when "DUMP"
        use_dump = 1
    end
}

begin
    hv = Harvest.hardy_client(subdomain: subdomain, username: username, password: password)	
    
    case TestMode
    when TEST_EXPORT_USER_HOURS
        hv_export_user_hours_amoeba(hv, Time.now.year, Time.now.month, use_debug)
    when TEST_EXPORT_PROJ_HOURS
        hv_export_project_hours(hv, use_debug)
    when TEST_EXPORT_USER_MASTER
        hv_export_users(hv, use_debug)
    when TEST_EXPORT_PROJ_MASTER
        hv_export_projects(hv, use_debug)
    when TEST_EXPORT_TASK_MASTER
        hv_export_task(hv, use_debug)
    when TEST_CW_POST
        cw_post_msg("マイチャット", "test投稿", "kitamura@motex.co.jp")
    end

rescue => e
    p e
    p e.backtrace
end


