#!/usr/bin/env ruby
# encoding: utf-8

require "csv"
require "sqlite3"
require "ipaddr"

IPADDR_DB = "/Users/koichi.ozawa/Documents/Database/ip_addr.sq3"
IPADDR_CSV = "/Users/koichi.ozawa/Documents/output/ip_addr_all.csv"

def prepare_ipaddr_table

    db = SQLite3::Database.new(IPADDR_DB)    
    counter = 0
    ip = ""

    begin
        
        db.execute("delete from IP_ADDRESS")

        CSV.foreach(IPADDR_CSV) do |row|

            if (counter != 0) 
                ip = IPAddr.new(row[0])
                db.execute("insert into IP_ADDRESS values (?, ?, ?, ?)", ip.to_i, row[1], row[2], ip.to_s)        
            end
            
            counter = counter + 1

        end

        
    rescue => e

        p e
        p ip.to_s
        p counter
        
    ensure
        db.close()

    end

end

prepare_ipaddr_table()


def is_ipaddress(ipaddr_s)

    ret = false

    begin
        ip = IPAddr.new(ipaddr_s)
        ret = true
    rescue => e 
        ret = false
    end

    return ret

end


def get_user_from_ipaddr(ipaddr_s)

    user = ""
    
    if (is_ipaddress(ipaddr_s) == false) then
        raise "Error. invalid ip address."
    end

    db = SQLite3::Database.new(IPADDR_DB)
    db.transaction()
  
    begin

        ip = IPAddr.new(ipaddr_s)

        ret = db.execute("select USER from IP_ADDRESS where IP_ADDRESS = ?", ip.to_i)
        if (ret.length != 0) then
            #一つ目だけを返す
            user = ret[0][0]
        end

        db.commit()
    rescue => e
        db.rollback()
        p e

    ensure
        db.close()
    end

    return user
    
end

def get_machine_from_ipaddr(ipaddr_s)

    machine = ""
    
    if (is_ipaddress(ipaddr_s) == false) then
        raise "Error. invalid ip address."
    end

    db = SQLite3::Database.new(IPADDR_DB)
    db.transaction()

    begin

        ip = IPAddr.new(ipaddr_s)
 
        ret = db.execute("select MACHINE from IP_ADDRESS where IP_ADDRESS = ?", ip.to_i)
        if (ret.length != 0) then
            #一つ目だけを返す
            machine = ret[0][0]
        end

        db.commit()

    rescue => e
        db.rollback()
        p e

    ensure
        db.close()
    end

    return machine
        
end

begin
    u = get_user_from_ipaddr("192.168.100.4")
    m = get_machine_from_ipaddr("192.168.100.4")
rescue => e
    p e
ensure
    p u
    p m
end

