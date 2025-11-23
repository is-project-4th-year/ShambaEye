# 🌾 ShambaEye: AI-Powered Crop Disease Detection Platform

![License](https://img.shields.io/npm/l/react?logo=react&labelColor=black&color=green)
![Tech](https://img.shields.io/badge/AI-Powered-blue?logo=tensorflow)
![Mobile](https://img.shields.io/badge/Flutter-Mobile_App-orange?logo=flutter)

---

## 📌 Description

**ShambaEye** is an intelligent agricultural assistant designed to help farmers detect crop diseases using artificial intelligence. Farmers capture a photo of a crop leaf, and the system analyzes it using a deep-learning model to identify diseases, estimate severity, and provide treatment recommendations.

The system consists of:

1. **Mobile App (Flutter)**  
   Used by farmers for detection, history tracking, and language-localized guidance.

2. **AI Backend (FastAPI + Python)**  
   Hosts the machine learning models, handles inference, and produces Grad-CAM heatmaps.

3. **Admin Dashboard (Next.js + Firebase Admin)**  
   Allows administrators to manage users, scan records, and view detailed analytics.

ShambaEye improves agricultural efficiency, reduces crop loss, and provides farmers with accurate, AI-driven insights.

---

## 🧩 Technologies Used

- **Flutter** – Mobile app  
- **FastAPI** – AI backend  
- **Next.js 16 (React 18)** – Admin dashboard  
- **Firebase Firestore** – Database  
- **Firebase Storage** – Image storage  
- **Firebase Admin SDK** – Server-side admin
- **TensorFlow / PyTorch** – Model architecture and training  
- **PyTorch_Lite_Flutter** - For local offline inference in the mobile app

---

## 🚀 Installation

### 1. **Clone the Repository**
```bash
git clone https://github.com/TijaniTatu/ShambaEye.git
```
Then in the terminal change the directory

```bash
cd ShambaEye
```
---

###  2. **Install Dependencies:**
<u>Start from the root directory</u>

For the admin panel:

```zsh
cd shambaeye-admin
npm i
```

For the server:
```zsh
cd backend
pip install -r requirements.txt
```

For the mobile app:
```zsh
cd mobile
flutter pub get
```
---
### 3. **System Configurations**

This section guides you through setting up Firebase for both the **Flutter mobile app** and the **Next.js admin panel**.



#### **A. Firebase Project Setup**

1. Open the Firebase Console: https://console.firebase.google.com  
2. Click **“Add Project”** and create a new project.  
3. After creation, you will configure the Flutter app and the admin panel.



#### **B. Flutter App Configuration**

##### **i. Add Flutter App to Firebase**
In Firebase:

- Go to **Project Overview → Add App → Flutter**
- Register your app with:
  - App nickname (optional)
  - Android package name (from `android/app/src/main/AndroidManifest.xml`)
  - iOS bundle ID (if needed)



##### **ii. Install Firebase CLI**

```zsh
npm install -g firebase-tools
```

##### **iii. Login to Firebase CLI**
```zsh
firebase login
```

##### **iv. Initialize FlutterFire**
Navigate to the Flutter app:
```zsh
cd mobile
flutterfire configure
```
This will:
* Link your FLutter app to your Firebase project
* Auto-generation the file:
    ```lib/firebase_option.dart```

#### **C. Admin Panel configuration**
##### **i. Generate Firebase Admin SDK Key**
In Firebase:
* Go to <b> Project Settings -> Service Accounts</b>
* Select Firebase Admin SDK
* Click “Generate new private key”
* Download the JSON file

##### **ii. Add credentials to .env.local**
Inside the ```shambaeye-admin`` folder, create the environment file:
```zsh
cd shambaeye-admin
touch .env.local
```

Then add the details

---

## 📱 Usage
### How to run the system
* For the mobile app:
```zsh
cd mobile
flutter run
```

* For the server:
```zsh
cd backend
uvicorn app.main:app --reload
```

* For the admin panel:
```zsh
cd shambaeye-admin
npm run dev
```
Then access the dashboard  
```
http://localhost:3000
```

### 📱 Usage Instructions
#### **Mobile App (Farmer)**

1. Launch the mobile app

2. Take a picture of the crop leaf/upload from gallery

3. Submit for AI analysis

3. Receive:

    * Detected disease

    * Severity level

    * Confidence score

    * Organic & chemical treatments

    * Grad-CAM heatmap

#### **Admin Dashboard**

* View all users

* View all scan records

* Visual analytics:

    * Disease distribution by region

    * Most common diseases

    * Daily/weekly activity

    * User growth over time
    ---


## 📊 Project Structure
```
ShambaEye
|
├─ mobile/                     # Flutter app
│  ├─ lib/
│  ├─ assets/
│  ├─ android/
│  └─ ios/
|
├─ backend/                    # FastAPI backend
│  ├─ app/
│  │  ├─ main.py
│  │  ├─ models/
│  │  ├─ services/
│  │  └─ utils/
│  ├─ models/
│  └─ requirements.txt
|
└─ admin/                      # Next.js admin panel
   ├─ app/
   │  ├─ dashboard/
   │  ├─ analytics/
   │  └─ api/
   ├─ components/
   ├─ lib/
   │  └─ firebase-admin.ts
   └─ package.json
```
## 🔑 Key Files

* mobile/lib/main.dart – Mobile app entry point
* backend/app/main.py – FastAPI entry point
* backend/app/services/predict.py – AI inference logic
* admin/app/dashboard/page.tsx – Admin dashboard home
* admin/lib/firebase-admin.ts – Firebase Admin initialization

## 🧪 Input / Output Examples
Input:
* Leaf image
* User location
* User ID

Output:
* Disease name
* Severity category
* Confidence score
* Heatmap
* Treatment guidance

## ⚠️ Known Issues

* Heatmap generation may take longer on slow servers
* Mobile inference depends on network speed
* Integration of Pytorch_Lite_Flutter is highly breakble and requires right dependancy

## 🙏 Acknowledgements

* [Flutter Documentation](https://flutter.dev/?utm_source=google&utm_medium=cpc&utm_campaign=brand_sem&utm_content=emea_emea&gclsrc=aw.ds&gad_source=1&gad_campaignid=13034410735&gbraid=0AAAAAC-INI-XoxBsC3ZuO3DpoF_LIkTh-&gclid=CjwKCAiA_orJBhBNEiwABkdmjIXN8UP4D1e1xZODCagtdyH6vNvSJBLbCiK7ybXmz6HLrr3ovScXyBoCzy0QAvD_BwE)
* [FastAPI Documentation](https://fastapi.tiangolo.com/)
* [Pytorch_Lite_Flutter](https://pub.dev/packages/flutter_pytorch_lite)
* [Firebase Firestore & Storage](https://firebase.google.com/docs?_gl=1*1ko7rti*_up*MQ..&gclid=CjwKCAiA_orJBhBNEiwABkdmjAL7tPOcT5p2mNxFQSQNIyOuW7CfbePdbP6l7KdN1cQkzADt71IGjBoCCmsQAvD_BwE&gclsrc=aw.ds&gbraid=0AAAAADpUDOjiub60q1avrE8xkCCC7wv-i)
* [Next.js Documentation](https://nextjs.org/docs)

## Contact
📧 [riekotijani@gmail.com]

For issues or feature requests, open a GitHub issue.
