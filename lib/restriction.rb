class Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  def initialize(p)
    @prompter = p
  end

  def age
    @age ||= @prompter.get_age
  end

  class DrinkingAge < Restriction

    def check
      age >= DRINKING_AGE
    end
  end

  class SmokingAge < Restriction

    def check
      age >= SMOKING_AGE
    end
  end

  class SundayBlueLaw < Restriction
    SUNDAY_DAY_OF_WEEK = 0

    def check
      Time.now.wday != SUNDAY_DAY_OF_WEEK
    end
  end
end
