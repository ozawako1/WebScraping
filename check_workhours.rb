#!/usr/bin/env ruby
# encoding: utf-8

COLUMN_AMOEBA_UID = 0
COLUMN_HARVEST_UID = 1
COLUMN_EMAIL_ADDRESS = 2
COLUMN_DEPT_CODE = 3
COLUMN_HARVEST_HOUR = 4
COLUMN_AMOEBA_HOUR = 5
COLUMN_CHECED_MONTH = 6

require_relative "CWebApp"
require_relative "util"
require_relative "get_harvest_users"
require_relative "get_harvest"
require_relative "get_amoeba"

use_proxy = 0
use_debug = 0
use_dump  = 0
yyyy = 0
mm = 0

ARGV.each { |arg|
    case arg
    when "PROXY"
        use_proxy = 1
    when "DEBUG"
        use_debug = 1
    when "DUMP"
        use_dump = 1
    else
        tmp = arg.split("/")
        if (tmp.length == 0) 
            puts("undefined arg. [" + arg + "]")
            exit(1)
        end
        yyyy = tmp[0].to_i
        mm = tmp[1].to_i
    end
}

if (yyyy == 0) then
    yyyy = Time.now.year
end
if (mm == 0) then
    mm = Time.now.month
end

puts("checking [" + yyyy.to_s + "/" + mm.to_s + "]")
 
hid = get_config("Harvest", "ID")
hpd = get_config("Harvest", "Password")
hLogin = Hash["email"=>hid, "password"=>hpd]
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
    harvest.Login(HARVEST_PAGE_LOGIN, "", hLogin)
	puts("done.")

	puts("checking HARVEST Users...")    
    get_harvest_users(harvest, use_debug)
	puts("done.")
    
	puts("checking HARVEST Hours...")    
    get_harvest_hours(harvest, yyyy, mm, usrhrs)
	puts("done.")
    
	puts("going to login AMOEBA...")    
    amoeba.Login(AMOEBA_PAGE_LOGIN, AMOEBA_FORM, aLogin)
	puts("done.")

	puts("checking AMOEBA Hours...")    
    get_amoeba_hours(amoeba, yyyy, mm, usrhrs)
	puts("done.")
    
	puts("going to login GOOGLE...")    
    google.Login()
	puts("done.")
    
	puts("Uploading Hours file...")
    google.WriteFile(usrhrs)
	puts("done.")
    
    puts("Sending Mail...")
    google.Kick_("/d/1zuj8DEgB15syssNb1izsIA3S4X8KBnduLTNTwVhYeCI/viewform", "ss2mail")
    puts("done.")
    

rescue => e
    p e
    p e.backtrace
end
