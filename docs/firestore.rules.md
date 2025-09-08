```
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null &&
                         exists(/databases/$(database)/documents/allowed_users/$(request.auth.token.email));
    }
  }
}
```