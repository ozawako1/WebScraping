class CConst
    attr_reader :data_page, :commit_page, :jump_page
    def initialize()
        @data_page = ""
        @commit_page = ""
        @jump_page = ""
    end
    def GetDataPage
        return @data_page
    end
    def GetCommitPage
        return @commit_page
    end
    def GetJumpPage
        return @jump_page
    end
end

class CConstAmoeba < CConst
    def initialize()
        @data_page = "/Main?referer=%2Fshare%2Fmenu.jsp&prepage=%2Fshare%2Fmenu.jsp&menuID=PKTO318-1&forward=%2Fteams%2FKTO%2FPKTO318%2Feditlist.jsp&service=&mode=&actionbean=Jump&listsize=-1&ParentID_0=KTO03-01&jp.co.kccs.greenearth.javakit.frame.TRANSIT_FROM_MENU_FG=true&isForwardManagement=1&forward_mng_menu_id=PKTO318-1&AppMode=1&menuname=%8B%CE%96%B1%8E%C0%90%D1%95%F1%8D%90%81i%8BN%95%5B%8E%D2%97p%81j%81@-PKTO318-1-"
        @commit_page = "/Main?referer=%2Fshare%2Fmenu.jsp&prepage=%2Fshare%2Fmenu.jsp&menuID=PKTO318-2&forward=%2Fteams%2FKTO%2FPKTO318%2Feditlist.jsp&service=&mode=&actionbean=Jump&listsize=-1&ParentID_0=KTO03-01&jp.co.kccs.greenearth.javakit.frame.TRANSIT_FROM_MENU_FG=true&isForwardManagement=1&forward_mng_menu_id=PKTO318-2&AppMode=2&menuname=%8B%CE%96%B1%8E%C0%90%D1%95%F1%8D%90%81i%8F%B3%94F%8E%D2%97p%81j+-PKTO318-2-"
        @jump_page = "/Main?referer=/teams/KTO/PKTO331%%2Fsearchlist.jsp&prepage=/sharemenu.jsp&menuID=PKTO331&forward=searchlist.jsp&service=jp.co.kccs.greenearth.erp.kto.pkto331.PersonalCalendarService&actionbean=GetList&mode=search&listsize=-1&no_header=&Objective_DT_P=%d/%02d&Time_CL_1=1&Stuff_No_0=%s&Name="
        
    end
end

class CConstHarvest < CConst
    def initialize()
        @data_page = "/reports/detailed/%d/%d/%d/%d/%s/any/any/ign/ign/ign/any?group=users"
    end
end