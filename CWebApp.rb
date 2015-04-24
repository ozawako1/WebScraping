require "mechanize"
require "nokogiri"

require "rubygems"
require "google/api_client"
require "google_drive"

require_relative "util"
require_relative "webutil"
require_relative "proc"

HARVEST_FILTER_FORM = "expense_report_filter_form"
HARVEST_FILTER_TYPE_DEPT = "departments"

AMOEBA_PAGE_LOGIN = "/"
AMOEBA_APPLY_SCRIPT    = 1
AMOEBA_APPROVE_SCRIPT  = 2
AMOEBA_FORM = "formMain"

GOOGLE_CALSYNC_FILE = "CalSync"
GOOGLE_HVALARM_FILE = "HarvestAlert"


class CWebApp
	attr_reader :base_url, :agent
    attr_accessor :debug

	def initialize(b_url, dbg = 0)
		@agent	= Mechanize.new
        @agent.user_agent = "CWebApp/1.0 (Mechanize; Nokogiri)"
        @base_url	= b_url
		@debug = dbg
	end
    
    def SetProxy(proxy_ipaddr, proxy_port)
        @agent.set_proxy(proxy_ipaddr, proxy_port)
    end
    

	def Login(page_login, f_login, info_login)
        
		l_page = @base_url + page_login
		
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
        p ("Page :" + url) if @debug == 1
        @agent.get(@base_url + url)
    end

    def RetrieveList(list_name, func)
        
        summary = Array.new
        
        doc = Nokogiri::HTML.parse(@agent.page.body)
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

    def GetItem(css)
        doc = Nokogiri::HTML.parse(@agent.page.body)
        if (doc == nil)
            raise "Document Body not found."
        end
        
        itm = doc.css(css)
        if (itm == nil || itm.size == 0) then
            raise "Data not found."
        end
        
        return itm
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

    def Execute(form_name, script = 0)
        
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
        
        f.submit
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

class CWebAppHarvest < CWebApp
    def GetTotalHours()
        
        hours = self.GetItem("div.ds-amt")
        val = hours[1].text
        pos = val.index("Hours")
     
        return (pos != nil) ? val[0, pos].strip : "0"
    end
end

class CWebAppAmoeba < CWebApp
    
    def Jump(menu_id)
        path = sprintf("/Main?actionbean=Shortcut&menuID=%s&referer=%%2Fshare%%2Fmenu.jsp&isForwardManagement=1&forward_mng_menu_id=%s", menu_id, menu_id)
        p ("Page : " + path) if @debug == 1
        @agent.get(@base_url + path)
    end
    
    def GetWorkHours()
        itm = self.GetItem("#TTL_Fixed_Time_lbl")
        hours = itm[1].text.strip
        
        itm = self.GetItem("#Overtime_Daily_lbl")
        otime = itm[1].text.strip
        
        hours = hours.to_f + otime.to_f
        
        return hours
    end
    
    def RunJS(script)
        
        form = search_form(@agent.page, AMOEBA_FORM)
        if (form == nil)
            raise "Form Not Found. [" + AMOEBA_FORM + "]"
        end

        key_val = Hash.new
        target_date = getlastworkday()
        
        case script
        when AMOEBA_APPLY_SCRIPT
            key_val = {
                "mode"          => "search",
                "forward"       => "editlist.jsp",
                "actionbean"    => "GetList",
                "service"       => "jp.co.kccs.greenearth.erp.kto.pkto318.PKTO318DisplayService",
                "Target_DT_Temp"    => target_date,
                "Target_DT_KEY"     => target_date,
                "ORG_CD_KEY"        => form.Belong_ORG_CD_1,
                "ORG_NA_KEY"        => form.ORG_NA,
                "Stuff_No_CONDITION"    => form.Stuff_No_2,
                "Name_CONDITION"    => form.DispName,
                "ORG_CD_CONDITION"  => form.Belong_ORG_CD_1,
                "ORG_NA_CONDITION"  => form.ORG_NA
            }
        when AMOEBA_APPROVE_SCRIPT
            key_val = {
                "mode"          => "search",
                "forward"       => "editlist.jsp",
                "actionbean"    => "GetList",
                "service"       => "jp.co.kccs.greenearth.erp.kto.pkto318.PKTO318DisplayService",
                "Target_DT_Temp"    => target_date,
                "Target_DT_KEY"     => target_date,
                "ORG_CD_KEY"        => form.Belong_ORG_CD_1,
                "ORG_NA_KEY"        => form.ORG_NA,
                "Stuff_No_CONDITION"    => form.Stuff_No_2,
                "Name_CONDITION"    => form.DispName,
                "ORG_CD_CONDITION"  => form.Belong_ORG_CD_1,
                "ORG_NA_CONDITION"  => form.ORG_NA
            }
        end
        
        key_val.keys.each { |k|
            fl = nil
            fl = form.field_with(:name => k)
            if (fl == nil)
                fls = form.add_field!(k)
                if (fls == nil)
                    raise "Field could not be created. [" + k.to_s + "]"
                end
                fl = fls[0]
            end
            fl.value = key_val[k]
        }
 
 
        if (form.encoding == "Cp943C")
            form.encoding = "Shift_JIS"
        end
        
        form.click_button

    end
    
    def pre_execute(form, script)
        
        key_val = Hash.new
        target_date = getlastworkday()
        
        case script
        when AMOEBA_APPLY_SCRIPT
            key_val = {
                "Decide_chk"    => "on",
                "Decide"        => "1",
                "forward"       => "editlist.jsp",
                "actionbean"    => "SaveList",
                "mode"          => "appli",
                "service"       => "jp.co.kccs.greenearth.erp.kto.pkto318.PKTO318DisplayService",
                "Target_DT_Temp"    => target_date,
                "ORG_CD_KEY"    => form.Belong_ORG_CD_1,
                "Stuff_No_CONDITION"    => form.Stuff_No_2,
                "ORG_CD_CONDITION"  => form.Belong_ORG_CD_1,
                "ORG_NA_CONDITION"  => form.ORG_NA
            }
        when AMOEBA_APPROVE_SCRIPT
            key_val = {
                "forward"       => "editlist.jsp",
                "actionbean"    => "SaveList",
                "mode"          => "approval",
                "service"       => "jp.co.kccs.greenearth.erp.kto.pkto318.PKTO318DisplayService",
                "Target_DT_Temp"    => target_date,
                "Target_DT_KEY" => target_date,
                "ORG_CD_KEY"    => form.Belong_ORG_CD_1,
                "ORG_NA_KEY"    => form.ORG_NA,
                "Stuff_No_CONDITION"    => form.Stuff_No_2,
                "Name_CONDITION"    => form.DispName,
                "ORG_CD_CONDITION"  => form.Belong_ORG_CD_1,
                "ORG_NA_CONDITION"  => form.ORG_NA
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

class CWebAppEco < CWebApp
    
    def initialize(b_url, dbg = 0)
        super(b_url, dbg)
        @agent.follow_meta_refresh = true
    end
    
    def GetEventsforDay(theday)
        
        form = search_form(@agent.page, "tskfil")
        if (form == nil)
            raise "Form Not Found. [tskfil]"
        end
        
        search_keys = Array.new()
        search_keys.push(Array.new(["FMinYear",    theday.year.to_s]))
        search_keys.push(Array.new(["FMinMonth",   theday.month.to_s]))
        search_keys.push(Array.new(["FMinDay",     theday.day.to_s]))
        search_keys.push(Array.new(["FMaxYear",    theday.year.to_s]))
        search_keys.push(Array.new(["FMaxMonth",   theday.month.to_s]))
        search_keys.push(Array.new(["FMaxDay",     theday.day.to_s]))
        
        set_options(form, search_keys)
        
        form.submit
        
        arr = RetrieveList("table.DefT", method(:proc_split_table_to_array))
        if (arr[1].length == 1)
            # this means no data.
            arr.delete_at(1)
        end
        arr.delete_at(0)
        
        return arr
    end
    
    def GetEventsForWeek()
        
        i = 0
        d = Date.today()
        
        arr = Array.new()
        while (i < 7)
            arr.concat(GetEventsforDay(d + i))
            i = i + 1
        end
        
        return arr
    
    end
    
    def GetEventDetail(event)
        
        url = event[3]
        
        Go("/cgi-bin/" + url)
        
        doc = Nokogiri::HTML.parse(@agent.page.body)
        if (doc == nil)
            raise "Document Body not found."
        end
        
        rows = doc.css("td.DefT")
        if (rows == nil || rows.size == 0)
            raise "Data Table Row not found."
        end
        
        detail = Array.new()
        rows.each { |r|
            detail.push(r.inner_text.strip)
        }
        
        p detail if @use_debug == 1
        
        t = split_event_time(detail[5])
        event.push(t[0])
        event.push(t[1])
        event.push(shrink_place(detail[12]))
        s = url.index("&tskno=") + "&tskno=".length
        e = url.index("&sday=")
        event.push(url[s, e - s])
        
    end
end

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
        auth.scope = "https://www.googleapis.com/auth/drive" + " " +
                    "https://spreadsheets.google.com/feeds/"
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



