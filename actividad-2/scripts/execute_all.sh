#!/bin/bash
LC_NUMERIC=C bash overhead-monitor cpu-overhead.txt cpu-monitor.sh
LC_NUMERIC=C bash overhead-monitor memory-overhead.txt memory-monitor.sh
LC_NUMERIC=C bash overhead-monitor.sh paralel-overhead.txt paralel-monitor.sh