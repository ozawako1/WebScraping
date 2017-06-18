# File: hv_export_projs.rb
# harvested API: http://www.rubydoc.info/github/zmoazeni/harvested


require "harvested"
require_relative "util"

use_debug = 0
ARGV.each { |arg|
	case arg
	when "DEBUG"
		use_debug = 1
	else
		puts("undefined arg. [" + arg + "]")
	end
}

subdomain = get_config("Harvest",	"SubDomain")
username  = get_config("Harvest",	"ID")
password  = get_config("Harvest",	"Password")
file = get_config("COMMON",	"CSVPath") + get_config("Harvest", "MProjectList")



=begin
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

begin
	# Login
	hv = Harvest.hardy_client(subdomain: subdomain, username: username, password: password)		
#    tasks = hv.tasks.all
    projs = hv.projects.all	
    repos = hv.reports

    summary = Array.new()

	projs.each do |p|

        if (p.active == true) 
            p_proj = Array.new(3)

            p_proj[0] = p.id
            p_proj[1] = p.code
            p_proj[2] = p.name
            
            summary.push(p_proj)
        end
    end

    summary = summary.sort { |x, y|
        x[1] <=> y[1]
    }

    flush_to_csv(summary, file, true)
    	
		
rescue => e
    p e
    p e.backtrace
    p Time.now

end

