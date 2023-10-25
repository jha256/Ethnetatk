#!/bin/sh

BRIDGE_NAME="br0"
v=10  # Set the number of iterations here

# Check if the bridge exists, and if so, delete it
if sudo ovs-vsctl br-exists $BRIDGE_NAME; then
    echo "Deleting existing bridge $BRIDGE_NAME."
    sudo ovs-vsctl del-br $BRIDGE_NAME
fi

# Create a new bridge
echo "Creating bridge $BRIDGE_NAME."
sudo ovs-vsctl add-br $BRIDGE_NAME

# Iterate over the specified number of iterations
x=1
while [ $x -le $v ]; do
    # Add port to the bridge with the specific tap number
    sudo ovs-vsctl add-port $BRIDGE_NAME tap$x -- set Interface tap$x type=internal ofport=$x
    
    # Set the interface up
    sudo ip link set tap$x up
    
    echo "Port tap$x added to $BRIDGE_NAME."
    x=$((x+1))
done