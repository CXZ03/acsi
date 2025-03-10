#!/bin/bash
# Nombre del archivo de salida
monitoring_time=${1:-7200}          # Primer parámetro o 7200 segundos (120 min)
time_interval=${2:-5}               # Segundo parámetro o 5 segundos
output_file=${3:-"cpu_and_memory_stats.csv"}   # Pone Nombre archivo o "cpu_stats.csv" por defecto

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
echo "ID,Timestamp,%CPU (global),Capacidad de memoria utilizada,% Memoria utilizada" > $output_file

total=$(vmstat -s | awk 'NR==1' | awk '{print $1}')

for (( i = 0; i < $num_samples; i++ )) 
do
    
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    # CPU
    top_output=$(top -b -n 1 | grep "%Cpu")
    idle=$(echo "$top_output" | awk -F '[,:]' '{print $5}' | awk '{print $1}')
    # Calcular uso global de CPU (100 - idle)
    global=$(awk "BEGIN {print 100 - $idle}")
    
    # MEMORIA
    top_output=$(vmstat 1 1 | awk 'NR==3')
    free=$(echo "$top_output" | awk '{print $4}')
    buff=$(echo "$top_output" | awk '{print $5}')
    cache=$(echo "$top_output" | awk '{print $6}')
    
    disponible=$(awk "BEGIN {print $free + $buff + $cache}")
    used=$(awk "BEGIN {print $total - $disponible}")
    percent_used=$(LC_NUMERIC=C awk "BEGIN {printf \"%.4f\", ($used / $total) * 100}")

    # Guardar en csv
    echo "$i,$timestamp,$global,$used,$percent_used" >> $output_file

    
    # Indicar % de muestra completada
    echo "$((i + 1))/$num_samples"    
    sleep ${time_interval}
done

echo "Monitoreo completado. Los datos se han guardado en $output_file"