FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libarrow-dev \
    libparquet-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the requirements.txt file and app.py into the container at /app
COPY requirements.txt ./
COPY app.py ./

# Install Python dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Expose port for Streamlit
EXPOSE 8501
ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
