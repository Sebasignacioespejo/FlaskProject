from flask import Flask, render_template

app = Flask(__name__)

# Datos actualizados de jugadores
players = {
    "kennys": {"rating": 1.12, "kd_ratio": 1.20, "headshot_percentage": 31.2, "image": "kennys.png"},
    "s1mple": {"rating": 1.24, "kd_ratio": 1.33, "headshot_percentage": 41.5, "image": "s1mple.png"},
    "m0nesy": {"rating": 1.23, "kd_ratio": 1.31, "headshot_percentage": 39.4, "image": "m0nesy.png"},
    "zywoo": {"rating": 1.33, "kd_ratio": 1.39, "headshot_percentage": 41.3, "image": "zywoo.png"}
}

@app.route("/")
def home():
    return render_template("index.html", players=players)

if __name__ == "__main__":
    app.run(debug=True)
