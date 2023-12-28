from flask import Flask
import psycopg2

app = Flask(__name__)

# Configure the database connection here
db_config = {
    'user': 'developer',
    'password': 'developer',
    'host': 'postgresql',  # This is the service name in OpenShift
    'port': '5432',
    'database': 'sampledb'
}

@app.route("/")
def hello_world():
    # Connect to the PostgreSQL database
    conn = psycopg2.connect(**db_config)
    cur = conn.cursor()
    
    # Perform database operations
    cur.execute('SELECT version();')
    db_version = cur.fetchone()
    
    # Close connection
    cur.close()
    conn.close()
    
    return f"<p>Hello, World! Here is the PostgreSQL version: {db_version[0]}</p>"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
