require 'rspec'
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'logger'

describe '#log' do
  let(:log_file) { '/tmp/test.log' }
  let(:logger) { Logger.new(logfile: log_file) }

  before do
    File.write(log_file, nil)
  end

  context 'with a string argument' do
    let(:test_string) { "TEST_STRING" }
    it 'logs the argument to log file' do
      logger.log(test_string)
      File.read(log_file).should eq "#{test_string}\n"
    end
  end

  context 'with a symbol argument' do
    let(:test_symbol) { :TEST_SYMBOL }
    it 'logs the String representation of value to log file' do
      logger.log(test_symbol)
      File.read(log_file).should eq "#{test_symbol}\n"
    end
  end

end

