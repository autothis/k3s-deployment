# Use a base image with the desired OS and Postfix pre-installed
FROM debian:latest

# Install OpenNTP  and other necessary packages
RUN apt-get update && apt-get install -y openntpd

RUN mkdir -p /var/lib/openntpd/db /var/run/openntpd

# Expose the NTP port (default: 123UDP)
EXPOSE 123/UDP

# Set the default command to start openntpd
CMD ["openntpd", "-d"]
