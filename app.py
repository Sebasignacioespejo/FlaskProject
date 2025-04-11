from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
import psycopg2
import os

app = Flask(__name__)

#Hello from Flask
# Configura la conexión
app.config['SQLALCHEMY_DATABASE_URI'] = f"postgresql://{os.environ.get('DB_USER')}:{os.environ.get('DB_PASSWORD')}@{os.environ.get('DB_HOST')}/{os.environ.get('DB_NAME')}"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Inicializa la DB y Migrate
db = SQLAlchemy(app)
migrate = Migrate(app, db)

# Crea el modelo de la tabla
class Player(db.Model):
    __tablename__ = 'players'

    id = db.Column(db.Integer, primary_key=True)
    player_name = db.Column(db.String(100), nullable=False)
    rating = db.Column(db.Float, nullable=False)
    kd_ratio = db.Column(db.Float, nullable=False)
    headshot_percentage = db.Column(db.Float, nullable=False)
    image = db.Column(db.Text, nullable=False)

    def __repr__(self):
        return f'<Player {self.player_name}>'

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
    conn = get_db_connection()  
    cur = conn.cursor()  
    cur.execute("SELECT * FROM players") 
    players_data = cur.fetchall() 
    cur.close() 
    conn.close() 

    # Convierte los resultados a un formato más amigable para Jinja (por ejemplo, un diccionario)
    players = {}
    for player in players_data:
        player_name = player[1]  
        players[player_name] = {
            'rating': player[2],
            'kd_ratio': player[3],
            'headshot_percentage': player[4],
            'image': player[5]
        }

    return render_template("index.html", players=players)

if __name__ == "__main__":
   app.run(debug=True, host='0.0.0.0', port=5000)
