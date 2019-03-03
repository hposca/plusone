# Running

```bash
make up
# Wait a while for the services to start
# Check that we are accepting connections
curl http://localhost:5000/
```

To run a simple validation that all the steps are working:

```bash
make local_integration_test
```

Deep look into database:

```bash
make shell
mysql -h mysql -u root -ppassword
show databases;
use plusone;
show tables;
select * from users;
```
