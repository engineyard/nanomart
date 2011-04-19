#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'nanomart'

@nanomart = Nanomart.new "/dev/stdout", HighlinePrompter.new 

loop do
  item = HighLine.new.choose do |menu|
    menu.prompt = "What would you like to buy?"
    menu.choice("Beer") { Item::Beer }
    menu.choice("Whiskey") { Item::Whiskey }
    menu.choice("Cigarettes") {Item::Cigarettes }
    menu.choice("Cola") { Item::Cola }
    menu.choice("Canned haggis") { Item::CannedHaggis }
  end
  if @nanomart.can_sell_me item
    @nanomart.sell_me item
    @nanomart.log_sale item
  else
    puts "You can't do that until the time is right ..."
  end
end
