
#
# callback routine for split Harvest List
# line: Harvest User List
# arr:  Array for return value[EmployeeCode, HarvestUserID]
def proc_split_list_to_array(line, arr)
    
    shain_code = line.css("span.first_name").text.strip
    huser_code = line.css("a.edit-button").attribute("href").value.strip
    pos1 = huser_code.index("/", 1)
    pos2 = huser_code.index("/", pos1 + 1)
    huser_code = huser_code[pos1 + 1, pos2 - pos1 - 1]
    
    itm = Array.new
    itm.push(shain_code)
    itm.push(huser_code)
    
    arr.push(itm)
end