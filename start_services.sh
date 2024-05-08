#!/bin/sh
# Run vehicle service in background
cd /code/vehicle
python app.py & 

# Run challan_as service in background
cd /code/challan_as
python app.py & 

# Run challan_ws service in background
cd /code/challan_ws
python app.py &

# Run challan_ws_public service
cd /code/challan_ws_public
python app.py 
