#!/bin/bash

input_file="ip_list.txt"
output_file="bmc_addresses.txt"

> "$output_file"

ssh_user="root"
ssh_options="-o StrictHostKeyChecking=no"
ssh_pass_list=("kjn5rfv69!" "kjn5rfv69" "lkm6tgb70" "kjn5rfv691")


extract_ip() {
    echo "$1" | awk -F": " '/IPv4Address/ {print $2}'
}

mapfile -t ip_addresses < "$input_file"


for ip in "${ip_addresses[@]}"; do
    echo "Connecting to $ip..."
    for ssh_pass in ${ssh_pass_list[*]}; do
        echo $ssh_pass
        i=1
        output=$(sshpass -p $ssh_pass ssh $ssh_options "$ssh_user@$ip" "esxcli hardware ipmi bmc get" 2>&1)
        ssh_exit_code=$?
        echo "$i SSH exit code: $ssh_exit_code"
        if [[ $ssh_exit_code -eq 0  ]]; then
            break
        fi
    done    

    echo "Command output: $output"

    if [[ $ssh_exit_code -eq 0 && -n "$output" ]]; then
        bmc_ip=$(extract_ip "$output")
        if [[ -n "$bmc_ip" ]]; then
            echo "BMC IP for $ip: $bmc_ip"
            echo "$ip: $bmc_ip" >> "$output_file"
        else
            echo "Could not extract BMC IP from $ip output"
            echo "$ip: Error extracting BMC IP" >> "$output_file"

        fi



    else

        echo "Failed to connect or execute command on $ip"
        echo "$ip: N/A" >> "$output_file"
    fi
done

echo "BMC IP addresses have been saved to $output_file"