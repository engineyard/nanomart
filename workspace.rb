could do th efollowing:

test cases in json fatory set hashes of types

could also do Object type for each kind of inventory



def check_if_salable(age, itemHash)

	i

   if var.class = "Alchohol" then 




class CheckRestriction
	def check(age, item)
	
	case 
	
		if item.class == "Beer"
			return false
		end
	end
end



class NanoMart

  def intialize()
		@myLog = logger.new('path/file')
		@myItems = [:beer, :whiskey, :coke, :haggis, :cigarettes]
	end
	
end








class logger



end












itm = case age
      when >19
        Item::Beer.new(@logfile, @prompter)
      when 
        Item::Whiskey.new(@logfile, @prompter)
      when :cigarettes
        Item::Cigarettes.new(@logfile, @prompter)
      when :cola
        Item::Cola.new(@logfile, @prompter)
      when :canned_haggis
        Item::CannedHaggis.new(@logfile, @prompter)
      else
        raise Argum