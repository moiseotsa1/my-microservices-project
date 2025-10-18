FROM postgres:13-alpine
COPY init/ /docker-entrypoint-initdb.d/
EXPOSE 5432
CMD ["postgres"]
