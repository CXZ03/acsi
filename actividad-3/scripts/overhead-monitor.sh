#!/bin/bash
output_file=${1:-"overhead_output.txt"}
monitor_name=${2:-"parallel-monitor.sh"}
shift 2

# Calcula el overhead del monitor a ejecutar y hace print usando time
{ time bash "$monitor_name" "$@"; } 2> time_output.txt

# Extrae el tiempo de ejecución del monitor
real=$(grep "real" time_output.txt | awk '{print $2}')
user=$(grep "user" time_output.txt | awk '{print $2}')
sys=$(grep "sys" time_output.txt | awk '{print $2}')

echo "--- Monitor: $monitor_name ---"
echo "Real: $real"
echo "User: $user"
echo "Sys: $sys"

real_seconds=$(echo "$real" | sed 's/m/*60+/;s/s//' | bc)
user_seconds=$(echo "$user" | sed 's/m/*60+/;s/s//' | bc)
sys_seconds=$(echo "$sys"   | sed 's/m/*60+/;s/s//' | bc)

ejecucion=$(echo "$user_seconds + $sys_seconds" | bc)
overhead=$(echo "scale=8; ($ejecucion / $real_seconds) * 100" | bc)

echo "--- Overhead ---"
echo "Tiempo de ejecución: $real_seconds seconds"
echo "Tiempo de ejecución del monitor: $ejecucion seconds"
echo "Overhead: $overhead %"

echo "--- Overhead ---" > "$output_file"
echo "Tiempo de ejecución: $real_seconds seconds" >> "$output_file"
echo "Tiempo de ejecución del monitor: $ejecucion seconds" >> "$output_file"
echo "Overhead: $overhead %" >> "$output_file"

# Clean up
rm time_output.txt
