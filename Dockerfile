FROM cirrusci/flutter:stable

# Install dependencies for building Windows apps
RUN apt-get update && apt-get install -y mingw-w64

# Set up Flutter environment
RUN flutter config --enable-windows-desktop
WORKDIR /app

# Add Flutter to the PATH
ENV PATH="/flutter/bin:$PATH"

# Run flutter doctor to set up dependencies
RUN flutter doctor --android-licenses
RUN flutter doctor
