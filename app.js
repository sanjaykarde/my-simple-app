const express = require('express');
const app = express();
const port = process.env.PORT || 80;

app.get('/', (req, res) => {
  res.send('Hello World from ECS Fargate!done');
});

app.listen(port, () => {
  console.log(`App running on port ${port}`);
});

