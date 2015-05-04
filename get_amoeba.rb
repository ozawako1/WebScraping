#!/usr/bin/env ruby
# encoding: utf-8
require_relative "CWebApp"


def get_amoeba_hours(amoeba_webapp, user_hours_file)
    
    site = amoeba_webapp

	jump_page = "/Main?referer=/teams/KTO/PKTO331%%2Fsearchlist.jsp&prepage=/sharemenu.jsp&menuID=PKTO331&forward=searchlist.jsp&service=jp.co.kccs.greenearth.erp.kto.pkto331.PersonalCalendarService&actionbean=GetList&mode=search&listsize=-1&no_header=&Objective_DT_P=%d/%02d&Time_CL_1=1&Stuff_No_0=%s&Name="

    begin
        table = CSV.read(user_hours_file)

        table.each do | ucode |
            
            site.Go(jump_page%[Time.now.year, Time.now.month, ucode[0]])
            
            amoeba_hours = site.GetWorkHours()
            
            ucode << amoeba_hours

        end

        flush_to_csv(table, user_hours_file)

    rescue => e
        p e
        p e.backtrace
        p Time.now

    end

end
