import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';
import { getStorage } from 'firebase/storage';

const firebaseConfig = {
    apiKey: "AIzaSyBZuuNg331doeCz_ZNL46v86mXNj_kuIS4",
    authDomain: "quickshop-f8450.firebaseapp.com",
    projectId: "quickshop-f8450",
    storageBucket: "quickshop-f8450.firebasestorage.app",
    messagingSenderId: "799899725143",
    appId: "1:799899725143:web:quickshop-admin"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize services
export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);

export default app;
