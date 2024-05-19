# Use the official Nginx image as the base image
FROM nginx:alpine

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the HTML files to the Nginx default directory
COPY src /usr/share/nginx/html

# Expose port 80 for the web server
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]