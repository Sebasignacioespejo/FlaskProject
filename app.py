from flask import Flask, render_template
import psycopg2
import os

app = Flask(__name__)

# Configura los detalles de la conexión
db_config = {
    'host': os.environ.get('DB_HOST'),
    'dbname': os.environ.get('DB_NAME'),
    'user': os.environ.get('DB_USER'),
    'password': os.environ.get('DB_PASSWORD'),
}

# Conectar a la base de datos
def get_db_connection():
    conn = psycopg2.connect(**db_config)
    return conn

# Ruta principal
@app.route("/")
def home():
    conn = get_db_connection()  # Obtén la conexión a la base de datos
    cur = conn.cursor()  # Crea un cursor
    cur.execute("SELECT * FROM players")  # Ejecuta una consulta SQL para obtener todos los jugadores
    players_data = cur.fetchall()  # Obtiene todos los resultados de la consulta
    cur.close()  # Cierra el cursor
    conn.close()  # Cierra la conexión a la base de datos

    # Convierte los resultados a un formato más amigable para Jinja (por ejemplo, un diccionario)
    players = {}
    for player in players_data:
        player_name = player[1]  # Asumiendo que player_name está en la columna 1 (índice 0 es id)
        players[player_name] = {
            'rating': player[2],
            'kd_ratio': player[3],
            'headshot_percentage': player[4],
            'image': player[5]
        }

    return render_template("index.html", players=players)

if __name__ == "__main__":
   app.run(debug=True, host='0.0.0.0', port=5000)
