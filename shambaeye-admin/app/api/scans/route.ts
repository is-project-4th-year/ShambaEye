import { NextResponse } from 'next/server';
import { firestore } from '../../../lib/firebase-admin';

export async function GET() {
    try {
        const snapshot = await firestore.collection('scans').get();
        const scans = snapshot.docs.map(doc => doc.data());
        return NextResponse.json({ scans });
    } catch (err) {
        return NextResponse.json({ error: (err as Error).message }, { status: 500 });
    }
}
