
#!/usr/bin/env ruby
# encoding: utf-8

COLUMN_AMOEBA_UID = 0
COLUMN_HARVEST_UID = 1
COLUMN_EMAIL_ADDRESS = 2
COLUMN_DEPT_CODE = 3
COLUMN_HARVEST_HOUR = 4
COLUMN_AMOEBA_HOUR = 5
COLUMN_CHECED_MONTH = 6

require_relative "CWebApp"
require_relative "util"
require_relative "get_harvest"
require_relative "get_amoeba"

def get_harvest_users_l(harvest_webapp, dbg = 0)

    member_page = "/team"
    pt = get_config("COMMON", "CSVPath")
    um = get_config("Harvest", "UserMaster")

    site = harvest_webapp

    begin
        
        # move to User list
        site.Go(member_page)
        
        # save user table to csv
        data = site.Table2Array(".team-overview-table")
        
        p data if dbg
        
        # append email and dept_code
        data.each do |member|
            if (member[0] != "Admin")
                site.Go("/people/" + member[1] + "/edit#profile_base")
                member.push(site.GetItem("#user_email").attribute("value").value.strip);
                member.push(site.GetItem("#user_department").attribute("value").value.strip);
            else
                member.push("");
                member.push("");
            end
        end
        
        # sort by dept_code
        sorted = data.sort { |a, b|
            a[3] <=> b[3]
        }
        
        # flush to file
        flush_to_csv(sorted, pt + um)
        
        p (pt + um) if dbg
        
    rescue => e

        p e
        p e.backtrace
        
    end
    
end


use_proxy = 0
use_debug = 0
use_dump  = 0
yyyy = 0
mm = 0

ARGV.each { |arg|
    case arg
    when "PROXY"
        use_proxy = 1
    when "DEBUG"
        use_debug = 1
    when "DUMP"
        use_dump = 1
    else
        tmp = arg.split("/")
        if (tmp.length == 0) 
            puts("undefined arg. [" + arg + "]")
            exit(1)
        end
        yyyy = tmp[0].to_i
        mm = tmp[1].to_i
    end
}

if (yyyy == 0) then
    yyyy = Time.now.year
end
if (mm == 0) then
    mm = Time.now.month
end

puts("checking [" + yyyy.to_s + "/" + mm.to_s + "]")
 
hid = get_config("Harvest", "ID")
hpd = get_config("Harvest", "Password")
hLogin = Hash["email"=>hid, "password"=>hpd]
harvest = CWebAppHarvest.new("https://motex.harvestapp.com", use_debug)
if harvest == nil
    puts("Init Error.")
end

usrhrs = get_config("COMMON", "CSVPath") + get_config("COMMON", "UserHours")


begin
	puts("going to login HARVEST...")    
    harvest.Login(HARVEST_PAGE_LOGIN, "", hLogin)
	puts("done.")

	puts("checking HARVEST Users...")    
    get_harvest_users_l(harvest, use_debug)
	puts("done.")
    
	puts("checking HARVEST Hours...")    
    get_harvest_hours(harvest, yyyy, mm, usrhrs)
	puts("done.")
    

rescue => e
    p e
    p e.backtrace
end


