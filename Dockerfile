
# Start from a Python base image
FROM python:3.9-slim

# Set working directory in the container
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Install dependencies
# Copy requirements file first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code to the container
COPY . .

# Expose the port Flask will run on
EXPOSE 5000

# Command to run the application
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]