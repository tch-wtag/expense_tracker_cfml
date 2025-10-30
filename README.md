# 💰 Expense Tracker (Lucee CFML)

A web-based **Expense Tracker** that helps users record, categorize, and analyze their expenses securely and efficiently.
Built with **Lucee CFML**, **MariaDB**, and a clean **HTML/CSS** frontend.

---

## 🚀 Features

* 🔐 User registration and login with secure password hashing
* 🌐 **Google OAuth 2.0 Login** for quick authentication
* 💸 Add, edit, delete, search, and view expenses
* 🗂️ Manage custom expense categories
* ⚙️ RESTful API with JSON responses
* 🛡️ JWT authentication and session management
* 💻 Responsive web interface

---

## 🧱 Tech Stack

| Layer        | Technology                            |
| ------------ | ------------------------------------- |
| Backend      | Lucee CFML                            |
| Database     | MariaDB                               |
| Frontend     | HTML, CSS                             |
| Security     | JWT, Session Management, Google OAuth |
| Architecture | MVC + Repository Pattern              |
| Deployment   | Docker, Docker Compose                |

---

## ⚙️ Setup

### 🖥️ Run Locally with Docker

1. **Start the containers**

   ```bash
   docker-compose up --build
   ```

2. **Create the environment config file**
   Before running the app, create `env.cfm` (as shown below in the **Google OAuth 2.0 Setup** section).

   > ⚠️ Without this file, Lucee will throw an error while loading environment variables.

3. **Configure the database** inside the Lucee admin panel:

   * Open the Lucee Admin at
     👉 [http://localhost:8888/lucee/admin/index.cfm](http://localhost:8888/lucee/admin/index.cfm)
   * Default password: **`hello`**

   Then create a new datasource with the following details:

   | Field           | Value                             |
   | --------------- | --------------------------------- |
   | Datasource Name | `myDSN`                           |
   | Database Type   | `MariaDB / MySQL`                 |
   | Database        | `testdb`                          |
   | Host            | `mariadb` *(Docker service name)* |
   | Port            | `3306`                            |
   | Username        | `dbuser`                          |
   | Password        | `mypassword`                      |

4. **Access the application**

   ```
   http://127.0.0.1:8888/index.cfm
   ```

---

### 🟢 Google OAuth 2.0 Setup (ColdFusion / Lucee)

1. Go to [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project and enable **Google People API**.
3. Under **OAuth consent screen**, select **External**, add your app name and test user email, then save.
4. Create **OAuth credentials** → choose **Web application**, and set the redirect URI to:

   ```
   http://127.0.0.1:8888/controllers/googleCallback.cfm
   ```
5. Copy the **Client ID** and **Client Secret**, then create a new file `/config/.env.cfm` with the following content:

   ```cfml
   <cfscript>
   application.env = {
       GOOGLECLIENTID = "YOUR_GOOGLE_CLIENT_ID",
       GOOGLECLIENTSECRET = "YOUR_GOOGLE_CLIENT_SECRET",
       GOOGLEREDIRECTURI = "http://127.0.0.1:8888/controllers/googleCallback.cfm",
       SECRET_KEY = "your-super-secret-key"
   };
   </cfscript>
   ```

> ⚠️ **Important Notes**
>
> * Do **not** commit `.env.cfm` to version control.
> * Add it to `.gitignore`.
> * Use a strong, random value for `SECRET_KEY`.
> * The `assets/images/` folder is also ignored in Git since it stores uploaded or temporary files — it will be created automatically when needed.
