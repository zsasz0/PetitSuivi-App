FROM ghcr.io/cirruslabs/flutter:3.38.4 AS builder
WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

ARG API_BASE_URL=http://localhost:8000
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
