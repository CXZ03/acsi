#!/bin/bash

threads="1 2 4 6 12"
loads="25000 50000 75000"
time_interval=1


bash overhead-monitor.sh overhead-all.txt sys-executer.sh "$loads" "$threads" $time_interval
