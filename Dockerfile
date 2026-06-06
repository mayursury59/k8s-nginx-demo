FROM nginx:stable-alpine

# Copy static website files into nginx html folder (optional)
# COPY ./html /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
