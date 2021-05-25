## Build

```
docker build --rm -t litan1106/example-app-roadrunner-demo:latest .
```

## Serve with Apache2

```
docker run --rm -it -p 8080:8080 litan1106/example-app-roadrunner-demo:latest
```
## Open http://localhost:8080

## Serve with RoadRunner 2

```
docker run --rm -it -p 8000:8000 litan1106/example-app-roadrunner-demo:latest sh -c "php artisan octane:start --host=0.0.0.0 --port=8000 --rpc-port=6001"
```

## Open http://localhost:8000