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

# Deploying

```bash
make infra-plan
make infra-create
# Answer all the 'Are you sure?' questions that terraform will ask
```

This will publish the docker image into the right ECR.

```bash
# Change for your real AWS Account ID
AWS_ACCOUNT=123456789012 make publish
```

Testing that everything is working on AWS:

```bash
export LOAD_BALANCER=$(cd infrastructure/ && ./all_outputs.sh 2>/dev/null | grep alb_dns_name | awk -F' = ' '{ print $2}')
./remote_validation.sh
```

If you want to live-follow log messages (stored on AWS CloudWatch), you can use [saw](https://github.com/TylerBrock/saw):

```bash
saw watch /ecs/plusone/plusone-task1
```

Small stress test:

```bash
export LOAD_BALANCER=$(cd infrastructure/ && ./all_outputs.sh 2>/dev/null | grep alb_dns_name | awk -F' = ' '{ print $2}')
./stress_test.sh
```

# Finalizing

After all the tests and validations one can destroy the spun up infrastructure:

```bash
make infra-destroy
# Answer the 'Are you sure?' question that terraform will ask
```
