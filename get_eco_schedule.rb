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

agent = Mechanize.new
agent.user_agent = "My User Agent"
# agent.set_proxy("10.0.2.58", 8080) if use_proxy == 1

id = get_config("Eco","UserID")
pd = get_config("Eco","password")
login_info = Hash["UserID"=>id, "password"=>pd, "login"=>"1", "grsel"=>"-1"]
path = get_config("Eco", "Url")

site = CWebAppEco.new(agent, "http://192.168.103.149/LspEco", use_debug)
if site == nil
    puts("Init Error.")
    exit
end

google = CWebAppGoogle.new("Eco2Calendar")
if site == nil
    puts("Google Init Error.")
    exit
end

begin
    site.Login("/cgi-bin/Eco.cgi", "loginf", login_info)
    p site.GetPage() if use_dump == 1
    
    site.Go("/cgi-bin/BSCD.cgi")
    p site.GetPage() if use_dump == 1
    
    events = site.GetEventsForToday()
    events.delete_at(0) # delete table header
    
    p site.GetPage() if use_dump == 1
    p events if use_debug == 1
    
    events.each { | ev |
        site.GetEventDetail(ev)
    }
    
    p compress(events)
    
    google.Login()
    
    google.WriteFile(events)
    
    kick = CWebApp.new(agent, "https://docs.google.com/forms", 0)
    if (kick ==nil)
        puts("Google Init Error.")
        exit
    end
    
    kick.Go(path)
    
    kick.Execute("ss-form")
    
    #p kick.GetPage()

rescue => e
    p e
    p e.backtrace
    p Time.now
    
end



