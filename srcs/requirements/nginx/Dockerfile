FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	nginx \
	openssl

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/generate_certs.sh /generate_certs.sh

RUN chmod +x /generate_certs.sh && /generate_certs.sh

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]