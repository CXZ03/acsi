#!/bin/bash

# Nombre del archivo de salida
monitoring_time=${1:-5400}          # Primer parámetro o 5400 segundos (90 min)
time_interval=${2:-5}               # Segundo parámetro o 5 segundos
output_file=${3:-"cpu_stats.csv"}   # Pone Nombre archivo o "cpu_stats.csv" por defecto

num_samples=$(($monitoring_time / $time_interval))

# Por si acaso
if [ $num_samples -eq 0 ]; then
    echo "El tiempo de monitoreo debe ser mayor al intervalo de tiempo."
    exit 1
fi

# Si ya existe, lo borra
if [ -f $output_file ]; then
    rm $output_file
fi

# Añadir encabezado al archivo CSV
echo "ID,Timestamp,%CPU (global), %CPU (user), %CPU(system)" > $output_file

for (( i = 0; i < $num_samples; i++ )) 
do
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    top_output=$(top -b -n 1 | grep "%Cpu")
    
    user=$(echo "$top_output" | awk -F '[,:]' '{print $2}' | awk '{print $1}')
    system=$(echo "$top_output" | awk -F '[,:]' '{print $3}' | awk '{print $1}')
    idle=$(echo "$top_output" | awk -F '[,:]' '{print $5}' | awk '{print $1}')

    # Calcular uso global de CPU (100 - idle)
    global=$(awk "BEGIN {print 100 - $idle}")
    
    # Guardar en csv
    echo "$i,$timestamp,$global,$user,$system" >> $output_file

    
    # Indicar % de muestra completada
    echo "$((i + 1))/$num_samples"    
    sleep ${time_interval}
done

echo "Monitoreo completado. Los datos se han guardado en $output_file"