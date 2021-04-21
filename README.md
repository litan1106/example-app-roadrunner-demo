## Build

```
docker build --rm -t example-app-roadrunner-demo:latest .
```

## Serve with Apache2

```
docker run --rm -it -p 8080:8080 example-app-roadrunner-demo:latest
```
## Open http://localhost:8080

## Serve with RoadRunner 2

```
docker run --rm -it -p 8000:8000 example-app-roadrunner-demo:latest sh -c "php artisan octane:start"
```

## Open http://localhost:8000