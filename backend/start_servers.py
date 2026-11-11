import subprocess
import sys
import time

def start_backend():
    print("Initializing database...")
    try:
        subprocess.run([sys.executable, "database_init.py"], check=True)
        print("Database initialized successfully.")
    except subprocess.CalledProcessError:
        print("Error initializing the database. Exiting.")
        sys.exit(1)

    print("Starting backend servers...")
    
    login_server_process = subprocess.Popen([sys.executable, "login_server.py"])
    voiceauth_server_process = subprocess.Popen([sys.executable, "voiceauth_stt_api.py"])
    
    print("Servers are running. Press Ctrl+C to stop.")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nStopping servers...")
        login_server_process.terminate()
        voiceauth_server_process.terminate()
        
        login_server_process.wait()
        voiceauth_server_process.wait()
        print("Backend servers stopped safely.")

if __name__ == "__main__":
    start_backend()
