import subprocess
import sys
import time


def init_staff_db():
  print("Initializing staff database...")
  try:
    subprocess.run([sys.executable, "staff_database_init.py"], check=True)
    print("Staff database initialized successfully.")
  except subprocess.CalledProcessError:
    print("Error initializing the staff database. Exiting.")
    sys.exit(1)


def start_staff_login_server():
  print("Starting staff login server...")
  return subprocess.Popen([sys.executable, "staff_login_server.py"])


def start_backend():
  print("Initializing database...")
  try:
    subprocess.run([sys.executable, "database_init.py"], check=True)
    print("Database initialized successfully.")
  except subprocess.CalledProcessError:
    print("Error initializing the database. Exiting.")
    sys.exit(1)

  init_staff_db()

  print("Starting backend servers...")

  login_server_process = subprocess.Popen([sys.executable, "login_server.py"])
  staff_login_server_process = start_staff_login_server()
  voiceauth_server_process = subprocess.Popen(
      [sys.executable, "voiceauth_stt_api.py"]
  )

  print("Servers are running. Press Ctrl+C to stop.")

  try:
    while True:
      time.sleep(1)
  except KeyboardInterrupt:
    print("\nStopping servers...")
    login_server_process.terminate()
    staff_login_server_process.terminate()
    voiceauth_server_process.terminate()

    login_server_process.wait()
    staff_login_server_process.wait()
    voiceauth_server_process.wait()
    print("Backend servers stopped safely.")


if __name__ == "__main__":
  start_backend()
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
