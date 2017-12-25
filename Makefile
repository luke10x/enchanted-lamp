user-list:
	docker run -it --rm \
		--volumes-from enchantedlamp_wordpress_1 \
		--network container:enchantedlamp_wordpress_1 \
		wordpress:cli user list

mysql-dump:
	docker exec enchantedlamp_mysql_1 \
	sh -c \
	'exec mysqldump --all-databases -uroot -p"$$MYSQL_ROOT_PASSWORD"' \
	> backup/$(shell date  +'%Y%m%d_%H%M%S').sql

shell-nginx:
	docker exec -it enchantedlamp_nginx_1 bash

shell-wordpress:
	docker exec -it enchantedlamp_wordpress_1 bash

process-map-wordpress:
	@tools/process-map.sh enchantedlamp_wordpress_1

