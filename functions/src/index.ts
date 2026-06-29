import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { Timestamp, FieldValue } from "firebase-admin/firestore"; // Dòng quan trọng nhất để fix lỗi
import * as nodemailer from "nodemailer"; // 1. Import thư viện

if (!admin.apps.length) {
    admin.initializeApp();
}
const db = admin.firestore();

// 2. Định nghĩa transporter ở đây (thay email và mật khẩu của bạn vào)
const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: "khnam2003@gmail.com", // Điền Gmail của bạn
        pass: "wxvh uykv yayv ctxb", // Điền MẬT KHẨU ỨNG DỤNG (Không phải mật khẩu đăng nhập Gmail)
    },
});

// --- 2. Hàm requestOtp đã sửa lỗi ---
export const requestOtp = functions.https.onCall(async (request) => {
    const email = request.data.email;

    if (!email) {
        throw new functions.https.HttpsError("invalid-argument", "Vui lòng cung cấp email.");
    }

    // 1. CHỐT CHẶN: Kiểm tra email đã tồn tại trong Firebase Auth chưa
    try {
        await admin.auth().getUserByEmail(email);
        // Nếu dòng trên chạy thành công, nghĩa là email đã có tài khoản
        throw new functions.https.HttpsError("already-exists", "Email này đã được đăng ký!");
    } catch (error: any) {
        // Nếu lỗi là 'auth/user-not-found' thì email hợp lệ -> Tiếp tục
        if (error.code !== 'auth/user-not-found') {
            throw error;
        }
    }

    // 2. TẠO OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = Timestamp.fromDate(new Date(Date.now() + 180 * 1000));

    try {
        // 3. LƯU FIRESTORE
        await db.collection("otp_codes").doc(email).set({
            otp: otp,
            expiresAt: expiresAt,
            createdAt: FieldValue.serverTimestamp(),
        });

        // 4. GỬI MAIL
        const mailOptions = {
            from: 'Organic Sleep <email.cua.ban@gmail.com>',
            to: email,
            subject: "Mã xác nhận Đăng ký tài khoản",
            html: `
                <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px;">
                    <h2>Chào mừng bạn đến với Organic Sleep!</h2>
                    <p>Mã xác nhận (OTP) của bạn là:</p>
                    <h1 style="color: #4CAF50; letter-spacing: 5px;">${otp}</h1>
                    <p><i>Mã này sẽ hết hạn trong vòng 3 phút. Vui lòng không chia sẻ mã này cho ai.</i></p>
                </div>
            `
        };

        await transporter.sendMail(mailOptions);

        return { success: true, message: "Đã gửi mã OTP thành công tới email." };

    } catch (error) {
        console.error("Lỗi hệ thống:", error);
        throw new functions.https.HttpsError("internal", "Không thể gửi mã OTP lúc này.");
    }
});

// --- API 2: XÁC THỰC MÃ OTP ---
export const verifyOtp = functions.https.onCall(async (request) => {
    const { email, otp } = request.data;

    const docRef = db.collection("otp_codes").doc(email);
    const doc = await docRef.get();

    if (!doc.exists) {
        throw new functions.https.HttpsError("not-found", "Mã không tồn tại hoặc đã bị xóa.");
    }

    // Lấy dữ liệu (sử dụng toán tử ! để khẳng định data tồn tại vì đã check doc.exists)
    const data = doc.data()!;

    // 1. Kiểm tra mã OTP
    if (data.otp !== otp) {
        throw new functions.https.HttpsError("unauthenticated", "Mã OTP không đúng.");
    }

    // 2. Kiểm tra thời gian hết hạn
    // Chuyển Timestamp của Firestore về miliseconds để so sánh với Date.now()
    const expiresAt = data.expiresAt.toMillis();
    const now = Date.now();

    if (now > expiresAt) {
        // Nếu quá hạn, xóa mã đi và báo lỗi
        await docRef.delete();
        throw new functions.https.HttpsError("deadline-exceeded", "Mã OTP đã hết hạn.");
    }

    // 3. Nếu mọi thứ OK, thực hiện xóa mã và trả về kết quả
    await docRef.delete();
    return { success: true, message: "Xác thực thành công!" };
});

