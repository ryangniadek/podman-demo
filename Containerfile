# Set the base image to the UBI 9 Python 3.11 image provided by Red Hat
FROM registry.access.redhat.com/ubi9/python-311:1-41
# Set working directory inside the container to /app
WORKDIR /app
# Copy the requirements.txt file from the local host to the container's /app directory
COPY ./application/requirements.txt /app
# Install the Python dependencies from the requirements.txt file
RUN pip install -r requirements.txt
# Copy the application files from the local host to the container's /app directory
COPY ./application /app
# Expose port 5000
EXPOSE 5000
# Set the default command for the container to flask run
CMD flask run --host=0.0.0.0
