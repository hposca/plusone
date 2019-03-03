# Running

```bash
docker-compose up web
```

```bash
curl http://localhost:5000/
```

Excute this script for a simple validation that all the steps are working:

```bash
./simple_validation.sh
```

Deep look into database:

```bash
docker-compose run web /bin/sh
mysql -h mysql -u root -ppassword
show databases;
use plusone;
show tables;
select * from users;
```
