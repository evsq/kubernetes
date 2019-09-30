npm install express --save

docker build -t test-nodejs .

docker run --rm -p 3000:3000 test-nodejs
