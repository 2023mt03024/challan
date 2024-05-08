# Start from the official Python base image.
FROM python:3.9

# Set the current working directory to /code.
# This is where we'll put the requirements.txt file and the app directory.
WORKDIR /code

# Copy the file with the requirements to the /code directory.
# Copy only the file with the requirements first, not the rest of the code.
# As this file doesn't change often, Docker will detect it and use the cache
# for this step, enabling the cache for the next step too.
COPY ./requirements.txt /code/requirements.txt

# Install the package dependencies in the requirements file.
# Disable pip's caching; since docker will cache
# The --no-cache-dir option tells pip to not save the downloaded packages 
# locally, as that is only if pip was going to be run again to install the
# same packages, but that's not the case when working with containers.
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Create necessary directories
RUN mkdir /code/vehicle
RUN mkdir /code/challan_as
RUN mkdir /code/challan_ws
RUN mkdir /code/challan_ws_public

# Copy templates folder, app.py, initdb.py to the /code directory.
# As this has all the code which is what changes most frequently ,the Docker cache
# won't be used for this or any following steps easily.
COPY ./vehicle/app.py /code/vehicle/app.py
COPY ./vehicle/initdb.py /code/vehicle/initdb.py
COPY ./challan_as/app.py /code/challan_as/app.py
COPY ./challan_ws/templates /code/challan_ws/templates
COPY ./challan_ws/app.py /code/challan_ws/app.py
COPY ./challan_ws_public/templates /code/challan_ws_public/templates
COPY ./challan_ws_public/app.py /code/challan_ws_public/app.py
COPY ./start_services.sh /code/start_services.sh

# Define flask app config variables
ENV FLASK_KEY=SECRET_KEY
ENV FLASK_KEY_VALUE='the random string'

# Define POSTGRES variables
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=mypwd

# app requires ctrl-c(SIGINT) for termination.
# The app must run as PID 1 inside docker to receive a SIGINT.
# To do so, one must use ENTRYPOINT instead of CMD. 
ENTRYPOINT  ["./start_services.sh"]
