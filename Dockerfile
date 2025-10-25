FROM nginx:alpine 

RUN mkdir -p /var/log/nginx

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]