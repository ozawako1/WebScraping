# File: hv_create_proj.rb
# Date Created: 2012-10-08
# Author(s): Mark Rickert (mjar81@gmail.com) / Skookum Digital Works - http://skookum.com
#
# Description: This example script takes user input from the command line and
# creates a project based the selected options. It then assigns tasks from Harvest
# to the project based on an array. After the tasks are added, it addes all the
# currently active users to the project.

=begin
{
	"mailtype":"21",
	"clientname":"栗田源喜",
	"replyaddress":"genki.kurita@motex.co.jp",
	"product":"LanScopeAn",
	"version":"2.7.3.0",
	"functionname":"Android O対応",
	"targetyear":"2017",
	"targetmonth":"10",
	"supervision":"サービス運用課(27E71130)",
	"amount":"\\3,000,000",
	"contact":"Android O が 8 月 ～ 10月頃にリリースされる予定です。※時期未定\r\nAnで環境対応すべく、調査から行ってまいります。\r\nご承認のほど、宜しくお願い致します。",
	"toaddress":["koichi.ozawa@motex.co.jp"],
	"ccaddress":["akihito.nakano@motex.co.jp,yasutomo.sakondo@motex.co.jp,hiroshi.arinobu@motex.co.jp,tomoaki.hoshino@motex.co.jp"],
	"code":"DA1706-005"
}
=end

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
 ends_on=nil
 estimate=nil 
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


require "harvested"
require_relative "util"
#require_relative "o365_mail"
require_relative "cw_post"

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
jsonpath  = get_config("Harvest",	"JsonPath")

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
			note: jdata["supervision"] + " / " + jdata["contact"],
			billable: true,
			hourly_rate: 5000,
			budget_by: "project_cost",
            estimate_by: "project_cost",
            cost_budget: jdata["amount"].scan(/[0-9]/).join.to_i,
			bill_by: "Project"	
			)
		puts("creating project [" + proj.name + "]...")

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
		
		puts("[" + proj.code  + "] created.")		
		File.rename(f, jsonpath + "done/" + File.basename(f))

		chatmsg = "[info][title]プロジェクトコードが採番されました[/title]"
		chatmsg += "プロジェクト名: " + jdata["functionname"] + "\r\n"
		chatmsg += "プロジェクトコード: " + jdata["code"]
		chatmsg += "[/info]（※このメッセージは、自動送信です。）"

		cw_post_msg("マイチャット", chatmsg, jdata["replyaddress"], jdata["ccaddress"][0])

	end
	
		
rescue => e
    p e
    p e.backtrace
    p Time.now

end

