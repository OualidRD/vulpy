# Dockerfile - Vulpy Application
# Based on Listing 1: Vulpy Application Container
FROM python:3.11-slim

# DS002: Create non-root user for security
RUN useradd -m -u 1000 vulpy && \
    mkdir -p /app && \
    chown -R vulpy:vulpy /app

# Set working directory
WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY bad/ ./bad/
COPY good/ ./good/
COPY utils/ ./utils/
COPY README.rst LICENSE ./

# DS013: Use WORKDIR instead of RUN cd
WORKDIR /app/bad
RUN python db_init.py

# DS026: Add HEALTHCHECK for monitoring
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5000/hello', timeout=5)" || exit 1

# Expose port
EXPOSE 5000

# DS002: Run as non-root user
USER vulpy

# Run the application
CMD ["python", "/app/bad/vulpy.py"]
