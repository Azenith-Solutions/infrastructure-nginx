FROM nginx:alpine 

COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/

RUN mkdir -p /var/log/nginx

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]