# Use Python 3.9 slim image as the base
FROM python:3.9-slim

# Install debugpy
RUN pip install debugpy

# Set working directory
WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install dependencies
RUN pip install -r requirements.txt

# Copy the rest of the application
# COPY . .

# Expose ports
EXPOSE 5000
EXPOSE 5678

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=app.py
ENV FLASK_ENV=development

# Command to run the application with debugging enabled
CMD ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "--wait-for-client", "-m", "flask", "run", "--host", "0.0.0.0", "--port", "5000"]
