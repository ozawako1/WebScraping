#!/usr/bin/env ruby
# encoding: utf-8

require "qrcode"


url = ""
url += get_config("JosysUtil", "Url")

begin

    url += "?p=" + params

    qr = RQRCode::QRCode.new(url)

    png = qrcode.as_png(
        resize_gte_to: false,
        resize_exactly_to: false,
        fill: 'white',
        color: 'black',
        size: 120,
        border_modules: 4,
        module_px_size: 6,
        file: nil # path to write
        )
    
    IO.write("/tmp/github-qrcode.png", png.to_s)
    
rescue => exception
    
else
    
ensure
    
end