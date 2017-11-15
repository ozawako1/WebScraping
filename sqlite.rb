#!/usr/bin/env ruby
# encoding: utf-8

require "csv"
require "sqlite3"
require "ipaddr"

IPADDR_DB = "/Users/koichi.ozawa/Documents/Database/ip_addr.sq3"
IPADDR_CSV = "/Users/koichi.ozawa/Documents/output/ip_addr_all.csv"

IPSEGMENT = [
    ["10.0.1.0/24",         "AWS VPN"],
    ["10.1.6.0/24",         "Azure VPN"],
    ["172.17.101.0/22",     "Osaka / 7F8F有線"],
    ["172.17.104.0/23",     "Osaka / 9F有線"],
    ["192.168.1.0/24",      "Tokyo / 業務フロア"],    
    ["192.168.2.0/24",      "Tokyo / Server Room"],    
    ["192.168.3.0/24",      "Tokyo / WiFi Guest"],    
    ["192.168.4.0/24",      "Tokyo / 会議室"],
    ["192.168.5.0/24",      "Tokyo / 監視カメラ"],    
    ["192.168.6.0/24",      "Tokyo / 有線 SE/サポート"],
    ["192.168.8.0/24",      "Tokyo / WiFi vlan02"],    
    ["192.168.9.0/24",      "Tokyo / WiFi vlan01"], 
    ["192.168.10.0/24",     "Nagoya / 有線"],    
    ["192.168.15.0/24",     "Nagoya / WiFi guest"],    
    ["192.168.18.0/24",     "Nagoya / WiFi vlan02"],
    ["192.168.19.0/24",     "Naogya / WiFi vlan01"],    
    ["192.168.30.0/24",     "Fukuoka / 有線"],
    ["192.168.80.0/24",     "公開Web / 監視"],
    ["192.168.100.0/24",    "Osaka / 6F, Server Room"],    
    ["192.168.101.0/24",    "Osaka / 5F有線"],    
    ["192.168.102.0/24",    "Osaka / 7FServerRoom有線 / SEサポート"],    
    ["192.168.103.0/24",    "Osaka / 4F有線"],    
    ["192.168.104.0/24",    "Osaka / 検証ルーム"],    
    ["192.168.105.0/24",    "Osaka / 4Fゲスト有線 / WiFi guest"],    
    ["192.168.111.0/24",    "Osaka / 2-3F, 10F, 11F有線"],    
    ["192.168.112.0/24",    "Osaka / 6F"],    
    ["192.168.113.0/24",    "Osaka / 8F検証ルーム有線"],    
    ["192.168.114.0/24",    "Osaka / An運用"],    
    ["192.168.120.0/24",    "Osaka / WiFi vlan01"],    
    ["192.168.130.0/24",    "Osaka / WiFi vlan02"],    
    ["192.168.250.0/24",    "Remote Access VPN"]    
]


def prepare_ipaddr_table

    db = SQLite3::Database.new(IPADDR_DB)    
    counter = 0
    ip = ""

    begin
        
        db.execute("delete from IP_ADDRESS")

        CSV.foreach(IPADDR_CSV) do |row|

            if (counter != 0) 
                ip = IPAddr.new(row[0])
                db.execute("insert into IP_ADDRESS values (?, ?, ?, ?, ?)", ip.to_i, row[1], row[2], ip.to_s, row[3])        
            end
            
            counter = counter + 1

        end

        
    rescue => e

        p e
        p e.backtrace
        p ip.to_s
        p counter
        
    ensure
        db.close()

    end

end

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
    db.busy_timeout(5000)
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
        p e.backtrace

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
    db.busy_timeout(5000)
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
        p e.backtrace
        
    ensure
        db.close()
    end

    return machine
        
end

def get_segment_from_idpaddr(ipaddr_s)

    ret = "(unknown)"

    IPSEGMENT.each do |seg|

        seg_range = IPAddr.new(seg[0]).to_range
        target_ip = IPAddr.new(ipaddr_s)
        
        if ( seg_range.cover?(target_ip) ) then
            ret = seg[1]
            break
        end
        
    end

    return ret

end




=begin

u = get_user_from_ipaddr("172.17.103.1")
m = get_machine_from_ipaddr("172.17.103.1")

p u
p m

=end

