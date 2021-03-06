#!/usr/bin/env ruby
# encoding: utf-8

require "mechanize"
require_relative "CWebApp"
require_relative "util"

def compress(arr)
    arr.each { |line|
        line.delete_at(9)
        line.delete_at(8)
        line.delete_at(7)
        line.delete_at(6)
        line.delete_at(5)
        line.delete_at(4)
        line.delete_at(3)
        line.delete_at(1)
        line.delete_at(0)
    }
    return arr
end

use_proxy = 0
use_debug = 0
use_dump  = 0
get_month = 0

ARGV.each { |arg|
    case arg
        when "PROXY"
            use_proxy = 1
        when "DEBUG"
            use_debug = 1
        when "DUMP"
            use_dump = 1
        when "MONTH"
            get_month = 1
        else
        puts("undefined arg. [" + arg + "]")
    end
}


id = get_config("Eco","UserID")
pd = get_config("Eco","password")
login_info = Hash["UserID"=>id, "password"=>pd, "login"=>"1", "grsel"=>"-1"]
path = get_config("Eco", "Url")

site = CWebAppEco.new("http://192.168.103.149/LspEco", use_debug)
if site == nil
    puts("Init Error.")
    exit
end

google = CWebAppGoogle.new("mygas")
if google == nil
    puts("Google Init Error.")
    exit
end

begin
    puts("Log in Eco ...")
    site.Login("/cgi-bin/Eco.cgi", "loginf", login_info)
    p site.GetPage() if use_dump == 1
    
    puts("Getting Schedule from Eco ...")
    if get_month == 1 then
        events = site.GetEventsForMonth()
    else
        events = site.GetEventsForWeek()
    end
    p site.GetPage() if use_dump == 1
    p events if use_debug == 1    
    
    puts("Getting Schedule detail from Eco ...")
    arr = Array.new
    events.each { | ev |
        arr.push(site.GetEventDetail(ev))
    }
    
    puts("Log in Google ...")
    google.Login()
    
    puts("Upload schedule to Google ...")
    google.WriteArray(arr)
    
    puts("Update Google Calendar ...")
    google.Kick_(path, "ss2cal") 
        
    puts("Success." + Time.now.strftime("%Y/%m/%d %H:%M:%S"))
    
rescue => e
    p e
    p e.backtrace
    p Time.now

	puts("Error." + e.message)
    
end



