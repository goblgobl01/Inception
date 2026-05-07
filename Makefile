COMPOSE = docker compose -f srcs/docker-compose.yml

all:
	mkdir -p /home/mmaarafi/data/db
	mkdir -p /home/mmaarafi/data/wordpress
	$(COMPOSE) up --build -d

down:
	$(COMPOSE) down

re: down all

clean:
	$(COMPOSE) down -v --rmi all

fclean: clean
	rm -rf /home/mmaarafi/data/db
	rm -rf /home/mmaarafi/data/wordpress

.PHONY: all down re clean fclean