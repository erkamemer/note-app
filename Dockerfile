FROM nginx:alpine

COPY index.html /usr/share/nginx/html/index.html

# -g global ayarlar için, deamon off nginx in arka planda değil ön planda çalışmasını sağlar yoksa cantainer kapanır.
CMD ["nginx", "-g", "daemon off;"]