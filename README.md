# Running

```bash
docker-compose up web
```

```bash
curl http://localhost:5000/
```

```bash
curl -X POST -d email=hello@world.com&password=asecretpassword http://localhost:5000/registration
curl -X POST -d email=hello@world.com&password=asecretpassword http://localhost:5000/login
```

Deep look into database:

```bash
docker-compose run web /bin/sh
mysql -h mysql -u root -ppassword
show databases;
use plusone;
show tables;
```
