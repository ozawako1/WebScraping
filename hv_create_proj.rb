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
jsonpath  = get_config("COMMON",	"CSVPath")

begin
	# Login
	hv = Harvest.hardy_client(subdomain: subdomain, username: username, password: password)		
	clients = hv.clients.all
	client = clients[0]
	tasks = hv.tasks.all
	users = hv.users.all
	
	Dir::glob(jsonpath + "*.json") do |f|
	
		puts("processing " + f + "...")
		jdata = open(f) do |io|
			JSON.load(io)
		end
		
		proj = Harvest::Project.new(
			client_id: client.id,
			name: jdata["functionname"], 
			code: jdata["code"],
			note: jdata["contact"],
			billable: true
			)
		puts("creating project ["+ proj.name + "]...")
		project = hv.projects.create(proj)
	
		tasks.each do |t|
			task_assignment = Harvest::TaskAssignment.new(task_id: t.id, project_id: project.id)
			hv.task_assignments.create(task_assignment)
		end
		
		users.each do |u|
			next unless u.is_active?
			user_assignment = Harvest::UserAssignment.new(user_id: u.id, project_id: project.id)
			hv.user_assignments.create(user_assignment)
		end

		File.rename(f, jsonpath + "done/" + File.basename(f))

	end
	
		
rescue => e
    p e
    p e.backtrace
    p Time.now

end

