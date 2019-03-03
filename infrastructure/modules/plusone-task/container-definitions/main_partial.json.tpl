{
  "cpu": ${MAIN_CPU},
  "image": "${MAIN_IMAGE_REPO}:${MAIN_IMAGE_TAG}",
  "memory": ${MAIN_MEMORY},
  "name": "${TASK_NAME}",
  "networkMode": "awsvpc",
  "portMappings": [
    {
      "hostPort": ${HOST_PORT},
      "protocol": "tcp",
      "containerPort": ${CONTAINER_PORT}
    }
  ],
  "environment" : [
    { "name": "APP_ENVIRONMENT",   "value": "${APP_ENVIRONMENT  }" },
    { "name": "AWS_REGION",        "value": "${AWS_REGION       }" },
    { "name": "LOG_IDENTIFIER",    "value": "${LOG_IDENTIFIER   }" },
    { "name": "DATABASE_NAME",     "value": "${DATABASE_NAME    }" },
    { "name": "DATABASE_ADDRESS",  "value": "${DATABASE_ADDRESS }" },
    { "name": "DATABASE_PORT",     "value": "${DATABASE_PORT    }" },
    { "name": "DATABASE_USERNAME", "value": "${DATABASE_USERNAME}" },
    { "name": "DATABASE_PASSWORD", "value": "${DATABASE_PASSWORD}" }
  ],
  "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${CLOUDWATCH_LOG_GROUP}",
        "awslogs-region": "${AWS_REGION}",
        "awslogs-stream-prefix": "ecs"
      }
  },
  "mountPoints": [
    { "sourceVolume": "${LOG_VOLUME}", "containerPath": "${LOGS_DIRECTORY}" }
  ]
}
