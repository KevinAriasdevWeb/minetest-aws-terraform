#!/bin/bash
apt-get update
apt-get install -y minetest minetest-server
systemctl enable minetest-server
systemctl start minetest-server