# 🚗 Rapido Corporate - Ride Booking Platform

[![Production Ready](https://img.shields.io/badge/Status-Production%20Ready-brightgreen.svg)](https://github.com/Vasu2219/Rapido_backend-Api)
[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)](https://flutter.dev)
[![React](https://img.shields.io/badge/React-18-blue.svg)](https://reactjs.org)
[![Node.js](https://img.shields.io/badge/Node.js-16+-green.svg)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-green.svg)](https://mongodb.com)

A comprehensive corporate ride booking platform built with Flutter (mobile app), React (web dashboard), and Node.js (backend API). This platform enables seamless ride management for corporate employees with admin oversight and real-time notifications.

> **🎯 Project Status**: **COMPLETE** - All features implemented, tested, and production-ready!

## 🎊 Key Achievements

✅ **Cross-Platform Mobile App** - Flutter app running on Android, iOS & Web  
✅ **Modern Web Dashboard** - React admin panel with real-time analytics  
✅ **Robust Backend API** - Node.js/Express with MongoDB and Swagger docs  
✅ **Production Deployment** - Live on Render with custom domain  
✅ **Complete Admin System** - Full ride management and user oversight  
✅ **Real-time Notifications** - Instant updates across all platforms  
✅ **Custom Branding** - Professional UI with corporate identity  

## 🌟 Features

### 👥 User Features
- **Secure Authentication** - Login/Signup with JWT tokens
- **Easy Ride Booking** - Book rides with pickup/drop locations
- **Real-time Tracking** - Track ride status and updates
- **Ride History** - View all past and upcoming rides
- **Profile Management** - Update personal information
- **Push Notifications** - Get notified about ride status changes

### 🛡️ Admin Features
- **Comprehensive Dashboard** - Overview of all rides and analytics
- **Ride Management** - Approve/reject ride requests
- **User Management** - Manage corporate users
- **Analytics & Reports** - Detailed insights and statistics
- **Real-time Notifications** - Instant alerts for new requests
- **Settings Management** - Configure platform settings

## 📱 Application Screenshots

### 🔐 Authentication Flow

<div align="center">

| Login Screen | Signup Screen |
|:---:|:---:|
| <img src="rapido_app/assets/images/login.jpg" alt="Login Screen" width="250"/> | <img src="rapido_app/assets/images/signup.jpg" alt="Signup Screen" width="250"/> |
| *Secure login with email and password* | *New user registration with corporate details* |

</div>

---

### 👤 User Experience

<div align="center">

| User Dashboard | Book Ride |
|:---:|:---:|
| <img src="rapido_app/assets/images/userdashboard.jpg" alt="User Dashboard" width="250"/> | <img src="rapido_app/assets/images/Bookride.jpg" alt="Book Ride Screen" width="250"/> |
| *Clean dashboard with recent rides* | *Easy ride booking interface* |

| My Rides | User Menu |
|:---:|:---:|
| <img src="rapido_app/assets/images/myrides.jpg" alt="My Rides Screen" width="250"/> | <img src="rapido_app/assets/images/usermenu.jpg" alt="User Menu" width="250"/> |
| *Complete ride history with tracking* | *Navigation menu with settings* |

</div>

---

### 🛡️ Admin Panel

<div align="center">

| Admin Dashboard | Admin Panel |
|:---:|:---:|
| <img src="rapido_app/assets/images/admindashboard.jpg" alt="Admin Dashboard" width="250"/> | <img src="rapido_app/assets/images/Adminpanel.jpg" alt="Admin Panel" width="250"/> |
| *Comprehensive analytics dashboard* | *Complete platform management* |

</div>

## � Live Demo

🚀 **The application is live and ready to use!**

- **Backend API**: `https://rapido-backend-api.onrender.com`
- **API Documentation**: `https://rapido-backend-api.onrender.com/api-docs`
- **Mobile App**: Download and run from source (supports Android, iOS, Web)

### Demo Credentials
```
Admin Login:
Email: admin@corporaterides.com
Password: Admin@123

User Login:
Register a new account or use the demo user credentials from the backend
```

## �🏗️ Technology Stack

### Frontend (Mobile App)
- **Flutter 3.8.1** - Cross-platform mobile development
- **Dart** - Programming language
- **Provider** - State management
- **HTTP** - API communication
- **Lottie** - Smooth animations
- **Font Awesome** - Icon library

### Frontend (Web Dashboard)
- **React 18** - Modern web framework
- **JavaScript/JSX** - Programming language
- **Axios** - HTTP client
- **Tailwind CSS** - Utility-first CSS framework
- **Vite** - Build tool

### Backend API
- **Node.js** - Server runtime
- **Express.js** - Web framework
- **MongoDB** - NoSQL database
- **Mongoose** - ODM for MongoDB
- **JWT** - Authentication tokens
- **Bcrypt** - Password hashing
- **Swagger** - API documentation

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (≥3.8.1)
- Node.js (≥16.0.0)
- MongoDB (local or Atlas)
- Android Studio / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Vasu2219/Rapido_backend-Api.git
   cd Rapido_backend-Api
   ```

2. **Setup Backend API**
   ```bash
   cd backend-api
   npm install
   cp env.example .env
   # Configure your environment variables
   npm start
   ```

3. **Setup Frontend Web**
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

4. **Setup Mobile App**
   ```bash
   cd rapido_app
   flutter pub get
   flutter run
   ```

### Environment Configuration

Create a `.env` file in the backend-api directory:

```env
# Production Configuration
NODE_ENV=production
PORT=5000

# Database (MongoDB Atlas recommended for production)
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/rapido_db

# Security
JWT_SECRET=your_super_secret_jwt_key_minimum_32_characters
JWT_EXPIRES_IN=30d

# CORS & API
FRONTEND_URL=https://your-frontend-domain.com
API_BASE_URL=https://your-api-domain.com

# Admin Account
DEFAULT_ADMIN_EMAIL=admin@yourcompany.com
DEFAULT_ADMIN_PASSWORD=SecurePassword123
```

## 🚀 Deployment

### Backend (Render/Heroku/AWS)
```bash
# Build and deploy backend
cd backend-api
npm install --production
npm start
```

### Frontend (Vercel/Netlify)
```bash
# Build and deploy frontend
cd frontend
npm install
npm run build
```

### Mobile App
```bash
# Android APK
cd rapido_app
flutter build apk --release

# iOS (requires Xcode)
flutter build ios --release

# Web deployment
flutter build web --release
```

## 📖 API Documentation

The API is fully documented with Swagger. After starting the backend server, visit:
```
http://localhost:5000/api-docs
```

### Key Endpoints

- **Authentication**: `/api/auth/login`, `/api/auth/register`
- **Rides**: `/api/rides`, `/api/admin/rides`
- **Users**: `/api/users`, `/api/admin/users`
- **Notifications**: `/api/notifications`
- **Analytics**: `/api/admin/analytics`

## 🔧 Features in Detail

### Real-time Notifications
- Instant notifications for ride status changes
- Admin alerts for new ride requests
- Push notifications for mobile users

### Security Features
- JWT-based authentication
- Password hashing with bcrypt
- Role-based access control
- API rate limiting
- Input validation and sanitization

### Mobile Optimizations
- Responsive design for all screen sizes
- Offline capability for basic features
- Optimized animations and transitions
- Clean Material Design UI

### Admin Analytics
- Ride statistics and trends
- User activity monitoring
- Revenue and performance metrics
- Exportable reports

## 🧪 Testing

### Backend Testing
```bash
cd backend-api
npm test
```

### Frontend Testing
```bash
cd frontend
npm test
```

### Mobile Testing
```bash
cd rapido_app
flutter test
```

## ⚡ Performance & Optimization

### Backend Optimizations
- **Database Indexing** - Optimized MongoDB queries
- **Caching** - Efficient data caching strategies
- **Rate Limiting** - API protection against abuse
- **Compression** - Gzip compression for faster responses

### Frontend Optimizations
- **Code Splitting** - Lazy loading for better performance
- **Image Optimization** - Compressed and responsive images
- **Bundle Optimization** - Tree shaking and minification
- **PWA Ready** - Service workers for offline capability

### Mobile Optimizations
- **Flutter Optimizations** - Tree shaking and code obfuscation
- **Asset Optimization** - Compressed images and animations

## 🔒 Security Features

- **JWT Authentication** - Secure token-based authentication
- **Password Hashing** - bcrypt with salt rounds
- **Input Validation** - Comprehensive request validation
- **SQL Injection Protection** - Mongoose ODM protection
- **Rate Limiting** - API abuse prevention
- **CORS Configuration** - Secure cross-origin requests
- **Environment Variables** - Secure configuration management

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## 👨‍💻 Author

**Vasu**
- GitHub: [@Vasu2219](https://github.com/Vasu2219)
- Email: gvasu1292@gmail.com



