
module Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  class Age
    def initialize(age)
      @age = age
    end

    def ck(prompter)
      age = prompter.get_age
      if age >= @age
        true
      else
        false
      end
    end
  end

  class SundayBlueLaw
    def ck(prompter)
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end
