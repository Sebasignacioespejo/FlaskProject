from app import db, Player  # Importar el objeto db de tu aplicación

def seed_players():
    # Crear una lista con los jugadores
    players = [
        (1, "kennyS", 1.12, 1.20, 31.2, "kennyS.png"),
        (2, "s1mple", 1.24, 1.33, 41.5, "s1mple.png"),
        (3, "m0nesy", 1.23, 1.31, 39.4, "m0nesy.png"),
        (4, "zywoo", 1.33, 1.39, 41.3, "zywoo.png")
    ]
    
    # Iterar sobre los jugadores e insertarlos en la base de datos
    for player_data in players:
        player = Player(
            id=player_data[0],
            player_name=player_data[1],
            rating=player_data[2],
            kd_ratio=player_data[3],
            headshot_percentage=player_data[4],
            image=player_data[5]
        )
        db.session.add(player)
    
    # Guardar los cambios en la base de datos
    db.session.commit()

if __name__ == '__main__':
    seed_players()
    print("Seeder ejecutado con éxito")
