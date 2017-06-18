#!/usr/bin/env ruby
# encoding: utf-8

require_relative "CWebApp"
require_relative "util"


def get_harvest_hours(harvest_webapp, yyyy, mm, user_hours_file)

    dataTableRow = "tr.dt-group"

    csvpath = get_config("COMMON", "CSVPath")
    usermst = get_config("Harvest", "MUsers")
    
    site = harvest_webapp

    #Amoeba上の第一稼働日を取得
    a_first_day = get_day_number_of_year(get_first_day_of_amoebamonth(yyyy, mm))
    
    #Amoeba上の最終稼働日を取得
    a_end_day = get_day_number_of_year(get_last_day_of_amoebamonth(yyyy, mm))
    
    t_year = yyyy ? yyyy : Time.now.year
    begin

        table = CSV.read(csvpath + usermst)

        table.each do | ucode |
            
            url = sprintf("/reports/detailed/%d/%d/%d/%d/%s/any/any/ign/ign/ign/any?group=users",
                          a_first_day, t_year, a_end_day, t_year, ucode[1])
            
            site.Go(url)
            
            hours = site.GetTotalHours()
            
            ucode << hours
        end
        
        flush_to_csv(table, user_hours_file)
        
    rescue => e
        p e
        p e.backtrace
    end

end