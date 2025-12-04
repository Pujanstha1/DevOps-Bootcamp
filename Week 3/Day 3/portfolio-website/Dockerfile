# Use nginx lightweight image
FROM nginx:alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy site files
COPY site /usr/share/nginx/html

# Expose port
EXPOSE 80

# Start nginx (default command from image is fine, but we reaffirm)
CMD ["nginx", "-g", "daemon off;"]