#!/usr/bin/env ruby
# encoding: utf-8

require "mechanize"
require "open-uri"
require "nokogiri"

require_relative "CWebApp"
require_relative "util"
require_relative "proc"

# this program will give you a file "harvest_user_master.csv"
# the file consist
# EmployeeCode : 9 digits text such as "040450592"
# HarvestUserID : ID for Harvest Internal Use
# Email Address :
# DepertmentCode : 8 digits text such as "27E50510"

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
        exit
    end
}

pageLogin = "/account/login"
formLogin = "signin_form"
id = get_config("Harvest", "ID")
pd = get_config("Harvest", "Password")
hLogin = Hash["email"=>id, "user_password"=>pd]

csvpath = "/Users/OzawaKoichi/Develop/output"

site = CWebAppHarvest.new("https://motex.harvestapp.com")
if site == nil
	puts("Init Error.")
    exit
end
site.debug = use_debug


begin
    # Login
    site.Login(pageLogin, formLogin, hLogin)
    
    # move to User list
    site.Go("/people")
    
    # save user list to csv
    data = site.RetrieveList("li.manage-list-item", method(:proc_split_list_to_array))
    
    # append email and deptNo.
    data.each do |member|
        site.Go("/people/" + member[1] + "/edit#profile_base")
        
        member.push(site.GetItem("#user_email").attribute("value").value.strip);
        
        member.push(site.GetItem("#user_department").attribute("value").value.strip);
        
    end
    
    sorted = data.sort { |a, b|
        a[3] <=> b[3]
    }
    
    # flush to file
    flush_to_csv(sorted, csvpath + "/harvest_user_master.csv")
    
rescue => e

	p e
    p e.backtrace
    
end
