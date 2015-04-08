#!/usr/bin/env ruby
# encoding: utf-8

require "mechanize"
require_relative "CWebApp"

use_proxy = 0
use_debug = 0
jump_page = "/Main?referer=/teams/KTO/PKTO331%%2Fsearchlist.jsp&prepage=/sharemenu.jsp&menuID=PKTO331&forward=searchlist.jsp&service=jp.co.kccs.greenearth.erp.kto.pkto331.PersonalCalendarService&actionbean=GetList&mode=search&listsize=-1&no_header=&Objective_DT_P=%d/%02d&Time_CL_1=1&Stuff_No_0=%s&Name="

ARGV.each { |arg|
	case arg
	when "PROXY"
		use_proxy = 1
	when "DEBUG"
		use_debug = 1
	else
		puts("undefined arg. [" + arg + "]")
	end
}

agent = Mechanize.new
agent.user_agent = "My User Agent"
agent.set_proxy("192.168.106.144", 8080) if use_proxy == 1

cd = get_config("Amoeba","CompanyCode")
id = get_config("Amoeba","ID")
pd = get_config("Amoeba","Password")

login_info = Hash["CompanyCD"=>cd, "UserID"=>id, "Password"=>pd]
csvpath = "/Users/OzawaKoichi/Develop/output"

site = CWebAppAmoeba.new(agent, "http://10.149.0.183:9080/teams", use_debug)
if site == nil
	puts("Init Error.")
    exit
end

begin
    site.Login(AMOEBA_PAGE_LOGIN, AMOEBA_FORM, login_info)

    table = CSV.read(csvpath + "/user_hours.csv")

    table.each do | ucode |
        
        site.Go(jump_page%[Time.now.year, Time.now.month, ucode[0]])
        
        amoeba_hours = site.GetWorkHours()
        
        ucode << amoeba_hours
        
        ucode << ucode[4].to_f - amoeba_hours.to_f
    end

    flush_to_csv(table, csvpath + "/user_hours.csv")


rescue => e
	p e
    p e.backtrace
	p Time.now

end
