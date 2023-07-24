package com.example.otp;

import android.Manifest;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.telephony.SmsManager;
import android.telephony.SmsMessage;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.util.Random;

public class MainActivity extends AppCompatActivity {

    private EditText phoneNumberEditText;
    private EditText otpEditText;
    private Button sendButton;
    private Button verifyButton;
    private BroadcastReceiver smsReceiver;
    private static final int SMS_PERMISSION_REQUEST_CODE = 1;
    private static final int SEND_SMS_PERMISSION_REQUEST_CODE = 2;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        phoneNumberEditText = findViewById(R.id.phoneNumberEditText);
        otpEditText = findViewById(R.id.otpEditText);
        sendButton = findViewById(R.id.sendButton);
        verifyButton = findViewById(R.id.verifyButton);

        sendButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String phoneNumber = phoneNumberEditText.getText().toString();
                String otp = generateOTP();
                sendSMS(phoneNumber, otp);
                otpEditText.setText(otp);
            }
        });

        verifyButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String enteredOtp = otpEditText.getText().toString();
                String generatedOtp = otpEditText.getText().toString();

                if (enteredOtp.equals(generatedOtp)) {
                    // OTP verification successful
                    Toast.makeText(MainActivity.this, "OTP verified!", Toast.LENGTH_SHORT).show();
                } else {
                    // OTP verification failed
                    Toast.makeText(MainActivity.this, "Invalid OTP!", Toast.LENGTH_SHORT).show();
                }
            }
        });

        // Request SMS permission if not granted
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.RECEIVE_SMS}, SMS_PERMISSION_REQUEST_CODE);
        } else {
            // Permission already granted, register the SMS receiver
            registerSmsReceiver();
        }

        // Request SEND_SMS permission if not granted
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.SEND_SMS}, SEND_SMS_PERMISSION_REQUEST_CODE);
        }
    }

    private void registerSmsReceiver() {
        smsReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (intent != null && intent.getAction() != null && intent.getAction().equals("android.provider.Telephony.SMS_RECEIVED")) {
                    Bundle extras = intent.getExtras();
                    if (extras != null) {
                        Object[] pdus = (Object[]) extras.get("pdus");
                        if (pdus != null) {
                            for (Object pdu : pdus) {
                                SmsMessage smsMessage = SmsMessage.createFromPdu((byte[]) pdu);
                                String messageBody = smsMessage.getMessageBody();
                                // Extract the OTP from the message body
                                String otp = extractOTP(messageBody);
                                otpEditText.setText(otp);
                            }
                        }
                    }
                }
            }
        };

        // Register the SMS receiver
        IntentFilter intentFilter = new IntentFilter("android.provider.Telephony.SMS_RECEIVED");
        registerReceiver(smsReceiver, intentFilter);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        // Unregister the SMS receiver
        unregisterReceiver(smsReceiver);
    }

    private String generateOTP() {
        // Generate a random 6-digit OTP
        Random random = new Random();
        int otp = random.nextInt(900000) + 100000;

        return String.valueOf(otp);
    }

    private void sendSMS(String phoneNumber, String message) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED) {
            SmsManager smsManager = SmsManager.getDefault();
            smsManager.sendTextMessage(phoneNumber, null, message, null, null);
        } else {
            Toast.makeText(this, "SEND_SMS permission not granted", Toast.LENGTH_SHORT).show();
        }
    }

    private String extractOTP(String messageBody) {
        // Implement your logic to extract the OTP from the message body
        // Here's a simple example assuming the OTP is the first 6 digits in the message
        return messageBody.substring(0, 6);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == SMS_PERMISSION_REQUEST_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted, register the SMS receiver
                registerSmsReceiver();
            } else {
                // Permission denied, show a toast or handle accordingly
                Toast.makeText(this, "SMS permission denied", Toast.LENGTH_SHORT).show();
            }
        } else if (requestCode == SEND_SMS_PERMISSION_REQUEST_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // SEND_SMS permission granted
            } else {
                // SEND_SMS permission denied
                Toast.makeText(this, "SEND_SMS permission denied", Toast.LENGTH_SHORT).show();
            }
        }
    }
}


