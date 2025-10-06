#!/bin/bash
# Sonde de supervision CPU/Mémoire/Stockage
# Plug and play, peut être déployée et lancée
# Reste à optimiser l'export .json pour récupération des données par un serveur de supervision

# Dossier et date
LOG_DIR="/var/log/sonde"
DATE=$(date +"%Y-%m-%d %H:%M")

# Création du dossier au cas où existe pas
mkdir -p "$LOG_DIR"

# Fichier spécifique à l'heure
HOUR_TAG=$(date +"%Y-%m-%d_%H")
LOG_FILE="$LOG_DIR/$(hostname)_sonde_$HOUR_TAG.log"

# Charge CPU par minute
CPU_LOAD=$(awk '{print $1}' /proc/loadavg)

# Calcul de la mémoire disponible
MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_AVAILABLE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
MEM_USED=$((MEM_TOTAL - MEM_AVAILABLE))
MEM_PRCT=$((100 * MEM_USED / MEM_TOTAL))

# Calcul du stockage disponible
STCK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
STCK_AVAILABLE=$(df -h / | awk 'NR==2 {print $4}')
STCK_USED=$(df -h / | awk 'NR==2 {print $3}')
STCK_PRCT=$(df -h / | awk 'NR==2 {print $5}')

# Outpout
OUTPUT=$(cat <<EOF
{
  "timestamp": "$DATE",
  "cpu_load_1min": "$CPU_LOAD",
  "memory_usage": "$MEM_USED / $MEM_TOTAL = $MEM_PRCT%",
  "storage_used": "$STCK_USED / $STCK_TOTAL = $STCK_PRCT"
}
EOF
)

# Output dans le log
echo "$OUTPUT" >> "$LOG_FILE"

# Output dans la console
echo "$OUTPUT"

# Suppression des logs de + de 7 jours
find "$LOG_DIR" -type f -mtime +7 -name "*.log" -delete
