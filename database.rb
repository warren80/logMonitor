#######################################################################
# Program:  Event Logger
# File:     database.rb
#
# Date Mar 5, 2012
# Designer: Warren Voelkl
# Programmer: Warren Voelkl
#
# Notes:
# This file manipulates and queries the failedAttempts and passwordlogs 
# tables in mysql.
#######################################################################

require 'rubygems'
require 'active_record'
require 'mysql'

# Connects to the sql database
ActiveRecord::Base.establish_connection(
:adapter=> "mysql",
:host => "localhost",
:database=> "eventLogger",
:reconnect=> "true"
)


#extends the activeRecord class (database connection)
class Failedattempts < ActiveRecord::Base
end

class Passwordlogs < ActiveRecord::Base
end

#######################################################################
# Class PasswordDB
#
# Functions:    blockedIp(ip, user, blocktime)
#               unblockIp(ip, user)
#               getPasswordLog(limit)
#               insertRecord(ip, user, time)
#               PasswordDB.getRecentAttempts(user, time, limit)
#
# Notes:
# The class used by outside programs used in manipulating the two 
# database tables.
#######################################################################
class PasswordDB

  #####################################################################
  # Function:   blockedIp(ip, user, blocktime
  # returns: void
  # Notes: adds a log entry into the password logs upon blocking ip
  #####################################################################
  def PasswordDB.blockedIp(ip, user, blocktime)
    Passwordlogs.create(
      :ip => ip,
      :user => user,
      :time => Time.now(),
      :msg => "Blocked",
      :length => blocktime)
  end
  #####################################################################
  # Function:   blockedIp(ip, user, blocktime)
  # returns: void
  # Notes: adds a log entry into the password logs upon unblocking ip
  #####################################################################
  def PasswordDB.unblockIp(ip, user)
    Passwordlogs.create(
      :ip       => ip,
      :user     => user,
      :time     => Time.now(),
      :msg      => "Unblocked")
  end

  #####################################################################
  # Function:   getPasswordLog(limit)
  # Returns:    a string in html format from the logs file
  #
  # Notes:      Queries the password logs table and returns a list
  #             ordered by time limited by the specified value of limit
  #####################################################################
  def PasswordDB.getPasswordLog(limit)
    query = Passwordlogs.find(
      :all,
      :order => "id desc",
      :limit => limit)
    string = ''
    query.each do |x|
      string += sprintf(
"   <tr>
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
    </tr>\n",
    x.msg, x.ip, x.user, x.time, x.length);
    end
    return string
  end

  #####################################################################
  # Function:   insertRecord
  # Returns:    void
  # Notes:      adds an entry into the failedattempts table
  #####################################################################
  def PasswordDB.insertRecord(ip, user, time)
    Failedattempts.create(:ip => ip, :user => user, :time => time)
  end

  #####################################################################
  #Function;    getRecentAttempts(user, time, limit)
  #Returns:     Number of qualifiying query results
  #
  #Notes:       for each row returned by the query that is older than 
  #             than the specified limit it deletes the result
  ####################################################################
  def PasswordDB.getRecentAttempts(user, time, limit)
    query = Failedattempts.find(
      :all,
      :conditions => ["user = ?", user])
    count = 0
    query.each do |x|
      #check for failed attemts in last x time 
      if x.time < time - limit
        x.delete
      else
        count += 1
      end
    end
  return count
  end
end

