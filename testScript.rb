
#Botnet test if different ips try to crack password
#should block all but first few attemts
for i in (1..10)
  time = Time.now
  system(sprintf("echo Mar d  %d %d:%d:%d wtf sshd[3904]: Failed password for root from 200.0.0.%d port 49243 ssh2 >> /var/log/secure", time.day, time.hour, time.min, time.sec, i))
end
#slow scan 20s interval attempt should be caught
for i in (1..10)
  time = Time.now
  system(sprintf("echo Mar d  %d %d:%d:%d wtf sshd[3904]: Failed password for root from 199.0.0.1 port 49243 ssh2 >> /var/log/secure", time.day, time.hour, time.min, time.sec))
  sleep(20)
end
#slow scan 110 s interval attempt should not be caught
for i in (1..10)
  time = Time.now
  system(sprintf("echo Mar d  %d %d:%d:%d wtf sshd[3904]: Failed password for root from 199.0.0.1 port 49243 ssh2 >> /var/log/secure", time.day, time.hour, time.min, time.sec))
  sleep(110)
end

