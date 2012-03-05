require 'rubygems'  
require 'active_record'  
require 'mysql'
ActiveRecord::Base.establish_connection(  
:adapter=> "mysql",  
:host => "localhost",  
:database=> "eventLogger"  
)  
  
class Failedattempts < ActiveRecord::Base  
end  

class Passwordlogs < ActiveRecord::Base
end

class PasswordDB
  def PasswordDB.blockedIp(ip, user, blocktime)
#    Failedattempts.create(:ip => ip, :user => user, :time => time)
    Passwordlogs.create(
      :ip => ip, 
      :user => user, 
      :time => Time.now(), 
      :msg => "Blocked", 
      :length => blocktime)
  end

  def PasswordDB.unblockIp(ip, user)
    Passwordlogs.create(
      :ip       => ip,
      :user     => user,
      :time     => Time.now(),
      :msg      => "Unblocked")
  end

  def PasswordDB.getPasswordLog(limit)
    query = Passwordlogs.find(
      :all, 
      :order => "id desc",
      :limit => limit)
    string = ''
    query.each do |x|
      string += sprintf(
"	<tr>
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

  def PasswordDB.insertRecord(ip, user, time)
    Failedattempts.create(:ip => ip, :user => user, :time => time)
  end
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
