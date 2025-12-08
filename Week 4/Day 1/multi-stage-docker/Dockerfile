# Build Stage
#---------------
FROM node:18-alpine AS builder 
##using alias for the base image


# Specifying the working directory
WORKDIR /app


#Copying package files first to optimize caching
COPY package*.json ./

RUN npm install --only=production

#Copy Source code
COPY . .

#Ensures dist folder exists and creates if not already created
RUN mkdir -p dist

#Build html file
RUN npm run build


# Runtime Stage 
# We are using nginx to serve static HTML
#----------------------------------------
FROM nginx:1.27-alpine AS runtime

#Copy build output from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

#This publishes port 80 inside the container to port 8080 on our machine.
#nginx listens on port 80 by default
EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]

