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

