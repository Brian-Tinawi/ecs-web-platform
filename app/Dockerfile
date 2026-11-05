FROM public.ecr.aws/docker/library/python:3.12-slim
RUN useradd --system --uid 10001 appuser
ARG APP_VERSION=dev
ENV APP_VERSION=$APP_VERSION
WORKDIR /app
COPY app.py .
USER 10001
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request;urllib.request.urlopen('http://127.0.0.1:8080/health')"
CMD ["python", "app.py"]
