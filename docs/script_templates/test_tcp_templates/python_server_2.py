import socket

HOST = ''      # Écoute sur toutes les interfaces
PORT = 10020   # Le port sur lequel votre application envoie des données

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    print(f"Le serveur écoute sur le port {PORT}...")
    conn, addr = s.accept()
    print(conn, addr)
    conn.send(bytearray(0))
    # conn.close()
