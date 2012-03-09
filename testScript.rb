
#Botnet test if different ips try to crack password
#should block all but first few attemts
puts "Starting mysql"
system("service mysqld start")
puts "flushing and creating new database"
system("mysql < dbSetup.sql")
#puts "Starting event logger now with 300s scan range 500s ban and 3 allowed attempts"
#system("ruby em.rb /var/log/secure 3 20 20 &")
system("iptables -L")
puts "simulating botnet attack ips 200.0.0.1 to 200.0.0.3"
for i in (1..3)
  time = Time.now
  system(sprintf("echo Mar 2 %d %d:%d:%d wtf sshd[3904]: Failed password for root from 200.0.0.%d port 49243 ssh2 >> /var/log/secure", time.day, time.hour, time.min, time.sec, i))
end
#slow scan 20s interval attempt should be caught
puts "Slow scan with 5s interval should be caught ip 199.0.0.1"
for i in (1..3)
 # printf("current time: %s, echoing password failure into /var/log/secure\n", Time.now)
  time = Time.now
  system(sprintf("echo Mar d  %d %d:%d:%d wtf sshd[3904]: Failed password for bob from 199.0.0.1 port 49243 ssh2 >> /var/log/secure", time.day, time.hour, time.min, time.sec))
  sleep(5)
end
system ("iptables -L")

