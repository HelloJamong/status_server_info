#!/bin/bash
# ANSI color definitions
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;36m" # Light blue for usage %
LIGHT_PURPLE="\033[1;35m"
BOLD_YELLOW="\033[1;93m"
RESET="\033[0m"

# Usage level interpretation
get_status() {
    local usage=$1
    if (( usage < 60 )); then
        echo -e "${GREEN}GOOD${RESET}"
    elif (( usage < 80 )); then
        echo -e "${YELLOW}WARN${RESET}"
    else
        echo -e "${RED}ALERT${RESET}"
    fi
}

# Usage string formatting
format_usage() {
    local usage=$1
    echo -e "[${BLUE}${usage}%${RESET} / 80%]"
}

# 1. CPU info
cpu_model=$(grep -i "model name" /proc/cpuinfo | head -n 1 | cut -d ':' -f2- | sed 's/^[[:space:]]*//')
cpu_idle=$(top -bn1 | grep "Cpu(s)" | sed 's/.*, *\([0-9.]*\)%* id.*/\1/')
cpu_usage=$(printf "%.0f" "$(echo "100 - $cpu_idle" | bc)")
cpu_stat=$(get_status "$cpu_usage")
sockets=$(lscpu | awk '/Socket\(s\)/ {print $2}')
cores=$(lscpu | awk '/Core\(s\) per socket/ {print $4}')
vcores=$(lscpu | awk '/^CPU\(s\):/ {print $2}')

# 2. Memory info (calculated from /proc/meminfo)
mem_total_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
mem_avail_kb=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
if [ -z "$mem_total_kb" ] || [ "$mem_total_kb" -eq 0 ]; then
    mem_pct=0
    mem_total_gib=0
    mem_avail_gib=0
    mem_used_gib=0
else
    mem_used_kb=$((mem_total_kb - mem_avail_kb))
    mem_pct=$(( (mem_used_kb * 100) / mem_total_kb ))
    mem_total_gib=$((mem_total_kb / 1024 / 1024))
    mem_avail_gib=$((mem_avail_kb / 1024 / 1024))
    mem_used_gib=$((mem_used_kb / 1024 / 1024))
fi
mem_stat=$(get_status "$mem_pct")

# Swap info (still from free)
swap_total=$(free -g | awk '/Swap:/ {print $2}')
swap_used=$(free -g | awk '/Swap:/ {print $3}')
if [ "$swap_total" -eq 0 ]; then
    swap_pct=0
else
    swap_pct=$(( (swap_used * 100) / swap_total ))
fi
swap_stat=$(get_status "$swap_pct")

# 3. Disk usage
get_disk_usage() {
    df -P "$1" | awk 'NR==2 {gsub("%", "", $5); print $5}'
}
root_usage=$(get_disk_usage /)
boot_usage=$(get_disk_usage /boot)
root_stat=$(get_status "$root_usage")
boot_stat=$(get_status "$boot_usage")

# 4. Uptime info
uptime_sec=$(cut -d. -f1 /proc/uptime)
uptime_days=$(( uptime_sec / 86400 ))
uptime_hours=$(( (uptime_sec % 86400) / 3600 ))
uptime_mins=$(( (uptime_sec % 3600) / 60 ))
weeks_up=$(( uptime_days / 7 ))
now_time=$(date '+%Y-%m-%d %H-%M-%S')

# Output
printf "\n================= ${YELLOW}SYSTEM MONITORING STATUS${RESET} =================\n\n"
# CPU
printf "${BOLD_YELLOW}■ %-23s${RESET} [%s]\n" "CPU INFO" "$cpu_model"
printf "${LIGHT_PURPLE}■ %-25s${RESET} (CPUs: $vcores | Socket: $sockets | Core: $cores | vCore: $vcores)\n" "CPU USING(%) STATUS"
printf "${LIGHT_PURPLE}■ %-25s${RESET} : %s (%s)\n" "CPU STATUS" "$(format_usage $cpu_usage)" "$cpu_stat"
# Memory
printf "\n${BOLD_YELLOW}■ %-25s${RESET} (MemTotal: ${mem_total_gib} GiB | SwapTotal: ${swap_total} GiB)\n" "MEMORY USING STATUS"
printf "${LIGHT_PURPLE}■ %-25s${RESET} : %s (%s)\n" "MEM USING(%)" "$(format_usage $mem_pct)" "$mem_stat"
printf "${LIGHT_PURPLE}■ %-25s${RESET} : %s (%s)\n" "SWAP USING(%)" "$(format_usage $swap_pct)" "$swap_stat"
# Disk
printf "\n${BOLD_YELLOW}■ %-25s${RESET}\n" "DISK USING STATUS"
printf "${LIGHT_PURPLE}■ %-25s${RESET} : %s (%s)\n" "ROOT(/) USING(%)" "$(format_usage $root_usage)" "$root_stat"
printf "${LIGHT_PURPLE}■ %-25s${RESET} : %s (%s)\n" "BOOT(/boot) USING(%)" "$(format_usage $boot_usage)" "$boot_stat"
# Uptime
printf "\n${BOLD_YELLOW}■ %-25s${RESET} : %s weeks\n" "LAST REBOOT TIME" "$weeks_up"
printf "${LIGHT_PURPLE}■ %-25s${RESET} : %s days %s hours %s mins\n" "SERVER UPTIME" "$uptime_days" "$uptime_hours" "$uptime_mins"
printf "${LIGHT_PURPLE}■ %-25s${RESET} : %s\n" "SERVER TIME" "$now_time"
# End
printf "============================================================\n\n"