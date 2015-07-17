module Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  class DrinkingAge
    def check(prompter)
      prompter.get_age >= DRINKING_AGE
    end
  end

  class SmokingAge
    def check(prompter)
      prompter.get_age >= SMOKING_AGE
    end
  end

  class SundayBlueLaw
    def check(prompter)
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end
