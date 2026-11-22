from flask import Flask, jsonify, request
from flask_cors import CORS
from database_init import get_db_connection
from auth_utils import generate_password_hash, check_password_hash

app = Flask(__name__)
CORS(app)


@app.route("/")
def home():
    return jsonify({"message": "Welcome to the staff Login System API!"})

@app.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    
    required_fields = ["username", "password", "first_name", "last_name", "email"]
    if not data or not all(data.get(field) for field in required_fields):
        return jsonify({"error": "Missing required fields (username, password, first_name, last_name, email)"}), 400
    
    username = data["username"] 
    password = data["password"]  
    first_name = data["first_name"]   
    last_name = data["last_name"]  
    email = data["email"]  
    hashed_password = generate_password_hash(password)    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute(
            """INSERT INTO staff (username, first_name, last_name, email, password) 
               VALUES (?, ?, ?, ?, ?)""",
            (username, first_name, last_name, email, hashed_password)
        )
        conn.commit()
    except Exception as e:
        return jsonify({"error": "Username or email already exists, or database error."}), 400
    finally:
        conn.close()
        
    return jsonify({"message": f"Staff member '{username}' registered successfully!"}), 201
    

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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
