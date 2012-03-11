#######################################################################
# Program:  	Event Logger
# File:     	em.rb
#
# Date: 	Mar 5, 2012
# Designer: 	Warren Voelkl
# Programmer: 	Warren Voelkl
#
# Notes:	Entry point in program
# 		Starts the eventMachine::tail object and adds the 
#		file specified.  Thereby having each input line written
#		to the log file to be parsed by the recieveData function
#		The program then add a failed password event to the db
#		then it checks for the amount of entries in the database
#		and blocks the ip according to the time specified
#######################################################################

#gems
require "rubygems"
require "eventmachine"
require "eventmachine-tail"
require "optparse"
#user defined
require "database"
require "webout"

#######################################################################
# Class 	Reader extends EventMachine::FileTail
#
# Functions:    block(ip, user)
#		self.limit(limit)
#		self.blockTime(blockTime)
#		self.errorTime(errorTime)
#		initialize(path, startpos=-1)
#		receive_data(data)
#		
#
# Notes:
# The class used by outside programs used in manipulating the two 
# database tables.
#######################################################################
class Reader < EventMachine::FileTail
  @@limit = 99
  @@blockTime = 10
  @@time_allowed_between_errors = 300
  @@logResults = 30

  #####################################################################
  # Function:   block(ip, user)
  # returns: 	void
  # Notes: 	Blocks the ip through the iptables program
  #	   	sets a timer based on the value of blocktime to unblock
  #		the blocked ip.
  #####################################################################
  def block(ip, user)
    printf("blocked ip: %s\n", ip)
    PasswordDB.blockedIp(ip, user, @@blockTime)
    system(sprintf("iptables -I INPUT -s %s -j DROP", ip)) 
    system(sprintf("iptables -I OUTPUT -d %s -j DROP", ip))
    Webout.create(PasswordDB.getPasswordLog(@@logResults))
    if @@blockTime != 0
      EventMachine.add_timer(@@blockTime) do
        printf("unblocking ip: %s\n", ip)
        system(sprintf("iptables -D INPUT -s %s -j DROP", ip))
        system(sprintf("iptables -D OUTPUT -d %s -j DROP", ip))
        PasswordDB.unblockIp(ip, user)
        Webout.create(PasswordDB.getPasswordLog(@@logResults))
      end
    end
  end 
  #####################################################################
  # Function:   limit(limit)
  # returns: 	void
  # Notes: 	sets the limit variable used in testing the number of
  #	        failed attempts before blocking an ip
  #####################################################################
  def self.limit(limit)
    @@limit = Integer(limit)
  end

  #####################################################################
  # Function:   blockTime(blockTime)
  # returns: 	void
  # Notes: 	sets the length of time that an ip will be blocked
  #####################################################################
  def self.blockTime(blockTime)
    @@blockTime = Integer(blockTime)
  end
  #####################################################################
  # Function:   blockTime(blockTime)
  # returns: 	void
  # Notes: 	sets the length of time to go back in time for
  #		determining the number of relevant failed attempts
  #####################################################################
  def self.errorTime(errorTime)
   @@time_allowed_between_errors = Integer(errorTime)
  end

  #####################################################################
  # Function:   initialize(path, startpos=-1)
  # returns: 	void
  # Notes: 	tokenizes the tailed data from specified file
  #####################################################################
  def initialize(path, startpos=-1)
    super(path, startpos)
    @buffer = BufferedTokenizer.new
  end

  #####################################################################
  # Function:   receive_data(data)
  # returns: 	void
  # Notes: 	parses the file and checks if its a failed password 
  #		attempt
  #####################################################################
  def receive_data(data)
    @buffer.extract(data).each do |buf|
      buf.split(/"\n"/).each do |line|
      	log = line.split(/ /)
	offset = 5
        if log[offset + 1] == 'Failed'
          offset += 1
        end
      	if log[offset] == 'Failed' && log[offset + 1] == 'password'
	    time = log[offset - 2].split(/:/)
    	  ip = log[offset + 5]
          user = log[offset + 3]
          #checks for login attempts to non user
          if user == "invalid"
            ip = log[offset + 7]
            user = log[offset + 5]
          end
		  
	  datetime = Time.utc(
	    Time.now.year, log[0], log[offset - 3], 
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
end

#####################################################################
# Function:    	main(args)
# returns: 	void
# Notes: 	parses the commandline and starts eventMachine
#####################################################################
def main(args)
  if args.length != 4 
    puts "Usage: #{$0} <path> <allowed attempts> <Length of time for bad attempts> <Block Length>"
    puts "For infinite ban use 0 in blocklength field"
    return 1
  end
  Reader.limit(args[1])
  Reader.errorTime(args[2])
  Reader.blockTime(args[3])
  printf("Monitoring: %s\n", args[0])
  EventMachine.run do
    EventMachine::file_tail(args[0], Reader)
  end
end 

exit(main(ARGV))
