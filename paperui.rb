require 'epaperify'
require 'rpi_gpio'
require 'json'

config = JSON.parse(File.read("config.json"))
readlog = JSON.parse(File.read("readlog.json"))

RPi::GPIO.set_numbering :board
RPi::GPIO.setup [8,10,12], :as => :input, :pull => :down

RPi::GPIO.watch 8, :on => :falling, :bounce_time => 200 do |pin, value|
    puts "pin 8 pushed"
end

RPi::GPIO.watch 10, :on => :falling, :bounce_time => 200 do |pin, value|
    puts "pin 10 pushed"
end

RPi::GPIO.watch 12, :on => :falling, :bounce_time => 200 do |pin, value|
    puts "pin 12 pushed"
end

canvas = Epaperify::PaperCanvas.new(Epaperify::DISPLAY_EPD_2IN7B_V2, 270)

font = Epaperify::Font.new(24, File.join("fonts", "NotoSans-Regular.ttf"))
title = Epaperify::Text.new(font)
title.string = "Paper OS"
width, height = title.measure canvas
title.render_string canvas, y: (canvas.height / 2 - height / 2), x: (canvas.width / 2 - width / 2)

canvas.show
canvas.sleep

gets