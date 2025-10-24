# Mudic 

**Built at [MLH AI Hackfest]**  
A mindful app that tunes into your mood and responds with personalized comfort using Gemini AI 

---

## Tech Stack

- **Frontend:** SwiftUI (iOS)
- **Backend:** Flask (Python)
- **AI Model:** Gemini (via Google Generative AI)
- **API Integration:** Ngrok for secure local API tunneling
- **Design Aesthetic:** Pastel-themed, playful, and emotional UI with mood-based color dynamics 

---

##  What is Mudic?

**Mudic** is your AI-powered emotional wellness companion that listens to your feelings and responds with personalized care.  
The name comes from **“Mood + Music”**, and the app adapts its look, voice, and content to how you're feeling.

Whether you're sad, angry, anxious, or just tired — Mudic holds space for you.

---

##  How It Works

### 1. **Mood Analysis**
The user enters how they’re feeling → Gemini AI processes the tone and returns:
- A precise **mood label** (e.g., “tired”, “angry”)
- A **motivational message** based on that mood
- A **pastel RGB color** for theming the UI

---

### 2. **Personalized Mood Pages**

Each mood unlocks a custom experience:

####  **Sad**
> Swipe through Gemini-generated *hilariously silly jokes* until your sadness gives up.

- Tinder-style card swiping
- Each swipe triggers a fresh AI joke
- Designed to surprise and amuse

####  **Angry**
> Vent freely, and let Gemini gently calm you down.

- Freeform text input
- Gemini responds with a soothing line
- Breathing animation and gentle UI to de-escalate stress

####  **Happy**
> Celebrate your joy with a magical, 13-word haiku written just for you.

- Gemini haiku generation based on your input
- Delightful display on a soft, cheerful interface

---

## API Endpoints (Flask)

| Endpoint         | Description                             |
|------------------|-----------------------------------------|
| `/api/analyze`   | Analyzes user input → returns mood, message & RGB |
| `/api/getHaiku`  | Generates a 13-word haiku               |
| `/api/vent`      | Responds gently to user vents           |
| `/api/joke` | Generates a silly joke for the sad page   |

---

##  UI Highlights

- **Dynamic Pastel Theme:** Mood-based color changes for UI background
- **Custom Animations:** Breathing circles, floating elements, and jiggly avatars
- **Minimalist & Emotional Design:** Every screen is created with the user’s emotional comfort in mind

---

##  Powered by Gemini

Gemini brings emotional intelligence to Mudic.  
Whether it’s a one-liner, a poetic haiku, or just a comforting word — each response is *unique, thoughtful, and alive*.

---

##  Why We Built Mudic

We noticed that even mood-tracking apps *ask too much* of users — especially when they’re already drained.  
Mudic flips the script. It listens, adapts, and lifts you up — one beautifully tailored moment at a time.

Built with care.  
For everyone who just needed to feel heard.

---

##  Setup Instructions (Dev)

1. **Clone the repo**
2. Start Flask backend (port 5001):
   ```bash
   python app.py
3. Run iOS app via Xcode (SwiftUI)
4. Use Ngrok to tunnel:
    ```bash
    ngrok http 5001

 Team: 

Bhaskar Das 
