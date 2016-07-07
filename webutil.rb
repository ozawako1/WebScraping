require "mechanize"

OT_FORM     = 1
OT_FIELD    = 2
OT_ANCHOR   = 3

def set_options(form, keys)
    
    keys.each { |kv|
        field = search_field(form, kv[0])
        if (field == nil)
            raise "Field Not Found. [" + kv[0] + "]"
        end
        field.option_with(:text => kv[1]).select
    }
    
end

def search_object(object_type, parent, name)
    o1 = nil
    o2 = nil
    
    case object_type
        when OT_FORM
            if (name == "")
                o1 = parent.forms[0]
            else
                o1 = parent.form_with(:name => name)
            end
            o2 = parent.form_with(:id   => name)
        when OT_FIELD
            o1 = parent.field_with(:name => name)
            o2 = parent.field_with(:id   => name)
        when OT_ANCHOR
            o1 = parent.link_with(:text => name)
    end
    
    return o1 ? o1 : o2
end

def search_form(page, f_name)
    return search_object(OT_FORM, page, f_name)
end

def search_field(form, f_name)
    return search_object(OT_FIELD, form, f_name)
end

def search_link(page, link_name)
    return search_object(OT_ANCHOR, page, link_name)
end
