user-list:
	docker run -it --rm \
		--volumes-from enchantedlamp_wordpress_1 \
		--network container:enchantedlamp_wordpress_1 \
		wordpress:cli user list

wordpress-connected-to:
	sudo nsenter -t $$(docker inspect -f '{{.State.Pid}}' enchantedlamp_wordpress_1) -n netstat -nptu

wordpress-get-php-src:
	mkdir -p src
	docker exec enchantedlamp_wordpress_1 cat /usr/src/php.tar.xz | xz -dc | tar -C ./src -xvf - 

wordpress-reset-volume:
	docker-compose stop && \
	docker-compose rm && \
	docker volume rm $$(docker volume ls -q) && \
	docker-compose up -d --build

mysql-dump:
	docker exec enchantedlamp_mysql_1 \
	sh -c \
	'exec mysqldump --all-databases -uroot -p"$$MYSQL_ROOT_PASSWORD"' \
	> backup/$(shell date  +'%Y%m%d_%H%M%S').sql

shell-nginx:
	docker exec -it enchantedlamp_nginx_1 bash

shell-wordpress:
	docker exec -it enchantedlamp_wordpress_1 bash

shell-mysql:
	docker exec -it enchantedlamp_mysql_1 bash

mysql:
	docker exec -it enchantedlamp_mysql_1 \
	sh -c \
	'exec mysql -uroot -p"$$MYSQL_ROOT_PASSWORD" wordpress'

LOCK_SQL = 'UPDATE wp_posts SET post_content=\"Pending content...\" WHERE id=1'
mysql-lock-post:
	./tools/blockdb.exp

client-edit-post:
	@echo 'Point your VNC client to *:15900 (Password: "secret")'
	@echo Login and edit post 
	@docker-compose run \
		-v '$(PWD)/docker/client/scripts:/scripts' \
		client \
		php /scripts/edit-post.php 
	@echo Done

process-map-wordpress:
	@tools/process-map.sh enchantedlamp_wordpress_1

process-map-mysql:
	@tools/process-map.sh enchantedlamp_mysql_1

wordpress-dbg:
	docker build -t wordpress:fpm -f ./docker/wordpress/Dockerfile ./docker/wordpress
