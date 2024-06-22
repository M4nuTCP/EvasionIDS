#!/bin/bash

greenColour="\e[0;32m\033[1m"
end="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"

function ctrl_c(){
    echo -e "\n\n${redColour}[!] Saliendo, Archivo${end}${greenColour} $output_file${end}${redColour} creado. ${end}\n"
    echo -e "\nPuertos cerrados: $closed_ports" >> "$output_file"
    exit 1 
}

trap ctrl_c INT

echo -en "\n${greenColour}[?] Windows/Linux (w/l):${end} "
read system_type

windows_ports=(135 139 445 3389 135 139 445 3389 135 139 445 3389 135 139 445 3389 135 139 445 3389 135 139 445 3389 135 139 445 3389 135 139 445 3389 135 139 445 3389 135 139 445 3389 135 139 445 3389 135 139 445 3389 135 139 445 3389 135 139 445 3389)
linux_ports=(22 80 443 25 110 993 995 143 465 587 3306 5432 8080 8443 20 21 37 69 123 161 162 389 636 989 990 2049 3260 3389 5900 8081 10050 10051 20000 27017 27018 27019 50070 50075 50090 50091 50095 50105 50110 50111 50120 50125 50126 50130 50135)

if [[ "$system_type" == "w" ]]; then
    ports=("${windows_ports[@]}")
elif [[ "$system_type" == "l" ]]; then
    ports=("${linux_ports[@]}")
else
    echo "Opción no válida. Por favor, elija 'w' para Windows o 'l' para Linux."
    exit 1
fi

echo -en "${greenColour}[?] IP:${end} "
read IP
echo -en "${greenColour}[?] Sleep (Recomendable +35): ${end}"
read sleep_time

echo -en "\n"

output_file="${IP}.txt"
echo -en "Puertos abiertos en ${IP}: \n" > "$output_file"
total_scanned=0
closed_ports=""

for ((i=0; i<${#ports[@]}; i+=2)); do
    ports_to_scan="${ports[i]}"
    if [ $((i+1)) -lt ${#ports[@]} ]; then
        ports_to_scan+=",${ports[i+1]}"
    fi
    echo -e "\n${greenColour}[+] Escaneo -> ${ports_to_scan} ($((total_scanned += 2)))${end}\n"
    scan_output=$(sudo nmap -sS -p"$ports_to_scan" -n "$IP")
    open_ports=$(echo "$scan_output" | grep -E "^(PORT|MAC|[0-9]+/tcp)" | grep "open")
    if [ -n "$open_ports" ]; then
        echo -e "$open_ports"
        echo -e "$open_ports" >> "$output_file"
    fi
    closed_ports+=$(echo "$scan_output" | grep "closed" | awk '{print $1}' | tr '\n' ' ')
    sleep "$sleep_time"
done

echo -e "\n ${greenColour}[+] Resultado completo guardado en $output_file${end}"
