from flask import Flask
import psycopg2

app = Flask(__name__)

# Database configuration
db_config = {
    'user': 'developer',
    'password': 'developer',
    'host': 'postgresql',  # Use the service name as the host
    'port': '5432',
    'database': 'sampledb'
}

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

@app.route("/create_table")
def create_table():
    try:
        print("Connecting to the database.")
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_config)
        cur = conn.cursor()
        print("Connected to the database.")

        # Create a table called 'test_table' with a single column 'id'
        print("Creating table 'test_table'.")
        cur.execute('CREATE TABLE IF NOT EXISTS test_table (id SERIAL PRIMARY KEY);')
        conn.commit()  # Commit changes to the database
        print("Table 'test_table' created successfully.")

        # Close the connection
        cur.close()
        conn.close()
        print("Closed the database connection.")

        return "<p>Table 'test_table' created successfully!</p>"
    except Exception as e:
        print(f"An error occurred: {e}")
        return f"<p>An error occurred: {e}</p>"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
