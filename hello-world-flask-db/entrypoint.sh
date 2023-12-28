#!/bin/bash
# entrypoint.sh

# Wait for the Postgres database server to be ready.
function wait_for_db() {
  local db_host="$1"
  local db_port="$2"
  echo "Waiting for database at $db_host:$db_port to be ready..."
  while ! pg_isready -h "$db_host" -p "$db_port" -q; do
    echo "Database not ready. Waiting..."
    sleep 1
  done
}

# Initialize the database if necessary.
function initialize_db() {
  local db_host="$1"
  local db_user="$2"
  local db_password="$3"
  # Use the environment variable for the database name if it's set, otherwise default to 'todo_list'.
  local db_name="${DB_NAME:-todo_list}"

  export PGPASSWORD="$db_password"
  echo "Creating database '$db_name' if it doesn't exist..."
  psql -h "$db_host" -U "$db_user" -tc "SELECT 1 FROM pg_database WHERE datname = '$db_name'" | grep -q 1 || psql -h "$db_host" -U "$db_user" -c "CREATE DATABASE $db_name"

  echo "Granting privileges to user '$db_user' on database '$db_name'..."
  psql -h "$db_host" -U "$db_user" -d "$db_name" -c "GRANT ALL PRIVILEGES ON DATABASE \"$db_name\" TO $db_user"
}

# The host and port of the database server are obtained from the environment variables.
DB_HOST="${DB_HOST:-postgresql}"
DB_PORT="${DB_PORT:-5432}"

# Run the wait_for_db and initialize_db functions.
wait_for_db "$DB_HOST" "$DB_PORT"
initialize_db "$DB_HOST" "$DB_USER" "$DB_PASSWORD"

# Execute the CMD from the Dockerfile and pass in any arguments.
exec "$@"
