#!/bin/bash

echo "=========================================================="
echo "Testing Round Robin Load Balancing (15 Requests)"
echo "Target: http://localhost:8080/api/drivers"
echo "=========================================================="

declare -A counts

for i in {1..15}
do
    response=$(curl -s http://localhost:8080/api/drivers)
    port=$(echo "$response" | sed -n 's/.*"port":"\([^"]*\)".*/\1/p')
    if [ -z "$port" ]; then
        port=$(echo "$response" | sed -n 's/.*"instanceId":"\([^"]*\)".*/\1/p')
    fi
    echo "Request $i -> Handled by: $port"
    echo "Response: $response"
    echo "----------------------------------------------------------"
    counts["$port"]=$(( ${counts["$port"]:-0} + 1 ))
done

echo ""
echo "=========================================================="
echo "Request Distribution Summary (Total 15 Requests):"
echo "=========================================================="
for key in "${!counts[@]}"; do
    echo "Instance $key : ${counts[$key]} requests"
done
echo "=========================================================="

