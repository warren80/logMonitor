yum install ruby ruby-devel rubygems
gem install eventmachine
gem install eventmachine-tail
gem install mysql
gem install activerecord
yum install mysql mysql-server
yum install openssh
service sshd start
service start mysqld
mysql -u < dbSetup.sql
echo "type ruby /var/log/secure <attempts> <rangetocheck> <blocklength>"
touch index.html
echo "refresh the firefox page once an ip has been blocked"
echo "type . setup.sh to run the test script"
#firefox index.html &
