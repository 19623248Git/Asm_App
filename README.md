Build image: 
```
docker build -t asm-app .
```

Run Container:
```
docker run -d --name asm-container -p 8080:8080 asm-app
```

Run Docker Compose:
```
docker-compose up -d --build
```