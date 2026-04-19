import socket
import time

HOST = ''      # Écoute sur toutes les interfaces
PORT = 10020   # Le port sur lequel votre application envoie des données

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    print(f"Le serveur écoute sur le port {PORT}...")
    while True:
        conn, addr = s.accept()
        print(f"Connecté par {addr}")
        while True:
            data = conn.recv(1024)
            if not data:
                print("Le client a fermé la connexion.")
                break
            message_recu = data.decode()
            print(f"Données reçues : {message_recu}")

            # time.sleep(0.5)

            # Préparer la réponse
            timestamp = time.perf_counter()
            reponse = f"{timestamp} Message reçu : {message_recu}\r\n"
            # Envoyer la réponse au client
            conn.sendall(reponse.encode())
            # conn.send(bytearray([1, 2]))
