# Dockerfile - Vulpy Application
# Based on Listing 1: Vulpy Application Container
FROM python:3.11-slim

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

# Initialize the database
RUN cd /app/bad && python db_init.py

# Expose port
EXPOSE 5000

# Run the application
CMD ["python", "/app/bad/vulpy.py"]
