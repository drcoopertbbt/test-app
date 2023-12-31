#!/bin/bash
# entrypoint.sh

# Print all environment variables for debugging
echo "Printing all environment variables..."
printenv

# Wait for the Postgres database server to be ready.
function wait_for_db() {
  local db_host="$1"
  local db_port="$2"
  echo "Using database host: $db_host"
  echo "Using database port: $db_port"
  echo "Waiting for database at $db_host:$db_port to be ready..."
  while ! pg_isready -h "$db_host" -p "$db_port" -q; do
    echo "Database not ready. Waiting..."
    sleep 1
  done
  echo "Database is ready David."
}

# Initialize the database if necessary.
function initialize_db() {
  local db_host="$1"
  local db_user="$2"
  local db_password="$3"
  local db_name="${DB_NAME:-todo_list}"

  echo "Initializing database '$db_name' with user '$db_user'"
  echo "Using password: $db_password (Note: actual password not printed for security reasons)"
  echo "Using host: $db_host"

  export PGPASSWORD="$db_password"
  echo "Creating database '$db_name' if it doesn't exist..."
  psql -h "$db_host" -U "$db_user" -d "postgres" -tc "SELECT 1 FROM pg_database WHERE datname = '$db_name'" | grep -q 1 || psql -h "$db_host" -U "$db_user" -d "postgres" -c "CREATE DATABASE \"$db_name\""

  echo "Granting privileges to user '$db_user' on database '$db_name'..."
  psql -h "$db_host" -U "$db_user" -d "$db_name" -c "GRANT ALL PRIVILEGES ON DATABASE \"$db_name\" TO \"$db_user\""
}

# Create the database schema if necessary.
function create_schema() {
  local db_host="$1"
  local db_user="$2"
  local db_password="$3"
  local db_name="${DB_NAME:-todo_list}"

  echo "Creating schema in database '$db_name' with user '$db_user'"
  echo "Using host: $db_host"

  export PGPASSWORD="$db_password"

  # SQL to create the 'tasks' table
  echo "Creating schema for database '$db_name'..."
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

echo "Using final DB_HOST: $DB_HOST"
echo "Using final DB_PORT: $DB_PORT"
echo "Using final DB_USER: $DB_USER"
echo "Using final DB_PASSWORD: $DB_PASSWORD (Note: actual password not printed for security reasons)"
echo "Using final DB_NAME: $DB_NAME"

# Run the wait_for_db, initialize_db, and create_schema functions.
wait_for_db "$DB_HOST" "$DB_PORT"
initialize_db "$DB_HOST" "$DB_USER" "$DB_PASSWORD"
create_schema "$DB_HOST" "$DB_USER" "$DB_PASSWORD"

# Execute the CMD from the Dockerfile and pass in any arguments.
exec "$@"
