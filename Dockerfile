FROM nginxinc/nginx-unprivileged:stable-alpine
WORKDIR /usr/share/nginx/html
COPY container/nginx.conf /etc/nginx/conf.d/default.conf
COPY dist/ .
EXPOSE 8080/tcp
ENTRYPOINT ["nginx", "-g", "daemon off;"]
