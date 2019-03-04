
<!-- vim-markdown-toc GFM -->

* [Running locally](#running-locally)
* [Deploying on AWS](#deploying-on-aws)
    * [Architecture](#architecture)
    * [Deploying](#deploying)
* [Finalizing](#finalizing)
* [Future](#future)
    * [Monitoring](#monitoring)
    * [High Availability](#high-availability)

<!-- vim-markdown-toc -->

# Running locally

- To run the application locally we can simply execute:

```bash
make up
```

- Wait a while for the services to start. After they are up and running check that we are accepting connections:

```bash
curl http://localhost:5000/
```

- To run a simple validation that all the routes are working as expected we can run:

```bash
make local_integration_test
```

- If one needs to debug and take a deep look into the database:

```bash
make shell
mysql -h mysql -u root -ppassword
show databases;
use plusone;
show tables;
select * from users;
```

# Deploying on AWS

## Architecture

On AWS we have, on a high level point of view, the following architecture:

```
                             +-------------+
                        +--->| ECS Service |----+
                        |    +-------------+    |
         \    +-----+   |          .        \   |     +--------------+
Requests  --->| ALB |---+          .         +--+---->| RDS Database |
         /    +-----+   |          .        /   |     +--------------+
                        |    +-------------+    |
                        +--->| ECS Service |----+
                             +-------------+
```

Requests come, from the internet, and hit the Application Load Balancer which
is responsible for distributing the connections to the ECS services that are
running. Those services access and store all the required information on the
RDS Database.

## Deploying

- To deploy our code into AWS the first step is to create all the required resources:

```bash
make infra-plan
make infra-create
# Answer the 'Are you sure?' question that terraform will ask
```

This whole process may take a while as some resources, specially the database, take a reasonable amount of time to be created.

If you wait for the whole creation process to finish and try to test the application, it will fail. Basically because there is no application to run.
As we are running this application from a docker image, we need to publish this image into AWS ECR for it to be pulled into ECS.

- Take note of your AWS Account Number and use it on the command below:

```bash
# Change for your real AWS Account ID
AWS_ACCOUNT=123456789012 make publish
```

After the image publication it will take a while for the ECS service to pull it. Keep monitoring on the ECS Console.

**NOTE:** You can run the previous command as soon as the ECR Repository is created. There is no need to wait for the whole process.

- After everything is green we can test that everything is working on AWS:

```bash
export LOAD_BALANCER=$(cd infrastructure/ && ./all_outputs.sh 2>/dev/null | grep alb_dns_name | awk -F' = ' '{ print $2}')
scripts/remote_validation.sh
```

- If you want to live-follow log messages (they are stored on AWS CloudWatch), you can use [saw](https://github.com/TylerBrock/saw):

```bash
saw watch /ecs/plusone/plusone-task1
```

- There is also a very small stress test:

```bash
export LOAD_BALANCER=$(cd infrastructure/ && ./all_outputs.sh 2>/dev/null | grep alb_dns_name | awk -F' = ' '{ print $2}')
scripts/stress_test.sh
```

# Finalizing

After all the tests and validations one can destroy the spun up infrastructure:

```bash
make infra-destroy
# Answer the 'Are you sure?' question that terraform will ask
```

# Future

## Monitoring

Currently, monitoring is very basic. We can only follow the log messages that are sent to AWS CloudWatch (default, and required, behaviour on AWS ECS).

To improve this situation a first step would be to integrate our application with [AWS Elasticsearch Service](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-gsg.html). With it, we can send all our logs to Elasticsearch and visualize them on [Kibana](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-kibana.html). This will not provide us with APMs but is an interesting first step to analyze and understand the application behaviour.

Later on, we can integrate our application with a vendor like [Datadog](https://www.datadoghq.com/), which provides APMs and also log management. Given the dashboard capabilities of datadog we can have a panoramic understanding of our application and also a deep one as we can even analyze the database queries that are being executed by our application.
We could also integrate with [New Relic](https://newrelic.com/) but, currently, it only offers APMs, not log management.

As our application is a web facing one, we could use [Pingdom](https://www.pingdom.com/) to check if our application is accessible to the world.

And, to alert us that something is not working as expected, we could use a tool like [PagerDuty](https://www.pagerduty.com/). With its integrations with the APM platforms we can have smart alerts that can be triggered only when necessary.

## High Availability

Currently we have some very simple rules that scale our application according to a schedule. This is a very simple strategy that is good, but not enough, if we know the times our application are more used.

AWS provides simple measures, like CPU and memory, that trigger autoscaling rules. As our application may require communication with other applications and services, these simple measures doesn't reflect the time to answer to the end user (We may have 20% CPU usage but our response time to the user is above 500 ms).

One strategy that can be used to improve the autoscaling capabilities is to create some Lambda functions, that are executed periodically, which verify real business indicators and then execute autoscaling. As an example, for batch processes this could be the size of a queue of jobs divided by the number of jobs being executed now. If this number is above a threshold we add more workers, if it is below other threshold we remove workers.

Similarly, we can use the APM monitors and their integrations to instead of simply sending an alert to a human, invoke a lambda function that would then execute autoscaling tasks. As an example, we could set an alert that if the responses to our users are above a threshold we should trigger a lambda function that will add more web facing applications.
