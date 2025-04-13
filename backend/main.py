import os
from dotenv import load_dotenv
from google import genai

# Load environment variables
load_dotenv()

# Get the API key from environment
api_key = os.getenv("GEMINI_API_KEY")
client = genai.Client(api_key=api_key)

# Function to get mood based on user input
def get_mood(user_input):
    response = client.models.generate_content(
        model="gemini-2.0-flash", 
        contents=f"reply lwithout any formatting only word answer. Based on the following text, determine the user's mood from the follwoing categhries. : happy, sad, anxious, angry, tired, stressed, please only the answer mood no other word atall: {user_input}"
    )
    return response.text.strip()

# Function to get a motivational message based on mood
def get_message(user_input):
    response = client.models.generate_content(
        model="gemini-2.0-flash", 
        contents=f"reply like youre the app so talk directly to the user in 1 line. Based on the following text, provide a motivational message or fact related to the user's mood: {user_input}"
    )
    return response.text.strip()

# Function to get UI suggestions based on mood
def get_ui_design(user_input):
    response = client.models.generate_content(
        model="gemini-2.0-flash", 
        contents=f"Based on the following text, give rgb value in an array and do not do any formatting or reasong only the asnwer in array please nothign else atall that reflect the user's mood: {get_mood(user_input)}"
    )
    return response.text.strip()

# Main function to run the logic
def main():
    user_input = input("Enter your text: ")

    # Get mood, message, and UI design suggestions
    mood = get_mood(user_input)
    message = get_message(user_input)
    ui_design = get_ui_design(user_input)

    # Print the results
    print("\nMood:", mood)
    print("\nMotivational Message:", message)
    print("\nUI Design Suggestions:", ui_design)

if __name__ == "__main__":
    main()
