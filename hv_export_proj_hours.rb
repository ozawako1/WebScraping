# File: hv_export_proj_hours.rb
# harvested API: http://www.rubydoc.info/github/zmoazeni/harvested


require "harvested"
require_relative "util"

CSV_COL_PJH_PROJECTCODE = 0
CSV_COL_PJH_TASKCODE    = 1
CSV_COL_PJH_TASKHOUR    = 2
CSV_COL_PJH_PROJECTHOUR = 3
CSV_COL_PJH_MAX         = 4

=begin
Harvest::Project 
 active=true 
 bill_by="none" 
 billable=true 
 budget=nil 
 budget_by="none" 
 client_id=2558898 
 code="DC1706-C03" 
 cost_budget=nil 
 cost_budget_include_expenses=false 
 created_at="2017-06-14T00:38:07Z" 
 ends_on=nil estimate=nil 
 estimate_by="none" 
 hint_earliest_record_at=nil 
 hint_latest_record_at=nil 
 hourly_rate=nil 
 id=14200342 
 name="..." 
 notes="" 
 notify_when_over_budget=false 
 over_budget_notification_percentage=80.0 
 over_budget_notified_at=nil 
 show_budget_to_all=false 
 starts_on=nil 
 updated_at="2017-06-14T00:38:07Z"

 {
    "task": {
        "id": 2086199,
        "name": "Admin",
        "billable_by_default": false,
        "created_at": "2013-04-30T20:28:12Z",
        "updated_at": "2013-08-14T22:25:42Z",
        "is_default": true,
        "default_hourly_rate": 0,
        "deactivated": true
    }
}

=end

def hv_get_task_code(arr, taskid)
    ret = ""
    arr.each do |a|
        if( a.id == taskid.to_i )
            ret = a.name[1,2]
            break
        end
    end
    return ret
end

def hv_export_task(oHarvest, iDbg)
    tasks = oHarvest.tasks.all

    summary = Array.new()

    tasks.each do |t|
        
        arr = t.to_a

        row = Array.new()
        
        arr.each do |a|
           row.push(a[1])
        end

        summary.push(row)
    end

    summary = summary.sort { |x, y|
        x[0] <=> y[0]
    }
    
    file = get_config("COMMON",	"CSVPath") + get_config("Harvest", "MTasks")
    flush_to_csv(summary, file)
    

end


def hv_export_project_hours(oHarvest, iDbg)

    projs = oHarvest.projects.all
    tasks = oHarvest.tasks.all	
    repos = oHarvest.reports

    summary = Array.new()

	projs.each do |p|
#        if (p.active == true && p.code == "W1503-015") 
        if (p.active == true && p.code != "") 

            printf("Processing Project[%s] ...\n", p.code)

            total = 0
            sub = 0
            
            #Projectの作成日から１ヶ月過去に遡って集計する
            startdate = Date.parse(p.created_at) << 1
            enddate = Date.today

            #タスクごとにハッシュで保存
            sub_total = {}

            timeentries = repos.time_by_project(p.id, startdate, enddate)
            timeentries.each do |t|
                sub = 0
                if (sub_total.has_key?("#{t.task_id}"))
                    sub = sub_total["#{t.task_id}"]
                end
                sub_total["#{t.task_id}"] = sub + t.hours
                total += t.hours
            end

            # ハッシュを配列に変換
            sub_total.to_a

            if (total > 0) 
                sub_total.each do |arr|
                    p_summary = Array.new(CSV_COL_PJH_MAX)
                    p_summary[CSV_COL_PJH_PROJECTCODE] = p.code
                    p_summary[CSV_COL_PJH_TASKCODE] = hv_get_task_code(tasks, arr[0])
                    p_summary[CSV_COL_PJH_TASKHOUR] = arr[1]
                    p_summary[CSV_COL_PJH_PROJECTHOUR] = total
                    summary.push(p_summary)
                end
            end
        end
    end

    summary = summary.sort { |x, y|
        x[0] <=> y[0]
    }

    file = get_config("COMMON",	"CSVPath") + get_config("Harvest", "ProjHourCsv")
    flush_to_csv(summary, file)
    	
		
rescue => e
    p e
    p e.backtrace
    p Time.now

end

