#!/bin/bash
monitor_name=${1:-"parallel-monitor.sh"}
# Calcula el overhead del monitor a ejecutar y hace print usando time
{ time bash $monitor_name $2 $3 $4; } 2> time_output.txt

# Extrae el tiempo de ejecución del monitor
real=$(grep "real" time_output.txt | awk '{print $2}')
user=$(grep "user" time_output.txt | awk '{print $2}')
sys=$(grep "sys" time_output.txt | awk '{print $2}')

echo "--- Monitor: $monitor_name ---"
echo "Real: $real"
echo "User: $user"
echo "Sys: $sys"

# Convert to seconds (assuming format like 0m3.585s)
real_seconds=$(echo "$real" | sed 's/m/*60+/;s/s//' | bc)
user_seconds=$(echo "$user" | sed 's/m/*60+/;s/s//' | bc)
sys_seconds=$(echo "$sys"   | sed 's/m/*60+/;s/s//' | bc)

ejecucion=$(echo "$user_seconds + $sys_seconds" | bc)
overhead=$(echo "scale=8; ($ejecucion / $real_seconds) * 100" | bc)

echo "--- Overhead ---"
echo "Tiempo de ejecución: $real_seconds seconds"
echo "Tiempo de ejecución del monitor: $ejecucion seconds"
echo "Overhead: $overhead %"

echo "--- Overhead ---" > overhead_output.txt
echo "Tiempo de ejecución: $real_seconds seconds" >> overhead_output.txt
echo "Tiempo de ejecución del monitor: $ejecucion seconds" >> overhead_output.txt
echo "Overhead: $overhead %" >> overhead_output.txt

# Clean up
rm time_output.txt
