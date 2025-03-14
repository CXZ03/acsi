#!/bin/bash

# Parametros
# 1. Nombre del archivo de salida
file=$1
# 2. Carga total
load=$2
# 3. Cantidad de hilos
threads=$3

# Si no se especifica el nombre del archivo, dar error
if [ -z $file ]; then
    echo "Debe especificar el nombre del archivo de salida."
    exit 1
fi

# Si no se especifica la carga total, dar error
if [ -z $load ]; then
    echo "Debe especificar la carga total."
    exit 1
fi

# Si no se especifica la cantidad de hilos, dar error
if [ -z $threads ]; then
    echo "Debe especificar la cantidad de hilos."
    exit 1
fi

# Si el archivo no existe, lo crea
if [ ! -f $file ]; then
    echo "timestamp,load,threads,total_threads,events_seconds,total_time,latency_min,latency_avg,latency_max,latency_95th,latency_sum,events_avg,events_stddev,execution_time_avg,execution_time_stddev" >> $file
fi

tmp_file='tmp.txt'

# Ejecutamos el sysbench y guardamos la salida en el archivo
sysbench cpu --threads=$threads --time=0 --cpu-max-prime=$load --events=$load run > $tmp_file

# Parseamos el archivo para obtener los valores
events_seconds=$(cat $tmp_file | grep "events per second" | awk '{print $4}')
total_time=$(cat $tmp_file | grep "total time:" | awk '{print $3}' | cut -d's' -f1)
latency_min=$(cat $tmp_file | grep "min:" | awk '{print $2}')
latency_avg=$(cat $tmp_file | grep "avg:" | awk '{print $2}')
latency_max=$(cat $tmp_file | grep "max:" | awk '{print $2}')
latency_95th=$(cat $tmp_file | grep "percentile:" | awk '{print $3}')
latency_sum=$(cat $tmp_file | grep "sum:" | awk '{print $2}')
events_avg=$(cat $tmp_file | grep "events (avg/stddev):" | awk '{print $3}' | cut -d'/' -f1)
events_stddev=$(cat $tmp_file | grep "events (avg/stddev):" | awk '{print $3}' | cut -d'/' -f2)
execution_time_avg=$(cat $tmp_file | grep "execution time (avg/stddev):" | awk '{print $4}' | cut -d'/' -f1)
execution_time_stddev=$(cat $tmp_file | grep "execution time (avg/stddev):" | awk '{print $4}' | cut -d'/' -f2)

# Otros valores
total_threads=$(nproc)
timestamp=$(date "+%Y-%m-%d %H:%M:%S.%3N")

# Lo Añadimos al csv de salida
echo "$timestamp,$load,$threads,$total_threads,$events_seconds,$total_time,$latency_min,$latency_avg,$latency_max,$latency_95th,$latency_sum,$events_avg,$events_stddev,$execution_time_avg,$execution_time_stddev" >> $file