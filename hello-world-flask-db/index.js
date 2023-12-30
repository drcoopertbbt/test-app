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


api.get("/todos/:id", async function (request, reply) {
  const id = request.params.id;
  const todo = await DB.get(id); // Implement the 'get' method in your DB module
  if (todo) {
      return todo;
  } else {
      reply.code(404).send({ message: "Todo not found" });
  }
});


api.addHook("onClose", async () => {
    await DB.close();
});


async function serve() {
  try {
    await DB.connect();
    await api.listen(process.env.PORT || 3000, '0.0.0.0');
  } catch (error) {
    console.error('Failed to start the server or connect to the database', error);
    process.exit(1);
  }
}

// In your DB module
async function get(id) {
  const result = await client.query("SELECT * FROM todos WHERE id = $1", [id]);
  return result.rows[0];
}



serve();
