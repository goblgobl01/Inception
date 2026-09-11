FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	nginx \
	openssl

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY --chmod=755 tools/script.sh /
RUN ./script.sh

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]