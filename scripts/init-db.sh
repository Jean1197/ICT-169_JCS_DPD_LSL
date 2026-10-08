#!/bin/bash

docker exec mysql mysql -u root -pRoot123! -e "
CREATE DATABASE IF NOT EXISTS wordpress;
"