#!/bin/bash

#foregrounds
_green='\033[0;32m'
_blue='\033[0;34m'
_yellow='\033[1;33m'
_red='\033[0;31m'
_nc='\033[0m' #reset-color


# Función para la animación de carga (Spinner)
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='/-\|'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

echo -e "${_blue}--- Iniciando limpieza del sistema --- ${_nc}"

# 1. Verificar Conexión e intentar Update
echo -n "Comprobando conexión a Internet... "
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "${_green}Conectado${_nc}"
    echo -e "${_yellow}Actualizando repositorios...${_nc}"

    # Ejecuta update en segundo plano para mostrar el spinner
    sudo apt update -y &> /dev/null &
    spinner $!
    echo -e "${_green}✓ Actualización completada${_nc}"
else
    echo -e "${_red}No hay Internet. Saltando actualización...${_nc}"
fi

# 2. clean packages
echo -e "${_yellow}Eliminando paquetes innecesarios y limpiando cache... ${_nc}"
sudo apt autoremove -y &> /dev/null & spinner $! 
sudo apt clean && sudo apt autoclean -y
echo -e "${_green}✓ limpieza terminada${_nc}"

# 3. clean logs
echo -e "${_yellow}Reduciendo el tamaño de logs... ${_nc}"
sudo journalctl --vacuum-time=2d &> /dev/null & spinner $!

echo "........ ...... .. ... .... ..... ... .. . . .."
echo -e "${_nc}¡Limpieza completada con exito! ${_nc}"
echo ".... ...... .. . .... ... ... .... .... .. .. ."
