# Firebase Firestore Security Rules Setup

## Problem
The app is getting "Missing or insufficient permissions" errors when trying to read/write to Firestore.

## Solution
Update your Firebase Firestore Security Rules to allow authenticated users to access their data.

## Steps to Deploy Rules

### Option 1: Using Firebase Console (Recommended)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **quickshop-f8450**
3. Click on **Firestore Database** in the left sidebar
4. Click on the **Rules** tab
5. Replace the existing rules with the content from `firestore.rules` file
6. Click **Publish**

### Option 2: Using Firebase CLI
```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not already done)
cd "/Users/purnajear/Downloads/Project/OuickShop by Mystore"
firebase init firestore

# Deploy the rules
firebase deploy --only firestore:rules
```

## Current Rules Issue
Your current Firestore rules are likely set to:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false; // Denies everything
    }
  }
}
```

This denies all read/write operations, which is why you're getting permission errors.

## New Rules Summary
The new rules in `firestore.rules` allow:
- ✅ Authenticated users to read/write their own user profile
- ✅ Authenticated users to read any user profile (for app features)
- ✅ Authenticated users to create/read/update their own orders
- ✅ Authenticated users to manage their own cart items
- ✅ Authenticated users to manage their own addresses
- ✅ Authenticated users to read products and categories
- ❌ Direct writes to products/categories (admin only)

## Testing After Deployment
After deploying the rules:
1. Restart your app
2. Try logging in with email
3. Complete profile setup
4. Profile should save successfully
5. You should see your profile page load correctly

## Important Notes
- **Development Mode**: These rules are suitable for development and testing
- **Production**: For production, consider adding more validation rules (e.g., validate field types, required fields)
- **Admin Access**: To add/modify products, you'll need to set up admin authentication separately
- **Test Mode**: Never use "allow read, write: if true" in production as it allows anyone to access your data

## Verification
After deploying, you should see these log messages instead of errors:
- ✅ User document created successfully
- ✅ Profile updated successfully in Firestore
- ✅ User logged in. firstName: [name], isLoggedIn: true

## Next Steps
1. Deploy the rules using one of the methods above
2. Test the app on your device
3. If still having issues, check Firebase Console > Firestore Database > Rules tab to verify the rules are published
