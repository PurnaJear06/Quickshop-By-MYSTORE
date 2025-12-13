// Test script to add sample data to Firestore
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, addDoc, Timestamp } from 'firebase/firestore';

const firebaseConfig = {
    apiKey: "AIzaSyADovI9usNr9bMvDfVFZy3C0DpxjnicvFw",
    authDomain: "quickshop-f8450.firebaseapp.com",
    projectId: "quickshop-f8450",
    storageBucket: "quickshop-f8450.firebasestorage.app",
    messagingSenderId: "799899725143",
    appId: "1:799899725143:web:a827887d58c9a432eee212"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function addTestData() {
    try {
        // Add test orders
        const order1 = await addDoc(collection(db, 'orders'), {
            orderNumber: 'ORD-001',
            customerName: 'John Doe',
            grandTotal: 1250,
            orderStatus: 'pending',
            userId: 'test-user-1',
            orderedAt: Timestamp.now(),
            items: [
                { name: 'Product 1', quantity: 2, price: 500 },
                { name: 'Product 2', quantity: 1, price: 250 }
            ]
        });
        console.log('✅ Order 1 added:', order1.id);

        const order2 = await addDoc(collection(db, 'orders'), {
            orderNumber: 'ORD-002',
            customerName: 'Jane Smith',
            grandTotal: 850,
            orderStatus: 'confirmed',
            userId: 'test-user-2',
            orderedAt: Timestamp.now(),
            items: [
                { name: 'Product 3', quantity: 1, price: 850 }
            ]
        });
        console.log('✅ Order 2 added:', order2.id);

        const order3 = await addDoc(collection(db, 'orders'), {
            orderNumber: 'ORD-003',
            customerName: 'Bob Johnson',
            grandTotal: 2100,
            orderStatus: 'delivered',
            userId: 'test-user-3',
            orderedAt: Timestamp.now(),
            items: [
                { name: 'Product 4', quantity: 3, price: 700 }
            ]
        });
        console.log('✅ Order 3 added:', order3.id);

        // Add test products
        const product1 = await addDoc(collection(db, 'products'), {
            name: 'Fresh Apples',
            price: 150,
            category: 'Fruits',
            description: 'Fresh red apples',
            isAvailable: true,
            isFeatured: true,
            stock: 100,
            imageUrls: []
        });
        console.log('✅ Product 1 added:', product1.id);

        const product2 = await addDoc(collection(db, 'products'), {
            name: 'Organic Milk',
            price: 60,
            category: 'Dairy',
            description: 'Fresh organic milk',
            isAvailable: true,
            isFeatured: false,
            stock: 50,
            imageUrls: []
        });
        console.log('✅ Product 2 added:', product2.id);

        console.log('\n🎉 Test data added successfully!');
        console.log('📊 Total Orders: 3');
        console.log('📦 Total Products: 2');
        console.log('💰 Total Revenue: ₹4200');

    } catch (error) {
        console.error('❌ Error adding test data:', error);
    }
}

addTestData();
