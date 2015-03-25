require "mechanize"
require "nokogiri"
require_relative "util"

HARVEST_FILTER_FORM = "expense_report_filter_form"
HARVEST_FILTER_TYPE_DEPT = "departments"

AMOEBA_PAGE_LOGIN = "/"
AMOEBA_APPLY_SCRIPT    = 1
AMOEBA_APPROVE_SCRIPT  = 2
AMOEBA_FORM = "formMain"

OT_FORM     = 1
OT_FIELD    = 2

def search_object(object_type, parent, name)
    o1 = nil
    o2 = nil
    
    case object_type
    when OT_FORM
        o1 = parent.form_with(:name => name)
        o2 = parent.form_with(:id   => name)
    when OT_FIELD
        o1 = parent.field_with(:name => name)
        o2 = parent.field_with(:id   => name)
    end

    return o1 ? o1 : o2
end

def search_form(page, f_name)
    return search_object(OT_FORM, page, f_name)
end

def search_field(form, f_name)
    return search_object(OT_FIELD, form, f_name)
end

class CWebApp
	attr_reader :base_url, :agent
    attr_accessor :debug

	def initialize(agent, b_url, dbg = 0)
		@agent	= agent
        @base_url	= b_url
		@debug = dbg
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
        if (rows == nil || rows.size == 0) then
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

    def Execute(form_name, script = 0)
        
        if (form_name == nil || form_name == "")
            raise "Form Name is not given."
        end
        
        f = @agent.page.form_with(:name => form_name)
        if (f == nil)
            raise "Form Not Found. [" + form_name + "]"
        end
        
        pre_execute(f, script)
        
        if (f.encoding == "Cp943C")
            f.encoding = "Shift_JIS"
        end
        
        f.submit
    end
    
private
    def pre_execute(form, script)
    end
end

class CWebAppHarvest < CWebApp
    def post_jump(script)
        
        f = search_form(@agent.page, HARVEST_FILTER_FORM)
        if (f == nil)
            raise "Form Not Found. [" + HARVEST_FILTER_FORM + "]"
        end
        f.click_button
        
        nexturi = @agent.page.uri.to_s
        nexturi = nexturi.gsub(/dates/, HARVEST_FILTER_TYPE_DEPT)
        
        @agent.get(nexturi)
    end
    
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
        p ("Page :" + path) if @debug == 1
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

