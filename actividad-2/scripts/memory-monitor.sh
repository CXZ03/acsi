#!/bin/bash

# Nombre del archivo de salida
monitoring_time=${1:-10800}                     # Primer parámetro o 10800 segundos (3 h)
time_interval=${2:-3}                           # Segundo parámetro o 3 segundos
output_file=${3:-"memory_stats.csv"} # Pone Nombre archivo o "cpu_stats.csv" por defecto

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
echo "ID,Timestamp,Capacidad disponible,Capacidad utilizada,% Memoria utilizada" > $output_file

for (( i = 0; i < $num_samples; i++ )) 
do
    
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    top_output=$(vmstat 1 1 | awk 'NR==3')
    
    free=$(echo "$top_output" | awk '{print $4}')
    buff=$(echo "$top_output" | awk '{print $5}')
    cache=$(echo "$top_output" | awk '{print $6}')
    
    total=$(awk "BEGIN {print $free + $buff + $cache}")
    used=$(awk "BEGIN {print $buff + $cache}")
    percent_used=$(LC_NUMERIC=C awk "BEGIN {printf \"%.4f\", ($used / $total) * 100}")
    
    # Guardar en csv
    echo "$i,$timestamp,$free,$used,$percent_used" >> $output_file

    
    # Indicar % de muestra completada
    echo "$((i + 1))/$num_samples"    
    sleep ${time_interval}
done

echo "Monitoreo completado. Los datos se han guardado en $output_file"