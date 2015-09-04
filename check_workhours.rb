#!/usr/bin/env ruby
# encoding: utf-8

require_relative "CWebApp"
require_relative "util"
require_relative "get_harvest_users"
require_relative "get_harvest"
require_relative "get_amoeba"

use_proxy = 0
use_debug = 0
use_dump  = 0

ARGV.each { |arg|
    case arg
    when "PROXY"
        use_proxy = 1
    when "DEBUG"
        use_debug = 1
    when "DUMP"
        use_dump = 1
    else
        puts("undefined arg. [" + arg + "]")
    end
}


hid = get_config("Harvest", "ID")
hpd = get_config("Harvest", "Password")
hLogin = Hash["email"=>hid, "user_password"=>hpd]
harvest = CWebAppHarvest.new("https://motex.harvestapp.com", use_debug)
if harvest == nil
    puts("Init Error.")
end

acd = get_config("Amoeba","CompanyCode")
aid = get_config("Amoeba","ID")
apd = get_config("Amoeba","Password")
aLogin = Hash["CompanyCD"=>acd, "UserID"=>aid, "Password"=>apd]
amoeba = CWebAppAmoeba.new("http://10.149.0.183:9080/teams", use_debug)
if amoeba == nil
    puts("Init Error.")
end

google = CWebAppGoogle.new("mygas", use_debug)
if google == nil
    puts("Init Error.")
end

usrhrs = get_config("COMMON", "CSVPath") + get_config("COMMON", "UserHours")


begin
	puts("going to login HARVEST...")    
    harvest.Login(HARVEST_PAGE_LOGIN, HARVEST_FORM_LOGIN, hLogin)
	puts("done.")

	puts("checking HARVEST Users...")    
    get_harvest_users(harvest)
	puts("done.")
    
	puts("checking HARVEST Hours...")    
    get_harvest_hours(harvest, usrhrs)
	puts("done.")
    
	puts("going to login AMOEBA...")    
    amoeba.Login(AMOEBA_PAGE_LOGIN, AMOEBA_FORM, aLogin)
	puts("done.")

	puts("checking AMOEBA Hours...")    
    get_amoeba_hours(amoeba, usrhrs)
	puts("done.")
    
	puts("going to login GOOGLE...")    
    google.Login()
	puts("done.")
    
	puts("Uploading Hours file...")
    google.WriteFile(usrhrs)
	puts("done.")

rescue => e
    p e
    p e.backtrace
end
