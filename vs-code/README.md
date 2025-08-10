# Code-Server Environment Variables

This project uses a `.env` file to configure the `docker-compose.yml` for running [code-server](https://github.com/coder/code-server) in Docker.

## 📄 `.env` File Structure

Create a `.env` file in the same directory as your `docker-compose.yml` with the following variables:

```env
# Password used to log in to code-server (required)
PASSWORD=YourStrongPasswordHere

# UID and GID of the user that will own the files inside the container
# Run `id -u` and `id -g` on the host machine to get these values.
UID=1000
GID=1000
