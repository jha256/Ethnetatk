#!/bin/sh

BRIDGE_NAME="br0"
v=2  # Set the number of iterations here

# Check if the bridge exists, and if so, delete it
if sudo ovs-vsctl br-exists $BRIDGE_NAME; then
    echo "Deleting existing bridge $BRIDGE_NAME."
    sudo ovs-vsctl del-br $BRIDGE_NAME
fi

# Create a new bridge
echo "Creating bridge $BRIDGE_NAME."
sudo ovs-vsctl add-br $BRIDGE_NAME

# Delete existing VM directory
sudo rm -rf vm*

cd ..
sudo rm -rf .vagrant.d
cd Ethnetatk

# Iterate over the specified number of iterations
x=1
while [ $x -le $v ]; do
    # Add port to the bridge with the specific tap number
    sudo ovs-vsctl add-port $BRIDGE_NAME tap$x -- set Interface tap$x type=internal ofport=$x
    
    # Set the interface up
    sudo ip link set tap$x up
    
    echo "Port tap$x added to $BRIDGE_NAME."

    # Make the VM directory

    sudo mkdir vm$x

    cd vm$x 
    
    sudo vagrant init generic/ubuntu1804
    
    sleep 1
    
    # Use sed to insert network configuration line inside the Ruby block
    sudo sed -i '/^Vagrant.configure("2") do |config|/a \ \ config.vm.network "public_network", bridge: "tap'$x'"' Vagrantfile
    
    #sudo vagrant up

    cd ..

    x=$((x+1))
done

# https://github.com/vagrant-libvirt/vagrant-libvirt/issues/658