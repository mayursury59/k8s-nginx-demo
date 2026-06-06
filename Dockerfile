FROM nginx:stable-alpine

# Copy static website files into nginx html folder (optional)
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
