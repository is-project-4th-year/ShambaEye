import { NextResponse } from "next/server";
import { firestore } from "../../../../lib/firebase-admin";

export async function PUT(
    request: Request,
    { params }: { params: { uid: string } }
) {
    try {
        const { uid } = params;
        const userData = await request.json();

        // Remove uid from data to avoid updating it
        const { uid: _, ...updateData } = userData;

        await firestore.collection("users").doc(uid).update(updateData);

        return NextResponse.json({ success: true, message: "User updated successfully" });
    } catch (error) {
        console.error("Error updating user:", error);
        return NextResponse.json(
            { error: "Failed to update user" },
            { status: 500 }
        );
    }
}

export async function DELETE(
    request: Request,
    { params }: { params: { uid: string } }
) {
    try {
        const { uid } = params;

        await firestore.collection("users").doc(uid).delete();

        return NextResponse.json({ success: true, message: "User deleted successfully" });
    } catch (error) {
        console.error("Error deleting user:", error);
        return NextResponse.json(
            { error: "Failed to delete user" },
            { status: 500 }
        );
    }
}