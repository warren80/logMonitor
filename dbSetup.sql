drop database if exists eventLogger;
create database eventLogger;
grant all on eventLogger.* to 'root'@'localhost';
use eventLogger;
drop table if exists failedattempts;
create table failedattempts (           
  id int NOT NULL AUTO_INCREMENT,                                  
  ip varchar(15) NOT NULL,          
  user varchar(100) NOT NULL,
  time datetime NOT NULL,                            
  PRIMARY KEY (id)           
);
use eventLogger;
drop table if exists passwordlogs;
create table passwordlogs (
  id int NOT NULL AUTO_INCREMENT,
  ip varchar(15) NOT NULL,
  user varchar(100) NOT NULL,
  time datetime NOT NULL,
  msg varchar(100) NOT NULL,
  length int NULL,
  PRIMARY KEY (id)
);

