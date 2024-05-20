# Use the official Python image from the Docker Hub
FROM python:3.8-slim

# Set the working directory
WORKDIR /app

# Copy the server script into the container
COPY server.py .

# Install any necessary dependencies
RUN pip install --no-cache-dir requests

# Expose the port the server will run on
EXPOSE 8081

# Run the server
CMD ["python", "server.py"]
