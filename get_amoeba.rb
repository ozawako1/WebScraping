#!/usr/bin/env ruby
# encoding: utf-8

require_relative "CWebApp"

def get_amoeba_hours(amoeba_webapp, yyyy, mm, user_hours_file)
    
    site = amoeba_webapp

    begin
        table = CSV.read(user_hours_file)

        table.each do | rows |
            
            amoeba_hours = site.GetWorkHoursByEmpCode(yyyy, mm, rows[0])
            
            rows << amoeba_hours
            
            rows << yyyy.to_s + "年" + mm.to_s + "月"

        end

        flush_to_csv(table, user_hours_file)

    rescue => e
        p e
        p e.backtrace
        p Time.now

    end

end
