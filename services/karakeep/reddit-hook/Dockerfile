FROM python:3.13-alpine
WORKDIR /app
COPY hook.py .
ENV PYTHONUNBUFFERED=1
CMD ["python", "-u", "hook.py"]
