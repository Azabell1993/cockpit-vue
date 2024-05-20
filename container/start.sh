#!/bin/bash
# start.sh

# Run the cockpit-cloud-connector
/container/cockpit-cloud-connector server --address=0.0.0.0 --port=8081 --use-tls &

# Run the run.sh script
/container/run.sh

# Wait for all background processes to finish
wait
