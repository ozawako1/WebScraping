require "mechanize"
require "nokogiri"

require "rubygems"
#require "google/api_client"
#require "google_drive"

require_relative "util"
require_relative "webutil"
require_relative "proc"

HARVEST_FILTER_FORM = "expense_report_filter_form"
HARVEST_FILTER_TYPE_DEPT = "departments"
# HARVEST_PAGE_LOGIN = "/account/login"
# HARVEST_FORM_LOGIN = "signin_form"
HARVEST_PAGE_LOGIN = "https://id.getharvest.com/harvest/sign_in"


AMOEBA_PAGE_LOGIN = "/"
AMOEBA_APPLY_SCRIPT    = 1
AMOEBA_APPROVE_SCRIPT  = 2
AMOEBA_APPLY_SCRIPT_SEARCH    = 3
AMOEBA_APPROVE_SCRIPT_SEARCH  = 4
AMOEBA_FORM = "formMain"

GARCSV_STARTDATE    = 0
GARCSV_STARTTIME    = 1
GARCSV_STOPDATE = 2
GARCSV_STOPTIME = 3
GARCSV_SCHEDULE_MENU    = 4
GARCSV_SCHEDUEL_TITLE   = 5
GARCSV_SCHEDULE_MEMO    = 6

GOCCSV_TITLE = 0
GOCCSV_BEGIN_UNIXTIME = 1
GOCCSV_END_UNIXTIME = 2
GOCCSV_FACILITY = 3
GOCCSV_OPTION = 4
GOCCSV_MAX = GOCCSV_OPTION

ECOLIST_URL = 3

ECOCSV_REG_INFO = 0
ECOCSV_UPD_INFO = 1
ECOCSV_ORDER_USER   = 2
ECOCSV_TITLE    = 3
ECOCSV_PRIORITY = 4
ECOCSV_SCHEDULE = 5
ECOCSV_EXECUTE  = 6
ECOCSV_OPEN_TO  = 7
ECOCSV_SCHEDULE_MEMO    = 8
ECOCSV_EXEC_MEM0    = 9
ECOCSV_USERS    = 10
ECOCSV_PLACE    = 11
ECOCSV_INFRA    = 12
ECOCSV_PROJECT  = 13
ECOCSV_TARGET   = 14
ECOCSV_PREPARE  = 15
ECOCSV_FINISH   = 16
ECOCSV_PROCESS  = 17

GOOGLE_CALSYNC_FILE = "CalSync"
GOOGLE_HVALARM_FILE = "HarvestAlert"

GAROON_PAGE_LOGIN = "login"
GAROON_FORM_LOGIN = "login-form-slash"

ECO_SEARCH_PAGE = "/cgi-bin/BSCD.cgi"


class CWebApp
	attr_reader :base_url, :agent, :encoding, :doc
    attr_accessor :debug

	def initialize(b_url, dbg = 0)
		@agent	= Mechanize.new
        @agent.user_agent = "CWebApp/1.0 (Mechanize; Nokogiri)"
        @base_url	= b_url
		@debug    = dbg
        @encoding   = nil
        @doc    = nil
	end
    
    def SetProxy(proxy_ipaddr, proxy_port)
        @agent.set_proxy(proxy_ipaddr, proxy_port)
    end
    
	def Login(page_login, f_login, info_login)
        
        l_page = ""
        if (page_login.match(/^http/) == nil) 
            l_page = @base_url
        end
		l_page += page_login
		
        p ("Login: " + l_page)          if @debug == 1
        p ("Form : " + f_login)         if @debug == 1
        p ("User : " + info_login.to_s) if @debug == 1
        
        p = @agent.get(l_page)
		if (p == nil)
			raise "Page Not Found. [" + page_login + "]"
		end
		
		f = search_form(p, f_login)
		if (f == nil)
			raise "Form Not Found. [" + f_login + "]"
		end

		info_login.keys.each do |k|
			fl = search_field(f, k)
			if (fl == nil)
				raise "Field Not Found. [" + k.to_s + "]"
			end
			fl.value = info_login[k]
		end

		f.submit
	end
    
    
    def Go(url)
        p ("Page :" + @base_url + url) if @debug == 1
        @agent.get(@base_url + url)
        @doc = nil
    end

    def RetrieveList(list_name, func)
        
        summary = Array.new()
        
        doc = ParsePage()
        if (doc == nil)
            raise "Document Body not found."
        end
        
        rows = doc.css(list_name)
        if (rows == nil || rows.size == 0)
            raise "Data Table Row not found."
        end
        
        rows.each { |r|
            func.call(r, summary)
        }
        
        return summary
    end
    
    def ParsePage()
        # if @doc == nil then
            @doc = Nokogiri::HTML.parse(@agent.page.body, nil, @encoding ? @encoding : @agent.page.encoding)
        # end
        return @doc
    end
    
    def GetItem(css)
        doc = ParsePage() 
        if (doc == nil)
            raise "Document Body not found."
        end
        
        itm = doc.css(css)
        if (itm == nil || itm.size == 0) then
            raise "Data not found. (" + css + ")"
        end
        
        return itm
    end

    def Table2Array(css_searchkey, order = 0)
        
        doc = ParsePage()
        
        # Tableを探す        
        elts = GetItem(css_searchkey)
        if is_empty(elts) then
            raise "Table not found."
        end
        
        if elts[0].name != "table" then
            elts = elts[0].css("table")
        end
        table = elts[order]

        # 行ごとに処理
        rows = table.css("tr")
        if is_empty(rows) then
            raise "Table has no data."
        end
        lines = Array.new(rows.length)
        
        i = 0
        while (i < rows.length) 
            cols = rows[i].css("td")
            if is_empty(cols) then
                raise "Row has no data."
            end
            
            lines[i] = Array.new(cols.length)
            l = 0
            while (l < cols.length)
                lines[i][l] = cols[l].inner_text.strip
                l += 1
            end
            i += 1
        end        
      
        return lines    
         
    end
    
    def SetFormFirstField(form_name, val)
        if (form_name == nil || form_name == "")
            raise "Form Name is not given."
        end
        
        f = search_form(@agent.page, form_name)
        if (f == nil)
            raise "Form Not Found. [" + form_name + "]"
        end
        
        fls = f.fields
        if (fls == nil)
            raise "No Field exist."
        end
        
        fls[0].value = val
        
    end
    
    def SetForm(form_name, keyvals)
        if (form_name == nil || form_name == "")
            raise "Form Name is not given."
        end
        
        f = search_form(@agent.page, form_name)
        if (f == nil)
            raise "Form Not Found. [" + form_name + "]"
        end
        
        keyvals.each { |kv|
            fl = nil
            fl = f.field_with(:name => kv[0])
            if (fl == nil)
                fls = f.add_field!(kv[0])
                if (fls == nil)
                    raise "Field could not be created. [" + kv[0].to_s + "]"
                end
                fl = fls[0]
            end
            fl.value = kv[1]
        }
    
    end

    def Execute(form_name, button_name = nil, script = 0)
        
        if (form_name == nil || form_name == "")
            raise "Form Name is not given."
        end
        
        f = search_form(@agent.page, form_name)
        if (f == nil)
            raise "Form Not Found. [" + form_name + "]"
        end
        
        pre_execute(f, script)
        
        if (f.encoding == "Cp943C")
            f.encoding = "Shift_JIS"
        end
        
        if (button_name == nil) 
            f.submit
        else
            btn = f.button_with(:value => button_name)
            if (btn == nil)
                raise "Button [" + button_name + "] not found."
            end
            f.click_button(btn)           
        end
        
    end
    
    def FollowLink(linkName)
        link = search_link(@agent.page, linkName)
        if (link == nil || link.length == 0)
            raise "Link not found."
        end
        link[0].click()
    end
    
    def GetPage()
        return @agent.page.body 
    end
    
private
    def pre_execute(form, script)
    end
end

class CWebAppHarvest
  	attr_reader :subdomain, :loginid, :password, :handle
 
    def initialize()
        @subdomain  = get_config("Harvest", "SubDomain")
        @username   = get_config("Harvest", "ID")
        @password   = get_config("Harvest", "Password")
    end

    def Login()
        @handle   = Harvest.hardy_client(subdomain: @subdomain, username: @username, password: @password)	
    end

    def ExportUser2File(export_file)

    	users = @handle.users.all
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

        flush_to_csv(summary, export_file, true)

    end
end

class CWebAppAmoeba < CWebApp

    def initialize(b_url, dbg = 0)
        super(b_url, dbg)
        @encoding = "CP932"
    end
    
    def Jump(menu_id)
        jump_url = "/Main?actionbean=Shortcut&menuID=%s&referer=%%2Fshare%%2Fmenu.jsp" +
                   "&isForwardManagement=1&forward_mng_menu_id=%s"
        self.Go(jump_url%[menu_id, menu_id])
    end
    
    def GetWorkHoursByEmpCode(yyyy, mm, emp_code)
        work_hours_page = "/Main?referer=/teams/KTO/PKTO331%%2Fsearchlist.jsp" +
                          "&prepage=/sharemenu.jsp&menuID=PKTO331&forward=searchlist.jsp" +
                          "&service=jp.co.kccs.greenearth.erp.kto.pkto331.PersonalCalendarService" +
                          "&actionbean=GetList&mode=search&listsize=-1&no_header=" +
                          "&Objective_DT_P=%d/%02d&Time_CL_1=1&Stuff_No_0=%s&Name="
        
        self.Go(work_hours_page%[yyyy, mm, emp_code])
    
        itm = self.GetItem("#TTL_Fixed_Time_lbl")
        hours = itm[1].text.strip
        
        itm = self.GetItem("#Overtime_Daily_lbl")
        otime = itm[1].text.strip
        
        hours = hours.to_f + otime.to_f
        
        return hours
    end
    
    def pre_execute(form, script)
        
        key_val = Hash.new
        target_date = getlastworkday()
        
        case script
        when AMOEBA_APPLY_SCRIPT
            key_val = {
                "mode"                  => "appli",
                "forward"               => "editlist.jsp",
                "actionbean"            => "SaveList",
                "service"               => "jp.co.kccs.greenearth.erp.kto.pkto318.PKTO318DisplayService",
                "Target_DT_Temp"        => target_date,
#               "Target_DT_Key"         => 
                "ORG_CD_KEY"            => form.Belong_ORG_CD_1,
#               "ORG_NA_KEY"            => 
                "ORG_CD_CONDITION"      => form.Belong_ORG_CD_1,
                "ORG_NA_CONDITION"      => form.ORG_NA,
                "Stuff_No_CONDITION"    => form.Stuff_No_2,
                "Decide_chk"            => "on",
                "Decide"                => "1"
            }
        when AMOEBA_APPROVE_SCRIPT
            key_val = {
                "mode"                  => "approval",
                "forward"               => "editlist.jsp",
                "actionbean"            => "SaveList",
                "service"               => "jp.co.kccs.greenearth.erp.kto.pkto318.PKTO318DisplayService",
                "Target_DT_Temp"        => target_date,
                "Target_DT_KEY"         => target_date,
                "ORG_CD_KEY"            => form.Belong_ORG_CD_1,
                "ORG_NA_KEY"            => form.ORG_NA,
                "ORG_CD_CONDITION"      => form.Belong_ORG_CD_1,
                "ORG_NA_CONDITION"      => form.ORG_NA,
                "Stuff_No_CONDITION"    => form.Stuff_No_2,
                "Name_CONDITION"        => form.DispName
            }
        when AMOEBA_APPLY_SCRIPT_SEARCH
            key_val = {
                "mode"                  => "search",
                "forward"               => "editlist.jsp",
                "actionbean"            => "GetList",
                "service"               => "jp.co.kccs.greenearth.erp.kto.pkto318.PKTO318DisplayService",
                "Target_DT_Temp"        => target_date,
                "Target_DT_KEY"         => target_date,
                "ORG_CD_KEY"            => form.Belong_ORG_CD_1,
                "ORG_NA_KEY"            => form.ORG_NA,
                "ORG_CD_CONDITION"      => form.Belong_ORG_CD_1,
                "ORG_NA_CONDITION"      => form.ORG_NA,
                "Stuff_No_CONDITION"    => form.Stuff_No_2,
                "Name_CONDITION"        => form.DispName
            }
        when AMOEBA_APPROVE_SCRIPT_SEARCH
            key_val = {
                "mode"                  => "search",
                "forward"               => "editlist.jsp",
                "actionbean"            => "GetList",
                "service"               => "jp.co.kccs.greenearth.erp.kto.pkto318.PKTO318DisplayService",
                "Target_DT_Temp"        => target_date,
                "Target_DT_KEY"         => target_date,
                "ORG_CD_KEY"            => form.Belong_ORG_CD_1,
                "ORG_NA_KEY"            => form.ORG_NA,
                "ORG_CD_CONDITION"      => form.Belong_ORG_CD_1,
                "ORG_NA_CONDITION"      => form.ORG_NA,
                "Stuff_No_CONDITION"    => form.Stuff_No_2,
                "Name_CONDITION"        => form.DispName
            }
        else
            raise "Unknown script type."
        end
        
        key_val.keys.each { |k|
            fl = nil
            if (k == "Decide")
                fls = form.fields_with(:name => k)
                if (fls == nil)
                    raise "Fields Not Found. [" + k.to_s + "]"
                end
                fl = fls[1] # this is Magic Number.  "Suzuki Yayoi" is in 2nd Line.
            else
                fl = form.field_with(:name => k)
                if (fl == nil)
                    fls = form.add_field!(k)
                    if (fls == nil)
                        raise "Field could not be created. [" + k.to_s + "]"
                    end
                    fl = fls[0]
                end
            end
            fl.value = key_val[k]
        }
        
    end
    
end

=begin
class CWebAppGoogle < CWebApp

    attr_reader :app_name, :session

    def initialize(app_name, dbg = 0)
        super("https://docs.google.com/forms", dbg)
        @app_name = app_name
    end
    
    def Login()
    
        client = Google::APIClient.new(:application_name => @app_name)
        auth = client.authorization
        auth.client_id      = get_config(@app_name, "client_id")
        auth.client_secret  = get_config(@app_name, "client_secret")
        auth.refresh_token  = get_config(@app_name, "refresh_token")
        auth.scope = "https://www.googleapis.com/auth/drive.file"
        auth.fetch_access_token!
        
        # Creates a session.
        @session = GoogleDrive.login_with_oauth(auth.access_token)
    end
    
    def WriteArray(arr)
        csv = ""
        arr.each { |line|
            csv += line.join(",").gsub(/(\r\n)/, "+")
            csv += "\r\n"
        }
        csv += "\r\n"
        
        g_file = @session.file_by_title(GOOGLE_CALSYNC_FILE)
        if (g_file != nil)
            g_file.update_from_string(csv)
        else
            @session.upload_from_string(csv, GOOGLE_CALSYNC_FILE, :content_type => "text/csv")
        end
    end

    def WriteFile(fpath)
        filename = File.basename(fpath)
        g_file = @session.file_by_title(filename)
        if (g_file != nil)
            g_file.update_from_file(fpath)
        else
            @session.upload_from_file(fpath, filename, :content_type => "text/csv")
        end
    end

    # UNDER CONSTRUCTION
    # this method does nothing with script files
    def GetFile(src, dst)
        srcfile = @session.file_by_title(src)
        if (srcfile == nil)
            raise "File (" + src + ") not found."
        end
        srcfile.download_to_file(dst)
    end
    
    def Kick_(path, ball)
        Go(path)
        SetFormFirstField("ss-form", ball)
        Execute("ss-form")
    end

end
=end

class CWebAppGaroon < CWebApp
    
    def initialize(b_url, dbg = 0)
        super(b_url, dbg)
    end
    
    def CreateEvent(event_info)
        
    end
    
end


class CWebAppChatwork < CWebApp
    attr_reader :token, :cli

    def initialize(b_url, dbg = 0)
        
        @token = get_config("chatwork", "APIToken")

#        uri = URI.parse('https://api.chatwork.com/v2')
        uri = URI.parse(b_url)
        @cli = Net::HTTP.new(uri.host, 443)
        @cli.use_ssl = true

        super(b_url, dbg)

    end

    def find_room(room_name)
        
        ret = ""

        # チャットの情報一覧を取得してお目当てのroomIDを探す
        res = @cli.get('/v2/rooms', {'X-ChatWorkToken' => @token})
        if (res.code != "200") 
            raise "Error. get rooms error." + res.code
        end

        jarr = JSON.parse(res.body)

        puts jarr if @debug == 1

        jarr.each do |j|
            if j["name"] == room_name
                ret = j["room_id"]
                break
            end
        end

        return ret
    end

    def find_account( user_name )

        ret = ""

        res = @cli.get("/v2/contacts", {"X-ChatWorkToken" => @token})
        if (res.code != "200") 
            raise "Error. get contacts error." + res.code
        end

        jarr = JSON.parse(res.body)
        puts jarr if @debug == 1

        jarr.each do |j|
            if j["name"] == user_name
                ret = j["account_id"]
                break
            end
        end


        return ret

    end

    def chat_msg (room_name, msg)

        room_id = find_room(room_name)

        res = @cli.post("/v2/rooms/" + room_id.to_s + "/messages", "body="+URI.encode(msg), {'X-ChatWorkToken' => @token})
        if (res.code != "200") 
            raise "Error. post message error." + res.code
        end

        # 正常に投稿されるとメッセージIDが返る
        ret = JSON.parse(res.body)

        puts ret if @debug == 1

    end

    def chat_msg_to (room_name, to_user, msg)

        begin

            account_id = find_account(to_user)

            body_msg = "[To:" + account_id + "] " + to_user + " さん\r\n" + msg

            chat_msg(room_name, body_msg)

        rescue => e
            raise e
        end

    end

    def flush_user_master()
        #account_id, room_id, name, chatwork_id, organization_id, organization_name, department, avatar_image_url

        res = @cli.get("/v2/contacts", {"X-ChatWorkToken" => @token})
        if (res.code != "200") 
            raise "Error. get contacts error." + res.code
        end

        csvfile = get_config("COMMON", "CSVPath") + get_config("chatwork", "UserMaster")

        jarr = JSON.parse(res.body)
        puts jarr if @debug == 1

        header = 0

        CSV.open(csvfile, "w", :force_quotes => true) do |writer|

            jarr.each do |line|
                writer << line.keys if header == 0
                header = header + 1
                writer << line.values
            end
        end
    
    end


end



