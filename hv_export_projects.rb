# File: hv_export_projects.rb
# harvested API: http://www.rubydoc.info/github/zmoazeni/harvested


require "harvested"
require_relative "util"

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
=end


def hv_export_projects(oHarverst, iDbg)
    
    projs = oHarverst.projects.all	


    summary = Array.new()

    column_header = [
        "id", "code", "name", "created_at",
        "notes","budget_by", "estimate_by", "hourly_rate", "cost_budget", 
        "active","bill_by", "billable", "budget", "client_id",
        "cost_budget_include_expenses", "ends_on", "estimate",  
        "hint_earliest_record_at", "hint_latest_record_at", "notify_when_over_budget", 
        "over_budget_notification_percentage", "over_budget_notified_at","show_budget_to_all", "starts_on","updated_at"
    ]
    summary.push(column_header)

	projs.each do |p|

        if (p.active == true && p.code != "") 
            p_proj = Array.new(25)

            p_proj[0] = p.id
            p_proj[1] = p.code
            p_proj[2] = p.name
            p_proj[3] = p.created_at

            p_proj[4] = p.notes            
            p_proj[5] = p.budget_by     #"project_cost"
            p_proj[6] = p.estimate_by  #"project_cost"
            p_proj[7] = p.hourly_rate  #5000
            p_proj[8] = p.cost_budget
            
            p_proj[9] = p.active
            p_proj[10] = p.bill_by
            p_proj[11] = p.billable
            p_proj[12] = p.budget
            p_proj[13] = p.client_id
            p_proj[14] = p.cost_budget_include_expenses
            p_proj[15] = p.ends_on
            p_proj[16] = p.estimate
            p_proj[17] = p.hint_earliest_record_at
            p_proj[18] = p.hint_latest_record_at
            p_proj[19] = p.notify_when_over_budget
            p_proj[20] = p.over_budget_notification_percentage
            p_proj[21] = p.over_budget_notified_at
            p_proj[22] = p.show_budget_to_all
            p_proj[23] = p.starts_on
            p_proj[24] = p.updated_at
        
            summary.push(p_proj)
        end
    end

    summary = summary.sort { |x, y|
        x[1] <=> y[1]
    }

    file = get_config("COMMON",	"CSVPath") + get_config("Harvest", "MProjs")
    flush_to_csv(summary, file, true)
    	

end

