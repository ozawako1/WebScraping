#!/usr/bin/env ruby
# encoding: utf-8

require "mechanize"
require_relative "CWebApp"
require_relative "util"

use_proxy = 0
use_debug = 0

ARGV.each { |arg|
	case arg
	when "PROXY"
		use_proxy = 1
	when "DEBUG"
		use_debug = 1
	else
		puts("undefined arg. [" + arg + "]")
	end
}

id = get_config("Garoon","username")
pd = get_config("Garoon","password")
login_info = Hash["username"=>id, "password"=>pd]

site = CWebAppGaroon.new("https://7vhc3.cybozu.com", use_debug)
if site == nil
    puts("Init Error.")
    exit
end
site.SetProxy("192.168.106.144", 8080) if use_proxy == 1

begin
    site.Login(GAROON_PAGE_LOGIN, GAROON_FORM_LOGIN, login_info)

    site.Go("/g/schedule/add.csp")
    
    site.CreateEvenet(event_info)
    
    puts("Success." + Time.now.strftime("%Y/%m/%d %H:%M:%S"))
    

rescue => e
    p e
    p e.backtrace
    p Time.now

end