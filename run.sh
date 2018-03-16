#!/bin/sh

MYSQL_USR='root'
MYSQL_PWD=''
MYSQL_DB='test'

mysql --silent -u$MYSQL_USR $MYSQL_DB < model.sql
mysql --silent -u$MYSQL_USR $MYSQL_DB < test.sql

