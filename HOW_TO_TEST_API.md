# 📡 How to Test Your API and See Output

## 🚀 Quick Start

### Method 1: Use the Test Script (Easiest)

```bash
cd /home/mhmd/Documents/konecta/erb_full_project
./test-api.sh
```

This script will:
- ✅ Test health endpoint
- ✅ Login and get JWT token
- ✅ Test multiple protected endpoints
- ✅ Show formatted JSON output

---

## 🔧 Method 2: Using cURL (Command Line)

### 1. **Test Health Check** (No authentication needed)
```bash
curl http://konecta-ass1-dev-alb-602225348.us-east-1.elb.amazonaws.com/actuator/health/ping
```

**Output:**
```json
{"status":"UP"}
```

### 2. **Login to Get JWT Token**
```bash
curl -X POST http://konecta-ass1-dev-alb-602225348.us-east-1.elb.amazonaws.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@konecta.com",
    "password": "Admin@123"
  }'
```

**Output:**
```json
{
  "result": {
    "accessToken": "eyJhbGciOiJSUzI1NiIs...",
    "expiresAtUtc": "2025-12-01T14:00:00Z",
    "userId": "...",
    "email": "admin@konecta.com",
    "roles": ["System Admin"]
  },
  "code": "200",
  "c_Message": "Login successful."
}
```

### 3. **Use Token for Protected Endpoints**

Save the token:
```bash
TOKEN="<paste-your-token-here>"
```

Then use it:
```bash
curl -X GET http://konecta-ass1-dev-alb-602225348.us-east-1.elb.amazonaws.com/hr/employees \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🌐 Method 3: Using Browser

### Public Endpoints (Work in Browser)

1. **Health Check:**
   ```
   http://konecta-ass1-dev-alb-602225348.us-east-1.elb.amazonaws.com/actuator/health/ping
   ```
   - Just paste in browser address bar
   - You'll see: `{"status":"UP"}`

### Protected Endpoints (Need Browser Extension)

For protected endpoints, you need to send authentication headers. Use a browser extension like:

- **ModHeader** (Chrome/Firefox)
- **REST Client** (VS Code extension)
- **Postman** (Desktop app)

---

## 📱 Method 4: Using Postman

1. **Create New Request:**
   - Method: `POST`
   - URL: `http://konecta-ass1-dev-alb-602225348.us-east-1.elb.amazonaws.com/auth/login`
   - Headers: `Content-Type: application/json`
   - Body (raw JSON):
     ```json
     {
       "email": "admin@konecta.com",
       "password": "Admin@123"
     }
     ```
   - Click "Send"
   - **See output** in response panel below

2. **Copy the `accessToken`** from response

3. **Create Another Request:**
   - Method: `GET`
   - URL: `http://konecta-ass1-dev-alb-602225348.us-east-1.elb.amazonaws.com/hr/employees`
   - Headers: 
     - `Authorization: Bearer <paste-token-here>`
   - Click "Send"
   - **See output** in response panel

---

## 🐍 Method 5: Using Python Script

Create `test_api.py`:

```python
import requests
import json

ALB_URL = "http://konecta-ass1-dev-alb-602225348.us-east-1.elb.amazonaws.com"

# 1. Health Check
print("1. Health Check:")
response = requests.get(f"{ALB_URL}/actuator/health/ping")
print(f"Status: {response.status_code}")
print(f"Response: {response.json()}")
print()

# 2. Login
print("2. Login:")
login_data = {
    "email": "admin@konecta.com",
    "password": "Admin@123"
}
response = requests.post(f"{ALB_URL}/auth/login", json=login_data)
print(f"Status: {response.status_code}")
result = response.json()
print(json.dumps(result, indent=2))
print()

# 3. Get Token
token = result.get("result", {}).get("accessToken")
if token:
    print(f"Token: {token[:50]}...")
    print()
    
    # 4. Use Token
    print("3. Test Protected Endpoint:")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{ALB_URL}/hr/employees", headers=headers)
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
```

Run:
```bash
python3 test_api.py
```

---

## 📊 Method 6: View Logs (For Debugging)

### View API Gateway Logs
```bash
aws logs tail /ecs/konecta-ass1-dev --follow --filter-pattern "api-gateway" --region us-east-1
```

### View Authentication Service Logs
```bash
aws logs tail /ecs/konecta-ass1-dev --follow --filter-pattern "authentication-service" --region us-east-1
```

### View All Service Logs
```bash
aws logs tail /ecs/konecta-ass1-dev --follow --region us-east-1
```

---

## 🎯 Quick Test Commands

Copy and paste these commands:

```bash
# Set ALB URL
ALB_URL="http://konecta-ass1-dev-alb-602225348.us-east-1.elb.amazonaws.com"

# 1. Health check
curl -s "$ALB_URL/actuator/health/ping" | python3 -m json.tool

# 2. Login and save token
TOKEN=$(curl -s -X POST "$ALB_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@konecta.com","password":"Admin@123"}' \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['result']['accessToken'])")

echo "Token: $TOKEN"

# 3. Test protected endpoint
curl -s -X GET "$ALB_URL/hr/employees" \
  -H "Authorization: Bearer $TOKEN" \
  | python3 -m json.tool
```

---

## 📝 Format JSON Output

To see pretty JSON output, pipe through `python3 -m json.tool`:

```bash
curl ... | python3 -m json.tool
```

Or use `jq` (if installed):
```bash
curl ... | jq .
```

---

## 🔍 Troubleshooting

### No output?
- Check if ALB URL is correct
- Verify internet connection
- Check AWS service status

### 401 Unauthorized?
- This is normal for protected endpoints
- Login first to get token
- Include token in Authorization header

### 404 Not Found?
- Check endpoint path
- Verify service is running
- Check route configuration

---

## 📞 Your ALB URL

```
http://konecta-ass1-dev-alb-602225348.us-east-1.elb.amazonaws.com
```

---

**Start with:** `./test-api.sh` for the easiest way to see all outputs! 🚀

