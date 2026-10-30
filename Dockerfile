# Small official Python base image
FROM python:3.11-slim

# Work inside /app in the container
WORKDIR /app

# Copy only the application file (tests are not needed at runtime)
COPY main.py .

# Command that runs when the container starts
CMD ["python", "main.py"]
