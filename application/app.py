from flask import Flask

app = Flask(__name__)


@app.route('/<name>')
def hello(name):
    return {'msg': f'Hello, {name}!'}


@app.route('/')
def root():
    return hello('Shadowman')
