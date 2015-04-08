#!/usr/bin/env ruby
# encoding: utf-8

require "mechanize"
require_relative "CWebApp"
require_relative "util"

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

if (is_already_ran == 1)
    exit if use_debug == 0
end

agent = Mechanize.new
agent.user_agent = "My User Agent"
# agent.set_proxy("10.0.2.58", 8080) if use_proxy == 1

id = get_config("Eco","UserID")
pd = get_config("Eco","password")
login_info = Hash["UserID"=>id, "password"=>pd, "login"=>"1", "grsel"=>"-1"]

site = CWebAppEco.new(agent, "http://192.168.103.149/LspEco", use_debug)
if site == nil
    puts("Init Error.")
    exit
end

begin
    site.Login("/cgi-bin/Eco.cgi", "loginf", login_info)
    p site.GetPage() if use_dump == 1
    
    site.Go("/cgi-bin/BSCD.cgi")
    p site.GetPage() if use_dump == 1
    
    site.GetEventsForDay()
    p site.GetPage() if use_dump == 1
    
    
    
=begin
 
    site.Jump("PKTO318-1")
    site.RunJS(AMOEBA_APPLY_SCRIPT)
    
    site.Execute(AMOEBA_FORM, AMOEBA_APPLY_SCRIPT)
    
    site.Jump("PKTO318-2")
    site.RunJS(AMOEBA_APPROVE_SCRIPT)
    
    site.Execute(AMOEBA_FORM, AMOEBA_APPROVE_SCRIPT)
    
    puts("Success." + Time.now.strftime("%Y/%m/%d %H:%M:%S"))
    
    mark_ran()
=end
rescue => e
    p e
    p e.backtrace
    p Time.now
    
end
