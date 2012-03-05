#gems
require "rubygems"
require "eventmachine"
require "eventmachine-tail"
require "optparse"
#user defined
require "database"
require "webout"

class Reader < EventMachine::FileTail
  @@limit = 99
  @@blockTime = 10
  @@time_allowed_between_errors = 300
  @@logResults = 30

  def block(ip, user)
    printf("blocked ip: %s\n", ip)
    PasswordDB.blockedIp(ip, user, @@blockTime)
    system(sprintf("iptables -I INPUT -s %s -j DROP", ip)) 
    system(sprintf("iptables -I OUTPUT -d %s -j DROP", ip))
    Webout.create(PasswordDB.getPasswordLog(@logResults))
    EventMachine.add_timer(@@blockTime) do
      printf("unblocking ip: %s\n", ip)
      system(sprintf("iptables -D INPUT -s %s -j DROP", ip))
      system(sprintf("iptables -D OUTPUT -d %s -j DROP", ip))
      PasswordDB.unblockIp(ip, user)
      Webout.create(PasswordDB.getPasswordLog(@logResults))
    end
  end 

  def self.limit(limit)
    @@limit = Integer(limit)
  end

  def self.blockTime(blockTime)
    @@blockTime = Integer(blockTime)
  end

  def self.errorTime(errorTime)
   @@time_allowed_between_errors = Integer(errorTime)
  end

  def initialize(path, startpos=-1)
    super(path, startpos)
    @buffer = BufferedTokenizer.new
  end

  def receive_data(data)
    @buffer.extract(data).each do |line|
      log = line.split(/ /)
      if log[6] == 'Failed' && log[7] == 'password'
	time = log[3].split(/:/)
	ip = log[11]
        user = log[9]
	datetime = Time.utc(
	  Time.now.year, log[0], log[2], 
	  time[0], time[1], time[2])
	PasswordDB.insertRecord(ip, user, datetime)
	result = PasswordDB.getRecentAttempts(user, datetime, 
		@@time_allowed_between_errors) 
        if result >= @@limit
           block(ip, user)
        end
      end
    end
  end

end

def main(args)
  if args.length != 4 
    puts "Usage: #{$0} <path> <allowed attempts> <Length of time for bad attempts> <Block Length>"
    return 1
  end
  Reader.limit(args[1])
  Reader.errorTime(args[2])
  Reader.blockTime(args[3])
printf("%s\n", args[0])
  EventMachine.run do
    EventMachine::file_tail(args[0], Reader)
  end
end 

exit(main(ARGV))
