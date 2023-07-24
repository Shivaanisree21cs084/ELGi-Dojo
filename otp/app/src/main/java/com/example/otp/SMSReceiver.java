package com.example.otp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.telephony.SmsMessage;

public class SMSReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        Bundle bundle = intent.getExtras();
        if (bundle != null) {
            Object[] pdus = (Object[]) bundle.get("pdus");
            if (pdus != null) {
                for (Object pdu : pdus) {
                    SmsMessage smsMessage = SmsMessage.createFromPdu((byte[]) pdu);
                    String senderPhoneNumber = smsMessage.getDisplayOriginatingAddress();
                    String message = smsMessage.getMessageBody();

                    // Extract the OTP from the message
                    String otp = extractOTP(message);

                    // Send the OTP to the MainActivity
                    sendOTPToMainActivity(context, otp);
                }
            }
        }
    }

    private String extractOTP(String message) {
        // Remove all non-digit characters from the message
        String digitsOnly = message.replaceAll("\\D+", "");

        // Check if the message contains a 6-digit OTP
        if (digitsOnly.length() >= 6) {
            // Extract the first 6 digits as the OTP
            return digitsOnly.substring(0, 6);
        } else {
            // OTP not found or not of expected length
            return "";
        }
    }


    private void sendOTPToMainActivity(Context context, String otp) {
        Intent intent = new Intent("com.example.otp.OTP_RECEIVED");
        intent.putExtra("otp", otp);
        context.sendBroadcast(intent);
    }
}
