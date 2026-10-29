# 📱 Smart Room Finder — Mobile Application

The mobile application for **Smart Room Finder**, developed as a Final Year Project (FYP).

The mobile application communicates with the Smart Room Finder backend through REST APIs and provides mobile users with access to the application's core functionality.

## 🚀 Tech Stack

* Flutter
* Dart
* REST APIs
  

## ✨ Features

* Mobile-friendly room-finding experience
* Backend API integration
* User interaction and navigation
* Room-related functionality

## ✨ Live Web Demo
  https://dearb00.github.io/smart-room-finder-mobile/

## 🔗 Related Repositories

### Frontend

The web frontend is available here:

**smart-room-finder-frontend**
https://github.com/itsaricode/smart-room-finder-frontend

Frontend development server:

```bash
npm run dev
```

### Backend

The Spring Boot backend is available here:

**smart-room-finder-backend**
https://github.com/itsaricode/smart-room-finder-backend

Backend development server:

```bash
mvn spring-boot:run
```

## 📁 Project Structure

```text
smart-room-finder-mobile/
│
├── assets/
├── build/
├── lib/
├── web/
├── pubspec.yaml
└── README.md
```
> Note: The local project directory is named `azh-app`. 
> It is published as the `smart-room-finder-mobile` GitHub repository.

## ⚙️ Installation & Setup

### 1. Clone the repository

git clone https://github.com/itsaricode/smart-room-finder-mobile.git


### 2. Open the project

```bash
cd smart-room-finder-mobile
```

### 3. Install dependencies

```bash
flutter pub get
```
### -->. Laptop/VS Code + Chrome

```bash
flutter run -d chrome
```
### -->. Chromebook/Web Server

```bash
flutter run -d web-server
```
### 4. Start the Backend

Open the backend repository:

```bash
cd smart-room-finder-backend
```

Run:

```bash
mvn spring-boot:run
```

Make sure the backend is running before testing features that require API communication.

### 5. Start the Mobile Application

Return to the mobile project:

```bash
cd smart-room-finder-mobile
```

Run the appropriate command for the project's framework.

## 🌐 Local Development

When running the application locally, make sure the mobile application can reach the backend server.

Depending on the development environment, the backend URL may need to use:

```text
localhost
```

or the local machine's network IP address.

For example:

```text
http://YOUR_LOCAL_IP:8080
```

> Replace this with the actual backend URL and port used by the project.

## 🔄 Project Architecture

```text
                 ┌──────────────────────┐
                 │   Web Frontend       │
                 │   npm run dev        │
                 └──────────┬───────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │ Spring Boot   │
                    │ Backend API   │
                    │ mvn           │
                    │ spring-boot:run│
                    └───────┬───────┘
                            │
                            ▼
                       Database
                            ▲
                            │
                 ┌──────────┴───────────┐
                 │   Mobile App        │
                 │   Mobile Client     │
                 └──────────────────────┘
```

## 👩‍💻 Project

**Smart Room Finder** was developed as a Final Year Project consisting of:

* Web Frontend
* Spring Boot Backend
* Mobile Application

Each component is maintained in a separate GitHub repository.

## 📌 Related Repositories

| Component | Repository                   | Development                  |
| --------- | ---------------------------- | ---------------------------- |
| Frontend  | smart-room-finder-frontend   | npm run dev                  |
| Backend   | smart-room-finder-backend    | mvn spring-boot:run          |
| Mobile    | smart-room-finder-mobile     | flutter run -d chrome        |
