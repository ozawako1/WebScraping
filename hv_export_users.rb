# File: hv_export_users.rb
# harvested API: http://www.rubydoc.info/github/zmoazeni/harvested


require "harvested"
require_relative "util"

=begin
Harvest::User 
 cost_rate=nil 
 created_at="2014-06-13T07:20:24Z" 
 default_hourly_rate=5000.0 
 department=nil 
 email="system@motex.co.jp" 
 first_name="yymmxxxxd" 
 has_access_to_all_future_projects=true 
 id=763711 
 is_active=true 
 is_admin=true 
 is_contractor=false 
 last_name="Motex" 
 telephone="" 
 timezone="Osaka" 
 updated_at="2017-05-16T02:36:30Z" 
 wants_newsletter=true 
 weekly_capacity=126000
=end

def hv_export_users(oHarvest, iDbg = 0)

	users = oHarvest.users.all

    summary = Array.new()

	users.each do |u|
        if (u.is_active == true && u.is_admin == false)
            p_user = Array.new(5)
            p_user[0] = u.first_name
            p_user[1] = u.id
            p_user[2] = u.email
            p_user[3] = u.department
            p_user[4] = u.last_name
            
            summary.push(p_user)
        end
    end

    summary = summary.sort { |x, y|
        x[0] <=> y[0]
    }

    file = get_config("COMMON",	"CSVPath") + get_config("Harvest", "MUsers")
    flush_to_csv(summary, file, true)

end

