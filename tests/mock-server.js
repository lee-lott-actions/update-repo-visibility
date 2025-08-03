const express = require('express');
const app = express();
app.use(express.json());

app.patch('/repos/:owner/:repo_name', (req, res) => {
  console.log('Mock intercepted: PATCH /repos/' + req.params.owner + '/' + req.params.repo_name);
  console.log('Request body:', JSON.stringify(req.body));
  
  if (req.body.visibility !== undefined) {
    res.status(200).json({ message: 'Repository created' });
  } else {
    res.status(422).json({ message: 'Repository creation failed' });
  }
});

app.listen(3000, () => {
  console.log('Mock server listening on http://127.0.0.1:3000...');
});
