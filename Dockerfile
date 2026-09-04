FROM python:3.11-slim

# Set work directory
WORKDIR /app

# Set environment variables to optimize Python performance in containers
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PORT 8080

# Copy requirements file first to leverage Docker layer caching
COPY requirements.txt .

# Install dependencies, gunicorn, and create a non-root user for security
RUN pip install --no-cache-dir -r requirements.txt gunicorn && \
    useradd -m appuser

# Copy the rest of the application code
COPY . .
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 8080

# Healthcheck using native python to keep the image slim (avoids installing curl)
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/products')" || exit 1

# 'app:app' assumes the Flask instance is named 'app' in 'app.py'
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]