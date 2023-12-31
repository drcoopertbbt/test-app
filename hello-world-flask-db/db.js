const { Client } = require("pg");

const host = process.env.DB_HOST || "postgresql";
const user = process.env.DB_USER || "developer";
const password = process.env.DB_PASSWORD || "test";
const database = "todo_list";
const client = new Client({ host, user, database, password });

module.exports = {
    connect,
    close,
    list,
    create,
    get,  // Include the get function in the export
}

async function connect() {
    try {
        await client.connect();
    } catch(error) {
        throw new Error("Could not connect to database:" + error);
    }

    await createSchema(client);
}

async function close() {
    await client.end(); // Ensure proper closure of the client
}

async function list() {
    const result = await client.query("SELECT * FROM todos");
    return result.rows;
}

async function create(task) {
    await client.query("INSERT INTO todos (task) VALUES ($1)", [task]);
}

async function get(id) {
    const result = await client.query("SELECT * FROM todos WHERE id = $1", [id]);
    return result.rows[0]; // Return the first row (the todo item) or undefined if not found
}

function createSchema() {
    return client.query(`
        CREATE TABLE IF NOT EXISTS todos (
            id serial PRIMARY KEY,
            task TEXT NOT NULL
        );
    `);
}
