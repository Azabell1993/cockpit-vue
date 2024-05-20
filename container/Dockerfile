# Build stage for building cockpit-cloud in C
FROM ubuntu:latest as builder

# Install necessary packages for building the project
RUN apt-get update && apt-get install -y \
    libglib2.0-dev \
    libmount-dev \
    libblkid-dev \
    pkg-config \
    make \
    gcc \
    libjson-glib-dev \
    libsoup2.4-dev \
    python3-venv

# Set up Python virtual environment
RUN python3 -m venv /opt/venv
RUN /opt/venv/bin/pip install --upgrade pip
RUN /opt/venv/bin/pip install requests

# Copy the source code and build it
COPY ./container/src/c /tmp/src/c
WORKDIR /tmp/src/c
RUN make

# Final stage
FROM ubuntu:latest

# Install necessary packages for running the project
RUN apt-get update && apt-get install -y \
    socat \
    strace \
    cockpit \
    python3-gi \
    python3-gi-cairo \
    gir1.2-gtk-3.0 \
    libjson-glib-dev \
    libsoup2.4-dev

# Copy the virtual environment and other necessary files
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /tmp/src/c/cockpit-cloud-connector /container/cockpit-cloud-connector
COPY ./container/run.sh /container/run.sh
COPY ./container/src/py /container/src/py
COPY ./container/secrets /container/secrets

# Ensure the run.sh script has execute permissions
RUN chmod +x /container/run.sh

# Ensure the cockpit-cloud-connector has execute permissions
RUN chmod +x /container/cockpit-cloud-connector

# Expose the necessary ports
EXPOSE 8080
EXPOSE 9090
EXPOSE 9091

# Run the main script
CMD ["/container/run.sh"]
