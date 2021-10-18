require 'epaperify'
require 'rpi_gpio'
require 'json'
require 'epub/parser'

MENU_BUTTON = 10
LEFT_BUTTON = 8
RIGHT_BUTTON = 12

@current_screen = :title

config = JSON.parse(File.read("config.json"))
readlog = JSON.parse(File.read("readlog.json"))

canvas = Epaperify::PaperCanvas.new(Epaperify::DISPLAY_EPD_2IN7B_V2, 270)
font = Epaperify::Font.new(24, File.join("fonts", "NotoSans-Regular.ttf"))
font_general_ui = Epaperify::Font.new(12, File.join("fonts", "AndadaPro-Regular.ttf"))
font_heading = Epaperify::Font.new(16, File.join("fonts", "AndadaPro-Regular.ttf"))
title = Epaperify::Text.new(font)

RPi::GPIO.set_numbering :board
RPi::GPIO.setup [LEFT_BUTTON,MENU_BUTTON,RIGHT_BUTTON], :as => :input, :pull => :down

RPi::GPIO.watch LEFT_BUTTON, :on => :falling, :bounce_time => 200 do |pin, value|
    puts "pin 8 pushed"
end

RPi::GPIO.watch MENU_BUTTON, :on => :falling, :bounce_time => 200 do |pin, value|
    canvas.clear
    if @current_screen == :title
        epubs = Dir["books/*.rb"]

        heading = Epaperify::Text.new(font_heading)
        heading.string = "Books\n"
        titles = Epaperify::Text.new(font_general_ui)
        titles.string = epubs.join("\n")
        heading.render_string canvas
        titles.render_string titles
    end
    canvas.show
end

RPi::GPIO.watch RIGHT_BUTTON, :on => :falling, :bounce_time => 200 do |pin, value|
    puts "pin 12 pushed"
end

title.string = "Paper OS"
width, height = title.measure canvas
title.render_string canvas, y: (canvas.height / 2 - height / 2), x: (canvas.width / 2 - width / 2)

book = EPUB::Parser.parse(File.join('books','oliver_twist.epub'))
book.each_page_on_spine do |page|
  puts page.read
end

canvas.show

puts "press any key to exit"
gets
puts "putting to sleep"
canvas.sleep