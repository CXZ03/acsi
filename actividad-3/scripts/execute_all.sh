#!/bin/bash

threads="1 2 3 4 6 9 12"
loads="12500 25000 37500 50000 62500 75000"
time_interval=1


LC_NUMERIC=C bash overhead-monitor.sh overhead-all.txt sys-executer.sh "$loads" "$threads" $time_interval
