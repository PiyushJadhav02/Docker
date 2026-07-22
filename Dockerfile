FROM eclipse-temurin:21-jre AS build

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8080

RUN java -jar app.jar > output.txt

RUN printf '<html>\n<head><title>Java App</title></head>\n<body>\n<h1>\n' > index.html && \
    cat output.txt >> index.html && \
    printf '\n</h1>\n</body>\n</html>\n' >> index.html

FROM nginx:latest

COPY --from=build /app/index.html /usr/share/html/index.html

EXPOSE 8080
