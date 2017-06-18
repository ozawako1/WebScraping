# File: project_create_script.rb
# Date Created: 2012-10-08
# Author(s): Mark Rickert (mjar81@gmail.com) / Skookum Digital Works - http://skookum.com
#
# Description: This example script takes user input from the command line and
# creates a project based the selected options. It then assigns tasks from Harvest
# to the project based on an array. After the tasks are added, it addes all the
# currently active users to the project.

require "harvested"
require_relative "util"

CLIENT_NAME = "Motex Inc."

use_debug = 1
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
file = get_config("COMMON",	"CSVPath")


def pivot 
    
end

=begin
Harvest::TimeEntry 
 adjustment_record=false 
 created_at="2017-06-02T00:04:10Z"
 hours=0.17
 id=624819984
 is_billed=false
 is_closed=false 
 otes=nil 
 project_id=9849478 
 spent_at=#<Date: 2017-06-01 ((2457906j,0s,0n),+0s,2299161j)> 
 task_id=3173156 
 timer_started_at=nil 
 updated_at="2017-06-02T00:04:14Z" 
 user_id=792160
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
        
            total = 0

            timeentries = repos.time_by_project(p.id, Date.new(2017,6,1), Date.today)
            timeentries.each do |t|
                total += t.hours    
            end

            p_summary = Array.new(2)
            p_summary[0] = p.code
            p_summary[1] = total
            summary.push(p_summary)

        end
        
    end

    file = file + "summary.csv"

    flush_to_csv(summary, file)
    p summary if use_debug
    	
	
		
rescue => e
    p e
    p e.backtrace
    p Time.now

end

