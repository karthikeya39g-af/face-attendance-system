# 🌟 Beginner's Guide: Running Face Attendance & Payroll on Windows

Welcome! This guide is written in very simple, easy-to-follow steps. Even if you have never written a single line of code in your life, you can run this project in just 3 easy steps!

---

## 🛠️ Step 1: Install 3 Free Software Tools

Think of these as the 3 tools your computer needs to run the project.

### 1. Python (The Engine)
1. Go to this website: **[https://www.python.org/downloads/](https://www.python.org/downloads/)**
2. Click the big yellow button: **"Download Python 3.x"**.
3. Open the downloaded file to install it.
4. ⚠️ **VERY IMPORTANT STEP**: On the very first screen of the installer, look at the bottom and **CHECK THE BOX** that says:
   > ☑️ **Add python.exe to PATH**
5. Click **"Install Now"** and wait for it to say "Setup was successful".

---

### 2. Node.js (The Web Display Helper)
1. Go to this website: **[https://nodejs.org/](https://nodejs.org/)**
2. Click the button on the left that says **"LTS (Recommended for Most Users)"**.
3. Open the downloaded installer.
4. Click **Next** -> **Next** -> **Next** -> **Install** (keep all default choices).
5. Click **Finish**.

---

### 3. PostgreSQL (The Data Notebook / Database)
1. Go to this website: **[https://www.enterprisedb.com/downloads/postgres-postgresql-downloads](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)**
2. Under "Windows x86-64", click **Download**.
3. Open the downloaded file to run the installer.
4. Click **Next** -> **Next** until it asks you for a **Password**:
   - Type `postgres` (or any simple password you will remember).
   - In the re-type box, type `postgres` again.
5. Keep Port as **5432** (leave it as it is).
6. Click **Next** -> **Next** -> **Install**.
7. When it finishes, uncheck "Stack Builder" and click **Finish**.

---

## 🚀 Step 2: One-Click Setup

1. Copy or extract this project folder onto your Windows computer (for example on your Desktop or in Documents).
2. Open the project folder.
3. Look for the file named:
   ### 👉 `setup_windows.bat`
4. **Double-click** on `setup_windows.bat`.
5. A black window will open. It will automatically:
   - Check Python and Node.js
   - Download the project libraries
   - Set up the database and pre-load all the employee records, shifts, and payroll data!
   - When asked for your PostgreSQL password, type the password you chose (e.g. `postgres`) and press **Enter**.
6. When it says `SETUP COMPLETED SUCCESSFULLY!`, press any key to close the window.

---

## 🎬 Step 3: Run the Application!

Whenever you want to use the app:
1. Simply double-click:
   ### 👉 `start_windows.bat`
2. Two black windows will open (one for the Backend API, one for the Frontend Web App).
3. **Your web browser will automatically pop up with the app!**
   - Address: **[http://localhost:5173](http://localhost:5173)**
4. You can mark attendance with your webcam, view all 5 employees, see salary breakdowns, and run payroll!

---

## 🛑 How to Stop the App

When you are done:
- Simply close the two black windows (`Attendance Backend` and `Attendance Frontend`). That's all!
