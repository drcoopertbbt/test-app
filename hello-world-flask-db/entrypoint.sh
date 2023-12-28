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
  local db_name="${DB_NAME:-todo_list}"

  export PGPASSWORD="$db_password"
  echo "Creating database '$db_name' if it doesn't exist..."
  psql -h "$db_host" -U "$db_user" -tc "SELECT 1 FROM pg_database WHERE datname = '$db_name'" | grep -q 1 || psql -h "$db_host" -U "$db_user" -c "CREATE DATABASE \"$db_name\""

  echo "Granting privileges to user '$db_user' on database '$db_name'..."
  psql -h "$db_host" -U "$db_user" -d "$db_name" -c "GRANT ALL PRIVILEGES ON DATABASE \"$db_name\" TO \"$db_user\""
}

# Create the database schema if necessary.
function create_schema() {
  local db_host="$1"
  local db_user="$2"
  local db_password="$3"
  local db_name="${DB_NAME:-todo_list}"

  export PGPASSWORD="$db_password"

  # SQL to create the 'tasks' table
  psql -h "$db_host" -U "$db_user" -d "$db_name" <<-EOSQL
    CREATE TABLE IF NOT EXISTS tasks (
      id SERIAL PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      is_completed BOOLEAN NOT NULL DEFAULT FALSE
    );
EOSQL
  echo "Schema created successfully."
}

# The host and port of the database server are provided from environment variables.
DB_HOST="${DB_HOST:-postgresql}"
DB_PORT="${DB_PORT:-5432}"

# Run the wait_for_db, initialize_db, and create_schema functions.
wait_for_db "$DB_HOST" "$DB_PORT"
initialize_db "$DB_HOST" "$DB_USER" "$DB_PASSWORD"
create_schema "$DB_HOST" "$DB_USER" "$DB_PASSWORD"

# Execute the CMD from the Dockerfile and pass in any arguments.
exec "$@"
