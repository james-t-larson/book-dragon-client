# ==========================================
# Stage 1: Build the Flutter Web App
# ==========================================
FROM debian:bookworm-slim AS build-env

# Install dependencies for Flutter
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Clone the Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Run the build
RUN flutter doctor
RUN flutter build web --release

# ==========================================
# Stage 2: Serve with Nginx
# ==========================================
FROM nginx:alpine

# Copy the build output from the first stage
# Note: The output lives in /app/build/web in the builder stage
COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
