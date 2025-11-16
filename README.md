# 🚀 Leelame — AI-Driven Auction App (Flutter)

## Overview

**Leelame** is a next-generation auction platform built with **Flutter** and powered by **AI-driven intelligence**, delivering real-time bidding insights, smart recommendations, and a seamless user experience across Android and iOS.  
Using **Clean Architecture**, the app ensures scalability, maintainability, and a robust separation of concerns—perfect for production-grade applications.

<div align="center">
  <img src="https://i.ibb.co/7nL4Z6G/leelame-logo.png" alt="Leelame Logo" width="200">

  <br/>

  ![License](https://img.shields.io/badge/license-MIT-blue.svg)
  ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
  ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
  ![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=flat&logo=mongodb&logoColor=white)

  **AI-enabled mobile auction platform built using Flutter, Clean Architecture & MongoDB**
</div>

---

## 🌟 Key Features

### 🤖 AI-Powered Capabilities
- Smart bidding predictions & analytics  
- Personalized recommendations for buyers  
- Intelligent fraud detection & anomaly tracking  
- NLP-based smart search  
- AI-driven price insights and valuation system  

### 📱 Seamless Mobile Experience
- Cross-platform support (Android & iOS)  
- Beautiful and responsive UI  
- Optimized animations and transitions  
- Offline data caching for smoother browsing  

### 🔐 Secure Authentication
- Login with email/phone  
- OAuth provider support (Google, GitHub, etc.)  
- JWT authentication & refresh tokens  
- Role-based access (Buyer/Seller/Admin)  
- Secure password hashing  

### 🛠️ Clean Architecture Implementation
Structured into:
- **Presentation Layer** (UI, ViewModels, BLoC/Cubit/Provider)  
- **Domain Layer** (Use Cases, Entities, Repository Interfaces)  
- **Data Layer** (Repositories, MongoDB services, DTOs)  

Ensures maintainability, modularity & scalable growth.

---

## 🧰 Tech Stack

### Mobile App
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

### Backend & Database
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Express.js](https://img.shields.io/badge/Express.js-000000?style=for-the-badge&logo=express&logoColor=white)

### Architecture & Tools
![Clean Architecture](https://img.shields.io/badge/Clean_Architecture-grey?style=for-the-badge)
![REST API](https://img.shields.io/badge/REST_API-blue?style=for-the-badge)
![State Management](https://img.shields.io/badge/BLoC/Provider-02569B?style=for-the-badge)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10+ recommended)  
- Dart SDK  
- MongoDB Atlas cluster OR local MongoDB  
- Backend API up and running  

---

### 📦 Installation & Setup

```bash
# Clone repository
git clone https://github.com/yourusername/leelame-mobile.git

# Navigate into project
cd leelame-mobile

# Install dependencies
flutter pub get

# (Optional) Generate files for DI / JSON serialization
flutter pub run build_runner build --delete-conflicting-outputs
