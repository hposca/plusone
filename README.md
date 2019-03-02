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
