FROM ubuntu:22.04

# Install Nginx along with your other build dependencies
RUN apt-get update && apt-get install -y nasm gcc make nginx

WORKDIR /usr/src/app

# Copy all your project files, including the new nginx.conf and start.sh
COPY . .

# Make the startup script executable inside the container
RUN chmod +x start.sh

# Build your assembly application using the Makefile
RUN make build

# Nginx will listen on port 80 for public web traffic
EXPOSE 80

# Use the startup script to launch both services
CMD ["./start.sh"]