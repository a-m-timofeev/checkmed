# API Examples

Примеры использования Drug Interaction Checker API.

## Authentication

### Google Sign-In

**Request:**
```http
POST /api/auth/google HTTP/1.1
Host: your-api.azurewebsites.net
Content-Type: application/json

{
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjU..."
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "John Doe",
    "email": "john@example.com",
    "is_premium": false
  }
}
```

### Refresh Token

**Request:**
```http
POST /api/auth/refresh HTTP/1.1
Host: your-api.azurewebsites.net
Content-Type: application/json

{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## Medications

### Get All Medications

**Request:**
```http
GET /api/medications HTTP/1.1
Host: your-api.azurewebsites.net
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "Warfarin",
    "dose": "5",
    "unit": "mg",
    "frequency": "once_daily",
    "time": "08:00",
    "route": "oral",
    "external_ids": {
      "rxcui": "11289"
    }
  },
  {
    "id": "223e4567-e89b-12d3-a456-426614174001",
    "name": "Aspirin",
    "dose": "100",
    "unit": "mg",
    "frequency": "once_daily",
    "route": "oral",
    "external_ids": {
      "rxcui": "1191"
    }
  }
]
```

### Add Medication

**Request:**
```http
POST /api/medications HTTP/1.1
Host: your-api.azurewebsites.net
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "name": "Amiodarone",
  "dose": "200",
  "unit": "mg",
  "frequency": "once_daily",
  "route": "oral"
}
```

**Response:**
```json
{
  "id": "323e4567-e89b-12d3-a456-426614174002",
  "name": "Amiodarone",
  "dose": "200",
  "unit": "mg",
  "frequency": "once_daily",
  "route": "oral",
  "external_ids": null
}
```

### Delete Medication

**Request:**
```http
DELETE /api/medications/323e4567-e89b-12d3-a456-426614174002 HTTP/1.1
Host: your-api.azurewebsites.net
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```http
HTTP/1.1 204 No Content
```

## Check Interactions

### Create Check

**Request:**
```http
POST /api/check HTTP/1.1
Host: your-api.azurewebsites.net
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "medications": [
    {
      "name": "Warfarin",
      "dose": "5",
      "unit": "mg",
      "frequency": "once_daily",
      "route": "oral"
    },
    {
      "name": "Amiodarone",
      "dose": "200",
      "unit": "mg",
      "frequency": "once_daily",
      "route": "oral"
    }
  ],
  "context": {
    "age": 65,
    "weight_kg": 80,
    "pregnancy": "no",
    "allergies": ["penicillin"]
  },
  "options": {
    "detailed_report": true,
    "include_sources": true
  }
}
```

**Response:**
```json
{
  "job_id": "423e4567-e89b-12d3-a456-426614174003",
  "status": "queued",
  "message": "Check job created. Please poll /api/check/results/{job_id} for results."
}
```

### Get Check Result (Polling)

**Request (processing):**
```http
GET /api/check/results/423e4567-e89b-12d3-a456-426614174003 HTTP/1.1
Host: your-api.azurewebsites.net
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response (still processing):**
```json
{
  "job_id": "423e4567-e89b-12d3-a456-426614174003",
  "status": "processing",
  "message": "Check is still processing. Please try again in a few moments."
}
```

**Response (completed):**
```json
{
  "job_id": "423e4567-e89b-12d3-a456-426614174003",
  "status": "completed",
  "summary": "Найдено 1 опасное взаимодействие между Warfarin и Amiodarone. Рекомендуется немедленно связаться с врачом.",
  "categories": {
    "danger": [
      {
        "meds": ["Warfarin", "Amiodarone"],
        "category": "danger",
        "short_summary": "Amiodarone значительно усиливает антикоагулянтный эффект Warfarin, увеличивая риск кровотечений.",
        "mechanism": "Amiodarone ингибирует CYP2C9 и CYP3A4, замедляя метаболизм Warfarin. Это приводит к повышению концентрации Warfarin в крови.",
        "symptoms_to_monitor": [
          "Необычное кровотечение или синяки",
          "Кровь в моче или стуле",
          "Продолжительное кровотечение из десен",
          "Головокружение",
          "Слабость"
        ],
        "evidence": [
          {
            "source": "rxnorm",
            "id": "warfarin_amiodarone_interaction",
            "quote": "Amiodarone increases anticoagulant effect of warfarin by affecting hepatic enzyme CYP2C9/10 metabolism."
          }
        ],
        "suggested_action": "НЕМЕДЛЕННО свяжитесь с врачом. Потребуется коррекция дозы Warfarin и контроль INR.",
        "confidence": 0.95
      }
    ],
    "caution": [],
    "recommendation": []
  },
  "confidence_score": 0.95,
  "sources": [
    {
      "type": "rxnorm",
      "url": "https://rxnav.nlm.nih.gov/REST/interaction"
    },
    {
      "type": "openai",
      "url": "https://api.openai.com/v1/chat/completions"
    }
  ]
}
```

### Get Check History

**Request:**
```http
GET /api/check/history?page=1&pageSize=10 HTTP/1.1
Host: your-api.azurewebsites.net
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
[
  {
    "job_id": "423e4567-e89b-12d3-a456-426614174003",
    "status": "completed",
    "summary": "Найдено 1 опасное взаимодействие...",
    "categories": { "danger": [...], "caution": [], "recommendation": [] },
    "confidence_score": 0.95
  },
  {
    "job_id": "523e4567-e89b-12d3-a456-426614174004",
    "status": "completed",
    "summary": "Взаимодействий не обнаружено",
    "categories": { "danger": [], "caution": [], "recommendation": [...] },
    "confidence_score": 0.88
  }
]
```

## Error Responses

### 400 Bad Request
```json
{
  "error": "Invalid request format"
}
```

### 401 Unauthorized
```json
{
  "error": "Invalid or expired token"
}
```

### 429 Too Many Requests
```json
{
  "error": "Rate limit exceeded. Please upgrade to premium or try again later."
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error"
}
```

## Rate Limiting

Headers в ответе:
```http
X-RateLimit-Limit: 5
X-RateLimit-Remaining: 3
X-RateLimit-Reset: 1640995200
```

**Free users:** 5 проверок в день
**Premium users:** 100 проверок в день

## Postman Collection

Загрузите Postman collection: [drug-interaction-api.postman_collection.json](./drug-interaction-api.postman_collection.json)

## cURL Examples

### Authentication
```bash
curl -X POST https://your-api.azurewebsites.net/api/auth/google \
  -H "Content-Type: application/json" \
  -d '{"id_token": "YOUR_GOOGLE_ID_TOKEN"}'
```

### Create Check
```bash
curl -X POST https://your-api.azurewebsites.net/api/check \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "medications": [
      {"name": "Warfarin", "dose": "5", "unit": "mg"},
      {"name": "Amiodarone", "dose": "200", "unit": "mg"}
    ]
  }'
```

### Get Result
```bash
curl -X GET https://your-api.azurewebsites.net/api/check/results/JOB_ID \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```