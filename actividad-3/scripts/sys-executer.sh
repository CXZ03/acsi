#!/bin/bash

# Parametros

# 2. Cargas totales (formato: "100 1000 10000")
loads_param=$1
if [ -z "$loads_param" ]; then
    echo "Debe especificar las cargas totales."
    exit 1
fi
# Convert space-separated string to array
loads=($loads_param)

# 3. Cantidad de hilos (formato: "1 2 4 8 12")
threads_param=$2
if [ -z "$threads_param" ]; then
    echo "Debe especificar la cantidad de hilos."
    exit 1
fi
# Convert space-separated string to array
threads=($threads_param)

# 4. Time interval default 5s
time_interval=$3
if [ -z "$time_interval" ]; then
    time_interval=5
fi

# Doble for para recorrer las cargas y los hilos
for thread in "${threads[@]}"; do
    # Create thread directory
    thread_dir="thread_${thread}"
    mkdir -p "$thread_dir"
    
    for load in "${loads[@]}"; do
        # Create load directory
        load_dir="${thread_dir}/load_${load}"
        mkdir -p "$load_dir"
        
        file_name="${load_dir}/${file}_${load}_${thread}.csv"
        overhead_name="${load_dir}/${file}_${load}_${thread}_overhead.txt"

        file_monitor="${load_dir}/${file}_${load}_${thread}_monitor.csv"

        # Setup trap to kill monitor process if script is interrupted
        cleanup() {
            echo "Interrupted. Cleaning up monitoring process..."
            if [ ! -z "$MONITOR_PID" ]; then
                kill $MONITOR_PID 2>/dev/null
                wait $MONITOR_PID 2>/dev/null
            fi
            exit 1
        }
        trap cleanup SIGINT SIGTERM

        echo "Iniciar monitoreo..."
        bash paralel-monitor.sh $time_interval $file_monitor &
        MONITOR_PID=$!

        echo "Ejecutando sysbench con carga $load y $thread hilos..."
        bash overhead-monitor.sh $overhead_name sys-metrics.sh $file_name $load $thread

        echo "Finalizar monitoreo..."
        # Una vez terminado overhead-monitor, terminamos paralel-monitor
        kill $MONITOR_PID 2>/dev/null
        wait $MONITOR_PID 2>/dev/null
        
        # Reset trap
        trap - SIGINT SIGTERM
    done
done