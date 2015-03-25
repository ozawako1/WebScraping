class CConst
    attr_reader :jump_page
    def initialize()
        @jump_page = ""
    end

    def GetJumpPage
        return @jump_page
    end
end

class CConstAmoeba < CConst
    def initialize()
        @jump_page = "/Main?referer=/teams/KTO/PKTO331%%2Fsearchlist.jsp&prepage=/sharemenu.jsp&menuID=PKTO331&forward=searchlist.jsp&service=jp.co.kccs.greenearth.erp.kto.pkto331.PersonalCalendarService&actionbean=GetList&mode=search&listsize=-1&no_header=&Objective_DT_P=%d/%02d&Time_CL_1=1&Stuff_No_0=%s&Name="
        
    end
end

class CConstHarvest < CConst
    def initialize()
        @data_page = "/reports/detailed/%d/%d/%d/%d/%s/any/any/ign/ign/ign/any?group=users"
    end
end