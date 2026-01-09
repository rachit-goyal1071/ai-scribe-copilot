# AI Scribe Copilot – Medical Transcription App

AI Scribe Copilot is a Flutter-based real-time medical transcription system built for the Attack Capital Mobile Engineering Challenge.  
It includes continuous audio streaming, chunked uploads, patient/session management, template-powered summaries, and native microphone handling for both Android and iOS.

---

## 🚀 1. Download & Demo Links

### 📱 Android APK
https://github.com/rachit-goyal1071/ai-scribe-copilot/releases/download/android/app-release.apk

### 🍎 iOS Demonstration Video
https://youtube.com/shorts/A9XY51wK8F4?feature=share

### 🤖 Android Demonstration Video
https://youtube.com/shorts/0dddxena1jg?feature=share

### 📚 API Documentation
https://docs.google.com/document/d/1hzfry0fg7qQQb39cswEychYMtBiBKDAqIg6LamAKENI/edit?usp=sharing

### 🔧 Postman API Collection
https://drive.google.com/file/d/1rnEjRzH64ESlIi5VQekG525Dsf8IQZTP/view?usp=sharing

### 🌐 Backend Deployment URL
http://142.93.213.55:8000  
Swagger Docs → http://142.93.213.55:8000/docs

---

## 🛠 2. Tech Stack

### **Frontend (Flutter)**
- Flutter 3.38.3 (stable)
- Dart 3.10.1
- BLoC State Management
- Native Audio Recorder (Android & iOS)
- Real-time waveform stream
- Background-safe chunking system
- Hive local DB for chunk queue
- Dio networking + retry logic

### **Backend**
- FastAPI (Python)
- PostgreSQL
- MinIO (S3 storage)
- Presigned URL upload flow
- Session & patient management
- Background transcription + summarization

---

## 📦 3. Flutter Version Used

Flutter 3.38.3 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 19074d12f7 (2 weeks ago) • 2025-11-20 17:53:13 -0500
Engine • hash 8bf2090718fea3655f466049a757f823898f0ad1 (revision 13e658725d) (13 days ago) • 2025-11-20 20:19:23.000Z
Tools • Dart 3.10.1 • DevTools 2.51.1


---

## 🏥 4. Core App Features

### 👤 **Patient Management**
- Create patient  
- List patient records  
- View previous transcription sessions  

### 🎙 **Real-Time Recording Engine**
- Native iOS AVAudioEngine implementation  
- Native Android AudioRecord implementation  
- Generates 5-second WAV/PCM chunks  
- Streams audio levels for live UI waveform  
- Continues recording when:
  - App minimized  
  - Screen locked  
  - Bluetooth/Wired headset switch  
  - Phone call interruption  
  - Network offline  

### ☁️ **Cloud Upload System**
- GET presigned URL  
- PUT raw audio to MinIO  
- Notify backend per chunk  
- Persistent retry queue using Hive  
- Survives app kill / device reboot  

### 📝 **Transcription & Summary**
- Merge audio chunks  
- Pipeline for LLM-based transcription  
- Summary extracted using template metadata  

---

## 🧱 5. Architecture Overview

Flutter App (UI)
↓ BLoC
Native Audio Service
↓
iOS Swift / Android Kotlin (Chunk Recorder)
↓
Hive Chunk Queue
↓
Uploader Worker (Retries + Backoff)
↓
FastAPI Backend
↓
MinIO Presigned URL Storage
↓
Transcription Engine


---

## 🗂 6. Repository Structure

/lib
/core/native # Platform channels & audio service
/data # Models, repositories, data sources
/presentation # UI + BLoC
/backend
app/
routers/
models/
utils/

---

## 🧪 7. Testing APIs

Swagger UI:  
http://142.93.211.149:8000/docs

Use the Postman collection for additional workflows.

---

## 🙌 8. Author

**Rachit Goyal**  
Flutter Developer | Mobile Systems Engineer  
GitHub: https://github.com/rachit-goyal1071

---

## 📄 9. License

MIT License  
Feel free to modify, extend, or build upon this project.
