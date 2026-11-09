# MariaDB Log Manager

A full-stack React application for writing and managing logs in a MariaDB database.

## 🚀 Features

- ✅ Create log entries with different severity levels (DEBUG, INFO, WARN, ERROR, FATAL)
- ✅ View all logs with real-time refresh
- ✅ Filter logs by severity level
- ✅ Add metadata (JSON) to log entries
- ✅ Delete individual logs or clear all logs
- ✅ Beautiful, responsive UI
- ✅ RESTful API backend with Express
- ✅ Apache HTTP Server for production frontend
- ✅ MariaDB integration with connection pooling

## 📋 Prerequisites

**For Docker (Recommended):**
- Docker
- Docker Compose

**Rocky Linux Quick Install (Docker + Node.js):**
```bash
sudo ./install-docker-rocky.sh
```
See [INSTALL-DOCKER.md](INSTALL-DOCKER.md) for details.

**Open Firewall Ports (Rocky Linux):**
```bash
sudo ./open-ports.sh
```
This opens ports 3000 (frontend), 5000 (backend), and optionally 3306 (database).

**For Manual Setup:**
- Node.js (v14 or higher)
- npm or yarn
- MariaDB or MySQL server

## 🛠️ Installation

### Quick Start with Docker

```bash
# Clone or navigate to the project
cd log-app

# Start everything with Docker Compose
docker compose up -d

# Or use the Makefile
make up

# Open browser to http://localhost:3000
```

That's it! Skip to the [API Endpoints](#-api-endpoints) section.

📘 **For detailed Docker instructions**, see [DOCKER.md](DOCKER.md)  
📘 **For Apache HTTP Server configuration**, see [APACHE.md](APACHE.md)  
📘 **For Node.js in Docker setup**, see [NODEJS-DOCKER.md](NODEJS-DOCKER.md)

### Manual Installation (without Docker)

### 1. Install MariaDB (if not already installed)

**Rocky Linux:**
```bash
sudo dnf install mariadb-server mariadb -y
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

**macOS:**
```bash
brew install mariadb
brew services start mariadb
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install mariadb-server
sudo systemctl start mariadb
```

### 2. Secure MariaDB Installation (Optional but recommended)
```bash
sudo mysql_secure_installation
```

### 3. Create Database and User

Log into MariaDB:
```bash
mysql -u root -p
```

Run these commands:
```sql
CREATE DATABASE logdb;
CREATE USER 'logapp'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON logdb.* TO 'logapp'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 4. Install Backend Dependencies

```bash
cd log-app/backend
npm install
```

### 5. Configure Backend Environment

Copy the example env file:
```bash
cp .env.example .env
```

Edit `.env` with your database credentials:
```env
PORT=5000
DB_HOST=localhost
DB_USER=logapp
DB_PASSWORD=your_secure_password
DB_NAME=logdb
```

### 6. Install Frontend Dependencies

```bash
cd ../frontend
npm install
```

## 🏃 Running the Application

### Option 1: Docker Compose (Recommended)

The easiest way to run the entire stack:

```bash
cd log-app

# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Stop and remove volumes (deletes database data)
docker-compose down -v
```

**Services will be available at:**
- Frontend: `http://localhost:3000`
- Backend API: `http://localhost:5000`
- phpMyAdmin: `http://localhost:8080`
- MariaDB: `localhost:3306`

**Default credentials:**
- Database: `logdb`
- User: `logapp`
- Password: `logapp123`
- Root Password: `rootpassword`

**phpMyAdmin Login:**
- Server: `mariadb`
- Username: `root` or `logapp`
- Password: `rootpassword` or `logapp123`

### Database export logging

Database exports are queued by the frontend and processed by `engine-min.sh`.
Run the engine from this directory in a separate terminal so dump files are
created here:

```bash
cd dbmigrate
./engine-min.sh
```

The engine needs a MariaDB/MySQL client and a `mysqldump` or `mariadb-dump`
command available in its environment. When a dump command finishes, the engine
records its database, filename, status, output, and file size in `export_log`.
Use `./engine-min.sh --once` to process pending commands once and exit.

### Option 2: Manual Setup

### Start Backend Server

```bash
cd backend
npm start
```

Or with auto-reload during development:
```bash
npm run dev
```

The API will be available at `http://localhost:5000`

### Start React Frontend

In a new terminal:
```bash
cd frontend
npm start
```

The app will open at `http://localhost:3000`

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check |
| GET | `/api/logs` | Get all logs (last 100) |
| GET | `/api/logs/:level` | Get logs by level |
| POST | `/api/logs` | Create a new log |
| DELETE | `/api/logs/:id` | Delete a specific log |
| DELETE | `/api/logs` | Clear all logs |

### Example POST Request

```bash
curl -X POST http://localhost:5000/api/logs \
  -H "Content-Type: application/json" \
  -d '{
    "level": "INFO",
    "message": "User logged in successfully",
    "source": "AuthService",
    "metadata": {"userId": 123, "ip": "192.168.1.1"}
  }'
```

## 🗄️ Database Schema

```sql
CREATE TABLE logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    level VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    source VARCHAR(100),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSON,
    INDEX idx_timestamp (timestamp),
    INDEX idx_level (level)
);
```

## 🎨 Log Levels

- **DEBUG**: Detailed information for debugging
- **INFO**: General informational messages
- **WARN**: Warning messages
- **ERROR**: Error messages
- **FATAL**: Critical errors

## 📦 Project Structure

```
log-app/
├── backend/
│   ├── server.js          # Express server
│   ├── package.json       # Backend dependencies
│   ├── Dockerfile         # Backend container config
│   ├── .env.example       # Environment variables template
│   └── .env               # Your config (not in git)
├── frontend/
│   ├── public/
│   │   ├── index.html     # HTML template
│   │   └── .htaccess      # Apache rewrite rules (alternative)
│   ├── src/
│   │   ├── components/
│   │   │   ├── LogForm.js      # Form component
│   │   │   └── LogList.js      # List component
│   │   ├── App.js              # Main app
│   │   ├── App.css             # Styles
│   │   ├── index.js            # Entry point
│   │   └── index.css           # Global styles
│   ├── Dockerfile         # Frontend container config
│   ├── apache.conf        # Apache HTTP Server configuration
│   ├── package.json       # Frontend dependencies
│   └── .env               # Frontend config
├── docker-compose.yml     # Docker orchestration
├── Makefile              # Helper commands
├── install-docker-rocky.sh  # Docker installation script
├── open-ports.sh         # Firewall port configuration script
├── verify-docker.sh      # Docker verification script
├── INSTALL-DOCKER.md     # Docker installation guide
├── DOCKER.md             # Docker documentation
├── APACHE.md             # Apache HTTP Server documentation
├── NODEJS-DOCKER.md      # Node.js in Docker guide
└── README.md             # This file
```

## 🔧 Troubleshooting

### phpMyAdmin Access

**Cannot connect to phpMyAdmin:**
```bash
# Check if phpMyAdmin container is running
docker ps | grep phpmyadmin

# View phpMyAdmin logs
docker logs logapp-phpmyadmin

# Restart phpMyAdmin
docker compose restart phpmyadmin
```

**Login issues:**
- Server: Use `mariadb` (not localhost)
- Username: `root` or `logapp`
- Password: `rootpassword` or `logapp123`

**Access from another machine:**
- Make sure port 8080 is open: `sudo firewall-cmd --list-all`
- Use server IP: `http://YOUR_SERVER_IP:8080`

### Docker Issues

**Port already in use:**
```bash
# Check what's using the port
sudo lsof -i :3000  # or :5000, :3306, :8080

# Change ports in docker-compose.yml
# For example, change "3000:80" to "3001:80"
```

**Permission denied:**
```bash
# Run with sudo or add user to docker group (Rocky Linux)
sudo usermod -aG docker $USER
newgrp docker
```

**View container logs:**
```bash
docker-compose logs backend
docker-compose logs frontend
docker-compose logs mariadb
```

**Rebuild containers:**
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Manual Setup Issues

### Backend won't connect to MariaDB
- Check MariaDB is running: 
  - Rocky Linux: `sudo systemctl status mariadb`
  - macOS: `brew services list`
  - Ubuntu/Debian: `systemctl status mariadb`
- Verify credentials in `.env`
- Check firewall settings (Rocky Linux: `sudo firewall-cmd --list-all`)

### Port already in use
- Backend: Change `PORT` in `backend/.env`
- Frontend: Set `PORT=3001` in terminal before `npm start`

### Firewall blocking access (Rocky Linux)
```bash
# Check if ports are open
sudo firewall-cmd --list-all

# Open ports with script
sudo ./open-ports.sh

# Or manually open specific port
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload

# Check what's listening on ports
sudo ss -tuln | grep -E ':(3000|5000|3306)'
```

### CORS errors
- Ensure backend is running on port 5000
- Check `REACT_APP_API_URL` in `frontend/.env`

## 🚀 Production Deployment

### Build Frontend
```bash
cd frontend
npm run build
```

### Serve with Backend
Update `backend/server.js` to serve static files:
```javascript
app.use(express.static(path.join(__dirname, '../frontend/build')));
```

## 📝 License

MIT

## 👤 Author

Your Name

## 🤝 Contributing

Pull requests are welcome!

##  Database erd:
[text](https://www.mysqltutorial.org/getting-started-with-mysql/mysql-sample-database/)

## if git conflict
git reset --hard

## rebuild after git pull
docker compose build
## restart docker compose
docker compose down && docker compose up -d
### if docker fails to start


$ sudo firewall-cmd --get-active-zones
$ sudo firewall-cmd --permanent --zone=docker --change-interface=docker0
$ sudo firewall-cmd --reload

cd log-app

# Stop and remove existing containers and volumes
docker compose down -v

# Start fresh (this will run the SQL file in logdb)
docker compose up -d

# Verify the tables were created in logdb
docker exec -it logapp-mariadb mysql -uroot -prootpassword logdb -e "SHOW TABLES;"
