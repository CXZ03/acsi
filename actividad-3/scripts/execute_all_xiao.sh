#!/bin/bash

threads="1"
loads="12500"
time_interval=1
rounds=5


LC_NUMERIC=C bash overhead-monitor.sh overhead-all.txt sys-executer.sh "$loads" "$threads" $time_interval $rounds
