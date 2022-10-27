import express from 'express';
import { json } from 'body-parser';
import axios from 'axios';

const PORT = process.env.PORT || 3000;
const APPLICATION_LOAD_BALANCER = process.env.APPLICATION_LOAD_BALANCER;

const app = express();
app.use(json());

app.get("/", async (req, res) => {
  axios
    .get("http://169.254.169.254/latest/meta-data/hostname", {
      headers: { "Content-Type": "text/plain" },
    })
    .then((response) => {
      const hostname = response.data;
      res.send(`Hello from ${hostname}`);
    })
    .catch((error) => {
      res.send(`Connection timeout!`);
    });
});

app.get("/init", async (req, res) => {
  axios
    .get(`http://${APPLICATION_LOAD_BALANCER}/init`)
    .then((response) => {
      const data = response.data;
      res.send(data);
    })
    .catch((error) => {
      res.send(`Connection timeout!`);
    });
});

app.get("/users", async (req, res) => {
  axios
    .get(`http://${APPLICATION_LOAD_BALANCER}/users`)
    .then((response) => {
      const data = response.data;
      res.send(data);
    })
    .catch((error) => {
      res.send(`Connection timeout!`);
    });
});
  
// Custom 404 route not found handler
app.use((req, res) => {
  res.status(404).send("404 not found");
});

app.listen(PORT, () => {
  console.log(`Listening on PORT ${PORT}`);
});