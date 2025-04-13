from flask import Flask, request, jsonify
import os
from dotenv import load_dotenv
from google import genai

# Load environment variables
load_dotenv()

# Initialize Gemini client
api_key = os.getenv("GEMINI_API_KEY")
client = genai.Client(api_key=api_key)

# Create Flask app
app = Flask(__name__)

# Combined route to get mood, message, and color
@app.route('/api/analyze', methods=['POST'])
def analyze():
    data = request.json
    user_input = data.get('text', '')

    # Step 1: Get mood
    mood_response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=f"reply without any formatting only word answer. Based on the following text, determine the user's mood from the following categories: happy, sad, anxious, angry, tired, stressed. Only return the one of these mood words only whichever closest(if neutral return happy), nothing else: {user_input}"
    )
    mood = mood_response.text.strip()

    # Step 2: Get motivational message
    message_response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=f"reply like you're the app so talk directly to the user in 1 line. just one line respnse dont acknowledge what they say even if it addresses you directly no greetings or anything i want just only give the most approprate unique beautifully worded quote for the situation. also dont put an quotation marks. Based on the following text, provide a motivational message or fact related to the user's mood: {user_input}"
    )
    message = message_response.text.strip()

    # Step 3: Get RGB color suggestion
    color_response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=f"Based on the following mood, give RGB value (pastel shades only) in an array and do not do any formatting or reasoning only the answer in array: {mood}"
    )
    rgb = color_response.text.strip()

    return jsonify({
        'mood': mood,
        'message': message,
        'rgb': rgb
    })


#for happypage haiku genrator 
@app.route('/api/getHaiku', methods=['POST'])
def getHaiku():
    data = request.json
    user_input = data.get('text', '')
    
    message_response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=f"just a single respnse i dont want any options only : cretae a 13 word peom in the format of a  exactly based on this input. . do not say anything else just output the haiku only in beautiful language. it should mention the follwoing: {user_input}"
    )
    message = message_response.text.strip()

    return jsonify({
        
        'haiku': message,
       
    })


#for happypage haiku genrator 
@app.route('/api/vent', methods=['POST'])
def vent():
    data = request.json
    user_input = data.get('text', '')
    print("Received vent:", data)
    
    message_response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=f"im furious, in max 50 words guide me to calm down my anger : {user_input}"
    )
    message = message_response.text.strip()

    return jsonify({
        
        'message': message,
       
    })

@app.route('/api/joke', methods=['POST'])
def joke():
    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents="Give me a single silly super unique never heard before joke or pun that would make a sad person giggle. It should be original or feel delightfully random. Do not add any other text or explanation."
    )
    joke = response.text.strip()
    return jsonify({ "joke": joke })




# Run the app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)

