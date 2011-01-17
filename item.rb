
class Item
  INVENTORY_LOG = 'inventory.log'

  def self.at_least(age)
    self.rstrctns << Restriction::Age.new(age)
  end
  def self.rstrctns
    @restrictions ||= []
  end
  def rstrctns
    self.class.rstrctns
  end

  def self.subcl
    @@subcl
  end
  def self.inherited(subclass)
    @@subcl ||= []
    @@subcl << subclass
  end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(nam.to_s + "\n")
    end
  end

  def nam
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
  end

  def try_purchase(success)
    if success
      return true
    else
      raise Nanomart::NoSale
    end
  end

end

