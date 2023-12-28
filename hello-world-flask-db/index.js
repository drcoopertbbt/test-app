const Fastify = require("fastify");

const DB = require("./db");

const api = Fastify({ logger: true });


api.get("/", async () => {
    return { title: 'Todo List API' };
});


api.get("/todos", async function listTodos() {
    const todos = await DB.list();
    return todos;
});


api.post("/todos", async function createTodo(request, reply) {
    const task = request.body.task;
    await DB.create(task);
    return reply.code(201).send();
});


api.addHook("onClose", async () => {
    await DB.close();
});


async function serve() {
  try {
    await connectToDatabase(); // Replace with the actual function you use to connect
    // ... Rest of your server logic
  } catch (error) {
    console.error('Failed to connect to the database', error);
    // Handle the error appropriately, such as retrying connection or exiting the process
    process.exit(1); // Exit with a non-zero exit code to indicate failure
  }
}



serve();
