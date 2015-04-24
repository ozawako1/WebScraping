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

if (is_already_ran == 1)
    exit if use_debug == 0
end

cd = get_config("Amoeba","CompanyCode")
id = get_config("Amoeba","ID")
pd = get_config("Amoeba","Password")
login_info = Hash["CompanyCD"=>cd, "UserID"=>id, "Password"=>pd]

site = CWebAppAmoeba.new("http://10.149.0.183:9080/teams", use_debug)
if site == nil
    puts("Init Error.")
    exit
end
site.SetProxy("192.168.106.144", 8080) if use_proxy == 1

begin
    site.Login(AMOEBA_PAGE_LOGIN, AMOEBA_FORM, login_info)

    site.Jump("PKTO318-1")
    site.RunJS(AMOEBA_APPLY_SCRIPT)
    
    site.Execute(AMOEBA_FORM, AMOEBA_APPLY_SCRIPT)
    
    site.Jump("PKTO318-2")
    site.RunJS(AMOEBA_APPROVE_SCRIPT)
    
    site.Execute(AMOEBA_FORM, AMOEBA_APPROVE_SCRIPT)
    
    puts("Success." + Time.now.strftime("%Y/%m/%d %H:%M:%S"))
    
    mark_ran()

rescue => e
    p e
    p e.backtrace
    p Time.now

end
