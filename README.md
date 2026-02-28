# REUNIFY  
## AI-Assisted Deterministic Child Reunification System  

Reunify is a deterministic AI-assisted inference system designed to support missing child reunification through structured memory interpretation and rule-based geographic reasoning.

This Flutter project contains the working prototype of the Reunify inference engine and user interface.

---

## ⚠️ Prototype Notice

This project is currently a **functional prototype**.

- No external APIs (Gemini, Google Maps, Google Places) are integrated yet.  
- All services use mock or abstract implementations.  
- The inference, scoring, and matching logic are fully implemented and deterministic.  

The core architecture and reasoning pipeline are designed to remain the same when real APIs are integrated in the future. Only the data retrieval layer will change — the deterministic inference logic will not.

---

## 📌 Important: Read Documentation First

Before running the application, please review the **Documentation** folder.

All detailed explanations about the system are provided there.

```
Documentation/
│
├── KitaHack Presentation Slide.pdf.url    → Project presentation slides
├── README_ARCHITECTURE.md.url             → Full system architecture explanation
├── README_DEMO.md.url                     → Step-by-step demo guide
```

### 📖 Recommended Reading Order

1️⃣ **README_ARCHITECTURE.md.url**  
Understand the deterministic inference pipeline and system design.

2️⃣ **README_DEMO.md.url**  
See how to run and test the system with example memory inputs.

3️⃣ **KitaHack Presentation Slide.pdf.url**  
Presentation overview of the project objectives, SDGs, and technical contribution.

---

## 🚀 Running the Application

After reviewing the documentation:

```bash
flutter pub get
flutter run
```

---
