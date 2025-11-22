import { NextResponse } from "next/server";
import { firestore, auth } from "../../../lib/firebase-admin";

export async function GET() {
    try {
        const usersSnapshot = await firestore.collection("users").get();
        const users = usersSnapshot.docs.map(doc => ({
            uid: doc.id,
            ...doc.data()
        }));

        return NextResponse.json({ users });
    } catch (err) {
        console.error("Error fetching users:", err);
        return NextResponse.json(
            { error: "Failed to fetch users" },
            { status: 500 }
        );
    }
}

export async function POST(request: Request) {
    try {
        const userData = await request.json();

        // Create user in Firebase Auth
        const userRecord = await auth.createUser({
            email: userData.email,
            password: userData.password || 'tempPassword123', // In real app, generate proper password
            displayName: userData.fullName,
        });

        // Create user document in Firestore
        await firestore.collection("users").doc(userRecord.uid).set({
            fullName: userData.fullName,
            email: userData.email,
            location: userData.location,
            farmSize: userData.farmSize,
            preferredLanguage: userData.preferredLanguage || 'en',
            createdAt: new Date(),
            updatedAt: new Date(),
        });

        return NextResponse.json({
            success: true,
            message: "User created successfully",
            uid: userRecord.uid
        });
    } catch (error) {
        console.error("Error creating user:", error);
        return NextResponse.json(
            { error: "Failed to create user" },
            { status: 500 }
        );
    }
}