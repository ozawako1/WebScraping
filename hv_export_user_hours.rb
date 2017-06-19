# File: hv_export_user_hours.rb
# harvested API: http://www.rubydoc.info/github/zmoazeni/harvested


require "harvested"
require_relative "util"

=begin
Harvest::TimeEntry 
 adjustment_record=false 
 created_at="2017-06-15T23:21:37Z" 
 hours=4.0 
 id=631318209 
 is_billed=false 
 is_closed=false 
 notes=nil 
 project_id=5799677 
 spent_at=#<Date: 2017-06-15 ((2457920j,0s,0n),+0s,2299161j)> 
 task_id=3173225 
 timer_started_at=nil 
 updated_at="2017-06-15T23:21:37Z" 
 user_id=792156
=end

def hv_export_user_hours(oHarvest, oStartDate, oEndDate, iDbg =0)

    users = oHarvest.users.all
    repos = oHarvest.reports

    summary = Array.new()

	users.each do |u|
        if (u.is_active == true && u.is_admin == false) 
            
            printf("Processing User[%s] ...\n", u.first_name)

            total = 0
            timeentries = repos.time_by_user(u.id, oStartDate, oEndDate)
            timeentries.each do |t|
                total += t.hours    
            end

            if (total > 0) 
                p_summary = Array.new(2)
                p_summary[0] = u.first_name
                p_summary[1] = total
                summary.push(p_summary)
            end
        end
    end

    summary = summary.sort { |x, y|
        x[0] <=> y[0]
    }

    file = get_config("COMMON",	"CSVPath") + get_config("Harvest",	"UserHourCsv")
    flush_to_csv(summary, file)
    	
end


def hv_export_user_hours_amoeba(oHarvest, yyyy, mm, iDbg)

    #Amoeba上の第一稼働日を取得
    a_first_day = get_first_day_of_amoebamonth(yyyy, mm)
    
    #Amoeba上の最終稼働日を取得
    a_end_day = get_last_day_of_amoebamonth(yyyy, mm)

    hv_export_user_hours(oHarvest, a_first_day, a_end_day, iDbg)

end
