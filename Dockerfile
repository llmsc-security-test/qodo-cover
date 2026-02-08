# Dockerfile to build installer for Cover Agent
FROM python:3.12-bookworm

# ---- Install system build tools needed by make/poetry ----
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git && \
    rm -rf /var/lib/apt/lists/*

# ---- Install Poetry (used for dependency management) ----
RUN pip install --no-cache-dir poetry

# Make Python output unbuffered (helps with logging in containers)
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Copy the entire project into the image
COPY . .

# Run project‑specific setup and install Python dependencies
RUN make setup-installer && \
    poetry install --no-root --no-interaction --no-ansi

# ---- Auto‑Generated Entrypoint Configuration ----
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    mkdir -p /var/log && touch /var/log/app.log

EXPOSE 8000

# Keep the original entrypoint as required
ENTRYPOINT ["/entrypoint.sh"]