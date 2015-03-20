#!/usr/bin/env ruby
# encoding: utf-8

require "mechanize"
require "open-uri"
require "nokogiri"

require_relative "CWebApp"
require_relative "CConst"
require_relative "util"

def separate_value(line, arr)
    shain_code = line.css("span.first_name").text.strip
    huser_code = line.css("a.edit-button").attribute("href").value.strip
    pos1 = huser_code.index("/", 1)
    pos2 = huser_code.index("/", pos1 + 1)
    huser_code = huser_code[pos1 + 1, pos2 - pos1 - 1]
    
    itm = Array.new
    itm.push(shain_code)
    itm.push(huser_code)
    
    arr.push(itm)
end


const = CConstHarvest.new()
agent = Mechanize.new
agent.user_agent = "My User Agent"

pageLogin = "/account/login"
formLogin = "signin_form"
id = get_config("Harvest", "ID")
pd = get_config("Harvest", "Password")
hLogin = Hash["email"=>id, "user_password"=>pd]

csvpath = "/Users/OzawaKoichi/Develop/output"

site = CWebAppHarvest.new(agent, "https://motex.harvestapp.com")
if site == nil
	puts("Init Error.")
end

site.debug = 1

begin
    # Login
    site.Login(pageLogin, formLogin, hLogin)
    
    # move to User list
    site.Go("/people")
    
    # save user list to csv
    data = site.RetrieveList("li.manage-list-item", method(:separate_value))
    
    data.each do |member|
        site.Go("/people/" + member[1] + "/edit#profile_base")
        
        member.push(site.RetrieveValue("#user_email").attribute("value").value.strip);
        
        member.push(site.RetrieveValue("#user_department").attribute("value").value.strip);
        
    end
    
    flush_to_csv(data, csvpath + "/harvest_user_master.csv")
    
rescue => e

	p e
    p e.backtrace
    
end
