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
require_relative "hv_export_users"
require_relative "hv_export_user_hours.rb"
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

=begin
hid = get_config("Harvest", "ID")
hpd = get_config("Harvest", "Password")
hLogin = Hash["email"=>hid, "password"=>hpd]
harvest = CWebAppHarvest.new("https://motex.harvestapp.com", use_debug)
if harvest == nil
    puts("Init Error.")
end
=end

acd = get_config("Amoeba","CompanyCode")
aid = get_config("Amoeba","ID")
apd = get_config("Amoeba","Password")
aLogin = Hash["CompanyCD"=>acd, "UserID"=>aid, "Password"=>apd]
amoeba = CWebAppAmoeba.new("http://10.149.0.183:9080/teams", use_debug)
if amoeba == nil
    puts("Init Error.")
end

=begin
google = CWebAppGoogle.new("mygas", use_debug)
if google == nil
    puts("Init Error.")
end
=end

#usrhrs = get_config("COMMON", "CSVPath") + get_config("COMMON", "UserHours")

begin
=begin
	puts("going to login HARVEST...")    
    harvest.Login(HARVEST_PAGE_LOGIN, "", hLogin)
	puts("done.")
=end

    subdomain = get_config("Harvest",	"SubDomain")
    username  = get_config("Harvest",	"ID")
    password  = get_config("Harvest",	"Password")
    hv = Harvest.hardy_client(subdomain: subdomain, username: username, password: password)	

	puts("checking HARVEST Users...")    
    hv_export_users(hv, use_debug)
	puts("done.")
    
	puts("checking HARVEST Hours...")    
    hv_export_user_hours_amoeba(hv, yyyy, mm, use_debug)
	puts("done.")
    
	puts("going to login AMOEBA...")    
    amoeba.Login(AMOEBA_PAGE_LOGIN, AMOEBA_FORM, aLogin)
	puts("done.")

	puts("checking AMOEBA Hours...")    
    get_amoeba_hours(amoeba, yyyy, mm)
	puts("done.")

=begin    
	puts("going to login GOOGLE...")    
    google.Login()
	puts("done.")
    
	puts("Uploading Hours file...")
    google.WriteFile(usrhrs)
	puts("done.")
    
    puts("Sending Mail...")
    google.Kick_("/d/1zuj8DEgB15syssNb1izsIA3S4X8KBnduLTNTwVhYeCI/viewform", "ss2mail")
    puts("done.")
=end

rescue => e
    p e
    p e.backtrace
end
