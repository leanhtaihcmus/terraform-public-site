import express from 'express';
import { json } from 'body-parser';
import axios from 'axios';

const PORT = process.env.PORT || 3000;
const APPLICATION_LOAD_BALANCER = process.env.APPLICATION_LOAD_BALANCER;

const app = express();
app.use(json());

app.get('/', async (req, res) => {
    axios.get('http://169.254.169.254/latest/meta-data/hostname').then(async (response) => {
        const hostname = await response.data;
        res.send(`Hello from ${hostname}`);
    });
});