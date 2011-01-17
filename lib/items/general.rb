

  class Beer < Item
    at_least Restriction::DRINKING_AGE
    def self.nam
      :beer
    end
  end

  class Whiskey < Item
    at_least Restriction::DRINKING_AGE
    def self.nam
      :whiskey
    end
    def initialize(logfile,prompter)
      super(logfile,prompter)
      self.rstrctns << Restriction::SundayBlueLaw.new if not self.rstrctns.include? Restriction::SundayBlueLaw.new 
    end
  end

  class Cigarettes < Item
    at_least Restriction::SMOKING_AGE
    # you have to be of a certain age to buy tobacco
    def self.nam
      :cigarettes
    end
  end

  class Cola < Item
    at_least 1
    def self.nam
      :cola
    end
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.nam doesn't work here
    def self.nam
      :canned_haggis
    end
  end
