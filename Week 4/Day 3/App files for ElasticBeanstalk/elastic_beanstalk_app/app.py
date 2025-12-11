from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def home():
    version = os.getenv("APP_VERSION", "v2.0.0")
    return f"<h1>Hello from ElasticBeanstalk!</h1><p>Version: {version}</p>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)


