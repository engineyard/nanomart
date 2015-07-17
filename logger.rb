class Logger
  def initialize(logfile: '/dev/null')
    @logfile = logfile
  end

  def log(value)
    File.open(@logfile, 'a') do |f|
      f.write(String(value) + "\n")
    end
  end
end

