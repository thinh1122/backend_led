# Sử dụng JDK 17
FROM eclipse-temurin:17-jdk
# Tạo thư mục app
WORKDIR /app
# Copy file jar đã build vào container (Sẽ build ở bước sau)
COPY target/*.jar app.jar
# Chạy ứng dụng
ENTRYPOINT ["java", "-jar", "app.jar"]
