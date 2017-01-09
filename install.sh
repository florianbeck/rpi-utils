#!/bin/bash
source $(dirname $0)/rpi-utils.conf
package_name="rpi-utils"
package_dir="/opt/$package_name"

# Outputs a RaspAP INSTALL log line
function install_log() {
    echo -e "\033[1;32m$package_name INSTALL: $*\033[m"
}

# Outputs a RaspAP INSTALL ERROR log line and exits with status code 1
function install_error() {
    echo -e "\033[1;37;41m$package_name INSTALL ERROR: $*\033[m"
    exit 1
}

function config_installation() {
    install_log "Configure installation"
    echo -n "Install directory [${package_dir}]: "
    read input
    if [ ! -z "$input" ]; then
        package_dir="$input"
    fi

    echo -n "Complete installation with these values? [y/N]: "
    read answer
    if [[ $answer != "y" ]]; then
        echo "Installation aborted."
        exit 0
    fi
}

function copy_files() {
    install_log "Copying files"
    if [ $(dirname $(readlink -f $0)) = "$package_dir" ]; then 
        echo "The files are already saved in the installation directory"
    else 
        if [ -d "$package_dir" ]; then
            echo "Old '$package_dir' moved to '$package_dir.original'"
            sudo mv $package_dir $package_dir.original || install_error "Unable to move old '$package_dir' out of the way"
        fi
        sudo mkdir -p "$package_dir" || install_error "Unable to create directory '$package_dir'"
        echo "Move files from '$(dirname $(readlink -f $0))' to '$package_dir'"
        #sudo cp -r --preserve=mode $(dirname $0)/* $package_dir/ || install_error "Unable to copy files to '$package_dir'"
        sudo mv $(dirname $0)/* $package_dir/ || install_error "Unable to move files to '$package_dir'"
        sudo rm -r $(dirname $(readlink -f $0)) || install_error "Unable to delete '$(dirname $(readlink -f $0))'"
    fi
}

function install_dependencies() {
    install_log "Installing required packages"
    sudo apt-get install isc-dhcp-server || install_error "Unable to install dependencies"
}

function copy_config() {
    _file=$1
    _newfile=$2
    _config=config
    echo "Move $_newfile defaults file"
    if [ -f $_file ]; then
        sudo mv $_file $package_dir/$_config/$_newfile.original || install_error "Unable to remove old '$_file'"
    fi
    sudo cp --preserve=mode  $package_dir/$_config/$_newfile $_file || install_error "Unable to move $newfile defaults file"
    if ! [ -f $package_dir/$_config/$_newfile.link ]; then
        sudo ln -s $_file $package_dir/$_config/$_newfile.link
    fi
}

function default_config() {
    install_log "Setting up configuration"
    sudo sed -i "s/PACKAGE_dir=.*/PACKAGE_dir=$(echo "$package_dir" | sed 's/\//\\\//g')/g" $package_dir/rpi-utils.conf
    copy_config /etc/dhcp/dhcpd.conf dhcpd.conf
    sudo sed -i "s/#hostname#/$(hostname)/g" /etc/dhcp/dhcpd.conf
    copy_config /etc/network/interfaces interfaces  
    sudo sed -i "s/#ssid#/$(hostname)/g" /etc/network/interfaces 
}

function add_package() {
    install_log "Make everything executable"
    if [ -f /usr/bin/wifi ]; then
        sudo mv /usr/bin/wifi /usr/bin/wifi.old || install_error "Unable to remove old '$_file'"
    fi
    sudo touch /usr/bin/wifi
    sudo chmod +x /usr/bin/wifi
    echo '#!/bin/sh' | sudo tee /usr/bin/wifi  > /dev/null
    echo "$package_dir/wifi \$*" | sudo tee -a /usr/bin/wifi  > /dev/null
    echo "Added '/usr/bin/wifi' file"
    if [ -f /usr/bin/shutdownbutton ]; then
        sudo mv /usr/bin/shutdownbutton /usr/bin/shutdownbutton.old || install_error "Unable to remove old '$_file'"
    fi
    sudo touch /usr/bin/shutdownbutton
    sudo chmod +x /usr/bin/shutdownbutton
    echo '#!/bin/sh' | sudo tee /usr/bin/shutdownbutton  > /dev/null
    echo "$package_dir/shutdownbutton \$*" | sudo tee -a /usr/bin/shutdownbutton  > /dev/null
    echo "Added '/usr/bin/shutdownbutton' file"
}

function add_autostart() {
    install_log "Modify rc.local file"
    sudo sed -i "$(echo "$package_dir" | sed 's/\//\\\//g')\/.*/d" /etc/rc.local
    sudo sed -i -e "\$i \\$package_dir/wifi set default" /etc/rc.local
    sudo sed -i -e "\$i \\$package_dir/wifi button start" /etc/rc.local 
    sudo sed -i -e "\$i \\$package_dir/shutdownbutton start\\n" /etc/rc.local  
}

function install_complete() {
    install_log "Installation completed!"
    
    echo -n "Reboot now? [y/N]: "
    read answer
    if [[ $answer != "y" ]]; then
        #echo "Installation aborted."
        exit 0
    fi
    sudo shutdown -r now || install_error "Unable to execute shutdown"
}


config_installation
copy_files
install_dependencies
default_config
add_package
add_autostart
install_complete
