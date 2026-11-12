from flask import Flask, jsonify, request
from database_init import get_db_connection
from auth_utils import generate_password_hash, check_password_hash

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({"message": "Welcome to the staff Login System API!"})



@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    
    if not data or not data.get("username") or not data.get("password"):
        return jsonify({"error": "Missing username or password"}), 400
        
    username = data["username"]
    password = data["password"]
    
    conn = get_db_connection()
    cursor = conn.cursor()
    user = cursor.execute(
        "SELECT * FROM staff WHERE username = ?",
        (username,)
    ).fetchone()
    
    conn.close()
    
    if user is None:
        return jsonify({"error": "Invalid username or password"}), 401
        
    stored_password = user["password"]
    
    if check_password_hash(stored_password, password):
        return jsonify({"message": "Login successful!", "username": username}), 200
    else:
        return jsonify({"error": "Invalid username or password"}), 401

if __name__ == "__main__":
    app.run(port = 5001)
