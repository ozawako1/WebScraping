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

def get_harvest_users(harvest_webapp)

    member_page = "/people"
    pt = get_config("COMMON", "CSVPath")
    um = get_config("Harvest", "UserMaster")

    site = harvest_webapp

    begin
        
        # move to User list
        site.Go(member_page)
        
        # save user list to csv
        data = site.RetrieveList("li.manage-list-item", method(:proc_split_list_to_array))
        
        # append email and dept_code
        data.each do |member|
            site.Go("/people/" + member[1] + "/edit#profile_base")
            
            member.push(site.GetItem("#user_email").attribute("value").value.strip);
            
            member.push(site.GetItem("#user_department").attribute("value").value.strip);
            
        end
        
        # sort by dept_code
        sorted = data.sort { |a, b|
            a[3] <=> b[3]
        }
        
        # flush to file
        flush_to_csv(sorted, pt + um)
        
    rescue => e

        p e
        p e.backtrace
        
    end
    
end
