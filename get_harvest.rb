#!/usr/bin/env ruby
# encoding: utf-8

require "mechanize"
require "open-uri"
require "nokogiri"
require_relative "CWebApp"
require_relative "util"

agent = Mechanize.new
agent.user_agent = "My User Agent"

pageLogin = "/account/login"
formLogin = "signin_form"
formExec = ""
dataTableRow = "tr.dt-group"

id = get_config("Harvest", "ID")
pd = get_config("Harvest", "Password")
hLogin = Hash["email"=>id, "user_password"=>pd]

csvpath = "/Users/OzawaKoichi/Develop/output"

#Amoeba上の第一稼働日を取得
a_first_day = get_day_number_of_year(get_first_day_of_amoebamonth())
#前日
yesterday = get_day_number_of_year(Date.today() - 1)
thisyear = Time.now.year


site = CWebAppHarvest.new(agent, "https://motex.harvestapp.com")
if site == nil
	puts("Init Error.")
end

begin

    table = CSV.read(csvpath + "/harvest_user_master.csv")

    site.Login(pageLogin, formLogin, hLogin)

    table.each do | ucode |
        
        url = sprintf("/reports/detailed/%d/%d/%d/%d/%s/any/any/ign/ign/ign/any?group=users",
                      a_first_day, thisyear, yesterday, thisyear, ucode[1])
        
        site.Go(url)
        
        hours = site.GetTotalHours()
        
        ucode << hours
    end
    
    flush_to_csv(table, csvpath + "/user_hours.csv")
    
rescue => e
	p e
    p e.backtrace
end
